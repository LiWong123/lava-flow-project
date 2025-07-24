close all force;
clearvars;

domain = Domain();
pde = FluidPDE();
pde.setFF(0.1); % set the F value
pde.setEpsilon(0.01)


xDomain = [-3 5]; % solve for a<x<b
yDomain = [-3 4]; % solve for c<y<d

domain.setMeshSize(0.1); % set resolution of solver

xVertices = [-0.232, -0.5];
yVertices = [1, 0];

domain.setDomain(xDomain,yDomain);
domain.addObstacleFromEdge(xVertices, yVertices, 0.5);
domain.setModel();
domain.showGeometry();

% create PDE: dh^3/dx = F[d/dx(h^3 dh/dx) + d/dy(h^3 dh/dy)]
pde.specifyPDE(domain);
% set far field condition: h=1 on boundary 
% and no flux on obstacle: q \dot n = epsilon 
pde.applyDefaultBCs();

% solve and plot answer
contours = linspace(0.2,3,20); % min, max contour lines, number of contour lines
pde.solvePDE();
pde.plotSolution(contours);


