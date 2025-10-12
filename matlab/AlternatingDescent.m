classdef AlternatingDescent < handle


    properties (Access = public)
        
        verbosity = true;
        tolerance = 1e-3;
        xStart = 2;
        nStart = 1;
        xmax = 2.5;
        xmin = 1.5;
        nmax = 1.3;
        nmin = 0.3;


    end

    methods

        
        function [xBest, nBest, fBest] = run(obj, objectiveFunc)

            xPrev = -inf;
            nPrev = -inf;

            xBest = obj.xStart;
            nBest = obj.nStart;
            fBest = inf;
            

            p = gcp();
            numWorkers = p.NumWorkers;
            maxDepth = obj.getMaxDepth(numWorkers)


            depth = 1;
            while depth < maxDepth

                xmin = obj.xmin;
                xmax = obj.xmax;
                nmin = obj.nmin;
                nmax = obj.nmax;

                for j=1:depth
                    
                    XX = linspace(xmin, xmax, numWorkers);
                    ff = zeros(1, numWorkers);
    
                    parfor i=1:numWorkers
                        f = objectiveFunc(XX(i), nBest);
                        ff(i) = f;
                    end
                    
                    [fCur, idx] = min(ff);
                    xmin = XX(max(1, idx-1));
                    xmax = XX(min(numWorkers, idx+1));
                    if fCur < fBest
                        xBest = XX(idx);
                        fBest = fCur;
                    end
    
                end

                for j=1:depth
    
                    NN = linspace(nmin, nmax, numWorkers);
                    ff = zeros(1, numWorkers);
    
                    parfor i=1:numWorkers
                        f = objectiveFunc(xBest, NN(i));
                        ff(i) = f;
                    end
    
                    [fCur, idx] = min(ff);

                    nmin = NN(max(1, idx-1));
                    nmax = NN(min(numWorkers, idx+1));
                    if fCur < fBest
                        nBest = NN(idx);
                        fBest = fCur;
                    end

                end

                if obj.verbosity
                    fprintf("best so far at depth %g: x0=%g, n=%g\n", depth, xBest, nBest);
                end

                if xBest == xPrev && nBest == nPrev
                    if obj.verbosity
                        fprintf("absolute best at depth %g: x0=%g, n=%g\n", depth, xBest, nBest);
                    end
                    depth = depth+1;
                end

                xPrev = xBest;
                nPrev = nBest;
                
            end

        end

        function d = getMaxDepth(obj, numWorkers)
            
            maxLen = max(obj.xmax-obj.xmin, obj.nmax-obj.nmin);
            d = 2 + log((numWorkers-1)*obj.tolerance/maxLen)/log(2/(numWorkers-1));

        end

    end




end