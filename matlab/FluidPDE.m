classdef FluidPDE < handle
    % class to create and solve the fluid PDE
    
    % pde parameters
    properties (Access = public)

        epsilon = 1e-7;
        verbosity = false;
        domain = NaN;
        model = NaN;
        results;
        fluidModel;
        
    end

    methods

        % constructor / setters
        function obj = FluidPDE(model)
            obj.fluidModel = model;
        end

        function setEpsilon(obj, epsilon)
            % set epsilon value
            obj.epsilon = epsilon;
        end

        function setVerbosity(obj, boolean)
            % determines whether warnings/pde output shown
            obj.verbosity = boolean;
        end


        function specifyPDE(obj, domain)
            
            % imports the model mesh from the geometry and
            % sets the equation dh^3/dx = F[d/dx(h^3 dh/dx) + d/dy(h^3 dh/dy)]

            if nargin == 2
                obj.domain = domain;
                obj.model = domain.model;
            elseif isequaln(obj.domain, NaN) || isequaln(obj.model, NaN)
                error('domain not specified');
            end

            

            specifyCoefficients(obj.model, ...
                'm', 0, ...
                'd', 0, ...
                'c', obj.fluidModel.cCoefFunc(), ...
                'a', 0, ...
                'f', obj.fluidModel.fCoefFunc() ...
                );

            obj.fluidModel.setDefaultSolverOptions(obj.model);

            if obj.verbosity
                obj.model.SolverOptions.ReportStatistics = 'on';
            end
            obj.applyDefaultBCs();
        end


        function applyDefaultBCs(obj)
           
            % applies source condition (h=1), far field condition (h=1) and
            % q \dot n = 0 (or epsilon) (no flux) on the obstacle
            
            % finds and sets the edges
            edgeDict = obj.domain.getEdgeDict();
            farFieldEdges = edgeDict("farfield"); farFieldEdges = farFieldEdges{1};
            freeFluxEdge = edgeDict("freeflux"); freeFluxEdge = freeFluxEdge{1};
            obstacleEdges = edgeDict("obstacle"); obstacleEdges = obstacleEdges{1};
            
            applyBoundaryCondition(obj.model,'dirichlet','Edge',farFieldEdges,'u',obj.fluidModel.farFieldCond());
            applyBoundaryCondition(obj.model, 'dirichlet', 'Edge', freeFluxEdge, 'u', obj.fluidModel.farFieldCond());
            applyBoundaryCondition(obj.model,'neumann','Edge',obstacleEdges,'q',obj.fluidModel.noFluxCond(),'g',0);
            
            % if the downstream edge is supplied in the domain object, set this BC as dh/dn=epsilon, dh/dn=0 elsewhere
            % otherwise set dh/dn=epsilon to edge closest to (0,0)
            if not(isnan(obj.domain.smallFluxEdge))
                downstreamEdge = nearestEdge(obj.model.Geometry, obj.domain.smallFluxEdge);
                applyBoundaryCondition(obj.model, 'neumann', 'Edge', downstreamEdge, 'q', obj.fluidModel.noFluxCond(), 'g', obj.epsilon);
                if obj.verbosity
                    fprintf('dh/dn=epsilon applied to edge %d\n', downstreamEdge)
                end
            else 
                downstreamEdge = nearestEdge(obj.model.Geometry, [0, 0]);
                applyBoundaryCondition(obj.model, 'neumann', 'Edge', downstreamEdge, 'q', obj.fluidModel.noFluxCond(), 'g', obj.epsilon);
                if obj.verbosity
                    fprintf('warning: downstream edge not specified, dh/dn = epsilon BC applied to edge %d. check this condition\n', downstreamEdge)
                end
            end

        end
       
        

        function solvePDE(obj)
            initfun = obj.fluidModel.initfunc();
            setInitialConditions(obj.model,initfun);
            results=solvepde(obj.model);
            obj.results = results;
        end 

        
        function heights = getFluidHeightAt(obj, xx, yy)
            heights =obj.fluidModel.getFluidHeightAt(obj.results, xx, yy);
        end

        function solveIteratively(obj)
            obj.fluidModel.solveIteratively(obj);
        end

        % function solveIteratively(obj)
        % 
        %     curEpsilon = 0.1;
        %     curMeshSize = 0.1;
        % 
        %     numIterations = ceil(log10(curEpsilon/obj.epsilon)) + 1;
        %     meshDiff = (curMeshSize-obj.domain.meshSize)/numIterations;
        % 
        %     obj.domain.setModel(curMeshSize);
        %     obj.specifyPDE(obj.domain);
        % 
        % 
        %     initfun = @(locations) (1 + locations.x*0);
        %     setInitialConditions(obj.model, initfun);
        % 
        %     for i = 1:numIterations
        % 
        %         fprintf('solving for epsilon = %d, meshsize = %d\n', curEpsilon, curMeshSize);
        % 
        % 
        %         obj.applyDefaultBCs(curEpsilon)
        %         obj.model.SolverOptions.MinStep = 0;
        %         obj.model.SolverOptions.MaxIterations = 100;
        %         obj.model.SolverOptions.ResidualTolerance = 1e-4;
        % 
        %         results = solvepde(obj.model);
        %         obj.results = results;
        % 
        %         obj.domain.setModel(curMeshSize);
        %         obj.specifyPDE(obj.domain)
        % 
        %         initfun = @obj.cleanInterp;
        %         setInitialConditions(obj.model, initfun);
        %         curEpsilon = curEpsilon/10;
        %         curMeshSize = curMeshSize - meshDiff;
        % 
        %     end
        % end
        % 
        % function values = cleanInterp(obj, location)
        %     vals = interpolateSolution(obj.results, location.x, location.y);
        %     if vals < 0.3
        %         vals = vals/5;
        %     end
        %     vals(isnan(vals)) = 0.01;
        %     values = vals;
        % end


        function plotSolution(obj, levels, fileName, dir)
            if nargin == 1
                levels = 20;
            end
            
            figure('Theme', 'light');
            dx=0.05;
            x=obj.domain.xmin:dx:obj.domain.xmax;
            y=obj.domain.ymin:dx:obj.domain.ymax;
            [XX,YY]=meshgrid(x,y);

            uu=obj.getFluidHeightAt(XX,YY);
            hh=reshape(uu,length(y),length(x));
            contourf(XX,YY,hh,levels); 
            hold on;
            colorbar;


            if nargin == 3
                Utils.saveFigure(fileName)
            elseif nargin == 4
                Utils.saveFigure(fileName, dir)
            end
        end



    end
    

end