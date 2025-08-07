close all force;
clearvars;

domain = Domain();
pde = FluidPDE();
pde.setFF(0.1);
pde.setEpsilon(0.001);

xDomain = [-5 5];
yDomain = [-5 5];
domain.setDomain(xDomain,yDomain);
domain.setMeshSize(0.1);

xVertices = [-3 -4 -3];
yVertices = [-1 0 1];

domain.addFlatEdgeObstacle(xVertices, yVertices);
domain.setModel();
domain.showGeometry();

pde.specifyPDE(domain);
pde.applyDefaultBCs();

pde.model.SolverOptions.MinStep = 1e-7;
pde.model.SolverOptions.MaxIterations = 50;

contours = linspace(0.2,3,20);
pde.solvePDE();
pde.plotSolution();