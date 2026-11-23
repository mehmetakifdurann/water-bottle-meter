function result = estimateBottleFill(photo)
%ESTIMATEBOTTLEFILL Estimate the volume fraction of one upright bottle.
% Input is an image path, normalized RGB, or a uint8/uint16 RGB array.
% An unmeasurable result has NaN percent. A valid contour can still be
% returned when the waterline is ambiguous.
if isstring(photo) || ischar(photo)
    photo = readBottlePhoto(photo);
end
if isa(photo, 'uint8') || isa(photo, 'uint16')
    photo = single(photo) / single(intmax(class(photo)));
end
validateattributes(photo, {'numeric'}, {'real', 'finite', 'nonempty', '>=', 0, '<=', 1});
if ndims(photo) ~= 3 || size(photo, 3) ~= 3
    error('Bottle:InvalidImage', 'Üç renk kanallı bir RGB görüntüsü gerekli.');
end

result = struct('percent', NaN, 'level', NaN, 'profile', [], ...
    'message', "Şişenin sınırları seçilemedi. Şişeyi elle çerçeveleyin.");
[h, w, ~] = size(photo);
if min(h, w) < 50
    result.message = "Fotoğraf küçük. Şişenin tamamını daha yakından çekin veya elle işaretleyin.";
    return
end

profile = findProfile(single(photo));
if isempty(profile)
    return
end
result.profile = profile;
result.message = "Su çizgisi ayırt edilemedi. Görünüyorsa çizgiyi elle işaretleyin.";
level = findWaterline(single(photo), profile);
if ~isnan(level)
    result.level = level;
    result.percent = bottleFillPercent(profile, level);
    result.message = "Otomatik hacim tahmini. Turkuaz çizginin su yüzeyiyle örtüştüğünü kontrol edin.";
end
end

function profile = findProfile(rgb)
% Estimate a smooth background using the unobstructed photo margins.
[h, w, ~] = size(rgb);
margin = max(3, round(0.08 * w));
leftBackground = movmedian(median(rgb(:, 1:margin, :), 2), 9, 1);
rightBackground = movmedian(median(rgb(:, end-margin+1:end, :), 2), 9, 1);
weight = reshape(single(linspace(0, 1, w)), 1, []);
background = leftBackground .* (1 - weight) + rightBackground .* weight;

residual = max(abs(rgb - background), [], 3);
sideResidual = [residual(:, 1:margin), residual(:, end-margin+1:end)];
noise = median(sideResidual(:));
threshold = max(0.035, noise + 6 * median(abs(sideResidual(:) - noise)));
profile = [];
if threshold > 0.14
    return
end

% The outermost vertically consistent pixels can enclose a clear interior.
foreground = movsum(residual > threshold, 7, 1) >= 4;
foreground(:, [1:margin, end-margin+1:end]) = false;
left = NaN(h, 1);
right = left;
for row = 1:h
    edges = find(foreground(row, :));
    if numel(edges) >= 4 && edges(end) - edges(1) >= 0.045 * w
        left(row) = edges(1);
        right(row) = edges(end);
    end
end

hasEdges = isfinite(left);
bridged = movmax(hasEdges, [0 4]) & movmax(hasEdges, [4 0]);
transitions = diff([false; bridged; false]);
starts = find(transitions == 1);
ends = find(transitions == -1) - 1;
[height, index] = max(ends - starts + 1);
if isempty(height) || height < 0.32 * h
    return
end
if sum(ends - starts + 1 > 0.65 * height) > 1
    return
end

rows = (starts(index):ends(index))';
if rows(1) <= 3 || rows(end) >= h - 3 || mean(hasEdges(rows)) < 0.86
    return
end
left = movmedian(fillmissing(left(rows), 'linear'), 9);
right = movmedian(fillmissing(right(rows), 'linear'), 9);
width = right - left + 1;
middle = round(0.23 * height):round(0.86 * height);
bodyWidth = median(width(middle));
center = (left + right) / 2;
if bodyWidth < 20 || height / bodyWidth < 1.25 || bodyWidth > 0.76 * w || ...
        any(left <= margin+2 | right >= w-margin-1) || ...
        max(abs(center - median(center(middle)))) > 0.22 * bodyWidth
    return
end

% Remove a small cap and base allowance before integrating cross-sections.
usable = (1 + round(0.045 * height)):(height - round(0.012 * height));
profile = struct('rows', rows(usable), 'left', left(usable), 'right', right(usable));
end

function level = findWaterline(rgb, profile)
% Compare bands just above and below each row at fixed horizontal positions.
% A water surface must produce a persistent horizontal change across the body.
rows = profile.rows;
n = numel(rows);
gap = max(2, round(n * 0.008));
band = max(3, round(n * 0.025));
width = profile.right - profile.left;
score = zeros(n, 1);
for k = (band + gap + 1):(n - band - gap)
    cols = round(profile.left(k) + width(k) * linspace(0.16, 0.84, 31));
    above = k-gap-band+1:k-gap;
    below = k+gap:k+gap+band-1;
    if min(width([above, below])) < 0.62 * median(width) || ...
            max(width([above, below])) - min(width([above, below])) > 0.19 * width(k)
        continue
    end
    upper = squeeze(mean(rgb(rows(above), cols, :), 1));
    lower = squeeze(mean(rgb(rows(below), cols, :), 1));
    change = lower - upper;
    direction = median(change, 1);
    magnitude = norm(direction) / sqrt(3);
    agreement = mean(change * direction' > 0.30 * dot(direction, direction));

    % Saturated label transitions and narrow glare usually violate these checks.
    saturation = @(samples) median(max(samples, [], 2) - min(samples, [], 2));
    if agreement >= 0.70 && max(saturation(upper), saturation(lower)) < 0.28
        % Compare away from the candidate too, to reject a thin isolated ridge.
        farAbove = k-2*band-gap+1:k-band-gap;
        farBelow = k+gap+band:k+gap+2*band-1;
        if farAbove(1) < 1 || farBelow(end) > n
            continue
        end
        farChange = squeeze(mean(rgb(rows(farBelow), cols, :), 1) - ...
            mean(rgb(rows(farAbove), cols, :), 1));
        farDirection = median(farChange, 1);
        persistence = dot(farDirection, direction) / max(eps, dot(direction, direction));
        if persistence > 0.4
            score(k) = magnitude * agreement;
        end
    end
end

level = NaN;
[peak, k] = max(score);
if peak < max(0.024, 4 * median(score))
    return
end
other = abs((1:n)' - k) > max(2 * band, round(n * 0.065));
if any(score(other) >= 0.72 * peak)
    return
end

% Use the sharpest local transition on the plateau of the band-wise score.
local = find(abs((1:n)' - k) <= gap + band & score >= 0.80 * peak);
edge = zeros(size(local));
for j = 1:numel(local)
    t = local(j);
    cols = round(profile.left(t) + width(t) * linspace(0.20, 0.80, 31));
    delta = squeeze(mean(rgb(rows(t:t+1), cols, :), 1) - ...
        mean(rgb(rows(t-2:t-1), cols, :), 1));
    edge(j) = norm(median(delta, 1));
end
[~, j] = max(edge);
level = rows(local(j)) - 0.5;
end
