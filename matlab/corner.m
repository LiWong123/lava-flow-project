close all force;
clearvars;

domain = Domain();
pde = FluidPDE();
pde.setFF(1); % set the F value
pde.setEpsilon(0.0001);
domain.setMeshSize(0.1);

domain.domain = polyshape({[0 -10 -10 10 10]}, ...
{[0 0 -10 -10 10]});
domain.setModel();
domain.showGeometry();


% create PDE: dh^3/dx = F[d/dx(h^3 dh/dx) + d/dy(h^3 dh/dy)]
pde.specifyPDE(domain);
applyBoundaryCondition(pde.model,'dirichlet','Edge',4,'u',1);
applyBoundaryCondition(pde.model,'neumann','Edge',[1,3,5],'q',0,'g',0);
applyBoundaryCondition(pde.model, 'neumann', 'Edge', 2, 'q', pde.noFluxCond(), 'g', pde.epsilon);

pde.model.SolverOptions.MinStep = 1e-5;
pde.model.SolverOptions.MaxIterations = 25;

% solve and plot answer
contours = [0.01, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9];
pde.solvePDE();
pde.plotSolution(contours);