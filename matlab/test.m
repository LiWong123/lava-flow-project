close all force;
clearvars;

domain = Domain();
pde = FluidPDE();
pde.setVerbosity(true);
pde.setFF(0.1);
pde.setEpsilon(1e-7);

xDomain = [-3 10];
yDomain = [-3 3];
domain.setDomain(xDomain,yDomain);
domain.setMeshSize(0.1);

xVertices = [0 -1];
yVertices = [-1 1];

domain.addFlatEdgeObstacle(xVertices, yVertices);

domain.setModel();
domain.showGeometry();

%% ----------------------------------------------------------



pde.specifyPDE(domain);
pde.applyDefaultBCs();
pde.model.SolverOptions.ResidualTolerance = 2.22e-2;

contours = 20;
pde.solvePDE();
pde.plotSolution(contours);


%% -------------------------------------------------

solutionCalculator = SolutionCalculator(pde);

solutionCalculator.plotBoundarySolution();

[hMax, coord] = solutionCalculator.getMaxHeight();
fprintf('max fluid height of %.4f, at (%.3f, %.3f)', hMax, coord(1), coord(2));

force = solutionCalculator.calculateForce()
magnitude = solutionCalculator.getMagnitude(force)


