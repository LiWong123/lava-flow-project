close all force;
clearvars;

domain = Domain();
pde = FluidPDE();
pde.setFF(0.1);
pde.setEpsilon(0.01)

xDomain = [-2 7];
yDomain = [-5 5];
domain.setDomain(xDomain,yDomain);
domain.setMeshSize(0.1);

arr1 = pi/2:0.01:3*pi/2;
xcircle = cos(arr1);
ycircle = sin(arr1);

domain.addFlatEdgeObstacle(xcircle, ycircle);
domain.setModel();
domain.showGeometry();


pde.specifyPDE(domain);
pde.applyDefaultBCs();

pde.model.SolverOptions.MinStep = 0;
pde.model.SolverOptions.ResidualTolerance = 1e-4;

contours = linspace(0.2,3,20);
pde.solvePDE()
pde.plotSolution(contours);