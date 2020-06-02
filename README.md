# StdVisualModel at Zeming Fang
This is new repositories to carry all the codes we need

## run code

### step0: create a new folder, and git clone the code to the folder. 

### step1: run 's1_prepare_inputs'.
Get a 'Data' folder that is parallel to the StdVisualModel inside the new folder you made. Inside the the data folder, there are 'E', 'Stimuli', 'fMRIdata'. (You should mannually delete the downloaded zip file to keep your disk clear and tidy)

### step2: fit the model 
* run 's21_paral;el_fit_all'
* run 's22_parallel_fit_target'

### step3: run 's3_create_tables' 
Create and save tables that show r square, rmse, and parameters

### step4: run 's4_creat_plots'
Create and save plots that show the fit conditions. 

## Estimated running time 

Here I estimate the time for running 1 job based on my experience.  And 1 job means 1 dataset x 1 roi x 1 model.

* model1 'contrast':  cross_valid: 40s
* model3 'normVar': cross_valid: 40s
* model4, model6 'soc' and 'soc_bound': 
  * no_cross: .5 - 1 hrs; 
  * cross_valid: 20 - 40 hrs?
* model5 'oriSurround':
  * no_cross: 1- 2 hrs;
  * cross_valid: 60 - 100 hrs?



