close all force;
clearvars;


%% --- Parameters ---
Fvals  = [0.05, 0.1, 0.25, 0.5, 1];
nvals  = 0:0.1:4;
x0vals = 0.1:0.1:4;

% Create all combinations
[Fgrid, ngrid, x0grid] = ndgrid(Fvals, nvals, x0vals);
combos = [Fgrid(:), ngrid(:), x0grid(:)];
N = size(combos,1);

progresstracker = HPC(N);
dq = parallel.pool.DataQueue;
afterEach(dq, @(~) progresstracker.updateProgress());

%% --- Start parallel pool ---
if isempty(gcp('nocreate'))
    % Try to get number of CPUs from SLURM, else default
    nWorkers = 4; % default
    if ~isempty(getenv('SLURM_CPUS_PER_TASK'))
        nWorkers = str2double(getenv('SLURM_CPUS_PER_TASK'));
    end
    parpool(nWorkers);
end

results = zeros(N, 7);  % columns: F,n,x0,forceX,forceY,absForce,height

parfor i = 1:N

    warning('off', 'all');
    F  = combos(i,1);
    n  = combos(i,2);
    x0 = combos(i,3);

    %fprintf("Running F=%g, n=%g, x0=%g\n", F, n, x0);

    [force, absForce, height] = Powers.evaluateASymPower2(x0, n, F);
    forceX = force(1);
    forceY = force(2);

    results(i,:) = [F, n, x0, forceX, forceY, absForce, height];
    send(dq, 1);
end

csvFile = "powerResultsASym2.csv";
fid = fopen(csvFile, "a");

fprintf(fid, "F,n,x0,force_x,force_y,abs(force),max_height\n");
fprintf(fid, "%g,%g,%g,%g,%g,%g,%g\n", results.');
fclose(fid);