classdef Powers

    methods (Static)
            
        function [force, absForce, height] = evaluate(x0, n, F)
    
            domain = Domain();
            pde = FluidPDE();
            pde.setVerbosity(true);
            pde.setFF(F);
            
            xMin = -x0-2;
            if n == 0
    		    xEdge = [-x0 -x0 0];
		        yEdge = [0 1 1];
	        else
            	xEdge = -x0:0.01:0;
            	yEdge = arrayfun(@(x) Powers.boundary(x, x0, n), xEdge);
            end 
        
            xDomain = [xMin 10];
            yDomain = [-3 3];
            domain.setDomain(xDomain,yDomain);
            domain.setMeshSize(0.1);
            
            domain.addSymmetricObstacle(xEdge, yEdge);
            domain.setModel();
            domain.showGeometry();

            pde.specifyPDE(domain);
            pde.model.SolverOptions.ResidualTolerance = 5e-4;
            pde.solvePDE();
            %pde.plotSolution();
        
            solutionCalculator = SolutionCalculator(pde);
            force = solutionCalculator.calculateForce();
            absForce = solutionCalculator.getMagnitude(force);
            height = solutionCalculator.getMaxHeight();
    
        end
        
        function y = boundary(x, x0, n)
            y = ((x+x0)/x0)^n;
        end

    end

end