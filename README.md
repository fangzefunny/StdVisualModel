# StdVisualModel at zeming branch
This is new repositories to carry all the codes we need

## Testing

edit the  s2_parrallel_fit file and run to see if we can replicate the fit. 

## Main code

### step0: create a new folder, and git clone the code inside the created folder. 

### step1: run 's1_prepare_inputs'.
Get a 'Data' folder that is parallel to the StdVisualModel inside the new folder you made. Inside the the data folder, there are 'E', 'Stimuli', 'fMRIdata'. (You should mannually delete the downloaded zip file to keep your disk clear and tidy)

### step2: fit the model 
To do the parallel fit, we should do the following 3 steps:

* Edit the script and test if the code works.
After edit the code, copy and paste the following codes in hyperparamter block to test if the code works. 1 job should take no more than 2 min.
```matlab 
%% hyperparameter: each time, we only need to edit this section !! 

optimizer        = 'fmincon';  % what kind of optimizer, bads or fmincon . value space: 'bads', 'fmincon'
target               = 'all';              % Two target stimuli or the whole dataset. value space: 'target', 'All'
fittime              = 5;               % how many initialization. value space: Integer
data_folder    = 'Cross';  % save in which folder. value space: 'noCross', .....
cross_valid      = 'cross_valid';           % choose what kind of cross validation, value space: 'one', 'cross_valid'. 'one' is no cross validation.
choose_model = 'orientation';          % choose some preset data 
```
* Fit the whole dataset
Copy and paste the following code in hyperparamter block
```matlab 
%% hyperparameter: each time, we only need to edit this section !! 

optimizer        = 'fmincon';  % what kind of optimizer, bads or fmincon . value space: 'bads', 'fmincon'
target               = 'all';              % Two target stimuli or the whole dataset. value space: 'target', 'All'
fittime              = 40;               % how many initialization. value space: Integer
data_folder    = 'Cross';  % save in which folder. value space: 'noCross', .....
cross_valid      = 'cross_valid';           % choose what kind of cross validation, value space: 'one', 'cross_valid'. 'one' is no cross validation.
choose_model = 'all';          % choose some preset data 
```

* Fit the target dataset
Copy and paste the following code in hyperparamter block
```matlab 
%% hyperparameter: each time, we only need to edit this section !! 

optimizer        = 'fmincon';  % what kind of optimizer, bads or fmincon . value space: 'bads', 'fmincon'
target               = 'target';              % Two target stimuli or the whole dataset. value space: 'target', 'All'
fittime              = 40;               % how many initialization. value space: Integer
data_folder    = 'Cross';  % save in which folder. value space: 'noCross', .....
cross_valid      = 'cross_valid';           % choose what kind of cross validation, value space: 'one', 'cross_valid'. 'one' is no cross validation.
choose_model = 'all';          % choose some preset data 
```

### step3: run 's3_create_tables' 
Create and save tables that show r square, rmse, and parameters

### step4: run 's4_creat_plots'
Create and save plots that show the fit conditions. 

## Estimated running time 

Here I estimate the time for running 1 job based on my experience.  And 1 job means 1 dataset x 1 roi x 1 model.

* model1 'contrast':  
  * no_cross: 40s
  * cross_valid: 3-5 min
* model3 'normVar': 
  * no_cross: 40s
  * cross_valid: 3-5 min
* model4, model6 'soc' and 'soc_bound': 
  * no_cross: .5 - 1 hrs; 
  * cross_valid: 20 - 40 hrs?
* model5 'oriSurround':
  * no_cross: 1- 2 hrs;
  * cross_valid: 60 - 100 hrs?



