%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  _   _                _                        
% | \ | |              | |                       
% |  \| | _____   _____| |                       
% | . ` |/ _ \ \ / / _ \ |                       
% | |\  | (_) \ V /  __/ |                       
% \_| \_/\___/ \_/ \___|_|                       
%                                                
%                                                
%            _   _____                     _     
%           | | /  ___|                   | |    
%   ___ __ _| |_\ `--.  ___  __ _ _ __ ___| |__  
%  / __/ _` | __|`--. \/ _ \/ _` | '__/ __| '_ \ 
% | (_| (_| | |_/\__/ /  __/ (_| | | | (__| | | |
%  \___\__,_|\__\____/ \___|\__,_|_|  \___|_| |_|
%                                                
%                                               
%   _____  _               _                     
%  |  __ \| |             (_)                    
%  | |__) | |__  _   _ ___ _  ___                
%  |  ___/| '_ \| | | / __| |/ _ \               
%  | |    | | | | |_| \__ \ | (_) |              
%  |_|____|_| |_|\__, |___/_|\___/             
%                 __/ |                    
%                |___/                 
%   _______        _    __ _ _                 
%  |__   __|      | |  / _(_) |                  
%     | | _____  _| |_| |_ _| | ___              
%     | |/ _ \ \/ / __|  _| | |/ _ \             
%     | |  __/>  <| |_| | | | |  __/             
%     |_|\___/_/\_\\__|_| |_|_|\___|   
%   .m script to generate the fields for a txt conditions file for
%   novel catsearch physiol task using both Teddy bears & Butterflies as targets
%   in a task similar to CatSearch_PHYSIOL, except that the there is a
%   target present in every trial. half (10) of the possible targets are the
%   'learned target set' whereas the other half (10) are novel targets from
%   the target category being used for the task.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function Novel_catSearchPHYSIOL_TextFile_ml2( target_eccentricity, num_conditions, fix_size,...
    TAbutton_size, image_size, num_distract, tasktype, category, selectNovel, RF_anglepos )
%CatSearch_Physiol_TEXTFILE generates the .txt file for a monkey logic task
%that interleaves Exemplar and categorically cued search tasks and is intended for physiological recordings.
%unlike behavioral tasks where the array position varies randomly, the
%Physio version is static with one array location centered on the receptive
%field (RF) center that has been experimentally determined.
%   CatSearch_CombineCat_TextFile takes:
%       1) target eccentricity. int      
%       2) num_conditions --> how many random distractor groupings to
%       arrange for
%       3) fixation size (deg.vis.ang.) size of fixation during the
%       innitial fixation period.
%       4) TAbutton_size (deg.vis.ang.) size of fixation during
%       target/distractor array presentation
%       5) image_size (deg.vis.ang) size of target & distractors
%       6) num_distract vector of possible distractor positions to fill.
%       final array geometry will have num_distract + 1 positions
%       7) tasktype: 'Exemplar' 'Cued' 'Interleaved'
%       8) category 'Bear' of 'BFly'
%       9) RF_anglepos as determined from receptive field mapping.

% Load configuration info:
taskname = 'NOVEL_CatSearchPhysiol_ml2';
condfile = 'C:\MonkeyLogic2\Experiments\Novel_catSearchPHYSIOL\CatSearch_Physiol_2017_10_20(1)_cfg2';
MLC = getMLConfig( condfile );
pix_per_degvisang = MLC.PixelsPerDegree; 
[task_folder, timing_file] = fileparts('C:\MonkeyLogic2\Experiments\Novel_catSearchPHYSIOL\Novel_catSearchPHYSIOL_ml2');
if strcmp(category, 'BFly')
    fix_rgb = [ 0 0 1]; %Blue fixation square.
    target_index_ids = [ 1 2 3 4 5 6 7 8 9 10 ];
    load('novelbfly_similarity.mat') %bearsimilarity matrix ranks the chi^2 distance
    %of various image features between the 500 distractors & each target
    %bfly
    %1st column is the distractor sstring names, second is average distractor
    %distances for all bfly targets, 3:11 are distractor rankings for each
    %bfly
    load( 'novelbfly_similarity_targetID' ) %bfly target for each column of bflysimilarity
    targetsimilarity = novelbfly_similarity;
    targetsimilarity_targetID = novelbfly_similarity_targetID;
    
    for ii = 1:size( targetsimilarity,1 )
        entry = targetsimilarity{ ii,1 };
        new_name = [ 'DBfly_' char(entry) ];
        targetsimilarity{ ii,1 } = new_name;
    end
elseif strcmp(category, 'Bear')
    fix_rgb = [ 1 0 0 ]; %Red fixation square
    target_index_ids = [ 84 36 147 25 40 123 99 102 10 57 ];
    %bear similarity by target
    load('bearsimilarity.mat') %bearsimilarity matrix ranks the chi^2 distance
    %of various image features between the 500 distractors & each target teddy bear
    %1st column is the distractor sstring names, second is average distractor
    %distances for all bear targets, 3:11 are distractor rankings for each bear
    load( 'bearsimilarity_targetID' ) %bear target for each column of bearsimilarity
    targetsimilarity = bearsimilarity;
    targetsimilarity_targetID = bearsimilarity_targetID;
    
    
    for ii = 1:size( targetsimilarity,1 )
        entry = targetsimilarity{ ii,1 };
        entry_split = regexp(entry, '\_', 'split');
        new_name = [ char(entry_split(1)) 'Bear_' char(entry_split(2)) ];
        targetsimilarity{ ii,1 } = new_name;
    end
end

[ ~, I] = sort( cell2mat( targetsimilarity( :,2 ) ) ); %'ascending'
target150SIM = targetsimilarity( I( end-149:end, : ), 1 ); %150 most simlar for each target
target150SIM = reshape( target150SIM, [ 150, 1 ] );
target150DIS = targetsimilarity( I( 1:150, : ), 1 ); %150 least similar for each target
target150DIS = reshape( target150DIS, [ 150, 1 ] );

% for i = 1:10
%     figure; Im = imread(bear50SIM{i,4}); image(Im);
% end
TAB_rgb = [ 1 1 1 ]; %white out for this experiment (no target absent trials)
fix_fill = 1; %0/1 == open/filled Sqr object
TAB_fill = 1;


  
%organize lists of target or distractor images
[ T, D ] = CatSearchListSortImages( task_folder, category );

%make a date unique random sequence stream
stream = RandStream('mt19937ar','seed',sum(100*clock));

%random order index of target 
max_num_distract = max( num_distract );
%for (relatively) even sampling of specified targets targets
idx = repmat(target_index_ids, 1, round(num_conditions/length(target_index_ids)));
idxx = cat(2, idx, target_index_ids(1:(num_conditions - length(idx))));
idxNOVEL = repmat(selectNovel, 1, round(num_conditions/length(selectNovel)));
idxxNOVEL = cat(2, idxNOVEL, selectNovel(1:(num_conditions - length(idxNOVEL))));
%random order index of interleaved targets from target_index_ids
interleaved_target_index = randperm( stream, num_conditions); 
pospos = 1:4; 
blockpos = repmat( pospos', [ 1 num_conditions ] ); %a matrix with pospos' x num_conditions collumns. sum( blockpos,2 ) = 1*n, 2*n, 3*n, 4*n
blockpos = cell2mat( arrayfun( @( k ) circshift( blockpos( :,k ),k ),1:size( blockpos,2 ),'uni',0 ) ); %circshift each column by 1 sum( blockpos,2 ) = 2.5*n; 2.5*n; 2.5*n; 2.5*n
blockpos = blockpos( :,randperm( size( blockpos,2 ) ) ); %randomly permutate the order of the columns, but still sum( blockpos,2 ) = 2.5*n; 2.5*n; 2.5*n; 2.5*n


size_pixels = ceil(image_size * pix_per_degvisang);


%INDEXES TO SET UP Target/NOTarget
percent_NOVELtarget = 50;
num_NOVELtarget = floor(num_conditions*percent_NOVELtarget/100);
NOVELtarget_index = randperm( stream, num_conditions,  num_NOVELtarget );
MOSTtarget_index = randperm( stream, num_conditions,  num_NOVELtarget );


% strings for return to fixation cue and reward sounds (buzz).
fixation = [ 'Sqr(' num2str( fix_size ) ',[' num2str( fix_rgb( 1 ) ) ' ' num2str( fix_rgb( 2 ) ) ' '...
    num2str( fix_rgb( 3 ) ) '],' num2str( fix_fill ) ',0,0)' ] ; 
% ex: Sqr(0.5,[1 0 0],1,0,0) 
correct_sound_string = 'Snd(sin,0.400,500.000)';
wrong_sound_string = 'Snd(sin,0.400,400.000)';


len_distract = length(num_distract); %one block for each target array configuration

if strcmp( tasktype, 'Exemplar' )
    num_blocks = 1;
    taskfixtype = 1;
elseif strcmp( tasktype, 'Cued' )
    num_blocks = 1;
    taskfixtype = 3;
elseif strcmp( tasktype, 'Interleaved' )
    num_blocks = 2;
    taskfixtype = [ 1 2 ];
else
    disp( 'tasktype error: options are Exemplar, Cued, or Interleaved.' )
end




%create a cell array to hold the entries for the text file
num_task_objects = 5 + max_num_distract; %2*fixations + 1target + num_distract + 2xbuzz
Condition_cell_array = cell( ( num_blocks*length(num_distract)*num_conditions + 1 ), 5 + num_task_objects ); % 
Condition_cell_array( 1,1:5 ) = {'Condition', 'Info', 'Frequency', 'Block', 'Timing File'}; 
for k = 1:num_task_objects
    add_task_object = ['TaskObject#' num2str(k)];
    Condition_cell_array( 1, ( 5 + k ) ) = { add_task_object };
end


%populate the cell array with trial values
for jjj = 1:num_blocks
    
    for jj = 1:len_distract
        
        num_positions = num_distract(jj) + 1;
        TAbutton_random_array_pos = randi( stream, [1,num_positions], [ num_conditions, 1]);
        distractor_index = randi( stream,  size(D,2), [ num_conditions, (num_distract(jj) + 1) ] );
        
        for j = 1:num_conditions
            % target name is random interleaved from idxx
            ang_position = (0 : ( 2*pi/num_positions ) : 2*pi) + deg2rad( RF_anglepos );  %radial position of  objects
            %make a target position sting array. get appended to end of TaskObject#
            TAbutton_eccentricity = 15;
            TAbutton_ang_position = ang_position + pi/num_positions;
            target_pos_str = TargetPositionString( num_positions, target_eccentricity, ang_position( 1 ), ang_position( end ) );
            TAbutton_pos_str = TargetPositionString( num_positions, TAbutton_eccentricity, TAbutton_ang_position( 1 ), TAbutton_ang_position( end ) );
            TA_button = [ 'Sqr(' num2str( TAbutton_size ) ',[' num2str( TAB_rgb( 1 ) ) ' ' num2str( TAB_rgb( 2 ) ) ' '...
                num2str( TAB_rgb( 3 ) ) '],' num2str( TAB_fill ) ',' char( TAbutton_pos_str( TAbutton_random_array_pos(j) ) ) ')' ];
            %placement = randperm( num_distract(jj) + 1 );
            placement = blockpos( :, j );
            if ~ismember( j, NOVELtarget_index )
                target_name = char( T( idxx(interleaved_target_index(j)) ) );
                TB_tag = target_name( 1:( length( target_name ) - 4 ) );
                cue_string = [ 'pic(' TB_tag ',0,0,' num2str(size_pixels) ',' num2str(size_pixels) ')'];
                fix_cue = [ cue_string ] ;
                info_string2 = '''ifLearnedTarget'', ''1'',';
                target_string = [ 'pic(' TB_tag ',' char( target_pos_str( placement( 1 ) )) ',' num2str(size_pixels) ',' num2str(size_pixels) ')'];
                %target_pos_str( placement( 1 ) )
            elseif ismember( j, NOVELtarget_index )
                info_string2 = '''ifLearnedTarget'', ''0'',';
                target_name = char( T( idxxNOVEL(interleaved_target_index(j)) ) );
                TB_tag = target_name( 1:( length( target_name ) - 4 ) );
                cue_string = [ 'pic(' TB_tag ',0,0,' num2str(size_pixels) ',' num2str(size_pixels) ')'];
                fix_cue = [ cue_string ] ;
                target_string = [ 'pic(' TB_tag ',' char( target_pos_str( placement( 1 ) )) ',' num2str(size_pixels) ',' num2str(size_pixels) ')'];
%                 target_name = char( D( distractor_index( j,1 ) ) );
%                 target_tag = target_name( 1:( length( target_name ) - 4 ) );
%                 target_string = [ 'pic(' target_tag ',' char( target_pos_str( placement( 1 ) ) )  ',' num2str(size_pixels) ',' num2str(size_pixels) ')'];
                %target_pos_str( placement( 1 ) )
            end
            
            array_cellarray = {};
            current_trial_distractorSTR = cell( 1, num_distract(jj) );
            distractor_order = randperm(num_distract(jj));
            d_num = 1;
            if ismember( j, MOSTtarget_index )
                info_string2 = [ info_string2 '''MOSTTarget'', ''1'',' '''ArOr'',''' num2str( RF_anglepos ) '''' ];
                TB_tag_split = regexp(TB_tag, '\_', 'split');
                %using average similarity not target specific
                %similarity_column = strmatch( validatestring( [ 'B_' char(TB_tag_split(2))], targetsimilarity_targetID ), targetsimilarity_targetID );
                d_name = char( target150SIM( randi( 50 ), 1 ) );
                dtag_split = regexp(d_name, '\_', 'split');
                d_name_split = regexp(d_name, '\.', 'split');
                distractor_string = [ 'pic(' d_name_split{1} ',' char( target_pos_str( placement( 2 ) ) )  ',' num2str(size_pixels) ',' num2str(size_pixels) ')'  ];
                %target_pos_str( placement( 2 ) )
                current_trial_distractorST{ 1 } = distractor_string;
                distractor_infostr = regexprep([ dtag_split{2} '_' char(target_pos_str( placement( 2 ) ) )],'[,%!]','_'); 
                array_entry = [ ',' '''TA' num2str( 1 + d_num) ''',' '''' distractor_infostr ] ;
                if ~strcmp(d_name, target_name) || ~ismember( array_entry, array_cellarray )
                    array_cellarray{d_num} = array_entry;
                    current_trial_distractorSTR{ 1 } = distractor_string;
                    %d_num = d_num + 1;
                end
            elseif ~ismember( j, MOSTtarget_index )
                info_string2 = [ info_string2 '''MOSTTarget'', ''0'',' '''ArOr'',''' num2str( RF_anglepos ) '''' ];
                TB_tag_split = regexp(TB_tag, '\_', 'split');
                %using average similarity not target specific
                %similarity_column = strmatch( validatestring( [ 'B_' char(TB_tag_split(2))], targetsimilarity_targetID ), targetsimilarity_targetID );
                d_name = char( target150DIS( randi( 50 ), 1 ) );
                dtag_split = regexp(d_name, '\_', 'split');
                d_name_split = regexp(d_name, '\.', 'split');
                distractor_string = [ 'pic(' d_name_split{1} ',' char( target_pos_str( placement( 2 ) ) )  ',' num2str(size_pixels) ',' num2str(size_pixels) ')'  ];
                %target_pos_str( placement( 2 ) )
                current_trial_distractorST{ 1 } = distractor_string;
                distractor_infostr = regexprep([ dtag_split{2} '_' char( target_pos_str( placement( 2 ) ) )],'[,%!]','_');
                array_entry = [ ',' '''TA' num2str( 1 + d_num) ''',' '''' distractor_infostr ];
                if ~strcmp(d_name, target_name) || ~ismember( array_entry, array_cellarray )
                    array_cellarray{d_num} = array_entry;
                    current_trial_distractorSTR{ 1 } = distractor_string;
                    %d_num = d_num + 1;
                end
            end
            
            %num_distract(jj)
            for md = 3:num_distract(jj) + 1
                %md
                d_name = char( D( distractor_index( j,(d_num+1) ) ) );
                dname_split = regexp(d_name, '\.', 'split');
                d_tag = dname_split{1};
                dtag_split = regexp(d_tag, '\_', 'split');
                distractor_string = [ 'pic(' d_tag ',' char( target_pos_str( placement( md ) ) )  ',' num2str(size_pixels) ',' num2str(size_pixels) ')'  ];
                distractor_infostr = regexprep([ dtag_split{2} '_' char( target_pos_str( placement( md) ) )],'[,%!]','_');
                %target_pos_str( placement( md ) )
                array_entry = [ ',' '''TA' num2str( 1 + d_num) ''',' '''' distractor_infostr ];
                if ~strcmp(d_name, target_name) || ~ismember( array_entry, array_cellarray )
                    array_cellarray{d_num} = array_entry;
                    current_trial_distractorSTR{ md -1 } = distractor_string;
                    d_num = d_num + 1;
                end
            end
            
            %current_trial_distractorSTR
            for distractor_entry = 1:num_distract(jj)
%                 distractor_entry
%                 distractor_order
%                 current_trial_distractorSTR
                Condition_cell_array( ( j + 1 + (jj-1)*num_conditions + (jjj-1)*num_conditions*len_distract), (10 + distractor_entry) ) = { current_trial_distractorSTR{distractor_order( distractor_entry )} };
            end
            
            %make the full row of Condition_cell_array to represent a condition in
            %the MonkeyLogic Condition text file.
            usefix = taskfixtype( jjj );
            if usefix == 1
                Condition_cell_array( ( j + 1 + (jj-1)*num_conditions), 1:10 ) = { (j+ (jj-1)*num_conditions), ...
                    info_string2 ,1, 1, timing_file, correct_sound_string, wrong_sound_string, fix_cue, TA_button, target_string };
            elseif usefix == 2
                Condition_cell_array( ( j + 1 + (jj-1)*num_conditions) + num_conditions*len_distract, 1:10 ) = { (j+ (jj-1)*num_conditions+ (jjj-1)*num_conditions*len_distract), ...
                    info_string2 ,1, 1, timing_file, correct_sound_string, wrong_sound_string, fixation, TA_button, target_string };
            elseif usefix == 3
                Condition_cell_array( ( j + 1 + (jj-1)*num_conditions), 1:10 ) = { (j+ (jj-1)*num_conditions), ...
                    info_string2 ,1, 1, timing_file, correct_sound_string, wrong_sound_string, fixation, TA_button, target_string };
            end
            
        end
        
    end
    
end

%filen = 'C:\monkeylogic\Experiments\categorical_search\Search_Exp1_im\test.txt'
filen = TaskFileName( taskname, task_folder );
fid = fopen(filen,'a+t');
WriteMLTable( fid, Condition_cell_array )
fclose(fid);

end

