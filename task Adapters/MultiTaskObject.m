classdef  MultiTaskObject < mladapter
    properties %properties that can be set in timing script
        TaskObjects
        Threshold
        Color
        Target
        TargetThreshold
        TargetColor
        MaxTime
        HoldTime
    end
    properties (SetAccess = protected) %properties that can be accessed in 
        %timing script but not changed
        Running
        Waiting
        BreakCount
        IsViewingNum
        WasViewing
        AcquiredTime
        ChosenTaskObjects
        FixationTime
        CurrentlyAcquired
    end
    properties (Access = protected) %properties that can niether be set nor
        %accessed 
        SingleTarget2
        FreeThenHold2
        nTaskObjects
        TaskObjectsID
        TargetID
    end
    
    methods
        function obj = MultiTaskObject(varargin)
            obj = obj@mladapter(varargin{:});
            
            if 0==nargin %cannot be empty needs 'eye_'
                return
            end
            %initialize some properties here
            obj.TaskObjects = [0 0; 0 0];
            obj.Threshold = 0;
            obj.Color = [0 1 0];
            obj.Target = 5;%initialize as 'target', but timing script logic 
            %tradesoff for Target Absent trials
            obj.TargetThreshold = 0;
            obj.TargetColor = [1 0 0];
            obj.MaxTime = 0;
            obj.HoldTime = 0;
        end
        
        function set.TaskObjects(obj,taskobjects)
            %validate the values being asigned to TaskObjects (input can be
            %coordinates or taskObject index that corresponds to the text
            %file used.
            %e.g. for catSearchPHYSIOL_ML2, TaskObjects is the class of
            %objects that will be monitored for viewing but not rewarded
            %ultimately for fixation.
            
            %get the number of taskobjects
            [m,n] = size(taskobjects);
            if 1==m || 2~=n
                taskobjects = taskobjects(:)';
                modality = obj.Tracker.TaskObject.Modality(taskobjects);
                nonvisual = ~ismember(modality,[1 2]);
                if any(nonvisual)
                    error('TaskObjects #%d is not visual',taskobjects(find(nonvisual,1))); 
                end
                if ~isempty(obj.TaskObjects) && ...
                        all(size(taskobjects)==size(obj.TaskObjects)) && ...
                        all(taskobjects==obj.TaskObjects)
                    return
                end
                obj.TaskObjects = taskobjects;
                obj.nTaskObjects = numel(obj.TaskObjects);
                obj.TaskObjectsID = obj.Tracker.TaskObject.ID(taskobjects); %#ok<*MCSUP>
            elseif 1<m && 2==n  % if target is a n-by-2 matrix ...
                %(i.e., coordinates), take it as it is.
                obj.TaskObjects = taskobjects;
                obj.nTaskObjects = size(taskobjects,1);
                obj.TaskObjectsID = [];
            else
                error('TaskObjects cannot be empty');
            end
            create_tracker(obj);
        end
        function set.Target(obj,target)
            %validate the values assigned to Target
            %this is the taskObject that will be rewarded for holding
            %fixation.
            if isscalar(target)
                modality = obj.Tracker.TaskObject.Modality(target);
                if 1~=modality && 2~=modality
                    error('Target #%d is not visual',target)
                end
                obj.Target = target;
            elseif 2==numel(target)
                obj.Target = target(:)';
            else
                error('Target must be a scalar or a 2-element vector');
            end
            create_tracker(obj);
        end
        function set.Threshold(obj,threshold)
            %validate the value of Threshold (for TaskObjects class)
            if 0==numel(threshold) || 2<numel(threshold)
                error('Threshold must be a scalar or a 1-by-2 vector'); 
            end
            threshold = threshold(:)';
            if ~isempty(obj.Threshold) &&...
                    all(size(threshold)==size(obj.Threshold)) && ...
                    all(threshold==obj.Threshold), 
                return
            end
            obj.Threshold = threshold;
            create_tracker(obj);
        end
        function set.TargetThreshold(obj,targetThreshold)
            %validate the value of TargetThreshold (for Target class)
            if 0==numel(targetThreshold) || 2<numel(targetThreshold)
                error('Threshold must be a scalar or a 1-by-2 vector'); 
            end
            targetThreshold = targetThreshold(:)';
            if ~isempty(obj.TargetThreshold) && ...
                    all(size(targetThreshold)==size(obj.TargetThreshold)) && ...
                    all(targetThreshold==obj.TargetThreshold)
                return
            end
            obj.TargetThreshold = targetThreshold;
            create_tracker(obj);
        end
        function set.Color(obj,color)
            %validate the value of Color (for TaskObjects class' tracker)
            if 3~=numel(color)
                error('Color must be a 1-by-3 vector')
            end
            color = color(:)';
            if ~isempty(obj.Color) && all(color==obj.Color)
                return
            end
            obj.Color = color;
            create_tracker(obj);
        end
        function set.TargetColor(obj,targetcolor)
            %validate the value of TargetColor (for Target class' tracker)
            if 3~=numel(targetcolor)
                error('TargetColor must be a 1-by-3 vector')
            end
            targetcolor = targetcolor(:)';
            if ~isempty(obj.TargetColor) && all(targetcolor==obj.TargetColor)
                return
            end
            obj.TargetColor = targetcolor;
            create_tracker(obj);
        end
        function set.MaxTime(obj,time)
            obj.MaxTime = time;
            create_tracker(obj);
        end
        function set.HoldTime(obj,time)
            obj.HoldTime = time;
            create_tracker(obj);
        end
        
        %initialize MultiTaskObject object
        function init(obj,p)
            init@mladapter(obj,p);
            %get a FreeThenHold instace for each TaskObject set
            for m=1:obj.nTaskObjects
                obj.FreeThenHold2{m}.init(p) 
            end

            %initialize protected properties
            obj.Running = true;
            obj.Waiting = true;
            obj.BreakCount = [];
            obj.AcquiredTime = [];
            obj.ChosenTaskObjects = [];
            obj.IsViewingNum = 0;
            obj.WasViewing = 0;
        end
        
        
        function fini(obj,p)
            fini@mladapter(obj,p);
            for m=1:obj.nTaskObjects
                obj.FreeThenHold2{m}.fini(p)
            end
        end
        
        %for each new screen, do these things
        function continue_ = analyze(obj,p)
            analyze@mladapter(obj,p);
            if ~obj.Running
                continue_ = false;
                return
            end

            continue_ = false;
            for m=1:obj.nTaskObjects

                continue_ = continue_ | obj.FreeThenHold2{m}.analyze(p);
                
                %if MultiTaskObject is waiting & there has been a
                %successul FreeThanHold2 acquisition of Target
                if obj.Waiting && ~isempty( obj.FreeThenHold2{m}.AcquiredTime )
                    obj.Waiting = false; %then we are no longer waiting
                    obj.AcquiredTime = obj.FreeThenHold2{m}.AcquiredTime;
                    %the FreeThenHold2{ target }.AcquiredTime is now
                    %MultiTaskObjects AcquiredTime
                end
                
                %if the object's singleTracker2 is waiting
                if obj.SingleTarget2{m}.IsViewing && obj.IsViewingNum == m
                    %disp( ' ' )
                elseif obj.SingleTarget2{m}.IsViewing && obj.IsViewingNum ~= m
                    disp( [ 'Just jumped into TaskObject #' num2str( m ) '''s threshold' ] )
                    %dashboard( [ 'Just jumped into TaskObject #' num2str( m ) '''s threshold' ] )
                    obj.IsViewingNum = m;
                %else
                    %obj.IsViewingNum = 0;
                end
                
                if obj.FreeThenHold2{m}.Success
                    if isempty(obj.TaskObjectsID)
                        obj.CurrentlyAcquired = m;
                    else
                        obj.CurrentlyAcquired = obj.TaskObjects(m);
                    end
                    obj.Running = false;
                    break
                end
            end
            
            obj.Success = obj.Target == obj.CurrentlyAcquired;
        end
    end
    
    methods (Access = protected)
        function create_tracker(obj)
            if isempty(obj.TaskObjects) || ...
                    isempty(obj.Threshold) || ...
                    isempty(obj.MaxTime) || ...
                    isempty(obj.HoldTime)
                return
            end
                        
            if length(obj.SingleTarget2)~=obj.nTaskObjects
                obj.SingleTarget2 = cell(1,obj.nTaskObjects);
                obj.FreeThenHold2 = cell(1,obj.nTaskObjects);
                for m=1:obj.nTaskObjects
                    obj.SingleTarget2{m} = SingleTarget2(obj.Tracker); %#ok<CPROP>
                    obj.FreeThenHold2{m} = FreeThenHold2(obj.SingleTarget2{m}); %#ok<CPROP>
                end
            end
            for m=1:obj.nTaskObjects
                if isempty(obj.TaskObjectsID)
                    obj.SingleTarget2{m}.Target = obj.TaskObjects(m,:);  % Target is coordinates
                else
                    obj.SingleTarget2{m}.Target = obj.TaskObjects(m);    % Target is TaskObject
                end
                obj.SingleTarget2{m}.Threshold = obj.Threshold;
                obj.SingleTarget2{m}.Color = obj.Color;
                obj.FreeThenHold2{m}.MaxTime = obj.MaxTime;
                obj.FreeThenHold2{m}.HoldTime = obj.HoldTime;
            end
            
                        
            mm = 1;
            if isempty(obj.TargetID)
                obj.SingleTarget2{mm}.Target = obj.Target(mm,:);  % Target is coordinates
            else
                obj.SingleTarget2{mm}.Target = obj.Target(mm);    % Target is TaskObject
            end
            obj.SingleTarget2{mm}.Threshold = obj.TargetThreshold;
            obj.SingleTarget2{mm}.Color = obj.TargetColor;
            obj.FreeThenHold2{mm}.MaxTime = obj.MaxTime;
            obj.FreeThenHold2{mm}.HoldTime = obj.HoldTime;
        end
    end
end


