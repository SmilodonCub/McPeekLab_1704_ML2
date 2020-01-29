%      _      _  __ _   _                               _   _             
%     | |    (_)/ _| | (_)                             | | (_)            
%   __| |_ __ _| |_| |_ _ _ __   __ _    __ _ _ __ __ _| |_ _ _ __   __ _ 
%  / _` | '__| |  _| __| | '_ \ / _` |  / _` | '__/ _` | __| | '_ \ / _` |
% | (_| | |  | | | | |_| | | | | (_| | | (_| | | | (_| | |_| | | | | (_| |
%  \__,_|_|  |_|_|  \__|_|_| |_|\__, |  \__, |_|  \__,_|\__|_|_| |_|\__, |
%                                __/ |   __/ |                       __/ |
%                               |___/   |___/                       |___/ 
%  _                _                                   _                 
% | |              | |                                 | |                
% | |__   __ _  ___| | ____ _ _ __ ___  _   _ _ __   __| |                
% | '_ \ / _` |/ __| |/ / _` | '__/ _ \| | | | '_ \ / _` |                
% | |_) | (_| | (__|   < (_| | | | (_) | |_| | | | | (_| |                
% |_.__/ \__,_|\___|_|\_\__, |_|  \___/ \__,_|_| |_|\__,_|                
%                        __/ |                                            
%                       |___/ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%BMC hackup of Grating_RF_Mapper for use as drifting grating background for
%a modified delayed saccade task
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%right now it takes arguments for touch which give the updated mous info. i
%want to dismantle all of that (& maybe give it eye input instead?)
%%%%%%%%%%%%%%%%%%
%i want to add parameters to modulate the contrast depth in pixel space
%right now it seems to be an issue. need to change DC of sine & make
%modulation about that midgray value


classdef Drifting_Grating_Background < mladapter
    properties
        Position                % [x,y] in degrees
        Radius                  % aperture radius in degrees
        Orientation = 45;       % degrees
        SpatialFrequency = 1;   % cycles per deg
        TemporalFrequency = 1;  % cycles per sec
        SpatialFrequencyStep = 0.2;
        TemporalFrequencyStep = 0.2;
        %some kinda %contrast in something like %pixel strength
        SinusoidDCOffset = 0.5; %modulate about midgray
        pixelModDepth = 0.15; %modulattion amplitude about SinusoidDCOffset
    end
    properties (Access = protected)
        GridX
        GridY
        Imdata
        ScrPosition
        ScrRadius
        GraphicID
        

    end
    methods
        
        %initialize Drifting_Grating_Background obj & make the position at
        %the origin & a radius of 25 the default
        function obj = Drifting_Grating_Background(varargin)
            obj = obj@mladapter(varargin{:});
            
            obj.Position = [0 0];
            obj.Radius = 25;
        end
        
        function delete(obj)
            if ~isempty(obj.GraphicID), mgldestroygraphic(obj.GraphicID); end
        end
        
        function set.Position(obj,pos)
            if 2~=numel(pos), error('Position must be a 1-by-2 vector'); end
            pos = pos(:)';
            if ~isempty(obj.Position) && all(pos==obj.Position), return, end
            obj.Position = pos;
            obj.ScrPosition = obj.Tracker.CalFun.deg2pix(pos); %#ok<*MCSUP>
        end
        function set.Radius(obj,radius)
            if ~isscalar(radius), error('Radius must be a scalar'); end
            if radius<=0, error('Radius must be a positive number'); end
            if ~isempty(obj.Radius) && radius==obj.Radius, return, end
            obj.Radius = radius;
            
            radius = obj.Radius;
            ppd = obj.Tracker.Screen.PixelsPerDegree;
            z = (-radius*ppd:radius*ppd) / ppd;
            cz = mean(z);
            [x,y] = meshgrid(z,z);
            imdata = zeros([size(x) 4]);
            imdata(:,:,1) = (x-cz).^2 + (y-cz).^2 < radius*radius;
            obj.GridX = x;
            obj.GridY = y;
            obj.Imdata = imdata;
        end
        
        
        function fini(obj,p)
            fini@mladapter(obj,p);
            mglactivategraphic(obj.GraphicID,false);
        end
        function continue_ = analyze(obj,p)
            continue_ = analyze@mladapter(obj,p);
            obj.Success = obj.Adapter.Success;
            
            
            % display some information on the control screen
            p.dashboard(1,sprintf('Position = [%.1f %.1f], Radius = %.1f',obj.Position,obj.Radius));
            p.dashboard(2,sprintf('Orientation = %.1f',obj.Orientation));
            p.dashboard(3,sprintf('SpatialFrequency = %.1f, TemporalFrequency = %.1f',obj.SpatialFrequency,obj.TemporalFrequency));
        end
        function draw(obj,p)
            draw@mladapter(obj,p);
            if ~isempty(obj.GraphicID), mgldestroygraphic(obj.GraphicID); end
            
            orientation = mod(-obj.Orientation,360);
            cycles_per_deg = obj.SpatialFrequency;
            cycles_per_sec = obj.TemporalFrequency;
            t = p.scene_frame() * p.Screen.FrameLength / 1000;  % in seconds
            grating = obj.pixelModDepth/2*(sind(360*cycles_per_deg*(obj.GridX*cosd(orientation) + obj.GridY*sind(orientation)) - 360*cycles_per_sec*t) + 1) / 2 + obj.SinusoidDCOffset;
            obj.Imdata(:,:,2) = grating;
            obj.Imdata(:,:,3) = grating;
            obj.Imdata(:,:,4) = grating;
            
            obj.GraphicID = mgladdbitmap(obj.Imdata);
            mglsetorigin(obj.GraphicID,obj.ScrPosition);
        end
    end
end
