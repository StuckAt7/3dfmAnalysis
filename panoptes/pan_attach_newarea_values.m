function outs = pan_attach_newarea_values(filepath, systemid)

if nargin < 2 || isempty(systemid)
    systemid = 'monoptes';
end

if nargin < 1 || isempty(filepath)
    error('No filepath defined.'); 
end

video_tracking_constants;

% other parameter settings
plate_type = '96well';
freqtype = 'f';
r = 20;


% load the metadata from the appropriate files generated by PanopticNerve
metadata = pan_load_metadata(filepath, systemid, '96well');

filelist = metadata.files.tracking;

if isempty(filelist)
    filelist = dir('*.csv');
end

FLburstfiles = metadata.files.FLburst;

Nfiles = length(filelist);

duration = metadata.instr.seconds;

filetype = 'csv'; % at the time this was written, only csv files contained area and sens values
% areas = []; sens = [];
% count = 1;
for k = 1:Nfiles
    
    % clear out old versions of these variables if they exist
    clear tmparea tmpsens;
    
    switch filetype 
        case 'vrpn'
            myfile = filelist(k).name;
        case 'csv'
            myfile = filelist(k).name;
            myfile = strrep(myfile, 'vrpn.mat', 'vrpn.csv');
        otherwise
            error('Unknown filetype. Use ''vrpn'' or ''csv'' instead.');
    end

    [well, pass] = pan_wellpass(filelist(k).name);
    
    FLburst_dir = [metadata.instr.experiment '_FLburst_pass' num2str(pass) '_well' num2str(well)];
   
    d = load_video_tracking(myfile, ...
                        metadata.instr.fps_imagingmode, ...
                        'pixels', 1, ...
                        'absolute', 'no', 'table');
                    
    tracker_halfsize = 15; % pull this from metadata when tracking cfg is included
    sort_by = 'sens';

    if isempty(d)
        continue;
    else
        
        % extract the first frame from the video data
        idx = ( d(:, FRAME) == 1 );
        frame1 = d(idx,:);

        % generate a list of tracker IDs
        tracker_list = unique(d(:,ID));
        
        FLfile = [FLburst_dir '\frame0001.pgm'];
        im = imread(FLfile);

        mystack = get_tracker_images(frame1, im, tracker_halfsize, 'n');
    
        dout = d;
        for m = 1:length(tracker_list);
            idx = ( d(:,ID) == tracker_list(m) );
            dout(idx,AREA) = mystack.newarea(m);
        end
        
        new_filename = strrep(filelist(k).name, '.csv', '.vrpn.csv');
        save_vrpn_csv_file(new_filename, dout);
                
    end    
    

end
 outs = 0;
return;

function save_vrpn_csv_file(filename, dout)
    video_tracking_constants;
    
    fid = fopen(filename, 'w');
    
    fprintf(fid, 'FrameNumber,Spot ID,X,Y,Z,Radius,Center Intensity,Orientation (if meaningful),Length (if meaningful),Fit Background (for FIONA),Gaussian Summed Value (for FIONA),Mean Background (FIONA),Summed Value (for FIONA),Region Size,Sensitivity\n');
    
    for k = 1:size(dout,1)
        fprintf(fid, '%u, %u, %0.5f, %0.5f, %0.5f, %0.5f, %0.5f, %0.5f, %0.5f, %0.5f, %0.5f, %0.5f, %0.5f, %u, %0.5f\n', ...
              dout(k,FRAME),dout(k,ID),dout(k,X),dout(k,Y),0,0,0,0,0,0,0,0,0, dout(k,AREA), dout(k,SENS) );
    end
    
    logentry(['Saved ' filename]);
    
    fclose(fid);
return;