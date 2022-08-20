function touch(ax)
%TOUCH Prettifies the plot specified via ax
%   Changes style of xlabel, ylabel, title, subtitle and legend
fontname = 'Verdana';
interpreter = 'tex';

if ~isempty(ax.XLabel.String)
    ax.XLabel.FontSize = 18;
    ax.XLabel.Interpreter = interpreter;
    ax.XLabel.FontName = fontname;
end

if ~isempty(ax.YLabel.String)
    ax.YLabel.FontSize = 18;
    ax.YLabel.Interpreter = interpreter;
    ax.YLabel.FontName = fontname;
end

if ~isempty(ax.Legend)
    ax.Legend.FontSize = 18;
    ax.Legend.Box = 'off';
    ax.Legend.Interpreter = interpreter;
    ax.Legend.FontName = fontname;
end

if ~isempty(ax.Title.String)
    ax.Title.FontSize = 24;
    ax.Title.Interpreter = interpreter;
    ax.Title.FontWeight = 'bold';
    ax.Title.FontName = fontname;
end

if ~isempty(ax.Subtitle.String)
    ax.Subtitle.FontSize = 18;
    ax.Subtitle.Interpreter = interpreter;
    ax.Subtitle.FontName = fontname;
end

ax.FontName = fontname;
ax.FontSize = 18;
ax.LineWidth = 2;
% ax.YGrid = 'on';
end

