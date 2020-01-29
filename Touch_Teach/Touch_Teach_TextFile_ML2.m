%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ___________                  .__     
% \__    ___/___  __ __   ____ |  |__  
%   |    | /  _ \|  |  \_/ ___\|  |  \ 
%   |    |(  <_> )  |  /\  \___|   Y  \
%   |____| \____/|____/  \___  >___|  /
%                            \/     \/ 
% ___________                  .__     
% \__    ___/___ _____    ____ |  |__  
%   |    |_/ __ \\__  \ _/ ___\|  |  \ 
%   |    |\  ___/ / __ \\  \___|   Y  \
%   |____| \___  >____  /\___  >___|  /
%              \/     \/     \/     \/ 
% ___________              __          
% \__    ___/___ ___  ____/  |_        
%   |    |_/ __ \\  \/  /\   __\       
%   |    |\  ___/ >    <  |  |         

%   |____| \___  >__/\_ \ |__|         
%              \/      \/               
% Bonnie Cooper 3/29/2019 bcooper@sunyopt.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Touch_Teach_TextFile_ML2( target_size, target_rgb )
%Saccade_TEXTFILE generate the text file for 'saccade_task' MonkeyLogic tasks
%   Saccade_TextFile takes:
%       1) target eccentricity. int or vec (to generate multiple
%       eccentricities
%       2) target_rgb. any [ m, 3 ] size matrix


%% configuration init
% Load configuration info:
taskname = 'Touch_Teach'; %ML txt file need to have a field that 
%identifies the timing file. That's what i use this for.
expFile = 'C:\MonkeyLogic2\Experiments\popOut_Search\180912_test_popOut_Search_2018_9_11(2).bhv2';
%expFile was last updated 9/12/2018
%expFile is an example configuration file that I use here to get current
%info on the screen size, pixperdeg & etc. It's a good idea to update this
%if there have been any changes to the set up. e.g. distance from subject
%to screen
[~, MLConfigTemplate, ~, ~] = mlread( expFile );
pix_per_degvisang = MLConfigTemplate.PixelsPerDegree( 1 );

%maybe instead of loading an old configuration trial i could instead ask
%for the subjects distance to screen? This could prevent some strange
%monkeylogic issues

%% task specific

task_folder = 'C:\MonkeyLogic2\Experiments\Touch_Teach';
timing_file = 'Touch_Teach';
num_conditions = size( target_rgb, 1 ); 
%total number of lines to be added to text conditions file is same as rows
%in target_rgb ( number of colors )
target_fill = 1; %0/1 == open/filled Crc object
vec_position = {'0.00,0.00'};

bzz_string = 'Snd(sin,0.400,500.000)';

%create a cell array to hold the entries for the text file
Condition_cell_array = cell( ( num_conditions + 1 ), 6 ); %preallocate for cell array
Condition_cell_array( 1,: ) = {'Condition', 'Frequency', 'Block', 'Timing File',...
    'TaskObject#1', 'TaskObject#2'}; %header for the cell array
%populate the cell array with trial values
for k = 1:size( target_rgb, 1 )
    for j = 1 : ( length( vec_position ) )
        crc_string = ['Crc(' num2str( target_size ) ',[' num2str( target_rgb( k,1 ) ) ' ' num2str( target_rgb( k,2 ) ) ' '...
            num2str( target_rgb( k,3 ) ) '],' num2str( target_fill ) ',' vec_position{j} ')'];
        
        Condition_cell_array( ( j + length( vec_position )*( k-1 ) + 1 ),: ) = { (j + length( vec_position )*( k-1 )),...
            1, 1, timing_file, crc_string, bzz_string };
    end
end


filen = TaskFileName( timing_file, task_folder );
fid = fopen(filen,'a+t');
WriteMLTable( fid, Condition_cell_array )
fclose(fid);


end
% target_rgb = [ 1 0 0 ];
