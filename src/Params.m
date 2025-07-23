classdef Params < handle

    properties (Access = public)
        
        gravityConst = 9.8;
        sourceFlux;
        density;
        viscosity;
        inclineAngle;
        LL;

        steadyDepth;
        FF;
   

    end

    methods

        function setFF(obj, FF)
            obj.FF = FF;
        end
        
        function setAll(obj, varargin)
            % set the FF value if all environment parameters are known
            % use if not setting FF value directly
            
            % read and set the environment parameters
            p = inputParser;
            p.KeepUnmatched = false;
            
            addParameter(p, 'viscosity', [], @(x) isnumeric(x) && isscalar(x));
            addParameter(p, 'density', [], @(x) isnumeric(x) && isscalar(x));
            addParameter(p, 'inclineAngle', [], @(x) isnumeric(x) && isscalar(x));
            addOptional(p, 'LL', 1, @(x) isnumeric(x) && isscalar(x));
            addOptional(p, 'sourceFlux', 1, @(x) isnumeric(x) && isscalar(x));

            parse(p, varargin{:});
            args = p.Results;
            
            if isempty(args.viscosity) || isempty(args.density) || isempty(args.inclineAngle)
                error('All of mu, rho, and beta must be provided.');
            end
            
            obj.viscosity = args.viscosity;
            obj.density = args.density;
            obj.inclineAngle = args.inclineAngle;
            obj.LL = args.LL;
            obj.sourceFlux = args.sourceFlux;

            % calculate the F value and steadyDepth
            obj.steadyDepth = (3*obj.viscosity*obj.sourceFlux/(obj.density*obj.gravityConst*sin(obj.inclineAngle)))^(1/3);
            obj.FF = obj.steadyDepth/(obj.LL*tan(obj.inclineAngle));
        end


    end

end