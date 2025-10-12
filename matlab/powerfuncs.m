close all force;
clearvars;

fid = fopen("powerResults.csv", "a");
fprintf(fid, "F,n,x0,force_x,force_y,abs(force),max_height\n");

for F = [0.05, 0.1, 0.25, 0.5, 0.75, 1]
    
    for n = [0.1, 0.25, 0.5, 1, 2, 3]

        for x0 = [0.5, 1, 1.5, 2, 2.5, 3]

            fprintf("running F=%g, n=%g, x0=%g\n", F, n, x0);

            [force, absForce, height] = evaluate(x0, n, F);
            forceX = force(1);
            forceY = force(2);

            fprintf(fid, "%g,%g,%g,%g,%g,%g,%g\n",F,n,x0,forceX,forceY,absForce,height);

        end

    end

end

fclose(fid);


function [force, absForce, height] = evaluate(x0, n, F)

    domain = Domain();
    pde = FluidPDE();
    %pde.setVerbosity(true);
    pde.setFF(F);
    
    xMin = -x0-2;
    xEdge = -x0:0.01:0;
    yEdge = arrayfun(@(x) boundary(x, x0, n), xEdge);

    xDomain = [xMin 10];
    yDomain = [-3 3];
    domain.setDomain(xDomain,yDomain);
    domain.setMeshSize(0.05);
    
    domain.addSymmetricObstacle(xEdge, yEdge);
    domain.setModel();
    
    pde.specifyPDE(domain);
    pde.model.SolverOptions.ResidualTolerance = 5e-4;
    pde.solvePDE();

    solutionCalculator = SolutionCalculator(pde);
    force = solutionCalculator.calculateForce();
    absForce = solutionCalculator.getMagnitude(force);
    height = solutionCalculator.getMaxHeight();

end

function y = boundary(x, x0, n)
    y = ((x+x0)/x0)^n;
end
