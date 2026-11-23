function testBottleFill(writeExamples)
%TESTBOTTLEFILL Exercise the estimator with images of known model volume.
arguments
    writeExamples (1,1) logical = false
end
root = fileparts(mfilename('fullpath'));
work = tempname;
mkdir(work);
cleanup = onCleanup(@() rmdir(work, 's')); %#ok<NASGU>

cases = [
    25  1  0
    50  2  1
    75  3  2
    75  1  1
    40  2  2
    85  3  0
];
for index = 1:size(cases, 1)
    target = cases(index, 1);
    shape = cases(index, 2);
    background = cases(index, 3);
    rgb = renderFixture(target, shape, background);
    filename = fullfile(work, sprintf('test_%d.jpg', index));
    imwrite(rgb, filename, Quality=91);
    result = estimateBottleFill(filename);
    assert(abs(result.percent - target) <= 5, ...
        'Case %d: expected %g%%, got %g%% (%s)', index, target, result.percent, result.message);
    fprintf('Case %d: expected %g%%, estimated %.1f%%\n', index, target, result.percent);
    if writeExamples && index <= 3
        imwrite(rgb, fullfile(root, 'ornekler', sprintf('sise_%d.png', target)));
    end
end

blank = estimateBottleFill(ones(160, 160, 3, 'single'));
assert(isnan(blank.percent) && isempty(blank.profile));
noLine = estimateBottleFill(renderFixture(0, 1, 0));
assert(isnan(noLine.percent) && ~isempty(noLine.profile));
full = estimateBottleFill(renderFixture(100, 1, 0));
assert(isnan(full.percent) && ~isempty(full.profile));
clipped = renderFixture(50, 1, 0);
result = estimateBottleFill(clipped(100:end, :, :));
assert(isnan(result.percent));

% Equal-height regions of different width must not contribute equal volume.
profile = struct('rows', (1:4)', 'left', ones(4, 1), 'right', [5; 5; 10; 10]);
assert(abs(bottleFillPercent(profile, 2.5) - 80) < 1e-10);
assert(bottleFillPercent(profile, 0.5) == 100);
assert(bottleFillPercent(profile, 4.5) == 0);
fprintf('No-line, cropped-photo and volume integration checks passed.\n');
end

function rgb = renderFixture(percent, shape, backdrop)
% Simulate a bottle with known cross-sections, reflections, cap and sensor noise.
h = 560;
w = 432;
top = 56;
bottom = 503;
rows = top:bottom;
t = linspace(0, 1, numel(rows))';
shoulder = min(1, max(0, (t - 0.095) / 0.18));
shoulder = shoulder.^2 .* (3 - 2 * shoulder);
body = 68 * ones(size(t));
switch shape
    case 2
        body = 76 - 22 * exp(-((t - 0.48) / 0.16).^2);
    case 3
        body = 53 + 30 * t;
end
halfWidth = (19 + (body - 19) .* shoulder) .* ...
    (1 - 0.16 * max(0, (t - 0.965) / 0.035).^2);
capacity = (t >= 0.043 & t <= 0.985);
weights = (2 * halfWidth).^2 .* capacity;
fillAtRow = 100 * flipud(cumsum(flipud(weights))) / sum(weights);
[~, levelIdx] = min(abs(fillAtRow - percent));

[x, y] = meshgrid(linspace(-1, 1, w), linspace(-1, 1, h));
bases = [0.92 0.91 0.88; 0.23 0.29 0.32; 0.70 0.78 0.84];
base = reshape(bases(backdrop+1, :), 1, 1, 3);
rgb = base + 0.044 * x - 0.035 * y + 0.014 * x .* y;
center = round(w * (0.49 + 0.045 * (shape - 2)));
offset = (1:w) - center;
for k = 1:numel(rows)
    xNorm = offset / halfWidth(k);
    columns = abs(xNorm) <= 1;
    u = xNorm(columns);
    rim = exp(-((abs(u) - 0.97) / 0.038).^2);
    glass = 0.043 * cos(2.5 * u) - 0.095 * rim + ...
        0.085 * exp(-((u + 0.61) / 0.072).^2);
    ribbing = 0.009 * cos(2 * pi * k / 33) .* abs(u).^2;
    baseRow = rgb(rows(k), columns, :);
    glass = glass + ribbing;
    if backdrop == 1
        glass = glass + 0.26 * rim; % Lit edge on a dark background.
    end
    wet = (percent == 100) || (percent > 0 && k >= levelIdx);
    if wet
        baseRow = baseRow + reshape([-0.088 -0.046 0.018], 1, 1, 3);
        glass = glass + 0.019 * exp(-((u - 0.54) / 0.12).^2);
    end
    if percent > 0 && percent < 100
        glass = glass + 0.042 * exp(-((k - levelIdx) / 1.3)^2);
    end
    if t(k) < 0.045
        capRibs = 0.02 * cos(offset(columns) * pi / 2);
        baseRow = reshape([0.09 0.42 0.53], 1, 1, 3) + capRibs;
        glass = 0.045 * cos(1.5 * u) - 0.03 * rim;
    end
    rgb(rows(k), columns, :) = baseRow + glass;
end
stream = RandStream('mt19937ar', 'Seed', 200 + shape);
rgb = rgb + 0.004 * randn(stream, h, w, 3);
rgb = uint8(round(255 * min(1, max(0, rgb))));
end
