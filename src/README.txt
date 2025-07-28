to be run on MATLAB 2025a. requires PDE and symbolic math toolbox
see cylinder.m or vshape.m for example code

known issues: 
code runs boundary condition dh/dn = epsilon instead of dh/dn = 0 on upstream edge of obstacle
running interpolateSolution(pde.model.results, x, y) just downstream of boundary returns higher than desired values.