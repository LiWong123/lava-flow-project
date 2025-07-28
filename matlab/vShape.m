close all force;
clearvars;

domain = Domain();
pde = FluidPDE();
pde.setFF(0.1); % set the F value
pde.setEpsilon(0.1);

xDomain = [-5 5]; % solve for a<x<b
yDomain = [-5 5]; % solve for c<y<d
domain.setDomain(xDomain,yDomain);
domain.setMeshSize(0.1); % set resolution of solver

% set obstacle location
xVertices = [-3 -4 -4];
yVertices = [-1 0 1];

domain.addObstacleFromEdge(xVertices, yVertices, 0.5);
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
