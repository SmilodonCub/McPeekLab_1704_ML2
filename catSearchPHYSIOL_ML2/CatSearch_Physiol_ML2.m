%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% _________         __                                     .__     
% \_   ___ \_____ _/  |_  ______ ____ _____ _______   ____ |  |__  
% /    \  \/\__  \\   __\/  ___// __ \\__  \\_  __ \_/ ___\|  |  \ 
% \     \____/ __ \|  |  \___ \\  ___/ / __ \|  | \/\  \___|   Y  \
%  \______  (____  /__| /____  >\___  >____  /__|    \___  >___|  /
%         \/     \/          \/     \/     \/            \/     \/ 
% __________.__                 .__       .__                      
% \______   \  |__ ___.__. _____|__| ____ |  |                     
%  |     ___/  |  <   |  |/  ___/  |/  _ \|  |                     
%  |    |   |   Y  \___  |\___ \|  (  <_> )  |__                   
%  |____|   |___|  / ____/____  >__|\____/|____/                   
%                \/\/         \/                              
%                                                       
%                                                                                                                                                
%   .timing script for categorical_search_training, a MonkeyLogic task 
%   1) a category specific fixation point (blue:butterfly red:bear) appears
%   for wait_for_fix msec
%   2) subjects holds fixation for initial_fix msec
%   3) on some trials a target is presented: the target (e.g. TBear) is 
%   presented in an array with a lure from the other category (e.g. BFly) 
%   and a set number of distractors (optional). the subject has 
%   max_reaction_time msec to complete a saccade to the target. 
%   4) the subject then holds fixation on the target for hold_target_time
%   msec to recieve a reward
%   5) on other trials, there is no target present, only the lure & 
%   distractors. in this case, the subject has max_reaction_time to fixate 
%   on the TA_button in the periphery and hold for hold_target_time to 
%   recieve a reward.
%
%
% 
% %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  _   _           _                             _       _    
% | | (_)         (_)                           (_)     | |   
% | |_ _ _ __ ___  _ _ __   __ _   ___  ___ _ __ _ _ __ | |_  
% | __| | '_ ` _ \| | '_ \ / _` | / __|/ __| '__| | '_ \| __| 
% | |_| | | | | | | | | | | (_| | \__ \ (__| |  | | |_) | |_  
%  \__|_|_| |_| |_|_|_| |_|\__, | |___/\___|_|  |_| .__/ \__| 
%                           __/ |                 | |         
%                          |___/                  |_|        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                    
%% editable variable                     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%editables. these can be changed dynamically in ML task menu ( press 'v')
editable('fix_radius');
editable('target_radius');
editable('TAButton_radius');
editable('wait_for_fix');        
editable('initial_fix');
editable('fix_increment') %ms to randomly add in random increasing multiple
editable('min_delay_fix');
editable('max_reaction_time');      
editable('hold_target_time');
editable('hold_TAB_time');
editable('intTint');
editable('reward');
editable('num_reward');
editable('pause_reward');
editable('method__touch_or_eye');

%% unique mark-up
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Send Start Experiment Stobes
trialcodenum = TrialRecord.LastTrialCodes.CodeNumbers; %get the eventmarkers that were sent in the previous trial
formatOut = 31;
DateStr = datestr(now,formatOut);
%disp( DateStr )
bhv_variable('DateStr',DateStr);
DateStrSplit = regexp(DateStr, '[- :]', 'split');
yyyyStrobe = str2double( DateStrSplit{1} );
mmddStrobe = str2double( [ DateStrSplit{2} DateStrSplit{3} ] );
hhmmStrobe = str2double( [ DateStrSplit{4} DateStrSplit{5} ] );
mmssStrobe = str2double( [ DateStrSplit{5} DateStrSplit{6} ] );
if isempty( trialcodenum ); %if there weren't any eventmarkers this must be the 1st trial
    disp( '�`�._.���.-~*����`*�~-.,-,.-~*����`*�~-.���._.���`�._.���.-~*����`*�~-.,-,.-~*����`*�~-.���._.���' )
    disp( 'start experiment' )
    disp( 'CatSearch_Physiol_ML2' )
    eventmarker( 2222 );
    eventmarker( [ yyyyStrobe mmddStrobe hhmmStrobe mmssStrobe ] );
else
    currentTrialNum = TrialRecord.CurrentTrialNumber;
    eventmarker( 2222 );
    eventmarker( hhmmStrobe );
    
end

%% task init
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%check eye signal input
if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end

showcursor(false);  % remove the joystick cursor
%bhv_code(10,'Fix Cue',20,'Sample',30,'Delay',40,'Go',50,'Reward',60,'Feedback');  % behavioral codes


% task variables
% % % give names to the TaskObjects defined in the conditions file:
% the numbers correspond with the TaskObject# in the text files
bzz = 1;
bzz2 = 2;
fixation_point = 3;     %red square target. 
TAbutton = 4;
hold_image = 5;
target = 5; 
distract1 = 6; distract2 = 7; distract3 = 8; distract4 = 9; distract5 = 10; distract6 = 11; distract7 = 12; distract8 = 13; distract9 = 14; distract10 = 15; distract11 = 16; 
targetobject_array = [fixation_point hold_image target TAbutton distract1 distract2 distract3 distract4 distract5...
    distract6 distract7 distract8 distract9 distract10 distract11];

% stimulus_array length is contingent on the how many distractors, so:
num_TaskObjects = length( TrialRecord.CurrentConditionStimulusInfo );
stim_array = targetobject_array( 2:(num_TaskObjects-1)); 
distractor_array = targetobject_array( 5:end );
%trialSpecificTargetObject_array = targetobject_array( 1:(num_TaskObjects-3 ));

%method of behavior reporting
% 'eye' for eye-tracking
% 'touch' for touch screen reaching task
method__touch_or_eye = 'eye';
if strcmp( method__touch_or_eye, 'eye' )
    methodSTR = 'eye_';
elseif strcmp( method__touch_or_eye, 'touch' )
    methodSTR = 'touch_';
else
    error('Invalid method. Please select either "eye" or "touch"')
end
    

% define time intervals (in ms) these are all editable:
wait_for_fix = 1500;         %interval to wait for fixation to start
initial_fix = 700;          %hold fixation on fixation_point
min_delay_fix = 0;            %hold fixation on fixation point while target is toggled on (msec)
fix_increment = 50;       %ms to randomly add in random increasing multiple (up to 4) to min_delay_fix    
max_reaction_time = 2000;    %max time after fixation given to complete a saccade
hold_target_time = 700;     %hold fixation on bear_image to get rewardTAbutton_time = 100;      %if no bear target is present, this is the interval of time the subject must hold fixation for reward
hold_TAB_time = 700;
intTint = 100;               %idle time inbetween conditions, useful to have a pause so that manual reward can be given during training.

% fixation window (in degrees):
fix_radius = 3;
target_radius = 4;
TAButton_radius = 6;

reward = 300;
num_reward = 2;
pause_reward = 75;
hotkey('g', 'goodmonkey(400, ''NumReward'', 2,''PauseTime'', 50);' );


%flag in case the Target Absent Button is the target of a saccade for a
%Target present trial
TAbutton_flag = 0;

%get condition info: does this trial present a target(1) or not(0)?
targetcon= str2double(TrialRecord.CurrentConditionInfo.ifTarget); 


%% task instances: define scenes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%scene 1:fixation
fix = SingleTarget( eval( methodSTR ) );
fix.Target = fixation_point;
fix.Threshold = fix_radius;
wth1 = WaitThenHold( fix );
wth1.WaitTime = wait_for_fix;
initial_fixdur = initial_fix + fix_increment*( unidrnd( 4 )-1 );
wth1.HoldTime = initial_fixdur;
scene1 = create_scene( wth1,fixation_point );

%scene 2:optional delay
if min_delay_fix ~= 0
    delay = WaitThenHold( fix );
    delay.WaitTime = 0;
    delaydur = min_delay_fix + fix_increment*( unidrnd( 4 )-1 );
    delay.HoldTime = delaydur;
    scene2 = create_scene(delay,[ fixation_point, stim_array] );
end

%scene 3:target array & choice
search = SingleTarget( eval( methodSTR ) );
if targetcon 
    hold_time = hold_target_time;
    search.Target = target;
    endGoal = target;
    search.Threshold = target_radius;
else
    hold_time = hold_TAB_time;
    search.Target = TAbutton;
    endGoal = TAbutton;
    search.Threshold = TAButton_radius;
end


freeView = FreeThenHold( search );
freeView.MaxTime = max_reaction_time;
freeView.HoldTime = hold_time;
scene3 = create_scene( freeView,stim_array );

%scene 4A:endscene Correct
fbtc_Correct = TimeCounter( null_ );
fbtc_Correct.Duration = 100;  % duration of the sound, ms
feedbackCorrect = create_scene( fbtc_Correct,bzz );

%scene 4B:endscene Wrong
fbtc_Wrong = TimeCounter( null_ );
fbtc_Wrong.Duration = 500;  % duration of the sound, ms
feedbackWrong = create_scene( fbtc_Wrong,bzz2 );

% scene 5: clear the screen. equivalent to idle(0)
endtrial = TimeCounter(null_);
endtrial.Duration = 0;
endscene = create_scene(endtrial);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%disp('______________________________________________________________________')
%disp('START TRIAL')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%eventmarker 1 == START trial
eventmarker(1);
%% task control

%initial fixation
run_scene( scene1,10 );
if ~wth1.Success;
    run_scene(endscene);
    if wth1.Waiting;
        %eventmarker 5 == Fixation not acquired
        eventmarker(5); 
        trialerror( 4 ); % no fixation
    else
        %eventmarker 7 == Fixation break
        eventmarker(7);
        trialerror( 3 ); % broke fixation
    end
    return
end
%eventmarker 3 == Fixation HELD
eventmarker( 3 )
%disp('fixation held')

%delay period (optional)
if min_delay_fix ~= 0;
    %eventmarker 71	== Delay ON
    eventmarker( 71 ) 
    run_scene( scene2,30 );
    if ~delay.Success;
        run_scene( endscene );
        %eventmarker 73	== Delay NOT acquired
        eventmarker( 73 );
        trialerror( 3 ); % broke fixation
        return
    end
%eventmarker 76	== Delay acquired
eventmarker( 76 );
end

%target fixation
run_scene( scene3,40 );


if ~freeView.Success;
    %disp( 'sad face. no success.' )
    if 0 == freeView.BreakCount;
        %disp( 'zero break fix on target' )
        %eventmarker 23 ==	Target Array NOT Aquired
        eventmarker(23);
        trialerror( 2 ); % no or late response (did not land on the target)
        run_scene( feedbackWrong );
        run_scene( endscene );
    else
        %disp( [ num2str( freeView.BreakCount ) ' break fix on target' ] )
        %eventmarker 25 == Target Array BREAK
        eventmarker(25);
        trialerror( 5 );  % broke fixation
        run_scene( feedbackWrong );
        run_scene( endscene );
    end
    return
end


% reward & give feedback
if freeView.Success;
    %disp( 'Success!' )
    %disp( [ num2str( freeView.BreakCount ) ' breaks fix on target' ] )
    %eventmarker 26	== Target Array Aquired
    eventmarker(26);
    trialerror( 0 ); % correct 
    run_scene( feedbackCorrect );
    %eventmarker 98 == Reward ON
    goodmonkey(reward, 'juiceline',1, 'numreward',num_reward, 'pausetime',pause_reward, 'eventmarker',98); % 100 ms of juice x 2
else
    %eventmarker 23 == Target Array NOT Aquired
    eventmarker(23);
    run_scene( feedbackWrong );
    trialerror(6); % chose the wrong (second) object among the options [target distractor]
    idle(700);
end
    


%end trial
%eventmarker == 100 END trial
eventmarker( 100 )

idle( 200 )

