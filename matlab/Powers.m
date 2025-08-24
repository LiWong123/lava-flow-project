classdef Powers

    methods (Static)
            
        function [force, absForce, height] = evaluateSymPower(x0, n, F)
    
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
            domain.setMeshSize(0.04);
            
            domain.addSymmetricObstacle(xEdge, yEdge);
            domain.setModel();
            domain.showGeometry();

            pde.specifyPDE(domain);
            pde.model.SolverOptions.ResidualTolerance = 5e-4;
            pde.solvePDE();
            pde.plotSolution();
        
            solutionCalculator = SolutionCalculator(pde);
            force = solutionCalculator.calculateForce();
            absForce = solutionCalculator.getMagnitude(force);
            height = solutionCalculator.getMaxHeight();
    
        end
        
        function y = boundary(x, x0, n)
            y = ((x+x0)/x0)^n;
        end

        function [force, absForce, height] = evaluateASymPower1(x0, n, F)
    
            domain = Domain();
            pde = FluidPDE();
            %pde.setVerbosity(true);
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
            domain.setMeshSize(0.05);
            
            domain.addFlatEdgeObstacle(xEdge, yEdge);
            domain.setModel();
            domain.showGeometry();

            pde.specifyPDE(domain);
            pde.model.SolverOptions.ResidualTolerance = 5e-4;
            pde.solvePDE();
            pde.plotSolution();
        
            solutionCalculator = SolutionCalculator(pde);
            force = solutionCalculator.calculateForce();
            absForce = solutionCalculator.getMagnitude(force);
            height = solutionCalculator.getMaxHeight();
    
        end


        function [force, absForce, height] = evaluateASymPower2(x0, n, F)
    
            domain = Domain();
            pde = FluidPDE();
            pde.setVerbosity(true);
            pde.setFF(F);
            
            xMin = -x0-2;
            if n == 0
    		    xEdge = [-x0 -x0 0];
		        yEdge = [-1 1 1];
	        else
            	xEdge = -x0:0.01:0;
            	yEdge = arrayfun(@(x) Powers.boundary2(x, x0, n), xEdge);
            end 
        
            xDomain = [xMin 10];
            yDomain = [-3 3];
            domain.setDomain(xDomain,yDomain);
            domain.setMeshSize(0.04);
            
            domain.addFlatEdgeObstacle(xEdge, yEdge);
            domain.setModel();
            domain.showGeometry();

            pde.specifyPDE(domain);
            pde.model.SolverOptions.ResidualTolerance = 5e-4;
            try
                pde.solvePDE();
            catch ME
                fprintf("error with parameters F=%g, n=%g, x0=%g\n", F, n, x0);
                rethrow(ME)
            end
            pde.plotSolution();
        
            solutionCalculator = SolutionCalculator(pde);
            force = solutionCalculator.calculateForce();
            absForce = solutionCalculator.getMagnitude(force);
            height = solutionCalculator.getMaxHeight();
    
        end

        function y = boundary2(x, x0, n)
            y = 2*((x+x0)/x0)^n - 1;
        end



    end

end