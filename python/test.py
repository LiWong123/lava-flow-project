import numpy as np
import matplotlib.pyplot as plt

# Rosenbrock function
def rosenbrock(x, y, a=1, b=10):
    return (a - x)**2 + b*(y - x**2)**2

# Grid
x = np.linspace(-2, 2, 500)
y = np.linspace(-1, 3, 500)
X, Y = np.meshgrid(x, y)
Z = rosenbrock(X, Y)

# Mask values where Z > 0.2
Z_masked = np.ma.masked_where(Z > 0.2, Z)

# Plot heatmap
plt.figure(figsize=(6,5))
c = plt.pcolormesh(X, Y, Z_masked, shading='auto', cmap='viridis')
plt.colorbar(c, label='Rosenbrock value')
plt.xlabel('x')
plt.ylabel('y')
plt.title('Rosenbrock Heatmap (cutoff z > 0.2)')
plt.show()