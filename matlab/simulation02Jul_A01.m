
function RUN = simulation02Jul_A01(dir) 
% this requires the directory where the parameter list is located (which is
% also where the data will be saved)

saving_directory = dir;
rng shuffle

%% loading parameters
%load([saving_directory,'params_',num2str(number),'.mat']); % loads the specific parameter configuration
%load('params_3.mat')

%% filename where data will be saved
filename = 'RESULTS_02Jul_A01v2.mat';

%% run simulation
FF=0.1;
epsilon=0.1;
AA=0.2679;

offs=-0.5;
tt = 0:0.002:1;
xx=horzcat(AA*tt+offs,AA*flip(tt));
yy=horzcat(tt,flip(tt));
pgon = polyshape({[-3 -3 5 5], xx}, ...
{[4 -3 -3 4], yy});
tr = triangulation(pgon);
model=createpde(1);
tnodes = tr.Points';
telements = tr.ConnectivityList';
geometryFromMesh(model,tnodes,telements);
meshsize = 0.1;
generateMesh(model,'Hmax', meshsize);
specifyCoefficients(model,'m',0,'d',0,'c',@ccoeffunction,'a',0,'f',@fcoeffunction);

applyBoundaryCondition(model,'dirichlet','Edge',5,'u',1);

applyBoundaryCondition(model,'neumann','edge',[1,3,4,6,8],'q',0,'g',0);
applyBoundaryCondition(model,'neumann','edge',7,'q',@fluxcond2,'g',0);
applyBoundaryCondition(model,'neumann','edge',2,'q',@fluxcond5,'g',epsilon); % downstream

initfun = @(locations) (1+locations.x*0);
setInitialConditions(model,initfun);
results=solvepde(model);
u = results.NodalSolution;

save([saving_directory,filename],...
'meshsize','model','results','u','xx','yy');

function cmatrix = ccoeffunction(region,state)
    FF = 0.1;
    cmatrix = FF*state.u(1,:).^3;


function fluxbc2 = fluxcond2(region,state)
    AA = 0.267;
    Lprimeminus1=@(y) (AA^(-1));
    fluxbc2 = -Lprimeminus1(region.y).*(state.u(1,:).^2)/(sqrt(1+Lprimeminus1(region.y).^2)).*heaviside(AA-region.x);


function fluxbc5 = fluxcond5(region,state)
    fluxbc5 = (state.u(1,:).^2);



function fmatrix = fcoeffunction(region,state)
    fmatrix = -3*(state.u(1,:).^2).*state.ux(1,:);
