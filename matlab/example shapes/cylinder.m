close all force;
clearvars;

domain = Domain();
pde = FluidPDE();
pde.setFF(0.1);
pde.setEpsilon(0.00001)

xDomain = [-2 7];
yDomain = [-5 5];
domain.setDomain(xDomain,yDomain);
domain.setMeshSize(0.1);

arr1 = 0:0.01:2*pi;
xcircle = cos(arr1);
ycircle = sin(arr1);

domain.addObstacle(xcircle, ycircle);
domain.setModel();
domain.showGeometry();

% create PDE: dh^3/dx = F[d/dx(h^3 dh/dx) + d/dy(h^3 dh/dy)]
pde.specifyPDE(domain);
pde.applyDefaultBCs();

pde.model.SolverOptions.MinStep = 0;
pde.model.SolverOptions.MaxIterations = 250;
pde.model.SolverOptions.ResidualTolerance = 3.5e-5;


contours = linspace(0.2,3,20); 
pde.solvePDE()
pde.plotSolution(contours);