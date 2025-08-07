close all force;
clearvars;

domain = Domain();
pde = FluidPDE();
pde.setFF(0.1);
pde.setEpsilon(0.001)

xDomain = [-3 5];
yDomain = [-3 4];

domain.setMeshSize(0.1);

xVertices = [-0.232, -0.5];
yVertices = [0.5, -0.5];

domain.setDomain(xDomain,yDomain);
domain.addObstacleFromEdge(xVertices, yVertices, 0.5);
domain.setModel();
domain.showGeometry();

pde.specifyPDE(domain);
pde.applyDefaultBCs();

contours = linspace(0.2,3,20);
pde.solveIteratively();
pde.plotSolution(contours);


