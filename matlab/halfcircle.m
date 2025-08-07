close all force;
clearvars;

domain = Domain();
pde = FluidPDE();
pde.setFF(0.1); % set the F value
pde.setEpsilon(0.01)

xDomain = [-2 7]; % solve for a<x<b
yDomain = [-5 5]; % solve for c<y<d
domain.setDomain(xDomain,yDomain);
domain.setMeshSize(0.1); % set resolution of solver

% set obstacle location
arr1 = pi/2:0.01:3*pi/2;
xcircle = cos(arr1);
ycircle = sin(arr1);

domain.addFlatEdgeObstacle(xcircle, ycircle);
domain.setModel();
domain.showGeometry();


% create PDE: dh^3/dx = F[d/dx(h^3 dh/dx) + d/dy(h^3 dh/dy)]
pde.specifyPDE(domain);
pde.applyDefaultBCs();

pde.model.SolverOptions.MinStep = 0;
% pde.model.SolverOptions.MaxIterations = 100;
% pde.model.SolverOptions.ResidualTolerance = 1e-4;

% solve and plot answer
contours = linspace(0.2,3,20); % min, max contour lines, number of contour lines
%pde.solveIteratively();
pde.solvePDE()
pde.plotSolution(contours);