#!/bin/bash

#SBATCH -p sapphire
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=64
#SBATCH --time=0-08:55:00
#SBATCH --mem=128G


# Send yourself an email when the job:
# aborts abnormally (fails)
#SBATCH --mail-type=FAIL
# begins
#SBATCH --mail-type=BEGIN
# ends successfully
#SBATCH --mail-type=END

# Use this email address:
#SBATCH --mail-user=minwong@student.unimelb.edu.au

#SBATCH --output=logs/jobID_%j.log
#SBATCH --error=logs/jobID_%j.log

module load MATLAB

time matlab -nodesktop -nodisplay -nosplash < parallelASymEllipses.m


