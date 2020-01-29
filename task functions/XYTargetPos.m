function [ XYpos ] = XYTargetPos( target_angles, eccentricity )
%XYTargetPos takes in the target_angles (1xNUM1) & the target
%eccentricity (1xNUM2) and returns XYpos (NUM1xNUM2,4 )
%to be used for repositioning taskObjects in MonkeyLogic tasks.
%where Col1 = Xpos, Col2 = Ypos, Col3 = Angle(deg), & Col4 = Eccentricity
%
%FOR EXAMPLE:
% 
% XY = XYTargetPos( [ 0 90 180 270 ], [5 10 12] )
% 
% XY =
% 
%      5     0     0     5
%      0     5    90     5
%     -5     0   180     5
%      0    -5   270     5
%     10     0     0    10
%      0    10    90    10
%    -10     0   180    10
%      0   -10   270    10
%     12     0     0    12
%      0    12    90    12
%    -12     0   180    12
%      0   -12   270    12



target_angles_rad = target_angles * ( 2*pi )/360;%convert to radians

num_decimal = 2;%decimal precision
num_target_angles = length( target_angles );
num_eccentricity = length( eccentricity );

XYpos = zeros( num_target_angles*num_eccentricity, 2 );

for m = 1:num_eccentricity
    for n = 1:num_target_angles
        pos_x = eccentricity( m ) * cos( target_angles_rad( n ) );
        pos_x = round(pos_x * 10^num_decimal) / 10^num_decimal;
        pos_y = eccentricity( m ) * sin( target_angles_rad( n ) );
        pos_y = round(pos_y * 10^num_decimal) / 10^num_decimal;
        XYpos( n+num_target_angles*(m-1), 1) = pos_x;
        XYpos( n+num_target_angles*(m-1), 2) = pos_y;
        XYpos( n+num_target_angles*(m-1), 3) = target_angles( n );
        XYpos( n+num_target_angles*(m-1), 4) = eccentricity( m );
    end
end



end
