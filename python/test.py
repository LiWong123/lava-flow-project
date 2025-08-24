import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv("powerResultsV2.csv")

# Group by F, then by x0, and pick the row with smallest force
min_force_df = df.loc[df.groupby(["F", "x0"])["abs(force)"].idxmin()]


# Create one figure
plt.figure(figsize=(8,6))

# Plot each F on the same axes
for F_value, group in min_force_df.groupby("F"):
    # Sort by x0 for cleaner line plotting
    group_sorted = group.sort_values("x0")
    plt.plot(group_sorted["x0"], group_sorted["n"], marker=".", label=f"F = {F_value}")

plt.xlabel("x0")
plt.ylabel("n (with min force)")
plt.title("Optimal n vs x0 for different F values")
plt.legend(title="F")
plt.grid(True)
plt.show()