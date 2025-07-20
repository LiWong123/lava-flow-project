
global FF;
FF=1;
global epsilon;
epsilon=0.00001;

pgon = polyshape({[0 -10 -10 10 10]}, ...
{[0 0 -10 -10 10]});

tr = triangulation(pgon);

model=createpde(1);

tnodes = tr.Points';
telements = tr.ConnectivityList';

geometryFromMesh(model,tnodes,telements);

generateMesh(model,'Hmax',0.1);
% figure;
% 	


%input geometry
%geometryFromEdges(model,gd);
figure(1); pdegplot(model,'EdgeLabels','on')

% 

specifyCoefficients(model,'m',0,'d',0,'c',@ccoeffunction,'a',0,'f',@fcoeffunction);

applyBoundaryCondition(model,'dirichlet','Edge',[3,4,5],'u',1);
applyBoundaryCondition(model,'neumann','edge',2,'q',@fluxcond5,'g',epsilon); % downstream
applyBoundaryCondition(model,'neumann','edge',1,'q',0,'g',0);


initfun = @(locations) (1+locations.x*0);
%generateMesh(model,'Hmax',0.2,'Jiggle','on');
setInitialConditions(model,initfun);
%tlist=[0:2];
results=solvepde(model);

u = results.NodalSolution;

% for j=1:1
%     FF
%     FF=max(0.05,FF/1.2);
%     setInitialConditions(model,results);
%     
%     results=solvepde(model);
% 
% end

levels = [0.01 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9];
figure(2);
pdegplot(model,'EdgeLabels','off');
hold on;
pdeplot(model,'xydata',u(:,1),'contour','on',...
'colorbar', 'on',...
'levels',levels,'mesh','off','xystyle','off');

function cmatrix = ccoeffunction(region,state)
global FF;
cmatrix = FF*state.u(1,:).^3;
end

function fluxbc2 = fluxcond2(region,state)
global AA;
Lprimeminus1=@(y) (AA^(-1));
fluxbc2 = -Lprimeminus1(region.y).*(state.u(1,:).^2)/(sqrt(1+Lprimeminus1(region.y).^2)).*heaviside(AA-region.x);
end

function fluxbc5 = fluxcond5(region,state)
fluxbc5 = (state.u(1,:).^2);
end


function fmatrix = fcoeffunction(region,state)
fmatrix = -3*(state.u(1,:).^2).*state.ux(1,:);
end


