%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ___________                  .__     
% \__    ___/___  __ __   ____ |  |__  
%   |    | /  _ \|  |  \_/ ___\|  |  \ 
%   |    |(  <_> )  |  /\  \___|   Y  \
%   |____| \____/|____/  \___  >___|  /
%                            \/     \/ 
%  ____   ___   ____        ___   __ __  ______     
% |    \ /   \ |    \      /   \ |  |  ||      |    
% |  o  )     ||  o  )    |     ||  |  ||      |    
% |   _/|  O  ||   _/     |  O  ||  |  ||_|  |_|    
% |  |  |     ||  |       |     ||  :  |  |  |      
% |  |  |     ||  |       |     ||     |  |  |      
% |__|   \___/ |__|        \___/  \__,_|  |__|          
% Bonnie Cooper 7/29/2019 bcooper@sunyopt.edu
% popOut_Search adapted for the touch screen: a touch target appears at the
% center of the screen and must be held for 'hold_touch_time' ms. upon
% successful hold, an array of 1 target & several distractors appears. the
% subject must touch the matching target to recieve reward.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% editables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
 
editable('wait_for_touch')   %max time after initial_fix given to complete a saccade (msec)
editable('hold_touch_time')    %hold fixation on bear_image (msec)
editable('touch_window')       %target sacade window (deg.vis.ang.)
editable('intTint')             %idle time inbetween conditions (msec)
editable('reward');
editable('num_reward');
editable('pause_reward');
editable('eccentricity_limit')

%% send unique strobes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Send Start Experiment Stobes only on the first trial
%this stobes unique values at the start of a new experiment
% previousTrialCode = TrialRecord.LastTrialCodes.CodeNumbers; %get the eventmarkers that were sent in the previous trial
% formatOut = 31; 
% DateStr = datestr(now,formatOut);
% disp( DateStr )
% bhv_variable('DateStr',DateStr);
% DateStrSplit = regexp(DateStr, '[- :]', 'split');
% yyyyStrobe = str2num( DateStrSplit{1} );
% mmddStrobe = str2num( [ DateStrSplit{2} DateStrSplit{3} ] );
% hhmmStrobe = str2num( [ DateStrSplit{4} DateStrSplit{5} ] );
% mmssStrobe = str2num( [ DateStrSplit{5} DateStrSplit{6} ] );
% if isempty( previousTrialCode ); %if there weren't any eventmarkers this must be the 1st trial
%     disp( '¯`·._.··¸.-~*´¨¯¨`*·~-.,-,.-~*´¨¯¨`*·~-.¸··._.·´¯`·._.··¸.-~*´¨¯¨`*·~-.,-,.-~*´¨¯¨`*·~-.¸··._.·´¯' )
%     disp( 'start experiment' )
%     disp( 'Touch Teach' )
%     eventmarker( 5555 );
%     eventmarker( [ yyyyStrobe mmddStrobe hhmmStrobe mmssStrobe ] );
% else
%     currentTrialNum = TrialRecord.CurrentTrialNumber;
%     eventmarker( 5555 );
%     eventmarker( hhmmStrobe );
% end

%% task body

if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');
bhv_code(10,'Fix Cue',20,'Sample',30,'Delay',40,'Go',50,'Reward');  % behavioral codes

% give names to the TaskObjects defined in the conditions file:
correctBZZ = 1;
wrongBZZ = 2;
fixation_point = 3;
%find the number of distractors used in the current txt file
crc1 = 4; crc2 = 5; crc3 = 6; crc4 = 7; crc5 = 8; crc6 = 9; crc7 = 10; ...
    crc8 = 11; crc9 = 12; crc10 = 13; crc11 = 14; crc12 = 15; crc13 = 16; crc14 = 17;
targetobject_array = [fixation_point crc1 crc2 crc3 crc4 crc5 crc6 crc7 ...
    crc8 crc9 crc10 crc11 crc12 crc13 crc14];
target = crc1;
% stimulus_array length is contingent on the how many distractors, so:
num_TaskObjects = length( TrialRecord.CurrentConditionStimulusInfo );
stim_array = targetobject_array( 2:(num_TaskObjects-2));

% define time intervals (in ms):
wait_for_touch = 5000;
hold_touch_time = 500;
intTint = 700;

% touch window (in degrees):
touch_window = 5.5;

% outer limit for repositioning the touch target
eccentricity_limit = 5;

reward = 300;
num_reward = 2;
pause_reward = 75;
hotkey('g', 'goodmonkey(400, ''NumReward'', 2,''PauseTime'', 50);' );


% scene 1: fixation
fix1 = SingleTarget(touch_);     
fix1.Target = fixation_point;  
fix1.Threshold = touch_window;   
wth1 = WaitThenHold(fix1);          
wth1.WaitTime = wait_for_touch;       
wth1.HoldTime = hold_touch_time;        
                                    
scene1 = create_scene(wth1,fixation_point);  % In this scene, we will present the fixation_point (TaskObject #1)
                                             % and detect the eye movement indicated by the above parameters.
                                             
% scene 2: target array & choice
mul2 = MultiTarget(touch_);          
mul2.Target = target; 
mul2.Threshold = touch_window;
mul2.WaitTime = wait_for_touch;
mul2.HoldTime = hold_touch_time;
mul2.TurnOffUnchosen = true;        
scene2 = create_scene(mul2,[target stim_array]);                                                                                     

%scene correct feedback
fbtc_Correct = TimeCounter( null_ );
fbtc_Correct.Duration = 100;  % duration of the sound, ms
feedbackCorrect = create_scene( fbtc_Correct,correctBZZ );

%clear the screen. equivalent to idle(0)
endtrial = TimeCounter(null_);
endtrial.Duration = 0;
endscene = create_scene(endtrial);

% TASK:
%scene1
run_scene(scene1,10);     % Run the first scene (eventmaker 10)
if ~wth1.Success          % If the WithThenHold failed, (either fixation is not acquired or broken during hold)
    idle(0);              % Clear the screen
    if wth1.Waiting       % Check if we were waiting for fixation.
        trialerror(4);    % If so, fixation was never made and this is the "no fixation (4)" error.
    else
        trialerror(3);    % If we were not waiting, it means that fixation was acquired but not held,
    end                   %     so it is the "break fixation (3)" error.
    return
end

%scene2
run_scene(scene2,10);     % Run the first scene (eventmaker 10)
rt = mul2.AcquiredTime;   % For the reaction time graph
if ~mul2.Success          % If the WithThenHold failed, (either fixation is not acquired or broken during hold)
    idle(0);              % Clear the screen
    if mul2.Waiting       % Check if we were waiting for fixation.
        trialerror(4);    % If so, fixation was never made and this is the "no fixation (4)" error.
    else
        trialerror(3);    % If we were not waiting, it means that fixation was acquired but not held,
    end                   %     so it is the "break fixation (3)" error.
    return
end

% reward
if target==mul2.ChosenTarget
    trialerror(0); % correct
    run_scene( feedbackCorrect );
    goodmonkey(reward, 'juiceline',1, 'numreward',num_reward, 'pausetime',pause_reward, 'eventmarker',50); % 100 ms of juice x 2
else
    trialerror(6); % wrong
    run_scene( endscene );
    idle(intTint);
    
idle(intTint);
end

