classdef MultiDistractor < mladapter  % Change the class name
    properties %user variables. must be initiated when calling an instance
        Target
        Distractor
        Threshold
        Color
        WaitTime
        HoldTime
    end
    properties (SetAccess = protected)%read-only variables
        Running
        Waiting
        AcquiredTime
        ChosenTarget
    end
    properties (Access = protected)%cannot be accessed
        TaskObjectFixated
        nDistractor
        DistractorID
    end
    
    methods
        function obj = MultiDistractor(varargin)%create the class obj
            obj = obj@mladapter(varargin{:});
            if 0==nargin, return, end
        end
        
        function set.Distractor(obj,distractor)%set Distractor properties
            [m,n] = size(distractor);%get dimensions of 'distractor' this
            if 1==m || 2~=n %if there is only 1 row or the number of collumns is not 2:
                distractor = distractor(:)';
                modality = obj.Tracker.TaskObject.Modality(distractor);
                nonvisual = ~ismember(modality,[1 2]);
                if any(nonvisual)
                    error('Distractor #%d is not visual',distractor(find(nonvisual,1))); 
                end
                if ~isempty(obj.Distractor) && ...
                        all(size(distractor)==size(obj.Distractor)) && ...
                        all(distractor==obj.Distractor), return, end
                obj.Distractor = distractor;
                obj.nDistractor = numel(obj.Distractor);
                obj.DistractorID = obj.Tracker.TaskObject.ID(distractor); %#ok<*MCSUP>
            elseif 1<m && 2==n  % if target is a n-by-2 matrix (i.e., coordinates), take it as it is.
                obj.Distractor = distractor;
                obj.nDistractor = size(distractor,1);
                obj.DistractorID = [];
            else
                error('Distractor cannot be empty');
            end
            create_tracker(obj);
        end
        function set.Threshold(obj,threshold)
            if 0==numel(threshold) || 2<numel(threshold) 
                error('Threshold must be a scalar or a 1-by-2 vector'); 
            end
            threshold = threshold(:)';
            if ~isempty(obj.Threshold) && ...
                    all(size(threshold)==size(obj.Threshold)) && ...
                    all(threshold==obj.Threshold), return, end
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

        
        function init(obj,p)
            init@mladapter(obj,p);
            for m=1:obj.nDistractor, obj.TaskObjectFixated{m}.init(p); end

            obj.Running = true;
            obj.Waiting = true;
            obj.AcquiredTime = [];
        end
        function fini(obj,p)
            fini@mladapter(obj,p);
            for m=1:obj.nDistractor, obj.TaskObjectFixated{m}.fini(p); end
        end
        
        function continue_ = analyze(obj,p)
            analyze@mladapter(obj,p);
            
            if ~obj.Running 
                continue_ = false; 
                return 
            end

            continue_ = false;
            for m=1:obj.nDistractor %every frame go through each distractor
                %if this taskobject currently acquired
                if obj.TaskObjectFixated{m}.Success
                %   flip a bool
                %   disp in control screen which m is fixated
                    disp( [ 'distractor #' nume2str( m ) ' fixated' ] )
                end
            end
        end
    end
    
    methods %(Access = protected)
        function create_tracker(obj)
            if isempty(obj.Distractor) || isempty(obj.Threshold), return, end
            
            if length(obj.TaskObjectFixated)~=obj.nDistractor
                obj.TaskObjectFixated = cell(1,obj.nDistractor);
                for m=1:obj.nDistractor
                    obj.TaskObjectFixated{m} = TaskObjectFixated(obj.Tracker); %#ok<CPROP>
                end
            end
            for m=1:obj.nDistractor
                if isempty(obj.DistractorID)
                    obj.TaskObjectFixated{m}.TaskObject = obj.Distractor(m,:);  % Target is coordinates
                else
                    obj.TaskObjectFixated{m}.TaskObject = obj.Distractor(m);    % Target is TaskObjectNum
                end
                obj.TaskObjectFixated{m}.Threshold = obj.Threshold;
                obj.TaskObjectFixated{m}.Color = obj.Color;
            end
        end

    end
end
