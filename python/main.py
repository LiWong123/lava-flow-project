from ProcessCSV import ProcessCSV
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

plt.close('all')
data = ProcessCSV("ellipsesASym.csv")
#data.df = data.df[data.df["n"]>0]
#data.make_graph(indept_var="n", dependent_var="abs(force)", control_vars=[("F", 0.05), ("x0", 2)])
f005_data = data.filter_controls([('F', 0.05)])
f005_data["log(force)"] = np.log(np.log(f005_data["abs(force)"]))
data.get_abs_minimum(f005_data, 'abs(force)')
data.make_heat_map(f005_data, objective='abs(force)')