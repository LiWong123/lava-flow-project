close all force;
clearvars;

domain = Domain();
pde = FluidPDE();
pde.setVerbosity(true); % enables warnings/solvepde statistics
pde.setFF(0.1); % set the F value
pde.setEpsilon(1e-7); % set epsilon value

xDomain = [-3 10]; % solve for a<x<b
yDomain = [-3 3]; % solve for c<y<d
domain.setDomain(xDomain,yDomain);
domain.setMeshSize(0.1); % set resolution of solver

% set obstacle location via the vertices of the obstacle. ensure the vertices are listed either clockwise or counterclockwise 
% limitations: the obstacle boundary must not have dy/dx = 0 except possibly at ymin/ymax
xVertices = [0 -2 0];
yVertices = [-1 0 1]; % yVertices should be increasing

% 3 options to set the obstacle
% 1. domain.addObstacle(xVertices, yVertices): if you want to specify all the vertices of the obstacle
% 2. domain.addFlatEdgeObstacle(xVertices, yVertices): specify only the upstream boundary + ensure that the downstream boundary is parallel to sources
% 3. domain.addObstacleFromEdge(xVertices, yVertices, thickness): specify only the upstream boundary + ensure that the downstream boundary is parallel to the upstream boundary
domain.addFlatEdgeObstacle(xVertices, yVertices);

domain.setModel();
domain.showGeometry();

%% ----------------------------------------------------------


% create PDE: dh^3/dx = F[d/dx(h^3 dh/dx) + d/dy(h^3 dh/dy)]
pde.specifyPDE(domain);
% code attempts to set dh/dn=epsilon boundary condition by default. 
% if addObstacle was used, the edge is the one closest to (0,0). 
% if another option was used, the edge is the extracted from the x/y Vertices 
pde.applyDefaultBCs();

% % if boundary conditions incorrect, set these manually
% applyBoundaryCondition(obj.model,'dirichlet','Edge',EdgeList,'u',1);
% applyBoundaryCondition(obj.model, 'neumann', 'Edge', EdgeList, 'q',0, 'g', 0);


% % optional: set these if convergence issues, current values show defaults
% pde.model.SolverOptions.MinStep = 0;
% pde.model.SolverOptions.MaxIterations = 50;
% pde.model.SolverOptions.ResidualTolerance = 1e-4;
pde.model.SolverOptions.ResidualTolerance = 5.7582e-4;


% solve and plot answer
contours = linspace(0.2,3,20); % min, max contour lines, number of contour lines
% contours = 20 % alternatively simply specify the number of contour lines
pde.solvePDE();
pde.plotSolution(contours);


%% -------------------------------------------------
% to calculate the force / graph h values
solutionCalculator = SolutionCalculator(pde);
% if you did NOT use either domain.addFlatEdgeObstacle or domain.addObstacleFromEdge, you need to specify the upstream boundary as such:
% solutionCalculator.setBoundaryEdge(xVertices, yVertices);

% use this function to get the h value at any point:
% solutionCalculator.getH(-1.5, 1.5);

% plots the height of fluid for the y values on the upstream boundary
solutionCalculator.plotBoundarySolution();

% get the maximum height of fluid along the wall, and the x,y coord where this occurs
[hMax, coord] = solutionCalculator.getMaxHeight();
fprintf('max fluid height of %.4f, at (%.3f, %.3f)', hMax, coord(1), coord(2));

% calculates the force via \int h^2 n ds on the boundary
force = solutionCalculator.calculateForce()
magnitude = solutionCalculator.getMagnitude(force)


