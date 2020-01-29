%driftingGrating_delayedSaccade


%% task control
if ~exist('touch_','var'), error('This demo requires the touch input. Please enable it in the main menu or try the simulation mode.'); end
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');
showcursor(false);  % remove the joystick cursor
TrialRecord.MarkSkippedFrames = false;  % skip skipped frame markers

dashboard(4,'Move: Left click + Drag, Resize: Right click + Drag',[0 1 0]);
dashboard(5,'Spatial Frequency: [LEFT(-) RIGHT(+)], Temporal Frequency: [DOWN(-) UP(+)]',[0 1 0]);
dashboard(6,'Press ''x'' to quit.',[1 0 0]);

% editables
Orientation = 45;
SpatialFrequency = 0.1;
TemporalFrequency = 1;
SpatialFrequencyStep = 0.01;
TemporalFrequencyStep = 0.1;
editable('SpatialFrequencyStep','TemporalFrequencyStep', 'Orientation', 'SpatialFrequency', 'TemporalFrequency' );

% create scene
grat1 = Drifting_Grating_Background(touch_);
grat1.SpatialFrequencyStep = SpatialFrequencyStep;
grat1.TemporalFrequencyStep = TemporalFrequencyStep;
grat1.Orientation = Orientation;
grat1.SpatialFrequency = SpatialFrequency;
grat1.TemporalFrequency = TemporalFrequency;
scene1 = create_scene(grat1);

% task
run_scene(scene1);
idle(0);

% save parameters
bhv_variable('position',grat1.Position);
bhv_variable('radius',grat1.Radius);
bhv_variable('orientation',grat1.Orientation);
bhv_variable('spatial_frequency',grat1.SpatialFrequency);
bhv_variable('temporal_frequency',grat1.TemporalFrequency);
