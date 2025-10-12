classdef BinghamModel < handle

    properties (Access = public)
        
        BB = 0;   % bingham constant
        aspectRatio = 0.1; % aspect ratio

    end

    methods (Access = public)
        
        function setBinghamConstant(obj, BB)
            obj.BB = BB;
        end

        function setAspectRatio(obj, ratio)
            obj.aspectRatio = ratio; 
        end

        function elevation = getElevation(obj, x)
            elevation = -x./obj.aspectRatio;
        end

        function y = Y1(obj, region, state)
            BB = obj.BB;
            FF = obj.aspectRatio;
            y = max(1e-7,state.u(1,:)-obj.getElevation(region.x)-BB./sqrt(1e-7+(FF*state.ux(1,:)).^2+(FF*state.uy(1,:)).^2));
        end


        function c = cCoefFunc(obj)
            c = @(region, state) 0.5*obj.Y1(region,state).^2.*(3*state.u(1,:)-3*obj.getElevation(region.x)-obj.Y1(region,state));
        end

        function f = fCoefFunc(obj)
            f = 0;
        end

        function farFieldBC = farFieldCond(obj)
            farFieldBC = @(region, state) 1 + obj.getElevation(region.x);
        end

        function noFluxBC = noFluxCond(obj)
            noFluxBC = 0;
        end

        function initialGuess = initfunc(obj)
            initialGuess = @(locations) 1 + obj.getElevation(locations.x);
        end

        function setDefaultSolverOptions(obj, model)
            model.SolverOptions.MinStep=0;
            model.SolverOptions.MaxIterations=350;
            model.SolverOptions.ResidualTolerance = 5e-4;
            model.SolverOptions.RelativeTolerance = 5.0000e-04;
        end

        function heights = getFluidHeightAt(obj, results, xx, yy)
            heights = interpolateSolution(results,xx,yy) - obj.getElevation(xx);
        end

    end
    

end