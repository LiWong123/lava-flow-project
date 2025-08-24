from ProcessCSV import ProcessCSV
import pandas as pd
import matplotlib.pyplot as plt

plt.close('all')
data = ProcessCSV("powerResultsV2.csv")
data.df = data.df[data.df["n"]>0]
data.make_graph(indept_var="n", dependent_var="abs(force)", control_vars=[("F", 0.05), ("x0", 2)])
