classdef FreeViewTarget < mladapter  % Change the class name
    properties
        % Define user variables here. All variables must be initialized.
        Target
        Color
        Distractor
        %DColor
        Threshold
        WaitTime
        HoldTime
        TurnOffUnchosen = false
    end
    properties (SetAccess = protected)
        % Variables that users need to read but should not change
        Running
        Waiting
        AcquiredTime
        ChosenTarget
        
    end
    properties (Access = protected)
        % Variables that should not be accessible from the outside of the object
        SingleTarget
        WaitThenHold
        nTarget
        TargetID
    end
    
    methods
        function obj = FreeViewTarget(varargin)  % Change the function name
            obj = obj@mladapter(varargin{:});
            if 0 == nargin, return, end
            
            % User variables can be initialized here, too.
            obj.Target = [0 0; 0 0];
            obj.Color = [ 0 1 0 ];
            obj.Distractor = [0 0; 0 0];
            %obj.DColor = [ 1 0 0 ];
            obj.Threshold = 0;
            obj.WaitTime = 0;
            obj.HoldTime = 0;
        end
        
%         function delete(obj) %#ok<INUSD>
%             % Things to do when this adapter is destroyed
%         end
        
        function set.Target( obj,target )
            [ m,n ] = size( target );
            if 1==m || 2~=n 
                target = target(:)';
                modality = obj.Tracker.TaskObject.Modality(target);
                nonvisual = ~ismember(modality,[1 2]);
                if any(nonvisual), error('Target #%d is not visual',target(find(nonvisual,1))); end
                if ~isempty(obj.Target) && all(size(target)==size(obj.Target)) && all(target==obj.Target), return, end
                obj.Target = target;
                obj.nTarget = numel(obj.Target);
                obj.TargetID = obj.Tracker.TaskObject.ID(target); %#ok<*MCSUP>
            elseif 1<m && 2==n %if target is an n-by-2 matrix (i.e., coordinates)
                obj.Target = target;
                obj.nTarget = size(target,1);
                obj.TargetID = [];
            else
                error('Target cannot be empty');
            end
            create_tracker(obj);
        end

        function set.Distractor( obj,distractor )
            [ m,n ] = size( distractor );
            if 1==m || 2~=n 
                distractor = distractor(:)';
                modality = obj.Tracker.TaskObject.Modality(distractor);
                nonvisual = ~ismember(modality,[1 2]);
                if any(nonvisual), error('Distractor #%d is not visual',distractor(find(nonvisual,1))); end
                if ~isempty(obj.Distractor) && all(size(distractor)==size(obj.Distractor)) && all(distractor==obj.Distractor), return, end
                obj.Distractor = distractor;
                obj.nDistractor = numel(obj.Distractor);
                obj.DistractorID = obj.Distractor.TaskObject.ID(distractor); %#ok<*MCSUP>
                create_tracker(obj);
            elseif 1<m && 2==n %if distractor is an n-by-2 matrix (i.e., coordinates)
                obj.Distractor = distractor;
                obj.nDistractor = size(distractor,1);
                obj.DistractorID = [];
                create_tracker(obj);
            else
                disp('Distractor is empty');
            end 
        end
        function set.Threshold(obj,threshold)
            if 0==numel(threshold) || 2<numel(threshold), error('Threshold must be a scalar or a 1-by-2 vector'); end
            threshold = threshold(:)';
            if ~isempty(obj.Threshold) && all(size(threshold)==size(obj.Threshold)) && all(threshold==obj.Threshold), return, end
            obj.Threshold = threshold;
            create_tracker(obj);
        end
        function set.Color(obj,color)
            if 3~=numel(color), error('Color must be a 1-by-3 vector'); end
            color = color(:)';
            if ~isempty(obj.Color) && all(color==obj.Color), return, end
            obj.Color = color;
            create_tracker(obj);
        end
        function set.WaitTime(obj,time)
            obj.WaitTime = time;
            create_tracker(obj);
        end
        function set.HoldTime(obj,time)
            obj.HoldTime = time;
            create_tracker(obj);
        end
        function set.TurnOffUnchosen(obj,val)
            obj.TurnOffUnchosen = logical(val);
        end

        function init(obj,p)
            init@mladapter(obj,p); 
            % Define things to do before a scene starts here
            for m=1:obj.nTarget, obj.WaitThenHold{m}.init(p); end
            for mm=1:obj.nDistractor, obj.WaitThenHold{mm}.init(p); end
            obj.Running = true;
            obj.Waiting = true;
            obj.AcquiredTime = [];
            obj.ChosenTarget = [];  
        end
        
        function fini(obj,p)
            fini@mladapter(obj,p);
            % Define things to do after a scene finishes here
            for m=1:obj.nTarget, obj.WaitThenHold{m}.fini(p); end
            for mm=1:obj.nDistractor, obj.WaitThenHold{mm}.fini(p); end    
        end
        
        function continue_ = analyze(obj,p)
            analyze@mladapter(obj,p);
            if ~obj.Running, continue_ = false; return, end
            
            continue_ = false;
            for m = 1:obj.nTarget %for each target
                %either continue of waitthenhold
                continue_ = continue_ | obj.WaitThenHold{m}.analyze(p);
                if obj.Waiting && ~obj.WaitThenHold{ m }.Waiting %if the wait time is up
                    obj.Waiting = false;
                    obj.AcquiredTime = obj.WaitThenHold{ m }.AcquiredTime;
                    if obj.TurnOffUnchosen %handles turning off unchosen targets
                        if isempty(obj.TargetID)
                            for n=find((1:obj.nTarget)~=m)
                                obj.SingleTarget{n}.stop();
                                obj.WaitThenHold{n}.stop();
                            end
                        else
                            for n=find(obj.Target~=obj.Target(m))
                                mglactivategraphic(obj.TargetID(n),false);
                                obj.SingleTarget{n}.stop();
                                obj.WaitThenHold{n}.stop();
                            end
                        end
                    end
                end
                if obj.WaitThenHold{m}.Success
                    if isempty(obj.TargetID), obj.ChosenTarget = m; else, obj.ChosenTarget = obj.Target(m); end
                    obj.Running = false;
                    break
                end
            end
            %for each distractor
            obj.Success = ~isempty(obj.ChosenTarget);
        end
    end
            
            % This function is called every frame during the scene.
            % Do things to detect behavior here.
            %
            % Two variables are important.
            % continue_ determines whether the analysis will be continued to next frame.
            % obj.Success indicates whether the behavior is detected.
            %
            % See WaitThenHold.m for an example.
    methods (Access = protected)
        function create_tracker(obj)
            if isempty(obj.Target) || isempty(obj.Threshold) || isempty(obj.WaitTime) || isempty(obj.HoldTime), return, end

            if length(obj.SingleTarget)~=obj.nTarget
                obj.SingleTarget = cell(1,obj.nTarget);
                obj.WaitThenHold = cell(1,obj.nTarget);
                for m=1:obj.nTarget
                    obj.SingleTarget{m} = SingleTarget(obj.Tracker); %#ok<CPROP>
                    obj.WaitThenHold{m} = WaitThenHold(obj.SingleTarget{m}); %#ok<CPROP>
                end
            end
            for m=1:obj.nTarget
                if isempty(obj.TargetID)
                    obj.SingleTarget{m}.Target = obj.Target(m,:);  % Target is coordinates
                else
                    obj.SingleTarget{m}.Target = obj.Target(m);    % Target is TaskObject
                end
                obj.SingleTarget{m}.Threshold = obj.Threshold;
                obj.SingleTarget{m}.Color = obj.Color;
                obj.WaitThenHold{m}.WaitTime = obj.WaitTime;
                obj.WaitThenHold{m}.HoldTime = obj.HoldTime;
            end
        end
    end            
       
%         function draw(obj,p)
%             draw@mladapter(obj,p);
%             
%             % This function is called every frame during the scene.
%             % Update graphics related to this adapter here.
%             
%         end
  
end


