classdef SolutionCalculator < handle

    properties (Access = public)
        
        pde;
        xEdge;
        yEdge;

        % number of samples for plotting/finding maximum
        samples = 1000;
        safeBoundaryX;
        safeBoundaryY;
        safeBoundaryH;

        dryTolerance = 0.03;
        dryRegionCoords;
        dryMeshSize = 0.03;

    end

    methods
        
        % getters and setters
        function obj = SolutionCalculator(pde, xEdge, yEdge)
            % constructor
            obj.pde = pde;

            if nargin == 1
                xEdge = pde.domain.xUpStreamEdge;
                yEdge = pde.domain.yUpstreamEdge;
            end

            if not(issorted(yEdge) || issorted(flip(yEdge)))
                fprintf("warning: boundary edge not properly specified - y coordinates should be increasing/decreasing\n")
            end
            obj.xEdge = xEdge;
            obj.yEdge = yEdge;
            
            if isequaln(xEdge, NaN) || isequaln(yEdge, NaN)
                error("no boundary specified. if using addObstacle, specify the upstream edge with SolutionCalculator(pde, xEdge, yEdge)")
            else
                [hh, xx, yy] = obj.safeInterpBoundary();
                obj.safeBoundaryH = hh;
                obj.safeBoundaryX = xx;
                obj.safeBoundaryY = yy;
            end
            
        end



        function [hh, xx, yy] = safeInterpBoundary(obj)
            
            % removes part of the boundary where dy/dx=0 to allow iteration over y direction
            [uniqYEdge, indices] = unique(obj.yEdge, 'stable');
            reducedXEdge = obj.xEdge(indices);
            yy = linspace(obj.yEdge(1), obj.yEdge(end), obj.samples);
            xx = interp1(uniqYEdge, reducedXEdge, yy, "linear");
            hh = arrayfun(@(x, y) obj.safeGetH(x, y), xx, yy);

        end

        function h = safeGetH(obj, x, y)
            h = obj.pde.getFluidHeightAt(x, y);
            while isequaln(h, NaN)
                x = x - 5e-5;
                h = obj.pde.getFluidHeightAt(x, y);
                if ~isequaln(h, NaN)
                    break
                else
                    y = y + 5e-5;
                    h = obj.pde.getFluidHeightAt(x, y);
                end
            end
        end

        % depreciated function
        % function h = getH(obj, x, y)
        %     % returns the h value of the solution at (x,y)
        %     h = interpolateSolution(obj.pde.results, x, y);
        % 
        % end
    

        function force = calculateForce(obj)

            force = [0, 0];
            % sum up \int h^2 \dot \n along the piecewise linear boundary
            for i = 1:length(obj.yEdge)-1
                force = force + integral(obj.getIntegrand(i), 0, 1, 'ArrayValued', true);
            end

        end

        function integrand = getIntegrand(obj, index)
            % integrand for the i'th piecewise linear part of boundary

            xmin = obj.xEdge(index);
            xmax = obj.xEdge(index+1);
            ymin = obj.yEdge(index);
            ymax = obj.yEdge(index+1);

            normal = obj.findNormal(index);

            % parametrise the line as r(t), so len = |r'(t)|
            r = @(t) [xmin + (xmax-xmin)*t, ymin + (ymax-ymin)*t];
            len = hypot(xmax-xmin, ymax-ymin);
            
            % then \int h^2 n ds = \int h^2 * n * len dr
            integrand = @(t) obj.hsquared(r, t) * len * (normal);
        end

        function h2 = hsquared(obj, r, t)
            % gives the h^2 value for a point t on line r(t)
            coord = r(t);
            x = coord(1);
            y = coord(2);
            h = obj.pde.getFluidHeightAt(x, y);
            if isnan(h)
                h = interp1(obj.safeBoundaryY, obj.safeBoundaryH, y, 'linear');
            end
            h2 = h^2;

        end

        function unitNorm = findNormal(obj, index)
            % find the normal vector between the i and i+1'th vertex in the boundary edge
            % normal vector always points right in this function
            x1 = obj.xEdge(index);
            x2 = obj.xEdge(index+1);
            y1 = obj.yEdge(index);
            y2 = obj.yEdge(index+1);
            
            % we allow dy/dx = 0 only at the top/bottom of the boundary. apply the normal to point out of boundary
            if y1 == y2
                if y1 > (obj.yEdge(1) + obj.yEdge(end))/2
                    unitNorm = [0 -1];
                else 
                    unitNorm = [0 1];
                end

            else
                perpGrad = -(x2-x1)/(y2-y1);
                magnitude = hypot(1, perpGrad);
                unitNorm = 1/magnitude*[1, perpGrad];
            end
        end

        function magnitude = getMagnitude(obj, force)
            magnitude = norm(force);
        end


        


        function [maxHeight, coord] = getMaxHeight(obj)
            % returns the max height and the x and y location on the boundary where this occurs
            % only returns a single location even if multiple exist

            [maxHeight, id] = max(obj.safeBoundaryH);
            coord = [obj.safeBoundaryX(id), obj.safeBoundaryY(id)];
            
        end

        function plotBoundarySolution(obj, fileName, dir)
            %sketch h values for different y values. default of 1000 samples but can be changed by user
            
            % find the x and y coordinates of the point where the max h value is
            [hmax, coord] = obj.getMaxHeight();
            xCoord = coord(1);
            yCoord = coord(2);
            
            figure('Theme', 'light');
            hold on;
            grid on;
            plot(obj.safeBoundaryY,obj.safeBoundaryH);
            plot(yCoord, hmax, 'o','MarkerSize', 6, 'MarkerFaceColor', 'k', 'MarkerEdgeColor','k');
            text(yCoord-0.2,hmax+0.1,sprintf('x=%.3f, y=%.3f, h=%.3f', xCoord, yCoord, hmax), 'Color', 'black');
            ylabel('height of flow');
            xlabel('y');
            
            % to save the figure
            if nargin == 2
                Utils.saveFigure(fileName)
            elseif nargin == 3
                Utils.saveFigure(fileName, dir)
            end

        end


        function cutoff = getDryCutoff(obj)
            
            xvals = obj.pde.domain.xmin:0.1:obj.pde.domain.xmax;
            yvals = obj.pde.domain.ymin:0.1:obj.pde.domain.ymax;

            [X, Y] = meshgrid(xvals,yvals);

            heights = obj.pde.getFluidHeightAt(X, Y);
            minval = min(heights(:),[],'omitnan');
            cutoff = minval + obj.dryTolerance;

        end

        function bool = checkInDryRegion(obj, x, y, cutoff)
            
            if isnan(obj.pde.getFluidHeightAt(x, y))
                bool = false;
            elseif obj.pde.getFluidHeightAt(x, y) < cutoff
                bool = true;
            else
                bool = false;
            end

        end

        function findDryRegion(obj)
            
            xvals = obj.pde.domain.xmin:obj.dryMeshSize:obj.pde.domain.xmax;
            yvals = obj.pde.domain.ymin:obj.dryMeshSize:obj.pde.domain.ymax;
            cutoff = obj.getDryCutoff();

            [X, Y] = meshgrid(xvals,yvals);
            boolArr = false(size(X));

            for i = 1:numel(X)
                boolArr(i) = obj.checkInDryRegion(X(i), Y(i), cutoff);
            end
            
            obj.dryRegionCoords = [X(boolArr), Y(boolArr)];

        end


        function area = getDryArea(obj)
            numPoints = length(obj.dryRegionCoords);
            area = numPoints * (obj.dryMeshSize)^2;
        end

        function plotDryRegion(obj)

            figure('Theme', 'light'); 
            pdegplot(obj.pde.model,'EdgeLabels','on')
            hold on
            plot(obj.dryRegionCoords(:,1), obj.dryRegionCoords(:,2), '.')
            
        end
        

    end



end