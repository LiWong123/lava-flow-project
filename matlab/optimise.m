close all force;
clearvars;

xx = linspace(-0.1, -5, 10);
forces = arrayfun(@(x) findForce(x, 1), xx);

figure('Theme', 'light');
hold on;
grid on;
plot(xx, forces);
ylabel('magnitude of force on upstream boundary');
xlabel('vertex at (x,-1) and (0,1)');

function force = findForce(xVertex, F)

    domain = Domain();
    pde = FluidPDE();
    fprintf("running x = %d\n", xVertex);
    %pde.setVerbosity(true);
    pde.setFF(F);
    
    xMin = xVertex-2;
    xEdge = [xVertex 0];
    yEdge = [-1 1];

    xDomain = [xMin 10];
    yDomain = [-3 3];
    domain.setDomain(xDomain,yDomain);
    domain.setMeshSize(0.1);
    
    domain.addFlatEdgeObstacle(xEdge, yEdge);
    domain.setModel();
    
    pde.specifyPDE(domain);
    pde.applyDefaultBCs();
    pde.model.SolverOptions.ResidualTolerance = 7e-4;
    pde.solvePDE();
    
    solutionCalculator = SolutionCalculator(pde);
    force = solutionCalculator.calculateForce();
    force = solutionCalculator.getMagnitude(force);

end

