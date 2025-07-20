
global FF;
FF=1;
global epsilon;
epsilon=0.00001;

arr1 = 0.5*pi+0.1:0.001:1.5*pi-0.1;
xleftcircle = cos(arr1);
yleftcircle = sin(arr1);
arr2 = -0.5*pi+0.1:0.001:0.5*pi-0.1;
xrightcircle = cos(arr2);
yrightcircle = sin(arr2);
xcircle = horzcat(xleftcircle, xrightcircle);
ycircle = horzcat(yleftcircle, yrightcircle);

pgon = polyshape({[-5 5 5 -5], xcircle}, ...
                    {[5 5 -5 -5], ycircle});

tr = triangulation(pgon);

model=createpde(1);

tnodes = tr.Points';
telements = tr.ConnectivityList';

geometryFromMesh(model,tnodes,telements);

generateMesh(model,'Hmax',0.05);
figure(1); pdegplot(model,'EdgeLabels','on')

% specifyCoefficients(model,'m',0,'d',0,'c',@ccoeffunction,'a',0,'f',@fcoeffunction);
% 
% applyBoundaryCondition(model,'dirichlet','Edge',[1,5,6],'u',1);
% applyBoundaryCondition(model,'neumann','edge',[2,4,8],'q',0,'g',0);
% applyBoundaryCondition(model,'neumann','edge',3,'q',@fluxcond,'g',0.1); % upstream
% applyBoundaryCondition(model,'neumann','edge',7,'q',@fluxcond,'g',0.1); % downstream
% 
% 
% initfun = @(locations) (1+locations.x*0);
% setInitialConditions(model,initfun);
% results=solvepde(model);
% 
% u = results.NodalSolution;
% 
% levels = linspace(0, 1.5, 60);
% figure(2);
% pdegplot(model,'EdgeLabels','off');
% hold on;
% pdeplot(model,'xydata',u(:,1),'contour','on',...
% 'colorbar', 'on',...
% 'levels',levels,'mesh','off','xystyle','off');
% 
% %figure(3); hold on; h=interpolateSolution(results,AA*tt+offs,tt); plot(tt,h);
% 
% function cmatrix = ccoeffunction(region,state)
% global FF;
% cmatrix = FF*state.u(1,:).^3;
% end
% 
% function fluxbc = fluxcond(region,state)
% x = region.x;
% fluxbc = (state.u(1,:).^2);
% end
% 
% function fmatrix = fcoeffunction(region,state)
% fmatrix = -3*(state.u(1,:).^2).*state.ux(1,:);
% end
% 
% 
