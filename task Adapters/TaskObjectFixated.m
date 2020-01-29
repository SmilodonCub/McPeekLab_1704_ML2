classdef TaskObjectFixated < mladapter  % Change the class name
    properties
        TaskObject
        Threshold
        Color = [0 0 1]
        StimulationTarget
    end
    properties (SetAccess = protected)
        CurrentlyAcquired
        FixationTime
    end
    properties (Access = protected)
        nTaskObject
        FixWindowID
        ScrPosition
        ThresholdInPixels
    end
    
    methods
        function obj = TaskObjectFixated(varargin)
            obj = obj@mladapter(varargin{:});
        end
        function delete(obj)
            destroy_fixwindow(obj);
        end
        
        function set.TaskObject(obj,taskobject)
            [m,n] = size(taskobject);
            if 1==m || 2~=n
                taskobject = taskobject(:)';
                modality = obj.Tracker.TaskObject.Modality(taskobject);
                nonvisual = ~ismember(modality,[1 2]);
                if any(nonvisual) 
                    error('TaskObject #%d is not visual',taskobject(find(nonvisual,1))); 
                end
                if ~isempty(obj.TaskObject) && all(size(taskobject)==size(obj.TaskObject)) && all(taskobject==obj.TaskObject) 
                    return 
                end
                obj.TaskObject = taskobject;
                obj.nTaskObject = numel(obj.TaskObject);
                obj.ScrPosition = obj.Tracker.TaskObject.ScreenPosition(taskobject,:); %#ok<*MCSUP>
            elseif 1<m && 2==n  % if target is a n-by-2 matrix (i.e., coordinates), take it as it is.
                obj.TaskObject = taskobject;
                obj.nTaskObject = size(taskobject,1);
                obj.ScrPosition = obj.Tracker.CalFun.deg2pix(taskobject);
            else
                error('TaskObject cannot be empty');
            end
            create_fixwindow(obj);
        end
        function set.Threshold(obj,threshold)
            if 0==numel(threshold) || 2<numel(threshold), error('Threshold must be a scalar or a 1-by-2 vector'); end
            threshold = threshold(:)';
            if ~isempty(obj.Threshold) && all(size(threshold)==size(obj.Threshold)) && all(threshold==obj.Threshold), return, end
            obj.Threshold = threshold;
            create_fixwindow(obj);
        end
        
        function init(obj,p)
            init@mladapter(obj,p);
            mglactivategraphic(obj.FixWindowID,true);
            obj.FixationTime = zeros(1,obj.nTaskObject);
        end
        function fini(obj,p)
            fini@mladapter(obj,p);
            mglactivategraphic(obj.FixWindowID,false);
        end
        
        %things to do each frame
        function continue_ = analyze(obj,p)
            continue_ = analyze@mladapter(obj,p);
            
            %get eye position data
            data = obj.Tracker.XYData(end,:);
            ndata = size(data,1);
            if 0==ndata, continue_ = true; return, end
            
            in = false(ndata,obj.nTaskObject);
            for m=1:obj.nTaskObject%for each taskobject
                if isscalar(obj.ThresholdInPixels)
                    in(:,m) = sum((data-repmat(obj.ScrPosition(m,:),ndata,1)).^2,2) < obj.ThresholdInPixels;
                else
                    rc = obj.ThresholdInPixels(m,:);
                    in(:,m) = rc(1)<data(:,1) & data(:,1)<rc(3) & rc(2)<data(:,2) & data(:,2)<rc(4);
                end
            end
            acquired = in(end,:);
            obj.CurrentlyAcquired = obj.TaskObject(acquired);
            obj.FixationTime(acquired) = obj.FixationTime(acquired) + obj.Tracker.Screen.FrameLength;
            obj.Success = obj.StimulationTarget == obj.CurrentlyAcquired;
            
            p.dashboard(1,sprintf('#1: %4.0f, #2: %4.0f, #3: %4.0f, #4: %4.0f',obj.FixationTime));
        end
    end
    
    methods (Access = protected)
        function create_fixwindow(obj)
            if isempty(obj.ScrPosition) || isempty(obj.Threshold), return, end
            destroy_fixwindow(obj);

            obj.FixWindowID = zeros(1,obj.nTaskObject);
            threshold_in_pixels = obj.Threshold * obj.Tracker.Screen.PixelsPerDegree;
            if isscalar(obj.Threshold)
                obj.ThresholdInPixels = threshold_in_pixels^2; 
            else
                obj.ThresholdInPixels = zeros(obj.nTaskObject,4);
            end
            for m=1:obj.nTaskObject
                if isscalar(obj.Threshold)
                    obj.FixWindowID(m) = mgladdcircle(obj.Color,threshold_in_pixels*2,10);
                else
                    obj.FixWindowID(m) = mgladdbox(obj.Color,threshold_in_pixels,10);
                    obj.ThresholdInPixels(m,:) = [obj.ScreenPosition-0.5*threshold_in_pixels obj.ScreenPosition+0.5*threshold_in_pixels];
                end
            end
            mglsetorigin(obj.FixWindowID,obj.ScrPosition);
            mglactivategraphic(obj.FixWindowID,false);
        end
        function destroy_fixwindow(obj)
            if ~isempty(obj.FixWindowID), mgldestroygraphic(obj.FixWindowID); obj.FixWindowID = []; end
        end
    end
end
