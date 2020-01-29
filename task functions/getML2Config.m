function [ MLConfig ] = getML2Config( condfile )
%getMLConfig will load condfile and creat the struct MLConfig 

% Load configuration info:
MLPrefs = getpref('MonkeyLogic2', 'Directories');
path(MLPrefs.Directories.RunTimeDirectory, path); %move run-time directory to head of list

[pname fname] = fileparts(condfile);
cfgfile = [MLPrefs.Directories.ExperimentDirectory fname '.mat'];
localcfgfile = [MLPrefs.Directories.ExperimentDirectory 'LOCAL_cfg.mat'];
if exist(cfgfile, 'file'),
    load(cfgfile);
    if isfield(MLConfig, 'UseLocal') && MLConfig.UseLocal, %#ok<NODEF>
        if exist(localcfgfile, 'file'),
            load([MLPrefs.Directories.ExperimentDirectory 'LOCAL_cfg.mat']);
            MLConfig.StrobeBitEdge      = MLConfigLoc.StrobeBitEdge;
            MLConfig.ScreenX            = MLConfigLoc.ScreenX;
            MLConfig.ScreenY            = MLConfigLoc.ScreenY;
            MLConfig.BufferPages        = MLConfigLoc.BufferPages;
            MLConfig.DiagonalScreenSize = MLConfigLoc.DiagonalScreenSize;
            MLConfig.ViewingDistance    = MLConfigLoc.ViewingDistance;
            MLConfig.VideoDevice        = MLConfigLoc.VideoDevice;
            MLConfig.RefreshRate        = MLConfigLoc.RefreshRate;
            MLConfig.PixelsPerDegree        = MLConfigLoc.PixelsPerDegree;
        else
            error('ML:NoLocalCFG','No local configuration file found.');
        end
    end
   
    fprintf('<<< MonkeyLogic >>> Using configuration file: %s\n', cfgfile);
    xs = MLConfig.ScreenX;
    ys = MLConfig.ScreenY;
else
    error('ML:NoCFG','Unable to find configuration file %s', cfgfile);
end


end

