# AXA-Driver-Telematics-Analysis
 
This project aim to design a solution to the
[AXA Driver Telematics challenge][AXA] on Kaggle.
 
The repository includes code of my solution with additional code
implementing ideas which where release after the competition had ended. 
 
## Code overview:
 
* scripts/sample_the_dataset.m - create _positive_ and _negative_ data sets
  for local evaluation purposes. It lets you define and import:
    * The driver of interests trips batch (_positive data set_)
    * The number of arbitrary irrelevant trips (_negative data set_) 
* scripts/local_evaluation.m - use k-fold cv to assess model AUC
  performance
* functions/getTelematicMeasurements - this function takes the Cartesian
  coordinates $(X,Y)$ of a trip, rotate them with regard to the centroid
  mean, and calculate measurements with respect to the time dimension,
  such as: speed, acceleration, distance, and orientation at each sec 
* functions/getSpatialMeasurements - this function takes the Cartesian
  coordinates $(X,Y)$ of a trip, simplified it by removing the time 
  dimension utilizing RDP (Ramer–Douglas–Peucker), and making coordinates
  pairs of equally spaced length.
* scripts/preprocess_the_dataset split the 547,200 `csv` files into N 
  `mat` files on disk for further analysis.
* unittests/test_all.m - run all unit tests
 
## How to Run a demo
 
* Download the project files
* Download all the data files from [Kaggle][AXA_DATA]
* Run _scripts/sample_the_dataset.R_ 
* Run the different scripts and reports, especially 
  _script/local_evaluation.R_
 
## How to Run a full submission
 
* Download the project files
* Download all the data files from [Kaggle][AXA_DATA]
* Run _scripts/preprocess_the_dataset.R_ 
* Run the different models within _models_ directory
* The submission file will appear by default at submission folder.
 

[AXA]: https://www.kaggle.com/c/axa-driver-telematics-analysis 
[AXA_DATA]: http://www.kaggle.com/c/axa-driver-telematics-analysis/data