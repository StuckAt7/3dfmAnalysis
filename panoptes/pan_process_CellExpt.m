function dataout = pan_process_CellExpt(filepath, exityn)
% pan_CellProcessingScript
%Wrapper for CellProcessingScript that runs the CellProcessingScript and
%exits for use inside PanopticNerve.

if nargin < 2 || isempty(exityn)
    exityn = 'n';
end


metadata = pan_load_metadata(filepath, '96well');
dataout  = panoptes_report(metadata);


if exityn == 'y'
    exit;
end

return;