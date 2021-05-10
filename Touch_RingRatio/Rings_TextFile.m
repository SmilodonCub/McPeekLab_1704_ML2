%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% .______       __  .__   __.   _______      _______.
% |   _  \     |  | |  \ |  |  /  _____|    /       |
% |  |_)  |    |  | |   \|  | |  |  __     |   (----`
% |      /     |  | |  . `  | |  | |_ |     \   \    
% |  |\  \----.|  | |  |\   | |  |__| | .----)   |   
% | _| `._____||__| |__| \__|  \______| |_______/    
%                                                            
%   _______        _    __ _ _                 
%  |__   __|      | |  / _(_) |                  
%     | | _____  _| |_| |_ _| | ___              
%     | |/ _ \ \/ / __|  _| | |/ _ \             
%     | |  __/>  <| |_| | | | |  __/             
%     |_|\___/_/\_\\__|_| |_|_|\___|   
%   .m script to generate the fields for a txt conditions file for
%   Physio_Exemplar using both Teddy bears & Butterflies as targets
%   in a task similar to CatSearch_Multiarray_Interleaved, except that the TAbutton os no longer used
%   but the catergorically specific cue is used at fixation..
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function Rings_TextFile( fix_size, im_sizes, LineWidth, centerSize, directory, pix_per_deg )
% Rings_TextFile generates the text file for 'ringTarget_DELAY' MonkeyLogic task
%   Rings_TextFile takes:
%       1) Im_sizes. vec deg.vis.ang.
%       2) LineWidth num
%       4) centerSize num deg.vis.ang
%       5) directory str
%       4) pix_per_deg num
%%

%task specific
task_folder = 'C:\MonkeyLogic2\Experiments\Touch_RingRatio';
timing_file = 'ringTarget_reach';
fix_rgb = [ 1 1 1 ]; %white fixation dot. can change. totally can.
fix_fill = 1; %0/1 == open/filled Sqr object



num_conditions = length( im_sizes ); 
%total number of lines to be added to text conditions file
num_task_objects = 4; % = fix + target image + sound_good + sound_bad


%use 'sqr' object for fixation cross fixation cross
fixation = [ 'Sqr(' num2str( fix_size ) ',[' num2str( fix_rgb( 1 ) ) ' ' num2str( fix_rgb( 2 ) ) ' '...
    num2str( fix_rgb( 3 ) ) '],' num2str( fix_fill ) ',0,0)' ] ;

correct_sound_string = 'Snd(sin,0.400,500.000)';
wrong_sound_string = 'Snd(sin,0.400,400.000)';



%create a cell array to hold the entries for the text file
Condition_cell_array = cell( ( num_conditions + 1 ), 4 + num_task_objects ); % 
Condition_cell_array( 1,1:5 ) = {'Condition', 'Info', 'Frequency', 'Block', 'Timing File'}; % 1st half header for the cell array

%make the second half of header
for k = 1:num_task_objects
    add_task_object = ['TaskObject#' num2str(k)];
    Condition_cell_array( 1, ( 5 + k ) ) = { add_task_object };
end



%draw the stimuli
names = drawManyCircles( im_sizes, LineWidth, centerSize, directory, pix_per_deg );


for r = 1:num_conditions
    circSize = im_sizes( r );
    info_string = [ '''circSize'',''' num2str( circSize ) '''' ];
    Condition_cell_array( ( r+1 ),1:8 ) = { r, info_string, 1, 1, timing_file, correct_sound_string, wrong_sound_string, fixation };
    crc_string = strcat( 'pic(', names( r ), ',0,0)' );
    Condition_cell_array( ( r+1 ),9 ) =  [crc_string];
end


filen = TaskFileName( timing_file, task_folder );
fid = fopen(filen,'a+t');
WriteMLTable( fid, Condition_cell_array )
fclose(fid);



end


