function [ pos_fixations ] = SaccadeDetectML( eyedata )
%SaccadeDetectML uses a simple velocity threshold to detect fixations from
%eyedata and returns the average x/y-pos of each detected fixation.

%1) smooth eye data and calculate eye velocities
%2) find fixations
%3) expand saccade detection area to compensate for smoothing artifact
%4) select fixations with length > minfixtime
%5) Get average fixation positions
%RETURN pos_saccades: average positions of detected fixations

%%
%PARAMETERS:
%configuration file info
file_path = 'C:\monkeylogic\Experiments\saccade_task\';
MLcfg = [ file_path 'delayedSaccadeTask_cfg.mat' ];
load( MLcfg );
frq = 1000;
velthresh = 2;                          %no. of standard deviations of eye velocity below which is considered fixation
sigma = MLConfig.EyeSmoothingSigma;     % sigma for eye velocity smoothing gaussian (milliseconds)
minfixtime = 50;          % the minimum time they eyes must be ~stationary to count as a fixation
%disp(minfixtime)

%%
%smooth eye data and calculate eye velocities
x = eyedata(:, 1);
y = eyedata(:, 2);
numdatapoints = length(x);
halfwin = ceil(3*frq*sigma/1000);
k = -halfwin:halfwin;
smoothkernel = exp(-(k.^2)/(sigma^2));
smoothkernel = smoothkernel/sum(smoothkernel);
x = conv(x, smoothkernel);
y = conv(y, smoothkernel);
x = x(halfwin:numdatapoints-halfwin);
y = y(halfwin:numdatapoints-halfwin);
v = frq*realsqrt((diff(x).^2) + (diff(y).^2));

%find fixations
saccadethreshold = velthresh*std(v);
fixation = v < saccadethreshold;
% disp('fixation')
% size(fixation)
% disp('v')
% size(v)

fixation = cat(1, 0, fixation, 0);
dfix = diff(fixation);
startfix = find(dfix == 1);
endfix = find(dfix == -1);

%%
%expand saccade detection area to compensate for smoothing artifact
if max(startfix) > max(endfix),
    endfix = cat(1, endfix, length(x));
end
if min(endfix) < min(startfix),
    startfix = cat(1, 1, startfix);
end
sacshift = ceil(1.5*sigma);
startfix = startfix + sacshift;
endfix = endfix - sacshift;
indx = (endfix > startfix) & (startfix < length(x)) & (endfix > 1);
startfix = startfix(indx);
endfix = endfix(indx);
if max(startfix) > max(endfix), %need to repeat now that points are shifted
    endfix = cat(1, endfix, length(x));
end
if min(endfix) < min(startfix),
    startfix = cat(1, 1, startfix);
end

%%
%select fixations with length > minfixtime
minfixpoints = minfixtime*frq/1000;
fixtime = endfix - startfix;
longfix = fixtime > minfixpoints;
startfix = startfix(longfix);
endfix = endfix(longfix);
numfix = length(startfix);

%Get average fixation positions
xfix = zeros(numfix, 1);
yfix = zeros(numfix, 1);
for i = 1:numfix,
    xfix(i) = mean(x(startfix(i):endfix(i)));
    yfix(i) = mean(y(startfix(i):endfix(i)));
end
pos_fixations = cat( 2, xfix, yfix );

end

