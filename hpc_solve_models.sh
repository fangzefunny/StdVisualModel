#! /bin/bash
#SBATCH --job-name=StdModel
#SBATCH -a 1-12 # these numbers are read in to SLURM_ARRAY_TASK_ID
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16g
#SBATCH --time=08:00:00
#SBATCH --output=/scratch/%u/logs/StdVisualModel_out_%x-%a.txt
#SBATCH --error=/scratch/%u/logs/StdVisualModel_error_%x-%a.txt
#SBATCH --mail-user=%u@nyu.edu
#SBATCH --mail-type=END #email me when it crashes or better, ends

module load matlab/2021a

matlab <<EOF

addpath(genpath('~/toolboxes/StdVisualModel'));
s1_prepare_inputs
s2_fit_all_cluster
EOF
