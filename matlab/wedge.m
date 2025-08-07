close all force;
clearvars;

domain = Domain();
pde = FluidPDE();
pde.setFF(0.1); % set the F value
pde.setEpsilon(0.001)


xDomain = [-3 5]; % solve for a<x<b
yDomain = [-3 4]; % solve for c<y<d

domain.setMeshSize(0.1); % set resolution of solver

xVertices = [-0.232, -0.5];
yVertices = [0.5, -0.5];

domain.setDomain(xDomain,yDomain);
domain.addObstacleFromEdge(xVertices, yVertices, 0.5);
domain.setModel();
domain.showGeometry();

% create PDE: dh^3/dx = F[d/dx(h^3 dh/dx) + d/dy(h^3 dh/dy)]
pde.specifyPDE(domain);
pde.applyDefaultBCs();


% solve and plot answer
contours = linspace(0.2,3,20); % min, max contour lines, number of contour lines
%pde.solvePDE();
pde.solveIteratively();
pde.plotSolution(contours);


