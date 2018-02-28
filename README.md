# StdVisualModel
This is new repositories to carry all the codes we need

### To use these code you should do the following steps
* **Step 0. Prepare for the fitting.** 
Download the code from Github and Download data from **Data** folder from google drive. Enter **Data** folder and copy all 5 folders (**Stimuli , ROImean, fMRIdata, fitResults and E**) to the folder you store your code. 

* **Step 1. Calculate ROImean.**
Run **s1_get_ROImean.m** to get the mean of ROI region and store them into folder **ROImean**. This part takes less than 30s. 

* **Step 2. Calculate Energy of the image.**
Run **s2_get_E.m** to calculate the Energy of model and store them into folder **E**. This part takes about 15 mintues. 

* **Step 3. Fit the model and generate the tables and figures.**
Run **s3_main_script.m** to fit the model and achieve the estimated parameters, lots of tables, figures. This is one of the most time consuming part, so we can choose to fit only when we need to. Usually,  combo like: 1 ROI + 4 datasets + 4 orientaion models fitting takes about 4 hours to do all the cross-validation. 1 ROI + 1 dataset + SOC model fitting takes about 12 hours. Use chooseData function to choose the ROI and model you are interested in. 

* **Step 4. Fit the two main stimulus class.**
Run **s4_fit_target_stimuli.m** to fit the model to two main stimulus classes. In this step, you do the model fitting, calculate R square, estimate parameters, just like what happen in step three except the stimul. Since I fit 5 models to 4 datasets, the whole step takes about 4 hours. 

**Note:** 
* 1. These steps are mostly sequential and skipping on step will lead to failutre in runing the following model. 
* 2. If you want to use the results I do, go to the **Results\Data**, and copy all 3 folders (**ROImean, fitResults, E**) to replace the folders with the same name. 
* 3. What are these scripts for: 
  * a. cal_prediction: Fit the built-in or input data, generate parameters, BOLD prediction, and R squares.
  * b. cross_validation: Do cal_prediction in a leave out cross validation way.
  * c. chooseData: A little tools helps in selecting dataset.
  * d. fitSOCwithoutTarget: Fit SOC model to the stimulus classes that does not contain those two main stimulus classes.
  * e. FUNF: Function used in model fitting.
  * f. gen_disk: Generate a disk to prevent edge effect.
  * g. Icontrast: Do the convolution and calculate the energy of the images.
  * h. makeGaborFilter: Create Gabor filters. 
