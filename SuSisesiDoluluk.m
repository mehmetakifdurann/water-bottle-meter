function window = SuSisesiDoluluk(initialPhoto)
%SUSISESIDOLULUK Open the Turkish bottle fill estimator.
arguments
    initialPhoto (1,1) string = ""
end
root = fileparts(mfilename('fullpath'));
examplePhoto = fullfile(root, 'ornekler', 'sise_75.png');
blue = [0.04 0.37 0.53];
ink = [0.09 0.16 0.22];
muted = [0.30 0.38 0.44];

window = uifigure(Name='Su Şişesi Doluluk Ölçer', Position=[100 100 920 620], ...
    Theme='light', Color=[0.95 0.97 0.98], Visible='off');
ui = uigridlayout(window, [3 2], RowHeight={42, '1x', 28}, ...
    ColumnWidth={'1x', 282}, Padding=[18 14 18 12], ColumnSpacing=15, ...
    BackgroundColor=[0.95 0.97 0.98]);
titleLabel = uilabel(ui, Text='Su Şişesi Doluluk Ölçer', FontSize=24, ...
    FontWeight='bold', FontColor=ink);
titleLabel.Layout.Column = [1 2];

ax = uiaxes(ui, Color=[0.89 0.93 0.95]);
ax.Layout.Row = 2;
ax.Layout.Column = 1;
ax.Toolbar.Visible = 'off';
disableDefaultInteractivity(ax);
axis(ax, 'off');

panel = uipanel(ui, BorderType='none', BackgroundColor=[1 1 1]);
panel.Layout.Row = 2;
panel.Layout.Column = 2;
controls = uigridlayout(panel, [9 1], ...
    RowHeight={37, 34, 53, 36, 35, 35, 35, 94, '1x'}, ...
    Padding=[14 13 14 10], RowSpacing=6, BackgroundColor=[1 1 1]);

uibutton(controls, Text='Fotoğraf Aç', BackgroundColor=blue, FontColor=[1 1 1], ...
    FontWeight='bold', ButtonPushedFcn=@pickPhoto);
uibutton(controls, Text='Örneği Aç', ButtonPushedFcn=@(~,~) loadPhoto(examplePhoto));
percentLabel = uilabel(controls, Text='—', FontSize=40, FontWeight='bold', FontColor=blue);
resultLabel = uilabel(controls, Text='Ölçüm bekleniyor', FontWeight='bold', ...
    FontColor=ink, WordWrap='on');
autoButton = uibutton(controls, Text='Otomatik Ölç', Enable='off', ...
    ButtonPushedFcn=@runAutomatic);
lineButton = uibutton(controls, Text='Su Çizgisini İşaretle', Enable='off', ...
    ButtonPushedFcn=@startLine);
frameButton = uibutton(controls, Text='Şişeyi Elle Çerçevele', Enable='off', ...
    ButtonPushedFcn=@startFrame);
status = uilabel(controls, Text=['Fotoğraf açın veya örneği deneyin. ', ...
    'Şişenin tamamı kadrajda, dik ve su çizgisi görünür olmalı.'], ...
    WordWrap='on', VerticalAlignment='top', FontColor=muted);
filenameLabel = uilabel(ui, Text='JPG, PNG, TIFF veya HEIC', FontColor=muted);
filenameLabel.Layout.Row = 3;
filenameLabel.Layout.Column = [1 2];

rgb = [];
profile = [];
level = NaN;
mode = "idle";
firstCorner = [];
isHandFramed = false;
hold(ax, 'on');
text(ax, 0.5, 0.5, 'Bir şişe fotoğrafı açın', ...
    HorizontalAlignment='center', FontSize=15, Color=muted);

if initialPhoto ~= ""
    loadPhoto(initialPhoto);
end
window.Visible = 'on';

    function pickPhoto(~, ~)
        [name, folder] = uigetfile({ ...
            '*.jpg;*.jpeg;*.png;*.tif;*.tiff;*.heic;*.heif;*.bmp', 'Fotoğraflar'; ...
            '*.*', 'Tüm dosyalar'}, 'Şişe fotoğrafı seç');
        if ~isequal(name, 0)
            loadPhoto(fullfile(folder, name));
        end
    end

    function loadPhoto(path)
        try
            selected = readBottlePhoto(path);
        catch problem
            uialert(window, problem.message, 'Fotoğraf açılamadı');
            return
        end
        rgb = selected;
        [~, name, extension] = fileparts(path);
        filenameLabel.Text = [char(name) char(extension)];
        autoButton.Enable = 'on';
        frameButton.Enable = 'on';
        runAutomatic();
    end

    function runAutomatic(~, ~)
        result = estimateBottleFill(rgb);
        profile = result.profile;
        level = result.level;
        isHandFramed = false;
        mode = "idle";
        firstCorner = [];
        status.Text = result.message;
        showResult("Otomatik hacim tahmini");
        redraw();
    end

    function startLine(~, ~)
        firstCorner = [];
        mode = "line";
        status.Text = "Fotoğraftaki su yüzeyine tıklayın. Alt sınır %0, üst sınır %100.";
        redraw();
    end

    function startFrame(~, ~)
        firstCorner = [];
        mode = "firstCorner";
        status.Text = "Şişenin iç hacmini çevreleyen kutunun sol üst köşesine tıklayın. Kapağı dışarıda bırakın.";
        redraw();
    end

    function clickPhoto(~, event)
        point = event.IntersectionPoint(1:2);
        switch mode
            case "firstCorner"
                firstCorner = point;
                mode = "secondCorner";
                status.Text = "İç tabanı kapsayacak şekilde kutunun sağ alt köşesine tıklayın.";
            case "secondCorner"
                if any(point - firstCorner < 8)
                    status.Text = "İkinci nokta ilk noktanın sağ altında ve yeterince uzakta olmalı.";
                    return
                end
                rows = (ceil(firstCorner(2)):floor(point(2)))';
                profile = struct('rows', rows, 'left', repmat(firstCorner(1), size(rows)), ...
                    'right', repmat(point(1), size(rows)));
                firstCorner = [];
                isHandFramed = true;
                level = NaN;
                showResult("");
                startLine();
                return
            case "line"
                if point(1) < min(profile.left) || point(1) > max(profile.right)
                    status.Text = "Su yüzeyini şişenin yan sınırları arasında işaretleyin.";
                    return
                end
                level = min(profile.rows(end)+0.5, max(profile.rows(1)-0.5, point(2)));
                mode = "idle";
                if isHandFramed
                    showResult("Elle işaretlendi · yükseklik oranı");
                    status.Text = "Bu oran sabit genişlik varsayar. Daralan ve genişleyen şişelerde hacim oranı farklı olabilir.";
                else
                    showResult("Elle işaretlendi · hacim tahmini");
                    status.Text = "İşaretlediğiniz su çizgisi ve algılanan şişe profili kullanıldı.";
                end
            otherwise
                return
        end
        redraw();
    end

    function showResult(method)
        if isempty(profile)
            lineButton.Enable = 'off';
        else
            lineButton.Enable = 'on';
        end
        percentLabel.Text = '—';
        resultLabel.Text = 'Yüzde hesaplanamadı';
        if isfinite(level)
            percentLabel.Text = sprintf('%%%d dolu', round(bottleFillPercent(profile, level)));
            resultLabel.Text = method;
        end
    end

    function redraw()
        cla(ax);
        image(ax, rgb, ButtonDownFcn=@clickPhoto);
        axis(ax, 'image');
        axis(ax, 'off');
        ax.YDir = 'reverse';
        ax.XLim = [0.5 size(rgb, 2)+0.5];
        ax.YLim = [0.5 size(rgb, 1)+0.5];
        if ~isempty(profile) && mode ~= "firstCorner" && mode ~= "secondCorner"
            for edge = [profile.left profile.right]
                plot(ax, edge, profile.rows, ':', Color=[0.10 0.85 0.83], ...
                    LineWidth=1.4, HitTest='off', PickableParts='none');
            end
            if isfinite(level) && mode ~= "line"
                row = min(numel(profile.rows), max(1, round(level - profile.rows(1)) + 1));
                span = [profile.left(row) profile.right(row)];
                plot(ax, span, [level level], Color=[0.04 0.22 0.25], ...
                    LineWidth=4, HitTest='off', PickableParts='none');
                plot(ax, span, [level level], Color=[0.24 1 0.90], ...
                    LineWidth=2, HitTest='off', PickableParts='none');
            end
        end
        if ~isempty(firstCorner)
            plot(ax, firstCorner(1), firstCorner(2), '+', Color=[0.04 0.37 0.53], ...
                MarkerSize=14, LineWidth=2, HitTest='off', PickableParts='none');
        end
    end
end
