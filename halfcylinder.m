
global FF;
FF=1;
global epsilon;
epsilon=0.00001;

arr1 = 0.5*pi:0.01:1.5*pi;
xleftcircle = cos(arr1);
yleftcircle = sin(arr1);

pgon = polyshape({[-5 5 5 -5], xleftcircle}, ...
                    {[5 5 -5 -5], yleftcircle});

tr = triangulation(pgon);

model=createpde(1);

tnodes = tr.Points';
telements = tr.ConnectivityList';

geometryFromMesh(model,tnodes,telements);

generateMesh(model,'Hmax',0.1);
figure(1); pdegplot(model,'EdgeLabels','on')

specifyCoefficients(model,'m',0,'d',0,'c',@ccoeffunction,'a',0,'f',@fcoeffunction);

applyBoundaryCondition(model,'dirichlet','Edge',[1,3,4],'u',1);
applyBoundaryCondition(model,'neumann','edge',5,'q',@fluxcond5,'g',epsilon); % downstream
applyBoundaryCondition(model,'neumann','edge',2,'q',@fluxcond2,'g',0); % downstream
applyBoundaryCondition(model,'neumann','edge',6,'q',0,'g',0);

initfun = @(locations) (1+locations.x*0);
setInitialConditions(model,initfun);
results=solvepde(model);

u = results.NodalSolution;

levels = linspace(0, 2, 60);
figure(2);
pdegplot(model,'EdgeLabels','off');
hold on;
pdeplot(model,'xydata',u(:,1),'contour','on',...
'colorbar', 'on',...
'levels',levels,'mesh','off','xystyle','off');

interpolateSolution(results, -1.1, 0)

%figure(3); hold on; h=interpolateSolution(results,AA*tt+offs,tt); plot(tt,h);

global AA;
AA = 1;

function cmatrix = ccoeffunction(region,state)
global FF;
cmatrix = FF*state.u(1,:).^3;
end

% function fluxbc2 = fluxcond2(region,state)
% fluxbc2 = -1.*(state.u(1,:).^2);
% end

function fluxbc2 = fluxcond2(region,state)
x = region.x;
fluxbc2 = -region.nx*(state.u(1,:).^2);
end

function fluxbc5 = fluxcond5(region,state)
fluxbc5 = (state.u(1,:).^2);
end


function fmatrix = fcoeffunction(region,state)
fmatrix = -3*(state.u(1,:).^2).*state.ux(1,:);
end
