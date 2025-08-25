import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from typing import List, Tuple

class ProcessCSV:

    def __init__(self, csvFileName: str):
        self.df = pd.read_csv(csvFileName)
        return
    
    def make_graph(self, indept_var: str, dependent_var: str, control_vars: List[Tuple[str, float]]):
        filtered_df = self.filter_controls(control_vars)
        plt.plot(filtered_df[indept_var], filtered_df[dependent_var], marker="o")
        plt.show()
        return filtered_df
    
    def filter_controls(self, control_vars: List[Tuple[str, float]]):

        filtered_df = self.df
        name = 0
        value = 1
        for control_var in control_vars:
            filtered_df = filtered_df[filtered_df[control_var[name]]==control_var[value]]

        return filtered_df
    
    def make_heat_map(self, df, objective: str):

        heatmap_data = df.pivot(index='x0', columns='n', values=objective)
        sns.heatmap(heatmap_data, cmap="viridis", annot=False) 
        plt.show()

    def get_abs_minimum(self, df, objective: str):

        idx = df[objective].idxmin()

        min_row = df.loc[idx]
        x0_min, n_min, f_min = min_row["x0"], min_row["n"], min_row[objective]

        print(f"Minimum = {f_min} at (x0, n) = ({x0_min}, {n_min})")