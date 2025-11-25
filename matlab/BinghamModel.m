classdef BinghamModel < handle

    properties (Access = public)
        
        BB;   % bingham constant
        aspectRatio; % aspect ratio

    end

    methods (Access = public)
        
        function setBinghamConstant(obj, BB)
            obj.BB = BB;
        end

        function setAspectRatio(obj, ratio)
            obj.aspectRatio = ratio; 
        end

        function elevation = getElevation(obj, x, y)
            elevation = -x./obj.aspectRatio;
        end

        function y = Y1(obj, region, state)
            BB = obj.BB;
            FF = obj.aspectRatio;
            y = max(1e-7,state.u(1,:)-obj.getElevation(region.x, region.y)-BB./sqrt(1e-7+(FF*state.ux(1,:)).^2+(FF*state.uy(1,:)).^2));
        end


        function c = cCoefFunc(obj)
            c = @(region, state) 0.5*obj.Y1(region,state).^2.*(3*state.u(1,:)-3*obj.getElevation(region.x, region.y)-obj.Y1(region,state));
        end

        function f = fCoefFunc(obj)
            f = 0;
        end

        function farFieldBC = farFieldCond(obj)
            farFieldBC = @(region, state) 1 + obj.getElevation(region.x, region.y);
        end

        function noFluxBC = noFluxCond(obj)
            noFluxBC = 0;
        end

        function initialGuess = initfunc(obj)
            initialGuess = @(locations) 1 + obj.getElevation(locations.x, locations.y);
        end

        function setDefaultSolverOptions(obj, model)
            model.SolverOptions.MinStep=0;
            model.SolverOptions.MaxIterations=350;
            model.SolverOptions.ResidualTolerance = 5e-4;
            model.SolverOptions.RelativeTolerance = 5.0000e-04;
        end

        function heights = getFluidHeightAt(obj, results, xx, yy)
            interp = interpolateSolution(results, xx, yy);
            interp = reshape(interp, size(xx));
            heights = interp - obj.getElevation(xx, yy);
        end

        function solveIteratively(obj, fluidPDE)

            finalBB = obj.BB;
            curBB = 0.1;
            
            initfunc = obj.initfunc();

            for i = 1:4
                obj.setBinghamConstant(curBB);
                fluidPDE.specifyPDE();
                setInitialConditions(fluidPDE.model, initfunc);
                results = solvepde(fluidPDE.model);
                initfunc = @(locations) obj.initInterp(results, locations);
                curBB = curBB + 0.1;
            end
            fluidPDE.results = results;

        end

        function values = initInterp(obj, results, locations) 
            values = interpolateSolution(results, locations.x, locations.y);
        end

    end
    

end