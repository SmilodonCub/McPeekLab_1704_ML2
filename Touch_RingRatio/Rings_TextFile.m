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

%task specific
task_folder = 'C:\MonkeyLogic2\Experiments\Touch_RingRatio';
timing_file = 'ringTarget_DELAY';
fix_rgb = [ 1 1 1 ]; %white fixation dot. can change. totally can.
fix_fill = 1; %0/1 == open/filled Sqr object


num_conditions = length( im_sizes ); 
%total number of lines to be added to text conditions file


%use 'sqr' object for fixation cross fixation cross
fixation = [ 'Sqr(' num2str( fix_size ) ',[' num2str( fix_rgb( 1 ) ) ' ' num2str( fix_rgb( 2 ) ) ' '...
    num2str( fix_rgb( 3 ) ) '],' num2str( fix_fill ) ',0,0)' ] ;

correct_sound_string = 'Snd(sin,0.400,500.000)';
wrong_sound_string = 'Snd(sin,0.400,400.000)';

%create a cell array to hold the entries for the text file
Condition_cell_array = cell( ( num_conditions + 1 ), 4 + num_task_objects + 1 ); % 
Condition_cell_array( 1,1:4 ) = {'Condition', 'Frequency', 'Block', 'Timing File'}; % 1st half header for the cell array

%make the second half of header
for k = 1:num_task_objects
    add_task_object = ['TaskObject#' num2str(k)];
    Condition_cell_array( 1, ( 4 + k ) ) = { add_task_object };
end

for r = 1:num_conditions
    Condition_cell_array( ( r+1 ),1:7 ) = { r, 1, 1, timing_file, correct_sound_string, wrong_sound_string, fixation };
end

Condition_cell_array_counter = 1;
%block_counter = 1;
for c = 1:length( target_eccentricity )
    
    for a = 1: length( num_positions )
        
        
        %for every target/distractor configuration
        block_counter = 1;
        ang_position = (0 : ( 2*pi/num_positions( a ) ) : 2*pi) + shift_angle ;
        block_rows = num_positions( a ) * size( target_rgb, 1 ); %* length( target_eccentricity ( c ) );
        crc_strings_block = cell( block_rows, num_positions( a ) );
        crc_string = ['crc(' num2str( target_radius ) ',[' ];  %num2str( target_rgb( k,1 ) ) ' ' num2str( target_rgb( k,2 ) ) ' '...
        %num2str( target_rgb( k,3 ) ) '],' num2str( target_fill ) ',' vec_position{j}];
        
        for b = 1:size( target_rgb, 1 )
            %
            %
            %  TAGRET/DISTRACTOR RGB STRINGS
            rgbval_t = target_rgb( b,: );
            crc_str_T = [ crc_string num2str( target_rgb( b,1) ) ' ' ...
                num2str( target_rgb( b,2 ) ) ' ' num2str( target_rgb( b,3 ) ) '],' num2str( target_fill ) ',' ];
            rgbval_d = distractor_rgb( b,: );
            crc_str_D = [ crc_string num2str( distractor_rgb( b,1) ) ' ' ...
                num2str( distractor_rgb( b,2 ) ) ' ' num2str( distractor_rgb( b,3 ) ) '],' num2str( target_fill ) ',' ];
            %
            %
            %           
            
            vec_position = TargetPositionString( num_positions( a ), target_eccentricity( c ), ang_position( 1 ), ang_position( end ) );
            vec_positions = cell( num_positions( a ), num_positions( a ) );
            
            for y = 1:num_positions( a )
                column = circshift( vec_position, y );
                vec_positions( :, y ) = column;
            end
                
            assign_position = cell( num_positions( a ),num_positions( a ) );
            

            bin_assign = zeros( num_positions( a ) );
            bin_assign(:,1) = 1;
            for e = 1:( num_positions( a )^2 )
                %position_string = vec_position{ ( mod( e,num_positions( a )) + 1) };
                if bin_assign(e)
                    position_string = vec_positions{ e };
                    full_crc_str = [crc_str_T position_string ')'];
                    assign_position( e ) = { full_crc_str };
                else
                    position_string = vec_positions{ e };
                    full_crc_str = [crc_str_D position_string ')'];
                    assign_position( e ) = { full_crc_str };
                end
            end
            crc_strings_block( block_counter:( block_counter + num_positions( a ) - 1 ),1:num_positions( a ) ) = ...
                assign_position( 1:num_positions( a ),1:num_positions( a ) );
            block_counter = block_counter + num_positions( a );
            %
            % end
            %
        end
        
        Condition_cell_array( ( Condition_cell_array_counter + 1 ):( Condition_cell_array_counter + block_rows ), 8:( 7 + num_positions( a ) ) ) = ...
            crc_strings_block( 1:block_rows,1:num_positions( a ) );
        Condition_cell_array_counter = Condition_cell_array_counter + block_rows;
        
        %
    end
end



filen = TaskFileName( timing_file, task_folder );
fid = fopen(filen,'a+t');
WriteMLTable( fid, Condition_cell_array )
fclose(fid);



end


