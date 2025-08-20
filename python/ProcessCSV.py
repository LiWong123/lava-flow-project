import pandas as pd
import matplotlib.pyplot as plt
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