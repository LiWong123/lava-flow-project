close all force;
clearvars;

domain = Domain();
pde = FluidPDE();
pde.setFF(0.1); % set the F value
pde.setEpsilon(0.0001)

xDomain = [-2 7]; % solve for a<x<b
yDomain = [-5 5]; % solve for c<y<d
domain.setDomain(xDomain,yDomain);
domain.setMeshSize(0.1); % set resolution of solver

% set obstacle location
arr1 = 0:0.01:2*pi;
xcircle = cos(arr1);
ycircle = sin(arr1);

domain.addObstacle(xcircle, ycircle);
domain.setModel();
domain.showGeometry();


% create PDE: dh^3/dx = F[d/dx(h^3 dh/dx) + d/dy(h^3 dh/dy)]
pde.specifyPDE(domain);
pde.applyDefaultBCs();

pde.model.SolverOptions.MinStep = 1e-5;
pde.model.SolverOptions.MaxIterations = 25;

% solve and plot answer
contours = linspace(0.2,3,20); % min, max contour lines, number of contour lines
pde.solvePDE();
pde.plotSolution(contours);