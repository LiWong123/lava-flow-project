% define parameters
global FF; FF=0.2; % aspect ratio
global B; B=0.2; % Bingham number

Hinf=fzero(@(h) (h-B).^2.*(h+B/2)-1,[max(1,B),1+B]); % farfield thickness

global E;
E=@(x,y) -x/FF; % topography (just a plane)

fluidModel = BinghamModel();
fluidModel.setBinghamConstant(0.2); % set the F value
fluidModel.setAspectRatio(0.2);

% create the domain
LL=5;
R1 = [3,4,-LL,-LL,LL,LL,-LL,LL,LL,-LL]'; % outer rectangle
R2 = [3,4,-1,-1,1,1,-1,1,1,-1]'; % square obstruction
geom = [R1,R2];

% Names for the two geometric objects
ns = (char('R1','R2'))';
% Set formula
sf = 'R1-R2';
% Create geometry
gd = decsg(geom,sf,ns);

% create model, change some options
model=createpde(1);
model.SolverOptions.ReportStatistics = 'on';
model.SolverOptions.MinStep=0;
model.SolverOptions.MaxIterations=350;
model.SolverOptions.ResidualTolerance = 5e-4;
model.SolverOptions.RelativeTolerance = 5.0000e-04;

% create mesh
geometryFromEdges(model,gd);
generateMesh(model,'Hmax',0.25);   

figure('Theme', 'light'); 
pdegplot(model,'EdgeLabels','on')

% boundary conditions and PDE coefficients
specifyCoefficients(model,'m',0,'d',0,'c',@ccoeffunction,'a',0,'f',0);
applyBoundaryCondition(model,'dirichlet','Edge',[1,2,4],'u',fluidModel.farFieldCond());   
%applyBoundaryCondition(model,'neumann','edge',[1,3,5,7,8],'q',0,'g',0);
%applyBoundaryCondition(model,'neumann','edge',4,'q',0,'g',0.0);
applyBoundaryCondition(model,'neumann','edge',[3,5,6,8],'q',0,'g',0);
applyBoundaryCondition(model,'neumann', 'edge', 7, 'q',0,'g',1e-6);

% initial guess
initfun = @(locations) 1+E(locations.x,locations.y);
setInitialConditions(model,initfun);

% solve the problem and measure time taken
tic
results=solvepde(model);
toc

% plot the results
dx=0.05;
x=-3:dx:5;
y=-3:dx:3;
[XX,YY]=meshgrid(x,y);
uu=interpolateSolution(results,XX,YY);
u1=reshape(uu,length(y),length(x));
h1= u1-E(XX,YY);
figure; contourf(XX,YY,h1,30); colorbar;

% boundary condition function
function bc=bfun(region,state)
global E;

bc=1+E(region.x,region.y);
end

% PDE coefficient function
function cmatrix = ccoeffunction(region,state)

global E;
global FF;
global B;
Y1=max(1e-7,state.u(1,:)-E(region.x,region.y)-B./sqrt(1e-7+(FF*state.ux(1,:)).^2+(FF*state.uy(1,:)).^2));


cmatrix=0.5*Y1.^2.*(3*state.u(1,:)-3*E(region.x,region.y)-Y1);

end



