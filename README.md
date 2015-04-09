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
* unittests/test_all.m - run all unit tests

[AXA]: https://www.kaggle.com/c/axa-driver-telematics-analysis 