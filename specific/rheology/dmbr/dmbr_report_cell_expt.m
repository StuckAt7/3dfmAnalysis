function rheo = dmbr_report_cell_expt(filename, report_params)
%
%
% filename = vfd file from dmbr experiment
%
%
%
%
%
%
%
%

dmbr_constants;                                               


% Three phases: 1) Load the data, 2) Maybe process the data, 3) Report the results


% general
% pathname = pwd;
[pathname, filename_root, ext, versn] = fileparts(filename);
close all;

% load metadata
        %metadatafile = [filename_root, '.vfd.mat'];
metadatafile = strcat(filename_root,  '.vfd.mat');
m = load(metadatafile);


a        = m.bead_radius;
pulses   = m.pulse_widths;
voltages = m.voltages;
calib_um = m.calibum;

% load tracking data
%trackingfile = [filename_root, '.raw.vrpn.evt.mat'];
trackingfile = [filename_root, '.vrpn.evt.mat'];

try 
    d = load(trackingfile);
catch
    trackingfile = [filename_root, '.raw.vrpn.mat'];
    try
        d = load(trackingfile);
    catch
        warning('Tracking file not found');
        beadmax = NaN;
    end
end

d = load_video_tracking(trackingfile, [], 'pixels', calib_um, 'absolute', 'yes', 'table');
beadmax = get_beadmax(d);

% load calibration 
filelist = dir('*.vfc.mat');
calibfile = filelist.name;
c = load(calibfile);

% load poleloc file
filelist2 = dir('poleloc.txt');
polelocfile = filelist2.name;

try
    p = load(polelocfile);
catch
    warning ('Poleloc file not found');
end

% obtain input parameters
input_params.metafile = metadatafile;
input_params.trackfile = trackingfile;
input_params.calibfile = calibfile;
input_params.poleloc = p;
input_params.force_type = 'disp';
input_params.tau = 6.25;
input_params.fit_type = 'Jeffrey';
input_params.scale = 0.5;

rheo = dmbr_run(input_params);

rheo_table = rheo.raw.rheo_table;

beads  = unique(rheo_table(:,ID))';
seqs   = unique(rheo_table(:,SEQ))';

for b = 1 : length(beads)    
    for s = 1 : length(seqs)
        clear filtx_on;
        
        ftable = dmbr_filter_table(rheo_table, beads(b), seqs(s), []);
        
        if size(ftable,1) <= 0
            break;
        end
        
        t = ftable(:,TIME);
        t = t - t(1);
        
        x = ftable(:,X);
        x = x - x(1);
        
        y = ftable(:, Y);
        y = y - y(1);
        
        radial = magnitude(x, y);
        
        Jx = ftable(:,J);

        
        idx = find(ftable(:,VOLTS) > 0);
        t_on = ftable(idx,TIME);
        x_on = ftable(idx,X);
        Jx_on = ftable(idx,J);   

        

        if ~exist('txFig');    txFig   = figure; end
        if ~exist('txFig2');   txFig2  = figure; end
        if ~exist('tJxFig');   tJxFig  = figure; end
        if ~exist('tJxFig2');  tJxFig2 = figure; end
%         if ~exist('xetaFig');  xetaFig = figure; end
%         if ~exist('xetaFig2'); xetaFig2 = figure; end



        % displacement vs. time plot
        figure(txFig);
        hold on;
        plot(t,radial*1e6, 'Color', [0 s/(length(seqs)+1) 0]);
        title(['bead displacement vs. time, bead ' num2str(beads(b))]);
        xlabel('time [s]');
        ylabel('displacement [\mum]');
        pretty_plot;
        hold off;
        drawnow;
        
        figure(txFig2); 
        hold on;
        plot(t,radial*1e6, 'Color', [0 s/(length(seqs)+1) 0]);
        title(['bead displacement vs. time, bead ' num2str(beads(b))]);
        xlabel('time [s]');
        ylabel('displacement [\mum]');
        pretty_plot;
        hold off;
        drawnow;
        
        % compliance vs. time plot
        figure(tJxFig); 
        hold on;
        plot(t,Jx, 'Color', [s/(length(seqs)+1) 0 0]);
        title(['Compliance vs. time, bead ' num2str(beads(b))]);
        xlabel('time [s]');
        ylabel('compliance [Pa^{-1}]');
        pretty_plot;
        hold off;
        drawnow;

        figure(tJxFig2); 
        hold on;
        plot(t,Jx, 'Color', [s/(length(seqs)+1) 0 0]);
        title(['Compliance vs. time, bead ' num2str(beads(b))]);
        xlabel('time [s]');
        ylabel('compliance [Pa^{-1}]');
        pretty_plot;
        hold off;
        drawnow;

    end
  
        txFigfilename   = [filename_root '.txFig.bead'  num2str(beads(b)) '.png'];
        txFigfilename2  = [filename_root '.txFig.bead'  num2str(beads(b)) '.fig'];
        tJxFigfilename  = [filename_root '.tJxFig.bead' num2str(beads(b)) '.png'];
        tJxFigfilename2  = [filename_root '.tJxFig.bead' num2str(beads(b)) '.fig'];
        xetaFigfilename = [filename_root '.xetaFig.bead'  num2str(beads(b)) '.png'];
        xetaFigfilename2 = [filename_root '.xetaFig.bead'  num2str(beads(b)) '.fig'];

        saveas(  txFig,  txFigfilename, 'png');
        saveas( tJxFig, tJxFigfilename, 'png');
%         saveas(xetaFig,xetaFigfilename, 'png');
        
        saveas(  txFig2,  txFigfilename2, 'fig');
        saveas( tJxFig2, tJxFigfilename2, 'fig');
%         saveas(xetaFig2, xetaFigfilename2, 'fig');
                
        close(txFig);
        close(tJxFig);
%         close(xetaFig);

        close(txFig2);
        close(tJxFig2);
%         close(xetaFig2);
end


% report
outfile = [filename_root '.html'];

fid = fopen(outfile, 'w');

% html code

nametag = 'REPLACE WITH INPUT';
fprintf(fid, '<html>\n');
fprintf(fid, ' <p><b>Sample Name:</b>  %s <br/>\n', nametag);
fprintf(fid, ' <b>Path:</b>  %s </p>\n', pathname);

fprintf(fid, '<br/>');

% Table 1: Identifying information
fprintf(fid, '<b>General Parameters</b><br/>\n');
fprintf(fid, '<table border="2" cellpadding="6"> \n');
fprintf(fid, '<tr> \n');
fprintf(fid, ' <td align="left"><b>File:</b>	%s </td> \n', filename_root);
fprintf(fid, ' <td align="left"><b>Pulse Voltages (V):</b>	[%s] </td> \n', num2str(voltages));
fprintf(fid, '</tr> \n');
fprintf(fid, '<tr> \n');
fprintf(fid, ' <td align="left" width=250><b>Bead Diameter (um):</b>	%g </td> \n', a*2);
fprintf(fid, ' <td align="left"><b>Pulse Widths (s):</b>	[%s]</td> \n', num2str(pulses));
fprintf(fid, '</tr> \n');
fprintf(fid, '<tr> \n');
fprintf(fid, ' <td align="left"><b>Number of Trackers:</b>	%i </td> \n', beadmax);
fprintf(fid, ' <td></td> \n');
fprintf(fid, '</tr> \n');
fprintf(fid, '</table> \n'); 

fprintf(fid, '<br/>');

% Table 2: Moving average and Window size in frames and seconds
fprintf(fid, '<b>Scale</b><br/>\n');
fprintf(fid, '<table border="2" cellpadding="6"> \n');
fprintf(fid, '<tr> \n');
fprintf(fid, '<td align="center"> %12.2f </td> \n', input_params.scale);
fprintf(fid, '</tr> \n');
fprintf(fid, '</table> \n\n'); 

fprintf(fid, '<br/>');

% Table 3: Shear rates and Weissenburg numbers for each bead/sequence pair
fprintf(fid, '<b>Summary of Results</b><br/>\n');
fprintf(fid, '<table border="2" cellpadding="6"> \n');
fprintf(fid, '<tr> \n');
fprintf(fid, '   <td align="center"><b>Tracker ID</b> </td> \n');
fprintf(fid, '   <td align="center"><b>Sequence #</b> </td> \n');
fprintf(fid, '   <td align="center"><b>G</b> </td> \n');
fprintf(fid, '   <td align="center"><b>Eta1</b> </td> \n');
fprintf(fid, '   <td align="center"><b>Eta2</b> </td> \n');
fprintf(fid, '   <td align="center"><b>R^2</b> </td> \n');
fprintf(fid, '</tr> \n\n');

for b = 1 : length(beads)    
    for s = 1 : length(seqs)
        idx = find(rheo.beadID == beads(b) & rheo.seqID == seqs(s));
        fprintf(fid, '<tr> \n');
        fprintf(fid, '<td align="center"> %i </td> \n', beads(b));  
        fprintf(fid, '<td align="center"> %i </td> \n', seqs(s));          
%        % shear_rate for this bead/sequence
%        fprintf(fid, '<td align="center"> %12.4g </td> \n', rheo.max_shear(idx));
        % G for this bead sequence
        fprintf(fid, '<td align="center"> %12.4g </td> \n', rheo.G(idx));
%        % Weissenberg_number for this bead/sequence
%        fprintf(fid, '<td align="center"> %12.4g </td> \n', rheo.Wi(idx));
        % eta1 for this bead/sequence
        fprintf(fid, '<td align="center"> %12.4g </td> \n', rheo.eta(idx));
%        % steady state viscosity for Jeffey model
%        fprintf(fid, '<td align="center"> %12.4g </td> \n', rheo.eta(idx,end));
        % eta2 for this bead/sequence
        fprintf(fid, '<td align="center"> %12.4g </td> \n', rheo.eta(idx,2));
        % R^2
        fprintf(fid, '<td align="center"> %0.4f </td> \n', rheo.Rsquare(idx));
        fprintf(fid, '</tr> \n');
    end
end
fprintf(fid, '</table> \n\n');
        
fprintf(fid, '<br/> \n\n');



% Plots
for b = 1:length(beads)
    txFigfilename   = [filename_root '.txFig.bead'  num2str(beads(b)) '.png'];
    tJxFigfilename  = [filename_root '.tJxFig.bead' num2str(beads(b)) '.png'];
%    xetaFigfilename = [filename_root '.xetaFig.bead'  num2str(beads(b)) '.png'];

    fprintf(fid, '<img src= %s width=520 height=400 border=2 > \n', txFigfilename);
    fprintf(fid, '<br/> \n');
    fprintf(fid, '<img src= %s width=520 height=400 border=2 > \n', tJxFigfilename);
    fprintf(fid, '<br/> \n');
%    fprintf(fid, '<img src= %s width=520 height=400 border=2 > \n', xetaFigfilename);
%    fprintf(fid, '<br/> \n');
end

fprintf(fid, '<br/> \n\n');

% Image of pole tip
fprintf(fid, ' <p><b>Pole tip image</b><br/>\n');
poleimage = [filename_root, '.MIP.bmp'];
fprintf(fid, '<img src= %s width=520 height=400 border=2> \n', poleimage);


fclose(fid);



% Printing to Excel Spreadsheet%%%%%%%%%%%%%%%%%

xlfilename = 'stithc-test.xlsx';

data = cell(length(beads),4*length(seqs));
videocolumn = cell(length(beads), 1);
beadcolumn = cell(length(beads), 1);
voltagecolumn = cell(length(beads), 1);
%macros = cell(1, 4*length(seqs)+2);
%macros(1, 3) = cellstr('TEST');
for b = 1:length(beads)
    videocolumn(b, 1) = cellstr(filename_root);
    beadcolumn(b, 1) = cellstr(num2str(b));
    voltagecolumn(b, 1) = cellstr(num2str(voltages(1)));
end

for b = 1 : length(beads)
    for s = 1 : length(seqs)
        idx = find(rheo.beadID == beads(b) & rheo.seqID == seqs(s));
        data(b, (4*s-3)) = cellstr(num2str(rheo.G(idx)));
        data(b, (4*s-2)) = cellstr(num2str(rheo.eta(idx, 1)));
        data(b, (4*s-1)) = cellstr(num2str(rheo.eta(idx, 2)));
        data(b, (4*s)) = cellstr(num2str(rheo.Rsquare(idx)));
    end
end

results = [videocolumn, beadcolumn, voltagecolumn, data];
header = cell(2, length(seqs)*4+3);
header(2, 1) = cellstr('video file');
header(2, 2) = cellstr('bead id');
header(2, 3) = cellstr('voltage');
for b = 1:length(seqs)
    header(1, 4*b) = cellstr(['Pull', num2str(b)]);
    header(2, 4*b) = cellstr('G');
    header(2, 4*b+1) = cellstr('eta1');
    header(2, 4*b+2) = cellstr('eta2');
    header(2, 4*b+3) = cellstr('R^2');
end
if ~exist(xlfilename, 'file')
   results = vertcat(header, results);
   xlswrite(xlfilename, results);
else
    xlswrite(xlfilename, header);
    xlsappend(xlfilename, results);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

return;
