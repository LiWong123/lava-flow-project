params = [
    0.3  0.1  0.9  1.0;
    0.3  0.2  0.7  0.9;
    0.3  0.3  0.6  0.8;
    0.3  0.4  0.5  0.7;
    0.3  0.5  0.5  0.6;
    0.4  0.1  0.8  1.0;
    0.4  0.2  0.5  0.9;
    0.4  0.3  0.6  0.8;
    0.4  0.4  0.5  0.7;
    0.4  0.5  0.5  0.6;
    0.5  0.1  0.8  1.0;
    0.5  0.2  0.6  0.9;
    0.5  0.3  0.6  0.8;
    0.5  0.4  0.5  0.7;
    0.5  0.5  0.5  0.7;
    
];

for k = 1:size(params, 1)

    BB  = params(k, 1);
    AR  = params(k, 2);
    n  = params(k, 3);
    x0 = params(k, 4);

    model = BinghamModel();
    model.setAspectRatio(AR);    
    model.setBinghamConstant(BB);  

    shapeCalculator = Shapes(model);
    shapeCalculator.meshSize = 0.06;
    shapeCalculator.verbosity = true;
    shapeCalculator.showSolution = true;

    [absforce, force, height] = shapeCalculator.evaluateShape( ...
        x0, n, @Shapes.powerBoundary, ...
        @(obj,x,y)obj.addSymmetricObstacle(x,y));


end