function percent = bottleFillPercent(profile, level)
%BOTTLEFILLPERCENT Integrate cross-sectional areas below a waterline.
% For circular or similarly scaled cross-sections, area scales as width^2.
% A constant-width profile reduces to a height-based estimate.
width = profile.right(:) - profile.left(:) + 1;
area = width.^2;
wetFraction = min(1, max(0, profile.rows(:) + 0.5 - level));
percent = 100 * sum(area .* wetFraction) / sum(area);
end
