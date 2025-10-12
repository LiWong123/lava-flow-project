classdef Shapes

    properties (Constant)
        
        meshSize = 0.03;
        verbosity = true;
        tolerance = 3e-4;
        showSolution = true;

    end

    methods (Static)
            
        function [absForce, force, height] = evaluateShape(x0, n, F, boundaryFunc, boundaryType)
    
            domain = Domain();
            pde = FluidPDE();
            pde.setVerbosity(Shapes.verbosity);
            pde.setFF(F);

            if ~Shapes.verbosity
                warning('off', 'all');
            end
            
            xMin = -x0-0.5;
            if n == 0
    		    xEdge = [-x0 -x0 0];
                yEdge = boundaryFunc(1, x0, n);
	        else
            	xEdge = -x0:0.01:0;
                yEdge = arrayfun(@(x) boundaryFunc(x, x0, n), xEdge);
            end  
            

            xDomain = [xMin 3];
            yDomain = [-3 3];
            domain.setDomain(xDomain,yDomain);
            domain.setMeshSize(Shapes.meshSize);
            
            boundaryType(domain, xEdge, yEdge);
            domain.setModel();
            if Shapes.showSolution
                domain.showGeometry();
            end    

            pde.specifyPDE(domain);
            pde.model.SolverOptions.ResidualTolerance = Shapes.tolerance;
            try
                pde.solvePDE();
            catch ME
                fprintf("error with parameters F=%g, n=%g, x0=%g\n", F, n, x0);
                rethrow(ME)
            end
            
            if Shapes.showSolution
                pde.plotSolution();
            end

            solutionCalculator = SolutionCalculator(pde);
            force = solutionCalculator.calculateForce();
            absForce = solutionCalculator.getMagnitude(force);
            height = solutionCalculator.getMaxHeight();

        end
        
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