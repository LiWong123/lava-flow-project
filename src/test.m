x_outer = [-3 -3 5 5 -3];
y_outer = [4 -3 -3 4 4];

area_outer = signedArea(x_outer, y_outer)


arr1 = 0:0.01:2*pi;
arr1 = flip(arr1);
xx = cos(arr1);
yy = sin(arr1);

x_inner = [xx xx(1)];
y_inner = [yy yy(1)];
area_inner = signedArea(x_inner, y_inner)

function sA = signedArea(x, y)
    sA = 0.5 * sum(x(1:end-1).*y(2:end) - x(2:end).*y(1:end-1));
end