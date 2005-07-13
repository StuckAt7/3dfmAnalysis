function drawlines(hax, x,colrx, stylex, y, colry, styley)
% A utility to draw horizontal or vertical lines from specified points
% usage : drawlines(gca, x,colrx, stylex, y, colry, styley)
% x is the vector containing points on X axis from which vertical lines are
% to be drawn
% y is the vector containing points on Y axis from which horizontal lines
% are to be drawn
% style? and colr? can be specified to draw customized lines
% x, y are defaulted to empty. style is defaulted to dash line '-.'
% colrx is defaulted to 'r', colry is defaulted to 'k'
%
% Created 13 July 2005 by   Kalpit V. Desai
if nargin < 7 | isempty(styley)  styley = '-.' end
if nargin < 6 | isempty(colry)  colry = 'k' end
if nargin < 5 | isempty(y)  y = []; end
if nargin < 4 | isempty(stylex)  stylex = '-.' end
if nargin < 3 | isempty(colrx)  colrx = 'r' end

    
axes(hax);
lastxrange = get(hax,'xlim');
lastyrange = get(hax,'ylim');
axis auto;

xrange = get(hax,'xlim');
yrange = get(hax,'ylim');
% first convert the arguments into horizontal matrices
if ((~isempty(x)) & size(x,1) > size(x,2));
    x = x';
end
if ((~isempty(y)) & size(y,1) > size(y,2));
    y = y';
end

if(~isempty(x) & size(x,1) > 1)
    disp('drawlines: Error:: This function accepts only vectors as inputs');
    return;
elseif(~isempty(y) & size(y,1) > 1)
    disp('drawlines: Error:: This function accepts only vectors as inputs');
    return;
end

if(~isempty(x))
    line(repmat(x,2,1), rempat(yrange',1,size(x,2),'LineStyle',stylex, 'Color', colrx);
end
if(~isempty(y))
    line(repmat(y,2,1), rempat(yrange',1,size(y,2),'LineStyle',styley, 'Color', colry);
end
%Now set the viewpoint back to where it was
set(hax, 'Xlim',lastxrange);
set(hax, 'Ylim',lastyrange);
