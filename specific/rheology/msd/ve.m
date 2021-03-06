function v = ve(d, bead_radius, freq_type, plot_results)
% VE computes the viscoelastic moduli from mean-square displacement data 
%
% 3DFM function
% specific\rheology\msd
% last modified 11/20/08 (krisford)
%  
% ve computes the viscoelastic moduli from mean-square displacement data.
% The output structure of ve contains four members: raw (contains data for 
% each individual tracker/bead), mean (contains means across trackers/beads), and 
% error (contains standard error (stdev/sqrt(Ntrackers) about the mean value, and Ntrackers (the
% number of trackers/beads in the dataset.
%
%  [v] = ve(d, bead_radius, freq_type, plot_results);  
%   
%  where "d" is the output structure of msd.
%        "bead_radius" is in [m].
%        "freq_type" is 'f' for [Hz] or 'w' for [rad/s], default is [Hz]
%        "plot_results" reports with a figure if 'y'. default is 'y'
%  
%  Notes:  
%  - This algorithm came from Mason 2000 Rheol Acta paper.
%  

if (nargin < 3) || isempty(freq_type)
    freq_type = 'f';   
end

if (nargin < 2) || isempty(bead_radius)
    bead_radius = 0.5e-6; 
end

if (nargin < 1) || isempty(d) || isempty(d.tau) || sum(isnan(d.tau(:))) >= length(d.tau(:))-1
    logentry('Error: no input data found.  Exiting now.'); 

    v.f = [];
    v.w = [];
    v.tau = [];
    v.msd = [];
    v.alpha = [];
    v.gamma = [];
    v.gstar = [];
    v.gp = [];
    v.gpp = [];
    v.nstar = [];
    v.np = [];
    v.npp = [];
    
    return;
end

msd = d.msd;
tau = d.tau;
Nestimates = d.Nestimates; % corresponds to the number of estimates for each bead at each tau

if isfield(d, 'Ntrackers')
    Ntrackers = d.Ntrackers; % corresponds to the number of trackers at each tau
else
    Ntrackers = sum( (d.Nestimates > 0), 2);
end


meantau = nanmean(tau,2);
% meanmsd = nanmean(msd,2);

% meantau = trimmean(tau, 15, 2);
% meanmsd = trimmean(msd, 15, 2);

logtau = log10(tau);
logmsd = log10(msd);

numbeads = size(logmsd,2);

% weighted mean for logmsd
weights = Nestimates ./ repmat(nansum(Nestimates,2), 1, size(Nestimates,2));

mean_logtau = nanmean(logtau');
mean_logmsd = nansum(weights .* logmsd, 2);

meanmsd = 10 .^ (mean_logmsd);

% computing error for logmsd
Vishmat = nansum(weights .* (repmat(mean_logmsd, 1, numbeads) - logmsd).^2, 2);
msderr =  sqrt(Vishmat ./ Ntrackers);


errhmsd = 10 .^ (mean_logmsd + msderr);
errlmsd = 10 .^ (mean_logmsd - msderr);


mygser  = gser(meantau, meanmsd, Ntrackers, bead_radius);
maxgser = gser(meantau, errhmsd, Ntrackers, bead_radius);
mingser = gser(meantau, errlmsd, Ntrackers, bead_radius);

v = mygser;

v.error.f = abs(mygser.f - mingser.f);
v.error.w = abs(mygser.w - mingser.f);
v.error.tau = abs(mygser.tau - mingser.tau);
v.error.msd = abs(mygser.msd - mingser.msd);
v.error.alpha = abs(mygser.alpha - mingser.alpha);
v.error.gamma = abs(mygser.gamma - mingser.gamma);
v.error.gstar = abs(mygser.gstar - mingser.gstar);
v.error.gp = abs(mygser.gp - mingser.gp);
v.error.gpp = abs(mygser.gpp - mingser.gpp);
v.error.nstar = abs(mygser.nstar - mingser.nstar);
v.error.np = abs(mygser.np - mingser.np);
v.error.npp = abs(mygser.npp - mingser.npp);

v.raw = d;

v.Ntrackers = Ntrackers;

% plot output
if (nargin < 4) || isempty(plot_results) || strncmp(plot_results,'y',1)  
    fig1 = figure; fig2 = figure;
    plot_ve(v, freq_type, fig1, 'Gg');
    plot_ve(v, freq_type, fig2, 'Nn');
end

return;



function v = gser(tau, msd, Ntrackers, bead_radius)
    k = 1.3806e-23;
    T = 298;

%     A = tau(1:end-1,:);
%     B = tau(2:end,:);
%     C = msd(1:end-1,:);
%     D = msd(2:end,:);

%     alpha = log10(D./C)./log10(B./A);

    
    % trim out NaNs
    mymsd = msd( ~isnan(tau));
    mytau = tau( ~isnan(tau));

    timeblur_decade_fraction = .3;
    [myalpha, tau_evenspace, msd_evenspace] = getMSDSlope(mymsd, mytau, timeblur_decade_fraction);

    alpha = NaN(size(msd));
    alpha(1:length(myalpha)) = myalpha;
    
    MYgamma = gamma(1 + abs(alpha));
    % gamma = 0.457*(1+alpha).^2-1.36*(1+alpha)+1.9;

    % because of the first-difference equation used to compute alpha, we have
    % to delete the last row of f, tau, and msd values computed.
    % msd = msd(1:end-1,:);
    % tau = tau(1:end-1,:);
    % Ntrackers = Ntrackers(1:end-1,:);

    % get frequencies all worked out from timing (tau)
    f = 1 ./ tau;
    w = 2*pi*f;

    % compute shear and viscosity
    gstar = (2/3) * (k*T) ./ (pi * bead_radius .* msd .* MYgamma);
    gp = gstar .* cos(pi/2 .* alpha);
    gpp= gstar .* sin(pi/2 .* alpha);
    nstar = gstar .* tau;
    np = gpp .* tau;
    npp= gp  .* tau;


    %
    % setup very detailed output structure
    %

    v.f = f;
    v.w = w;
    v.tau = tau;
    v.msd = msd;
    v.alpha = alpha;
    v.gamma = MYgamma;
    v.gstar = gstar;
    v.gp = gp;
    v.gpp = gpp;
    v.nstar = nstar;
    v.np = np;
    v.npp = npp;

return;

% function for writing out stderr log messages
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 've: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;    