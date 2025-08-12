close all force;
clearvars;

domain = Domain();
pde = FluidPDE();
pde.setVerbosity(true);
pde.setFF(0.1);
pde.setEpsilon(1e-7);

xDomain = [-3 10];
yDomain = [-3 3];
domain.setDomain(xDomain,yDomain);
domain.setMeshSize(0.1);

xEdge = [0 -1];
yEdge = [1 0];

domain.addSymmetricObstacle(xEdge, yEdge);

domain.setModel();
domain.showGeometry();

%% ----------------------------------------------------------




%% -------------------------------------------------




