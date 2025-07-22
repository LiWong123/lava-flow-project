classdef FluidPDE < handle
    % class to create and solve the fluid PDE
    
    % pde parameters
    properties (Access = public)
       
        gravityConst = 9.8;
        sourceFlux;
        density;
        viscosity;
        inclineAngle;
        steadyDepth;
        LL;

        epsilon = 1e-5;
        FF = 1;
        
    end

    methods

        function setFF(obj, FF)
            % set FF value manually
            obj.FF = FF;
        end

        function setEpsilon(obj, epsilon)
            % set epsilon value
            obj.epsilon = epsilon;
        end


        
        function setEnvVars(obj, varargin)
            % set the FF value if all environment parameters are known
            % use if not setting FF value directly
            
            % read and set the environment parameters
            p = inputParser;
            p.KeepUnmatched = false;
            
            addParameter(p, 'viscosity', [], @(x) isnumeric(x) && isscalar(x));
            addParameter(p, 'density', [], @(x) isnumeric(x) && isscalar(x));
            addParameter(p, 'inclineAngle', [], @(x) isnumeric(x) && isscalar(x));
            addOptional(p, 'LL', 1, @(x) isnumeric(x) && isscalar(x));
            addOptional(p, 'sourceFlux', 1, @(x) isnumeric(x) && isscalar(x));

            parse(p, varargin{:});
            args = p.Results;
            
            if isempty(args.viscosity) || isempty(args.density) || isempty(args.inclineAngle)
                error('All of mu, rho, and beta must be provided.');
            end
            
            obj.viscosity = args.viscosity;
            obj.density = args.density;
            obj.inclineAngle = args.inclineAngle;
            obj.LL = args.LL;
            obj.sourceFlux = args.sourceFlux;

            % calculate the F value and steadyDepth
            obj.steadyDepth = (3*obj.viscosity*obj.sourceFlux/(obj.density*obj.gravityConst*sin(obj.inclineAngle)))^(1/3);
            obj.FF = obj.steadyDepth/(obj.LL*tan(obj.inclineAngle));
        end

    end



    
    properties
        % domain properties
        xmin;
        xmax;
        ymin;
        ymax;

        % pde properties
        meshSize;
        model;
        solution;
    end

    methods 

        function setDomain(obj, xDomain, yDomain)
            obj.xmin = xDomain(1);
            obj.xmax = xDomain(2);
            obj.ymin = yDomain(1);
            obj.ymax = yDomain(2);
        end

        function setMeshSize(obj, meshSize)
            obj.meshSize = meshSize;
        end

        function pgon = createObstacle(obj, xObstacle, yObstacle)
            
            pgon = polyshape({[obj.xmin obj.xmax obj.xmax obj.xmin], xObstacle}, ...
                    {[obj.ymax obj.ymax obj.ymin obj.ymin], yObstacle});

        end
        
        function setModel(obj, pgon)

            % generates the mesh for solving the pde
            tr = triangulation(pgon);
            obj.model=createpde(1);
            tnodes = tr.Points';
            telements = tr.ConnectivityList';
            geometryFromMesh(obj.model,tnodes,telements);
            generateMesh(obj.model,'Hmax', obj.meshSize);

        end

        function showGeometry(obj)
            % shows the geometry
            figure(1); pdegplot(obj.model,'EdgeLabels','on')
        end

        function specifyPDE(obj)
            specifyCoefficients(obj.model, ...
                'm', 0, ...
                'd', 0, ...
                'c', obj.cCoefFunc(), ...
                'a', 0, ...
                'f', obj.fCoefFunc());
        end

        function applyDefaultBCs(obj)
            
        end

        function solvePDE(obj)
            initfun = @(locations) (0.2+locations.x*0);
            setInitialConditions(obj.model,initfun);
            obj.model.SolverOptions.MinStep = 0;
            obj.model.SolverOptions.MaxIterations = 500;
            obj.model.SolverOptions.ResidualTolerance = 1e-04;
            results=solvepde(obj.model);
            obj.solution = results;
        end

        function plotSolution(obj, levels)
            u = obj.solution.NodalSolution;
            figure(2);
            
            pdeplot(obj.model,'xydata',u(:,1),'contour','on',...
            'colorbar', 'on',...
            'levels',levels,'mesh','off','xystyle','off');
            hold on;
            p = pdegplot(obj.model,'EdgeLabels','off');
            set(p, 'Color', 'k', 'LineWidth', 1.5); 
        end

    end





    methods
        
        % functions for specifying the PDE
        function c = cCoefFunc(obj)
            FF = obj.FF;
            c = @(region, state) FF * state.u(1,:).^3;
        end

        function f = fCoefFunc(obj)
            f = @(region, state) -3*(state.u(1,:).^2).*state.ux(1,:);
        end

        function noFluxBC = noFluxBC(obj)
            noFluxBC = @(region, state) state.ux(1,:).^2 + obj.epsilon;
        end

        
    end
    

end