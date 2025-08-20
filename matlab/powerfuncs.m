close all force;
clearvars;

fid = fopen("powerResults.csv", "a");
fprintf(fid, "F,n,x0,force_x,force_y,abs(force),max_height\n");

for F = [0.1, 0.25, 0.5, 0.75, 1]
    
    for n = [0 0.1, 0.25, 0.5, 1, 2, 3]

        for x0 = [2, 2.5, 3]

            fprintf("running F=%g, n=%g, x0=%g\n", F, n, x0);

            [force, absForce, height] = Powers.evaluate(x0, n, F);
            forceX = force(1);
            forceY = force(2);

            fprintf(fid, "%g,%g,%g,%g,%g,%g,%g\n",F,n,x0,forceX,forceY,absForce,height);

        end

    end

end

fclose(fid);



