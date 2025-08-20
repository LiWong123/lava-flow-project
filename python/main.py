from ProcessCSV import ProcessCSV
import pandas as pd


data = ProcessCSV("powerResults.csv")
data.make_graph(indept_var="n", dependent_var="max_height", control_vars=[("F", 0.1), ("x0", 1)])
