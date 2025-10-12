classdef NewtonianModel < handle
    
    properties (Access = public)
        FF=0.1
    end

    methods (Access = public)
        
        function setFF(obj, FF)
            obj.FF = FF;
        end

        function c = cCoefFunc(obj)
            FF = obj.FF;
            c = @(region, state) FF * state.u(1,:).^3;
        end

        function f = fCoefFunc(obj)
            f = @(region, state) -3*(state.u(1,:).^2).*state.ux(1,:);
        end

        function farFieldBC = farFieldCond(obj)
            farFieldBC = 1;
        end

        function noFluxBC = noFluxCond(obj)
            noFluxBC = @(region, state) -region.nx .* (state.u(1,:).^2);
        end

        function initialGuess = initfunc(obj)
            initialGuess = @(locations) (1+locations.x*0);
        end

        function setDefaultSolverOptions(obj, model)
            model.SolverOptions.MinStep = 0;
            model.SolverOptions.MaxIterations = 50;
            model.SolverOptions.ResidualTolerance = 5e-4;
        end

        function heights = getFluidHeightAt(obj, results, xx, yy)
            heights = interpolateSolution(results,xx,yy);
        end


    end


end