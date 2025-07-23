classdef Geometry < handle
    
    properties
        % domain properties
        xmin;
        xmax;
        ymin;
        ymax;

        meshSize;
        domain;
        model;
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

        function addObstacle(obj, xObstacle, yObstacle)
            
            obj.domain = polyshape({[obj.xmin obj.xmax obj.xmax obj.xmin], xObstacle}, ...
                    {[obj.ymax obj.ymax obj.ymin obj.ymin], yObstacle});

        end

        function addObstacleFromEdge(obj, xEdge, yEdge, thickness)

            
            
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
            figure(); 
            pdegplot(obj.model,'EdgeLabels','on')
        end

    end

end