function ba_livehist(obj,event,hImage)
% This callback function updates the displayed frame and the histogram.

% Copyright 2007-2017 The MathWorks, Inc.
%

% Display the current image frame.
set(hImage, 'CData', event.Data);

% Select the second subplot on the figure for the histogram.
subplot(2,1,2);

D = double(event.Data(:));
avgD = round(mean(D));
stdD = round(std(D));
maxD = num2str(max(D));
minD = num2str(min(D));


avgD = num2str(avgD, '%u');
stdD = num2str(stdD, '%u');
maxD = num2str(maxD, '%u');
minD = num2str(minD, '%u');

% Plot the histogram. Choose 128 bins for faster update of the display.
imhist(event.Data, 32768);
set(gca,'YScale','log')
title([avgD, ' \pm ', stdD, ' [', minD ', ', maxD, ']']);


% Modify the following numbers to reflect the actual limits of the data returned by the camera.

% For example the limit a 16-bit camera would be [0 65535].

a = ancestor(hImage, 'axes');

cmin = min(double(hImage.CData(:)));
cmax = max(double(hImage.CData(:)));
set(a, 'CLim', [uint16(cmin) uint16(cmax)]);
% set(a, 'CLim', [0 65535]);

% Refresh the display.
drawnow

return