%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ___________                  .__     
% \__    ___/___  __ __   ____ |  |__  
%   |    | /  _ \|  |  \_/ ___\|  |  \ 
%   |    |(  <_> )  |  /\  \___|   Y  \
%   |____| \____/|____/  \___  >___|  /
%                            \/     \/ 
%  ______    ___   __    _  _______  _______ 
% |    _ |  |   | |  |  | ||       ||       |
% |   | ||  |   | |   |_| ||    ___||  _____|
% |   |_||_ |   | |       ||   | __ | |_____ 
% |    __  ||   | |  _    ||   ||  ||_____  |
% |   |  | ||   | | | |   ||   |_| | _____| |
% |___|  |_||___| |_|  |__||_______||_______|
%

% Bonnie Cooper 4/20/2021 bcooper@sunyopt.edu
% training for touch version of Baptiste's Ring Ratio task.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% editables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
 
editable('wait_for_touch')   %max time after initial_fix given to complete a saccade (msec)
editable('hold_touch_time')    %hold fixation on bear_image (msec) 
editable('touch_window')       %center disc window (deg.vis.ang.)
editable('touch_target')       %target disc window
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
fixation_point = 3;
target = 4;
bzz_correct = 1;
bzz_wrong = 1;

% define time intervals (in ms):
wait_for_touch = 5000;
hold_touch_time = 500;
intTint = 700;
min_delay_fix = 500;            %hold fixation on fixation point while target is toggled on (msec)
delay_fix_increment = 50;       %ms to randomly add in random increasing multiple (up to 4) to min_delay_fix 

% touch window (in degrees):
touch_window = 3;
touch_target = 3;
% outer limit for repositioning the touch target
eccentricity_limit = 5;

reward = 300;
num_reward = 2;
pause_reward = 75;
hotkey('g', 'goodmonkey(400, ''NumReward'', 2,''PauseTime'', 50);' );

%generate a location within eccentricity_limit in pixels
current_mlconfig = mlconfig;
pixperdeg = current_mlconfig.PixelsPerDegree;
plusMinus = ( rand( 1,2 ) > 0.5 )*2 - 1; % a 1x2 vec that decides which quadrant to place the target
new_location = ( plusMinus.*( touch_window/2 + ( eccentricity_limit-touch_window/2 )*rand( 1,2 ) ) );
%get a position that is greater than the touch_window for the fixation
%target but less than the eccentricity limit while accounting for the
%radius of the touch target (place target such that the targets touch
%radius is within the eccentricity limit)

%move touch target to new location
reposition_object( target, new_location( 1, 1 ), new_location( 1, 2 ) );


% scene 1: fixation
fix1 = SingleTarget(touch_);     
fix1.Target = fixation_point;  
fix1.Threshold = touch_window;   
wth1 = WaitThenHold(fix1);          
wth1.WaitTime = wait_for_touch;       
wth1.HoldTime = hold_touch_time;        
                                    
scene1 = create_scene(wth1,fixation_point);  % In this scene, we will present the fixation_point (TaskObject #1)
                                             % and detect the eye movement indicated by the above parameters.
                                             
% % scene 2: sample
% targetImage = SingleTarget(touch_);     
% targetImage.Target = fixation_point;  
% targetImage.Threshold = touch_window;   
% wth2 = WaitThenHold(targetImage);          
% wth2.WaitTime = 0;       
% wth2.HoldTime = 10;        
%                                     
% scene2 = create_scene(wth2,fixation_point);  % In this scene, we will present the target (TaskObject #2)
%                                              % and detect the eye movement indicated by the above parameters.                                             
                                           
% scene 3: delay  
fix3 = SingleTarget(touch_);
fix3.Target = fixation_point;
fix3.Threshold = touch_window;
wth3 = WaitThenHold(fix3);
wth3.WaitTime = 0;
wth3.HoldTime = 0;

scene3 = create_scene(wth3,[ fixation_point,target ] );

% scene 4: target
targetImage = SingleTarget(touch_);     
targetImage.Target = target;  
targetImage.Threshold = touch_target;   
wth4 = WaitThenHold(targetImage);          
wth4.WaitTime = wait_for_touch;       
wth4.HoldTime = 10;

scene4 = create_scene(wth4,target);  % In this scene, we will present the target (TaskObject #2)
                                             % and detect the eye movement indicated by the above parameters.                                              
%scene correct feedback
fbtc_Correct = TimeCounter( null_ );
fbtc_Correct.Duration = 100;  % duration of the sound, ms
feedbackCorrect = create_scene( fbtc_Correct,bzz_correct );

%scene wrong feedback
fbtc_Wrong = TimeCounter( null_ );
fbtc_Wrong.Duration = 100;  % duration of the sound, ms
feedbackWrong = create_scene( fbtc_Wrong,bzz_wrong );

%clear the screen. equivalent to idle(0)
endtrial = TimeCounter(null_);
endtrial.Duration = 0;
endscene = create_scene(endtrial);

%%

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

% %scene2
% run_scene(scene2,10);     % Run the first scene (eventmaker 10)
% rt = wth2.AcquiredTime;   % For the reaction time graph
% if ~wth2.Success          % If the WithThenHold failed, (either fixation is not acquired or broken during hold)
%     idle(0);              % Clear the screen
%     if wth2.Waiting       % Check if we were waiting for fixation.
%         trialerror(4);    % If so, fixation was never made and this is the "no fixation (4)" error.
%     else
%         trialerror(3);    % If we were not waiting, it means that fixation was acquired but not held,
%     end                   %     so it is the "break fixation (3)" error.
%     return
% end
run_scene(scene3,30);     % Run the third (delay) scene (eventmarker 30)
if ~wth3.Success
    idle(0);
    trialerror(3);        % break fixation (3)
    return
end

run_scene(scene4,40);     % Run the fourth scene (eventmarker 40)
if ~wth4.Success          % The failure of MultiTarget means that none of the targets was chosen.
    idle(0);              % Clear the screen.
    if wth4.Waiting       % If we were waiting for the target selection (in other words, the gaze did not
        trialerror(2);    % land on either the target or distractor), it is the "late response (2)" error.
    else
        trialerror(3);    % Otherwise, the fixation is broken (3) and the choice was not held to the end.
    end
    return
end

% reward
if target==targetImage.Target
    trialerror(0); % correct
    run_scene( feedbackCorrect );
    goodmonkey(reward, 'juiceline',1, 'numreward',num_reward, 'pausetime',pause_reward, 'eventmarker',50); % 100 ms of juice x 2
else
    trialerror(6); % wrong
    run_scene( feedbackWrong );
    run_scene( endscene );
    idle(intTint);
    
idle(intTint);
end
