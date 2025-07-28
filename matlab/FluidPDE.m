classdef FluidPDE < handle
    % class to create and solve the fluid PDE
    
    % pde parameters
    properties (Access = public)

        epsilon = 1e-5;
        FF = 1;
        
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
            
            % applies far field conditions: h=1 on the boundaries and
            % q \dot n = epsilon (no flux) on the obstacle
            xmin = obj.domain.xmin;
            xmax = obj.domain.xmax;
            ymin = obj.domain.ymin;
            ymax = obj.domain.ymax;

            xmid = (xmin+xmax)/2;
            ymid = (ymin+ymax)/2;

            
            farFieldEdges = [nearestEdge(obj.model.Geometry, [xmin, ymid]), ...
                nearestEdge(obj.model.Geometry, [xmax, ymid]), ...
                nearestEdge(obj.model.Geometry, [xmid, ymin]), ...
                nearestEdge(obj.model.Geometry, [xmid, ymax])];

            applyBoundaryCondition(obj.model,'dirichlet','Edge',farFieldEdges,'u',1);

            obstacleEdges = [];
            for i = 1:obj.model.Geometry.NumEdges
                if not(ismember(i, farFieldEdges))
                    obstacleEdges = [obstacleEdges, i];
                end
            end

            applyBoundaryCondition(obj.model,'neumann','Edge',obstacleEdges,'q',obj.noFluxCond(),'g',obj.epsilon);

        end
        
        % PLEASE CHECK :) the no flux boundary condition
        function noFluxBC = noFluxCond(obj)
            noFluxBC = @(region, state) -region.nx .* (state.u(1,:).^2);
        end



        function solvePDE(obj)
            initfun = @(locations) (1+locations.x*0);
            setInitialConditions(obj.model,initfun);
            results=solvepde(obj.model);
            obj.results = results;
        end

        function plotSolution(obj, levels)
            u = obj.results.NodalSolution;
            figure();
            
            pdeplot(obj.model,'xydata',u(:,1),'contour','on',...
            'colorbar', 'on',...
            'levels',levels,'mesh','off','xystyle','off');
            hold on;
            p = pdegplot(obj.model,'EdgeLabels','off');
            set(p, 'Color', 'k', 'LineWidth', 1.5); 
        end

    end
    

end