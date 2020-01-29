classdef FreeThenHold2 < mladapter
    %exactly the same as FreeThenHold, except runs with SingleTarget2
    properties
        MaxTime = 0;
        HoldTime = 0;
    end
    properties (SetAccess = protected)
        BreakCount
        AcquiredTime
    end
    properties (Access = protected)
        ST
        WasGood
        EndTime
    end
    
    methods
        function obj = FreeThenHold2(varargin)
            obj = obj@mladapter(varargin{:});
            obj.ST = get_adapter(obj,'SingleTarget2');
            if isempty(obj.ST), error('SingleTarget2 is not found in the chain!!!'); end
        end
        function init(obj,p)
            init@mladapter(obj,p);
            obj.BreakCount = 0;
            obj.WasGood = false;
            obj.EndTime = 0;
			obj.AcquiredTime = [];
        end
        function fini(obj,p)
            fini@mladapter(obj,p);
            if obj.Success && strcmp(obj.Tracker.Signal,'Eye'), p.EyeTargetRecord = [obj.ST.Position [obj.AcquiredTime 0]+obj.HoldTime/2]; end
        end
        function continue_ = analyze(obj,p)
            analyze@mladapter(obj,p);

            good = obj.ST.Success;
            elapsed = p.scene_time();

            if ~good && ~obj.WasGood
                continue_ = elapsed < obj.MaxTime;
                return
            end
            
            if ~good && obj.WasGood
                obj.BreakCount = obj.BreakCount + 1;
                obj.WasGood = false;
                continue_ = elapsed < obj.MaxTime;
                return
            end
            
            if good && ~obj.WasGood
                obj.AcquiredTime = obj.ST.Time;
                obj.WasGood = true;
                obj.EndTime = elapsed + obj.HoldTime;
            end
            
            if good && obj.WasGood
                if elapsed < obj.EndTime
                    continue_ = true;
                else
                    obj.Success = true;
                    continue_ = false;
                end
                return
            end
            
            continue_ = true;
        end
    end
end

