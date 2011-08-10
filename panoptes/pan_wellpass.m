function [mywell, mypass] = pan_wellpass(filenamein)
% PAN_WELLPASS extracts the well and pass values in the filename for a PanopticNerve run.
%
%
%  [mywell, mypass] = pan_wellpass(filenamein) 
%   
%  where "mywell" is pass value
%        "mypass" is the well value
%        "filenamein" is the input filename
%  

    wchunk  = regexp(filenamein, '_well[0-9]*', 'match');
    mywell = regexp(wchunk, '[0-9]*', 'match');
    mywell = str2double(mywell{:}); 
    
    pchunk = regexp(filenamein, '_pass[0-9]*', 'match');
    mypass = regexp(pchunk, '[0-9]*', 'match');
    mypass = str2double(mypass{:});
       
  return;
  