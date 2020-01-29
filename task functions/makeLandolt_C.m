function [ Lcrcs ] = makeLandolt_C( pixperdeg, cue_gap, Lcrc_diameter, rgb, varargin)
%SYNTAX:
%        Lcrcs = makeLandolt_Cs(pixperdeg, angle_vec, task file, cue_gap, Lcrc_diameter, [r g b], bgcolor)
%
% IMPORTANT: pixperdeg is calculated in the monkeylogic configuration file that is
% specific for the task & saved in it's experiment folder. the task configuation file 
% must be loaded for this function to work.
% angle_vec gets the angle vector of posible cue locations for landolt C's
% diameter & cue_gap is in degrees of visual angle. 
% bgcolor is background color (optional).
%

%pixperdeg = MLConfig.PixelsPerDegree;
Lcrc_diameter = Lcrc_diameter * pixperdeg;
cue_gap = cue_gap * pixperdeg;

radius = 0.5 * Lcrc_diameter;
r2 = round(1.2 * radius);
i = -r2:1:r2;
[x, y] = meshgrid(i);

Lcrcs = sqrt((x.^2) + (y.^2));

thresh = 0;
Lcrcs = radius - abs((radius - Lcrcs).^2);
Lcrcs = Lcrcs.*(Lcrcs > thresh);

[ h, w ] = size( Lcrcs );
cue_cut = Lcrcs( round( h/2 - cue_gap/2 ) : round( h/2 + cue_gap/2 ), round ( w/2:w ) );
Lcrcs( round( h/2 - cue_gap/2 ) : round( h/2 + cue_gap/2 ), round ( w/2:w ) ) = zeros( size ( cue_cut ) );

Lcrcs = Lcrcs./max(max(Lcrcs));
Lcrcs = repmat(Lcrcs, [1 1 3]);

if isempty(varargin),
    Lcrcs(:, :, 1) = Lcrcs(:, :, 1).*rgb(1);
    Lcrcs(:, :, 2) = Lcrcs(:, :, 2).*rgb(2);
    Lcrcs(:, :, 3) = Lcrcs(:, :, 3).*rgb(3);
else
    bgcolor = varargin{1};
    Lcrcs(:, :, 1) = Lcrcs(:, :, 1).*(rgb(1) - bgcolor(1)) + bgcolor(1);
    Lcrcs(:, :, 2) = Lcrcs(:, :, 2).*(rgb(2) - bgcolor(2)) + bgcolor(2);
    Lcrcs(:, :, 3) = Lcrcs(:, :, 3).*(rgb(3) - bgcolor(3)) + bgcolor(3);
    
end

end