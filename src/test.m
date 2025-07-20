pde = FluidPDE()

arr1 = 0:0.01:2*pi;
xcircle = cos(arr1);
ycircle = sin(arr1);

pgon = polyshape({[-5 5 5 -5], xcircle}, ...
                    {[5 5 -5 -5], ycircle});

meshSize = 0.1;
pde.setModel(pgon, meshSize)
pde.showGeometry()

applyBoundaryCondition(pde.model,'dirichlet','Edge',[2,3,4],'u',1);
applyBoundaryCondition(pde.model,'neumann','edge',5,'q',@fluxcond5,'g',epsilon); % downstream
applyBoundaryCondition(pde.model,'neumann','edge',1,'q',0,'g',0);