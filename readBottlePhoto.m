function rgb = readBottlePhoto(filename)
%READBOTTLEPHOTO Read and orient a photo, limiting the working resolution.
arguments
    filename (1,1) string
end

[~, ~, extension] = fileparts(filename);
if any(strcmpi(extension, [".jpg", ".jpeg", ".tif", ".tiff", ".heic", ".heif"]))
    [pixels, map, alpha] = imread(filename, AutoOrient=true);
else
    [pixels, map, alpha] = imread(filename);
end
if ~isempty(map)
    pixels = ind2rgb(pixels, map);
end
if isinteger(pixels)
    pixels = single(pixels) / single(intmax(class(pixels)));
else
    pixels = single(pixels);
end
if ismatrix(pixels)
    pixels = repmat(pixels, 1, 1, 3);
end
if size(pixels, 3) ~= 3
    error('Bottle:UnsupportedColor', 'Fotoğrafı RGB olarak kaydedip tekrar açın.');
end

[h, w, ~] = size(pixels);
scale = min(1, 1000 / max(h, w));
rows = round(linspace(1, h, max(1, round(h * scale))));
cols = round(linspace(1, w, max(1, round(w * scale))));
rgb = pixels(rows, cols, :);
if ~isempty(alpha)
    opacity = alpha(rows, cols);
    if isinteger(opacity)
        opacity = single(opacity) / single(intmax(class(opacity)));
    end
    rgb = rgb .* single(opacity) + (1 - single(opacity));
end
end
