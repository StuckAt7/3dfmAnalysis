function [outf] = new_carreau_fit(srate, visc, weights, plot_report, init_values)
%CREATEFIT Create plot of data sets and fits
%   CREATEFIT(srate,visc,WEIGHTS)
%   Creates a plot, similar to the plot in the main Curve Fitting Tool,
%   using the data that you provide as input.  You can
%   use this function with the same data you used with CFTOOL
%   or with different data.  You may want to edit the function to
%   customize the code and this help message.
%
%   Number of data sets:  1
%   Number of fits:  1

% Data from data set "visc vs. srate with weights":
%     X = srate:
%     Y = visc:
%     Weights = weights:

% Auto-generated by MATLAB on 04-Jan-2011 16:32:10

if nargin < 5 || isempty(init_values)
    init_values = [0.001 0.0250 0.25 0.680 0];
end

if nargin < 4 || isempty(plot_report)
    plot_report = 'yes';
end

if nargin < 3 || isempty(weights)
    weights = ones(size(srate));
end

srate = srate(:);
visc = visc(:);
weights = weights(:);

% --- Create fit "fit1"
fo_ = fitoptions( 'method', 'NonlinearLeastSquares', ...
                  'Lower',  [1e-005 0.001  0  0  0], ...
                  'Upper',  [0.01  Inf  Inf  Inf  1]);
              
ok_ = isfinite(srate) & isfinite(visc) & isfinite(weights);

if ~all( ok_ )
    warning( 'GenerateMFile:IgnoringNansAndInfs',...
        'Ignoring NaNs and Infs in data.' );
end

st_ = init_values;
set(fo_,'Startpoint',st_);
set(fo_,'Weight',weights(ok_));
ft_ = fittype('(eta_zero - eta_inf) * ( (1+ (lambda*gamma_dot)^m) ^ ((n-1)/m)) + eta_inf',...
              'dependent',    {'eta_apparent'}, ...
              'independent',  {'gamma_dot'},   ...
              'coefficients', {'eta_inf', 'eta_zero', 'lambda', 'm', 'n'});

% Fit this model using new data
[cf_, gof, fitstruct] = fit(srate(ok_),visc(ok_),ft_,fo_);

coeff_values = coeffvalues(cf_);
conf_int     = confint(cf_);

outf.srate = srate;
outf.visc = visc;
outf.eta_inf = [conf_int(1,1) coeff_values(1) conf_int(2,1)];
outf.eta_zero = [conf_int(1,2) coeff_values(2) conf_int(2,2)];
outf.lambda = [conf_int(1,3) coeff_values(3) conf_int(2,3)];
outf.m = [conf_int(1,4) coeff_values(4) conf_int(2,4)];
outf.n = [conf_int(1,5) coeff_values(5) conf_int(2,5)];


if strfind(plot_report, 'y')
        % Set up figure to receive data sets and fits
        f_ = clf;
        figure(f_);
        set(f_,'Units','Pixels','Position',[551 329 688 485]);
        % Line handles and text for the legend.
        legh_ = [];
        legt_ = {};
        % Limits of the x-axis.
        xlim_ = [Inf -Inf];
        % Axes for the plot.
        ax_ = axes;
        set(ax_,'Units','normalized','OuterPosition',[0 0 1 1]);
        set(ax_,'Box','on');
        set(ax_,'XScale', 'log');
        set(ax_,'YScale', 'log');
        axes(ax_);
        hold on;

        % --- Plot data that was originally in data set "visc vs. srate with weights"
        h_ = line(srate,visc,'Parent',ax_,'Color',[0.333333 0 0.666667],...
            'LineStyle','none', 'LineWidth',1,...
            'Marker','.', 'MarkerSize',12);
        xlim_(1) = min(xlim_(1),min(srate));
        xlim_(2) = max(xlim_(2),max(srate));
        legh_(end+1) = h_;
        legt_{end+1} = 'visc vs. srate with weights';

        % Nudge axis limits beyond data limits
        if all(isfinite(xlim_))
            xlim_ = xlim_ + [-1 1] * 0.01 * diff(xlim_);
            set(ax_,'XLim',xlim_)
        else
            set(ax_, 'XLim',[-0.26633333333333342, 30.299666666666674]);
        end
        
        % Plot this fit
        h_ = plot(cf_,'fit',0.95);
        set(h_(1),'Color',[1 0 0],...
            'LineStyle','-', 'LineWidth',2,...
            'Marker','none', 'MarkerSize',6);
        % Turn off legend created by plot method.
        legend off;
        % Store line handle and fit name for legend.
        legh_(end+1) = h_(1);
        legt_{end+1} = 'fit1';

        % --- Finished fitting and plotting data. Clean up.
        hold off;
        % Display legend
        leginfo_ = {'Orientation', 'vertical', 'Location', 'NorthEast'};
        h_ = legend(ax_,legh_,legt_,leginfo_{:});
        set(h_,'Interpreter','none');
        % Remove labels from x- and y-axes.
        xlabel(ax_,'');
        ylabel(ax_,'');        
end

return;
