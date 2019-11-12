function rheo_collect(filename, exptime_ms, Nsec)

if nargin < 1 || isempty(filename)
    error('Need filename.');
end

if nargin < 2 || isempty(exptime_ms)
    exptime_ms = 8; % [ms]
end

Name = {'PEG20k'}';
Conc = {0.2}';
ConcUnits = {'mass fraction'}';
NoInt = table(Name, Conc, ConcUnits);
clear Name Conc ConcUnits


%
% 4x, 1x, 1.80 [pixels/um], 0.56 [um/pixel]
% 4x, 1.6x, 2.86 pixels/um, 0.35 [um/pixel]
% 10x, 1x, 2.89 pixels/um, 0.346 [um/pixel]
% 10x, 1.6x, 4.59 pixels/um, 0.218 [um/pixel]
% 40x, 1x, 11.61 pixels/um, 0.086 [um/pixel]
% 40x, 1.6x, 18.41 pixels/um, 0.054 [um/pixel]
% 60x, 1x, 8.8953 pixels/um, 0.1124 [um/pixel]
% 60x, 1.6x, 14.12 pixels/um, 0.0704 [um/pixel]
% 
Maglist = [4 10 40 60]';
Multlist = [1 1.6];
calibumMatrix = [0.56 0.35; 0.346 0.218; 0.086 0.054; 0.1124 0.0704];





abstime{1,1} = [];
framenumber{1,1} = [];
TotalFrames = 0;

Fps = 1 / (exptime_ms/1000);
NFrames = ceil(Fps * Nsec);
% NFrames = 7625;

imaqmex('feature', '-previewFullBitDepth', true);
vid = videoinput('pointgrey', 1,'F7_Raw16_1024x768_Mode2');
vid.ReturnedColorspace = 'grayscale';
triggerconfig(vid, 'manual');
vid.FramesPerTrigger = NFrames;

% Some of the following code auto-generated by matlab acquisition
% More info here: http://www.mathworks.com/help/imaq/basic-image-acquisition-procedure.html
src = getselectedsource(vid); 
src.ExposureMode = 'off'; 
src.FrameRateMode = 'off';
src.ShutterMode = 'manual';
src.Gain = 10;
src.Gamma = 1.15;
src.Brightness = 5.8594;
src.Shutter = exptime_ms;

vidRes = vid.VideoResolution;
imagetype = 'uint16';

imageRes = fliplr(vidRes);

filename = [filename, '_', num2str(vidRes(1)), 'x', ...
                           num2str(vidRes(2)), 'x', ...
                           num2str(NFrames), '_uint16'];

f = figure;%('Visible', 'off');
pImage = imshow(uint16(zeros(imageRes)));

axis image
setappdata(pImage, 'UpdatePreviewWindowFcn', @rheo_preview)
p = preview(vid, pImage);
set(p, 'CDataMapping', 'scaled');


% ----------------
% Controlling the Hardware and running the experiment
%
pause(2);
logentry('Starting video...');
start(vid);
pause(2);

NFramesAvailable = 0;
NFramesTaken = 0;

binfilename = [filename,'.bin'];
if ~isempty(dir(binfilename))
    delete(vid);
    clear vid
    close(f)
      error('That file already exists. Change the filename and try again.');
end
fid = fopen(binfilename, 'w');

logentry('Triggering video collection...');
cnt = 0;
trigger(vid);

% start timer for video timestamps
t1=tic; 
pause(4/Fps);
while(NFramesTaken < NFrames)
    cnt = cnt + 1;
    
    NFramesAvailable(cnt,1) = vid.FramesAvailable;
    NFramesTaken = NFramesTaken + NFramesAvailable(cnt,1);
%     disp(['Num Grabbed Frames: ' num2str(NFramesAvailable(cnt,1)) '/' num2str(NFramesTaken)]);

    [data, ~, meta] = getdata(vid, NFramesAvailable(cnt,1));    
    
    if isempty(data)
        continue;
    end
    
    abstime{cnt,1} = vertcat(meta(:).AbsTime);
    framenumber{cnt,1} = meta(:).FrameNumber;

%     [rows, cols, rgb, frames] = size(data);
% 
%     numdata = double(squeeze(data));
% 
%     squashedstack = reshape(numdata,[],frames);
%     meanval{cnt,1} = transpose(mean(squashedstack));
%     stdval{cnt,1}  = transpose(std(squashedstack));
%     maxval{cnt,1}  = transpose(max(squashedstack));
%     minval{cnt,1}  = transpose(min(squashedstack));
    
    if cnt == 1
        firstframe = data(:,:,1);
    end
        
    fwrite(fid, data, imagetype);

    if ~mod(cnt,5)
        drawnow;
    end

end

lastframe = data(:,:,1,end);

elapsed_time = toc(t1);

logentry('Stopping video collection...');
stop(vid);
pause(1);
    
% Close the video .bin file
fclose(fid);

NFramesCollected = sum(NFramesAvailable);
AbsFrameNumber = cumsum([1 ; NFramesAvailable(:)]);
AbsFrameNumber = AbsFrameNumber(1:end-1);

logentry(['Total Frame count: ' num2str(NFramesCollected)]);
logentry(['Total Elapsed time: ' num2str(elapsed_time)]);

Time = cellfun(@datenum, abstime, 'UniformOutput', false);
Time = vertcat(Time{:});
% Max = vertcat(maxval{:});
% Mean = vertcat(meanval{:});
% StDev = vertcat(stdval{:});
% Min = vertcat(minval{:});

Fid = ba_makeFid;
[~,host] = system('hostname');

[a,b] = regexpi(filename,'(\d*)_Well-(\d*)_Mag-(\d*)x_Mult-(\d*)x_(\d*)x(\d*)x(\d*)_(\w*)', 'match', 'tokens');

b = b{1};
SampleInstance = b{1};
WellNumber = b{2};
Magnification = b{3};
Multiplier = b{4};

m.File.Fid = Fid;
m.File.SampleName = filename;
m.File.SampleInstance = SampleInstance;
m.File.Binfile = binfilename; 
m.File.Binpath = pwd;
m.File.Hostname = strip(host);

m.Scope.Name = 'Olympus IX-71';
m.Scope.CodeName = 'Ixion';
m.Scope.Magnification = b{3};
m.Scope.Multiplier = b{4};

m.Video.ExposureMode = src.ExposureMode; 
m.Video.FrameRateMode = src.FrameRateMode;
m.Video.ShutterMode = src.ShutterMode;
m.Video.Gain = src.Gain;
m.Video.Gamma = src.Gamma;
m.Video.Brightness = src.Brightness;
m.Video.Format = vid.VideoFormat;
m.Video.Height = 768;
m.Video.Width = 1024;
m.Video.Depth = 16;
m.Video.ExposureTime = src.Shutter;

m.Results.ElapsedTime = elapsed_time;
m.Results.TimeHeightVidStatsTable = table([1:length(Time)]',Time);
m.Results.FirstFrame = firstframe;
m.Results.LastFrame = lastframe;

save([filename, '.meta.mat'], '-STRUCT', 'm');

delete(vid);
clear vid

close(f)
logentry('Done!');

return

function rheo_preview(obj,event,hImage)
% This callback function updates the displayed frame and the histogram.

% Copyright 2007-2017 The MathWorks, Inc.
%

    % Display the current image frame.
    set(hImage, 'CData', event.Data);


    % disp('Inside callback.');

    D = double(event.Data(:));
    avgD = round(mean(D));
    stdD = round(std(D));
    maxD = num2str(max(D));
    minD = num2str(min(D));

    avgD = num2str(avgD, '%u');
    stdD = num2str(stdD, '%u');
    maxD = num2str(maxD, '%u');
    minD = num2str(minD, '%u');

    title([avgD, ' \pm ', stdD, ' [', minD ', ', maxD, ']']);

    a = ancestor(hImage, 'axes');

    cmin = min(double(hImage.CData(:)));
    cmax = max(double(hImage.CData(:)));
    set(a, 'CLim', [uint16(cmin) uint16(cmax)]);

return

% function for writing out stderr log messages
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'ba_pulloff: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return