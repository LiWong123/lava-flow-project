close all force;
clearvars;

domain = Domain();
pde = FluidPDE();
pde.setVerbosity(true);
pde.setFF(0.1);


xDomain = [-3 10];
yDomain = [-3 3];
domain.setDomain(xDomain,yDomain);
domain.setMeshSize(0.1);

xVertices = -1:0.01:0;
yVertices = arrayfun(@(x) boundary(x), xVertices);

domain.addSymmetricObstacle(xVertices, yVertices);
domain.setModel();
domain.showGeometry();

%% ----------------------------------------------------------

pde.specifyPDE(domain);
pde.model.SolverOptions.ResidualTolerance = 1e-3;
pde.solvePDE();
pde.plotSolution(20);


%% -------------------------------------------------

solutionCalculator = SolutionCalculator(pde);

[hMax, coord] = solutionCalculator.getMaxHeight();
fprintf('max fluid height of %.4f, at (%.3f, %.3f)', hMax, coord(1), coord(2));

force = solutionCalculator.calculateForce()
magnitude = solutionCalculator.getMagnitude(force)

%% -------------------------------------

function y = boundary(x)
    y = (x+1)^5;
end


