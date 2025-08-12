classdef Domain < handle
    
    properties (Access = public)
        % domain properties
        xmin;
        xmax;
        ymin;
        ymax;

        smallFluxEdge = NaN;
        xUpStreamEdge = NaN;
        yUpstreamEdge = NaN;
        
        symmetricDomain = false;

        meshSize = 0.1;
        domain;
        model;
    end

    methods 

        function setDomain(obj, xDomain, yDomain)
            obj.xmin = xDomain(1);
            obj.xmax = xDomain(2);
            obj.ymin = yDomain(1);
            obj.ymax = yDomain(2);
            obj.domain = polyshape({[obj.xmin obj.xmin obj.xmax obj.xmax]}, ...
                    {[obj.ymax obj.ymin obj.ymin obj.ymax]});
        end

        function setMeshSize(obj, meshSize)
            obj.meshSize = meshSize;
        end

        function addObstacle(obj, xObstacle, yObstacle)
            % fully specify an obstacle using x and y vertex coords
            obj.domain = polyshape({[obj.xmin obj.xmax obj.xmax obj.xmin], xObstacle}, ...
                    {[obj.ymax obj.ymax obj.ymin obj.ymin], yObstacle});

        end

        function addFlatEdgeObstacle(obj, xEdge, yEdge)
            % add an obstacle by specifying the left edge, ensures that the downstream boundary is parallel to the source
            obj.xUpStreamEdge = xEdge;
            obj.yUpstreamEdge = yEdge;
            
            if xEdge(1) == xEdge(end)
                xFlat = xEdge(1);
                xObstacle = xEdge;
                yObstacle = yEdge;
            elseif xEdge(1) > xEdge(end)
                xFlat = xEdge(1);
                xObstacle = [xEdge, xFlat];
                yObstacle = [yEdge, yEdge(end)];
            else
                xFlat = xEdge(end);
                xObstacle = [xFlat, xEdge];
                yObstacle = [yEdge(1), yEdge];
            end

            obj.smallFluxEdge = [xFlat, (yEdge(1)+yEdge(end))/2];

            obj.domain = polyshape({[obj.xmin obj.xmax obj.xmax obj.xmin], xObstacle}, ...
                    {[obj.ymax obj.ymax obj.ymin obj.ymin], yObstacle});

        end

        function addObstacleFromEdge(obj, xEdge, yEdge, thickness)
            
            % takes the LEFT edge of an obstacle, and removes a wall of
            % width=thickness from the domain
            obj.xUpStreamEdge = xEdge;
            obj.yUpstreamEdge = yEdge;

            xObstacle = horzcat(xEdge,flip(xEdge)+thickness);
            yObstacle = horzcat(yEdge,flip(yEdge));
            obj.domain = polyshape({[obj.xmin obj.xmax obj.xmax obj.xmin], xObstacle}, ...
                    {[obj.ymax obj.ymax obj.ymin obj.ymin], yObstacle});

        end 


        function addSymmetricObstacle(obj, xEdge, yEdge)

            obj.xUpStreamEdge = xEdge;
            obj.yUpstreamEdge = yEdge;
            
            xObstacle = horzcat(xEdge, flip(xEdge));
            yObstacle = horzcat(yEdge, -flip(yEdge));

            xFlat = max([xEdge(1), yEdge(end)]);

            obj.smallFluxEdge = [xFlat, 0];

            obj.domain = polyshape({[obj.xmin obj.xmax obj.xmax obj.xmin], xObstacle}, ...
                    {[obj.ymax obj.ymax obj.ymin obj.ymin], yObstacle});
            
        end

        
        function setModel(obj, meshSize)

            if nargin < 2
                meshSize = obj.meshSize;
            end

            % generates the mesh for solving the pde
            tr = triangulation(obj.domain);
            obj.model=createpde(1);
            tnodes = tr.Points';
            telements = tr.ConnectivityList';
            geometryFromMesh(obj.model,tnodes,telements);
            generateMesh(obj.model,'Hmax', meshSize);

        end

        function edgeDict = getEdgeDict(obj)
            % returns a dictionary that specifies the source, freeflux and obstacle edges
            
            xmid = (obj.xmax + obj.xmin)/2;
            ymid = (obj.ymax + obj.ymin)/2;
            
            % these are the edges on the boundary of the domain
            sourceEdge = [nearestEdge(obj.model.Geometry, [obj.xmin, ymid])];
            freeFluxEdges = [nearestEdge(obj.model.Geometry, [obj.xmax, ymid]), ...
                nearestEdge(obj.model.Geometry, [xmid, obj.ymin]), ...
                nearestEdge(obj.model.Geometry, [xmid, obj.ymax])];
            
            % edges not on the boundary
            farFieldEdges = [sourceEdge, freeFluxEdges];
            obstacleEdges = [];
            for i = 1:obj.model.Geometry.NumEdges
                if not(ismember(i, farFieldEdges))
                    obstacleEdges = [obstacleEdges, i];
                end
            end

            edgeDict = dictionary(["source", "freeFlux", "obstacle"], ...
                {sourceEdge, freeFluxEdges, obstacleEdges});

        end

        function showGeometry(obj)
            % shows the geometry
            figure('Theme', 'light'); 
            pdegplot(obj.model,'EdgeLabels','on')
        end

    end

end