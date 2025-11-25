function binghamPowerJob(BB)
    aspectRatio = 0.5;

    filename = sprintf("binghamPowerResults_B%g_AR%g.csv", BB, aspectRatio);
    fid = fopen(filename, "w");
    fprintf(fid, "B,n,x0,force_x,force_y,abs(force),max_height\n");

    p = gcp();
    numWorkers = p.NumWorkers


    n_values = 0.1:0.1:2;
    x0_values = 0.3:0.1:3;

    parfor i = 1:numel(n_values)
        n = n_values(i);
        for j = 1:numel(x0_values)
            x0 = x0_values(j);

            fprintf("Running B=%g, n=%g, x0=%g\n", BB, n, x0);

            model = BinghamModel();
            model.setAspectRatio(aspectRatio);
            model.setBinghamConstant(BB);

            shapeCalculator = Shapes(model);
            shapeCalculator.meshSize = 0.1;
            [absforce, force, height] = shapeCalculator.evaluateShape( ...
                x0, n, @Shapes.powerBoundary, ...
                @(obj,x,y)obj.addSymmetricObstacle(x,y));

            forceX = force(1);
            forceY = force(2);

            dataLine = sprintf("%g,%g,%g,%g,%g,%g,%g\n", ...
                BB, n, x0, forceX, forceY, absforce, height);

            f = fopen(filename, "a");
            fprintf(f, "%s", dataLine);
            fclose(f);
        end
    end

    fclose(fid);
