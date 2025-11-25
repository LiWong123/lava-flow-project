classdef Shapes

    properties
        
        meshSize = 0.1;
        verbosity = false;
        tolerance = 5e-4;
        showSolution = false;
        pde;

    end

    methods

        function obj = Shapes(model)

            obj.pde = FluidPDE(model);

        end
            
        function [absForce, force, height] = evaluateShape(obj, x0, n, boundaryFunc, boundaryType)
    
            domain = Domain();
            obj.pde.setVerbosity(obj.verbosity);

            if ~obj.verbosity
                warning('off', 'all');
            end
            
            xMin = -x0-2;
            if n == 0
    		    xEdge = [-x0 -x0 0];
                yEdge = boundaryFunc(1, x0, n);
	        else
            	xEdge = -x0:0.01:0;
                yEdge = arrayfun(@(x) boundaryFunc(x, x0, n), xEdge);
            end  
            

            xDomain = [xMin 5];
            yDomain = [-3 3];
            domain.setDomain(xDomain,yDomain);
            domain.setMeshSize(obj.meshSize);
            
            boundaryType(domain, xEdge, yEdge);
            domain.setModel();
            % if obj.showSolution
            %     domain.showGeometry();
            % end    

            obj.pde.specifyPDE(domain);
            obj.pde.model.SolverOptions.ResidualTolerance = obj.tolerance;
            try
                obj.pde.solvePDE();
            catch ME
                fprintf("error with parameters B=%g, aspRatio=%g, n=%g, x0=%g\n", obj.pde.fluidModel.BB, obj.pde.fluidModel.aspectRatio, n, x0);
                rethrow(ME)
            end
            
            if obj.showSolution
                obj.pde.plotSolution();
            end

            solutionCalculator = SolutionCalculator(obj.pde);
            force = solutionCalculator.calculateForce();
            absForce = solutionCalculator.getMagnitude(force);
            height = solutionCalculator.getMaxHeight();

        end
        


    end

    methods (Static)

        function y = powerBoundary(x, x0, n)
            if n == 0
                y = [0 1 1];
            else
                y = ((x+x0)/x0)^n;
            end
        end


        function y = powerBoundary2(x, x0, n)
            if n == 0
                y = [-1 1 1];
            else
                y = 2*((x+x0)/x0)^n - 1;
            end
        end

        function y = ellipseBoundary(x, x0, n)
            y = (1-(-x/x0)^n)^(1/n);
        end

        function y = ellipseBoundary2(x, x0, n)
            y = 2*(1-(-x/x0)^n)^(1/n)-1;
        end

    end

end