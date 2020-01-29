%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%            _   _____                     _     _____ ______ ___________  
%           | | /  ___|                   | |   |  __ \| ___ \_   _|  _  \ 
%   ___ __ _| |_\ `--.  ___  __ _ _ __ ___| |__ | |  \/| |_/ / | | | | | | 
%  / __/ _` | __|`--. \/ _ \/ _` | '__/ __| '_ \| | __ |    /  | | | | | | 
% | (_| (_| | |_/\__/ /  __/ (_| | | | (__| | | | |_\ \| |\ \ _| |_| |/ /  
%  \___\__,_|\__\____/ \___|\__,_|_|  \___|_| |_|\____/\_| \_|\___/|___/ 
%
%  _            _  ______ _ _      
% | |          | | |  ___(_) |     
% | |_ _____  _| |_| |_   _| | ___ 
% | __/ _ \ \/ / __|  _| | | |/ _ \
% | ||  __/>  <| |_| |   | | |  __/
%  \__\___/_/\_\\__\_|   |_|_|\___|                                
%
%
% populates the fields for a MonkeyLogic txt condition file for the experiment
% catSearchGRID
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function catSearchGRID_TextFile_ML2( RF_eccentricity, RF_anglepos, num_conditions, fix_size,...
    image_size, tasktype, category )
%catSearchGRID_TextFile_ML2 generates the .txt file for catSearchGRID,a 
%monkey logic task that interleaves Exemplar and categorically cued search 
%tasks and is intended for physiological recordings.
%unlike behavioral tasks where the array position varies randomly, the
%Physio version is static with one array location centered on the receptive
%field (RF) center that has been experimentally determined.
%This GRID version populates the screne with a mosaic of object images
%at varying eccentricities instead of just a 4 member array.
%   catSearchGRID_TextFile_ML2 takes:
%       1) RF_eccentricity. int
%       2) RF_anglepos as determined from receptive field mapping.
%       3) num_conditions --> how many random distractor groupings to
%       arrange for
%       4) fixation size (deg.vis.ang.) size of fixation during the
%       innitial fixation period.
%       5) image_size (deg.vis.ang) size of target & distractors
%       6) tasktype: 'Exemplar' 'Cued' 'Interleaved'
%       7) category 'Bear' of 'BFly'


%% configuration init
% Load configuration info:
taskname = 'catSearchGRID_ML2'; %ML txt file need to have a field that 
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

%% category specific init
[task_folder, timing_file] = fileparts('C:\MonkeyLogic2\Experiments\catSearchPHYSIOL_ML2\CatSearch_Physiol_ML2');
if strcmp(category, 'BFly')
    fix_rgb = [ 0 0 1]; %Blue fixation square.
    target_index_ids = [ 1 2 3 4 5 6 7 8 9 10 ];
    load('bflysimilarity.mat') %bearsimilarity matrix ranks the chi^2 distance
    %of various image features between the 500 distractors & each target
    %bfly
    %1st column is the distractor sstring names, second is average distractor
    %distances for all bfly targets, 3:11 are distractor rankings for each
    %bfly
    load( 'bflysimilarity_targetID' ) %bfly target for each column of bflysimilarity
    targetsimilarity = bflysimilarity;
    targetsimilarity_targetID = bflysimilarity_targetID;
    
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

[ ~, I] = sort( cell2mat( targetsimilarity( :,3:end ) ) ); %'ascending'
target50SIM = targetsimilarity( I( end-49:end, : ), 1 ); %50 most simlar for each target
target50SIM = reshape( target50SIM, [ 50, 10 ] );
target50DIS = targetsimilarity( I( 1:50, : ), 1 ); %50 least similar for each target
target50DIS = reshape( target50DIS, [ 50, 10 ] );


%% stimuli init
  
%organize lists of target or distractor images
[ T, D ] = CatSearchListSortImages( task_folder, category );

%make a date unique random sequence stream
stream = RandStream('mt19937ar','seed',sum(100*clock));

%random order index of target 
num_distract
max_num_distract = max( num_distract );
%for (relatively) even sampling of specified targets
idx = repmat(target_index_ids, 1, round(num_conditions/length(target_index_ids)));
idxx = cat(2, idx, target_index_ids(1:(num_conditions - length(idx))));
%random order index of interleaved targets from target_index_ids
interleaved_target_index = randperm( stream, num_conditions); 
pospos = 1:4; 
blockpos = repmat( pospos', [ 1 num_conditions ] ); %a matrix with pospos' x num_conditions collumns. sum( blockpos,2 ) = 1*n, 2*n, 3*n, 4*n
blockpos = cell2mat( arrayfun( @( k ) circshift( blockpos( :,k ),k ),1:size( blockpos,2 ),'uni',0 ) ); %circshift each column by 1 sum( blockpos,2 ) = 2.5*n; 2.5*n; 2.5*n; 2.5*n
blockpos = blockpos( :,randperm( size( blockpos,2 ) ) ); %randomly permutate the order of the columns, but still sum( blockpos,2 ) = 2.5*n; 2.5*n; 2.5*n; 2.5*n


size_pixels = ceil(image_size * pix_per_degvisang);

%INDEXES TO SET UP Target/NOTarget
percent_NOtarget = 50;
num_notarget = floor(num_conditions*percent_NOtarget/100);
notarget_index = randperm( stream, num_conditions,  num_notarget );
MOSTtarget_index = randperm( stream, num_conditions,  num_notarget );


% strings for return to fixation cue and reward sounds (buzz).
fixation = [ 'Sqr(' num2str( fix_size ) ',[' num2str( fix_rgb( 1 ) ) ' ' num2str( fix_rgb( 2 ) ) ' '...
    num2str( fix_rgb( 3 ) ) '],' num2str( fix_fill ) ',0,0)' ] ; 
% ex: Sqr(0.5,[1 0 0],1,0,0) 
correct_sound_string = 'Snd(sin,0.400,500.000)';
wrong_sound_string = 'Snd(sin,0.400,400.000)';

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

%how many positions are needed to tile the experiment screen?
num_available_array_pos 

num_distract = num_available_array_pos - 1; %+..... find how many array positions are needed to tile the screen

len_distract = length(num_distract); %one block for each target array configuration

end

