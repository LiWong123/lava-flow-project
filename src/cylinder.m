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

% create PDE: dh^3/dx = F[d/dx(h^3 dh/dx) + d/dy(h^3 dh/dy)]
pde.specifyPDE();

% source of h=1 at x=a, steady flow far from obstacle -> h=1 on y=c, y=d
% free flux condition at x=b

applyBoundaryCondition(pde.model,'dirichlet','Edge',[1,2,3,4],'u',1);
applyBoundaryCondition(pde.model,'neumann','edge',5,'q',@fluxcond2,'g',pde.epsilon);
%applyBoundaryCondition(pde.model,'neumann','edge',1,'q',0,'g',0);


% solve and plot answer
pde.solvePDE();
pde.plotSolution(contours);


% function for boundary condition at obstacle
function fluxbc2 = fluxcond2(region,state)
x = region.x;
fluxbc2 = x*(state.u(1,:).^2);
end