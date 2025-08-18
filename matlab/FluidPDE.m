classdef FluidPDE < handle
    % class to create and solve the fluid PDE
    
    % pde parameters
    properties (Access = public)

        epsilon = 1e-7;
        FF = 1;
        verbosity = false;
        
    end

    methods
        % setters

        function setFF(obj, FF)
            % set FF value manually
            obj.FF = FF;
        end

        function setEpsilon(obj, epsilon)
            % set epsilon value
            obj.epsilon = epsilon;
        end

        function setVerbosity(obj, boolean)
            % determines whether warnings/pde output shown
            obj.verbosity = boolean;
        end

    end

    
    properties

        % pde properties
        domain;
        model;
        results;

    end

    methods 

        function specifyPDE(obj, domain)
            
            % imports the model mesh from the geometry and
            % sets the equation dh^3/dx = F[d/dx(h^3 dh/dx) + d/dy(h^3 dh/dy)]
            obj.domain = domain;
            obj.model = domain.model;

            specifyCoefficients(obj.model, ...
                'm', 0, ...
                'd', 0, ...
                'c', obj.cCoefFunc(), ...
                'a', 0, ...
                'f', obj.fCoefFunc());

            obj.model.SolverOptions.MinStep = 0;
            obj.model.SolverOptions.MaxIterations = 50;
            obj.model.SolverOptions.ResidualTolerance = 1e-4;
            if obj.verbosity
                obj.model.SolverOptions.ReportStatistics = 'on';
            end
            obj.applyDefaultBCs();
        end
        
        % functions for specifying the PDE
        function c = cCoefFunc(obj)
            FF = obj.FF;
            c = @(region, state) FF * state.u(1,:).^3;
        end

        function f = fCoefFunc(obj)
            f = @(region, state) -3*(state.u(1,:).^2).*state.ux(1,:);
        end


        function applyDefaultBCs(obj)
           
            % applies source condition (h=1), far field free flux condition (dh/dt=0) and
            % q \dot n = 0 (or epsilon) (no flux) on the obstacle
            
            % finds and sets the edges
            edgeDict = obj.domain.getEdgeDict();
            sourceEdge = edgeDict("source"); sourceEdge = sourceEdge{1};
            freeFluxEdges = edgeDict("freeFlux"); freeFluxEdges = freeFluxEdges{1};
            obstacleEdges = edgeDict("obstacle"); obstacleEdges = obstacleEdges{1};
            
            applyBoundaryCondition(obj.model,'dirichlet','Edge',sourceEdge,'u',1);
            applyBoundaryCondition(obj.model, 'neumann', 'Edge', freeFluxEdges, 'q',0, 'g', 0);
            applyBoundaryCondition(obj.model,'neumann','Edge',obstacleEdges,'q',obj.noFluxCond(),'g',0);
            
            % if the downstream edge is supplied in the domain object, set this BC as dh/dn=epsilon, dh/dn=0 elsewhere
            % otherwise set dh/dn=epsilon to edge closest to (0,0)
            if not(isnan(obj.domain.smallFluxEdge))
                downstreamEdge = nearestEdge(obj.model.Geometry, obj.domain.smallFluxEdge);
                applyBoundaryCondition(obj.model, 'neumann', 'Edge', downstreamEdge, 'q', obj.noFluxCond(), 'g', obj.epsilon);
                if obj.verbosity
                    fprintf('dh/dn=epsilon applied to edge %d\n', downstreamEdge)
                end
            else 
                downstreamEdge = nearestEdge(obj.model.Geometry, [0, 0]);
                applyBoundaryCondition(obj.model, 'neumann', 'Edge', downstreamEdge, 'q', obj.noFluxCond(), 'g', obj.epsilon);
                if obj.verbosity
                    fprintf('warning: downstream edge not specified, dh/dn = epsilon BC applied to edge %d. check this condition\n', downstreamEdge)
                end
            end

        end
        
        % no flux boundary condition
        function noFluxBC = noFluxCond(obj)
            noFluxBC = @(region, state) -region.nx .* (state.u(1,:).^2);
        end


        function solvePDE(obj)
            initfun = @(locations) (1+locations.x*0);
            setInitialConditions(obj.model,initfun);
            results=solvepde(obj.model);
            obj.results = results;
        end

        % % completely useless lol
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
            % contour plot. allow user to specify contour lines
            
            % default 20 contour lines if no input given
            if nargin == 1
                levels = 20;
            end

            u = obj.results.NodalSolution;
            figure('Theme', 'light');
            
            pdeplot(obj.model,'xydata',u(:,1),'contour','on',...
            'colorbar', 'on',...
            'levels',levels,'mesh','off','xystyle','off');
            hold on;
            p = pdegplot(obj.model,'EdgeLabels','off');
            set(p, 'Color', 'k', 'LineWidth', 1.5);

            if nargin == 3
                Utils.saveFigure(fileName)
            elseif nargin == 4
                Utils.saveFigure(fileName, dir)
            end

        end

    end
    

end