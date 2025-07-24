
global FF;
FF=0.1;
global epsilon;
epsilon=0.01;
global AA;
AA=0.2679; % cot psi

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

generateMesh(model,'Hmax',0.1);
% figure;
% 	


%input geometry
%geometryFromEdges(model,gd);
figure(1); pdegplot(model,'EdgeLabels','on')

%% 

specifyCoefficients(model,'m',0,'d',0,'c',@ccoeffunction,'a',0,'f',@fcoeffunction);

applyBoundaryCondition(model,'dirichlet','Edge',[5,6,4,1],'u',1);

applyBoundaryCondition(model,'neumann','edge',[3,8],'q',0,'g',0);
applyBoundaryCondition(model,'neumann','edge',7,'q',@fluxcond2,'g',0);
applyBoundaryCondition(model,'neumann','edge',2,'q',@fluxcond5,'g',epsilon); % downstream


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

figure(2);
pdeplot(model,'xydata',u(:,1),'contour','on',...
'colorbar', 'on',...
'levels',linspace(0.2,3,20),'mesh','off','xystyle','off');
hold on;
p = pdegplot(model,'EdgeLabels','off');
set(p, 'Color', 'k', 'LineWidth', 1.5);

%figure(3); hold on; h=interpolateSolution(results,AA*tt+offs,tt); plot(tt,h);

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
fluxbc5 = 0.966*(state.u(1,:).^2);
end


function fmatrix = fcoeffunction(region,state)
fmatrix = -3*(state.u(1,:).^2).*state.ux(1,:);
end


