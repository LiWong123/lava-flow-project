clearvars;

pde = FluidPDE();
pde.setFF(0.1); % set the F value
pde.setEpsilon(0.01)

contours = linspace(0.2,3,20); % min, max contour lines, number of contour lines
xDomain = [-2 7]; % solve for a<x<b
yDomain = [-5 5]; % solve for c<y<d
pde.setMeshSize(0.1); % set resolution of solver

% set obstacle location
arr1 = 0:0.01:2*pi;
xcircle = cos(arr1);
ycircle = sin(arr1);

pde.setDomain(xDomain, yDomain);
domain = pde.createObstacle(xcircle, ycircle);
pde.setModel(domain);
pde.showGeometry();