# Crash Tests and Safety for Service Robots

-------------
Data, analysis, and models of crash testing between service robots and pedestrians.
-------------

<p align="center">
<img src="https://github.com/epfl-lasa/crash-tests-service-robots/blob/main/figures/Safety_Mobile_Service_Robots.png"  width="500"></>	
	
Requirements:
```
Data files are in .xlsx format
Scripts for plots require matlab2020 +
Scripts for Injury risk metrics require matlab2020 +

Setup:
git clone https://github.com/epfl-lasa/service_robots_collisions.git

Dowload the Dataset with raw and processed sensor information from: https://doi.org/10.5281/zenodo.5266447 [1]

Create a folder on the parent directory: "../collision_data"

Place the following folders from the dataset in this directory:
    collision_test_analysis
    collision_test_data
    data_metrics
    data_raw
```
-------------
This repository includes data of collisions between a service robot - Qolo - and pedestrian dummies: male adult Hybrid-III (H3) and child model 3-years-old (Q3).
You will find scripts to read and plot the data, as well as, analysis of the injury risk based on standard crash testing metrics: Head Injury Criteria (HIC-15), Neck Injury (Nij), Chest deflection, and tibia forces.

Further descriptions of the scenarios included in this data can be found in the supplementary materials of the referenced publication.

## Repository Structure

### Data

All data should be contained on the parent directory on a folder with the name "collision_data", for direct execution of the functions provided.
Alternatively, give the directory location of the dataset downlowded from [2].

structure: Test#/01_values/test_num_name_CFC1000 (xlsx) --> This files contain the data processed with CFC1000 filter (considered Raw for the current sensor setup)

Raw data in a single struct for Adult 50-percentile Dummy H3:
data_raw/H3_raw_collision_struct.mat

Raw data in a single struct for Child Dummy Q3:
data_raw/Q3_raw_collision_struct.mat

Filtered data:
data_raw/filtered_collision_struct.mat

    % List of data recordings
    % % Each scenario comprises 3 speeds at contact --> [1.0, 1.5, 3.1] [m/s]
    % 4 setups with the child dumm Q3 (3-years-old dummy) [1.05m height / 15kg weight]
    % %     Setup A: Dummy Q3 impact at the Chest - [133kg carrier robot]
    % %     Setup A2: Dummy Q3 impact at the Chest - [60kg carrier robot]
    % %     Setup B: Dummy Q3 impact at the Head - [133kg carrier robot]
    % %     Setup C: Dummy Q3 impact at the Legs (Tibia / fibia)  - [133kg carrier robot]

    % 1 setups with adult dumm HIII (50-percentile adult) [1.77m height / 81.5kg weight] 
    % %     Setup D: Dummy H3 impact at the Legs (Tibia / fibia)  - [133kg carrier robot]
	

### Analysis

analysis_scripts/ : 

Data pipelines for modelling, risk assessment and other statistics to operate on the cleaned dataset. 
Also, it contains visualization functions.

### Visualization

figures/ : 
Contains visualization for all data, raw and processed by name.

### Preprocessing

collision_models/ : 

Collision models tested and built from the validated data are described here, with examples.


### Collision Scenarios with Q3 Dummy (Child 3-year-old 50% percentile)

Qolo robot with dummy drive H3
Robot mass: 133 Kg
Differential velocity at collision time: [1.0, 1.5, 3.0] [m/s]

Setup A: Collision at chest height.
Robot mass: 60 Kg [dotted lines] vs. 133 kg [solid lines]
Chest Deflection
<p align="center">
<img src="https://github.com/epfl-lasa/service_robots_collisions/blob/master/figures/Deflection%20Q3-Chest-Robot-%5B60-133%20kg%5D.png"  width="750"></>

Chest Deflection vs. Impact Force ratio
<p align="center">
<img src="https://github.com/epfl-lasa/service_robots_collisions/blob/master/figures/Deflection-Force%20ratio%20Q3-Chest.png"  width="750"></>

Head Acceleration at the Chest Impact
<p align="center">
<img src="https://github.com/epfl-lasa/service_robots_collisions/blob/master/figures/Head-Acceleration-Impact%20Q3-Chest-Robot%5B60kg%20vs%20130kg%5D.png"  width="750"></>

Head Acceleration at the ground Impact
<p align="center">
<img src="https://github.com/epfl-lasa/service_robots_collisions/blob/master/figures/Head-Acceleration-Ground%20Q3-Chest-Robot%5B133Kg%5D.png"  width="750"></>


Setup A: Collision at chest height. Robot mass: 133 kg.
<p align="center">
<img src="https://github.com/epfl-lasa/service_robots_collisions/blob/master/figures/Impact%20Q3-Chest-Robot%5B133Kg%5D.png"  width="750"></>

<p align="center">
<img src="https://github.com/epfl-lasa/service_robots_collisions/blob/master/figures/Deflection%20Q3-Chest-Robot%20%5B133Kg%5D.png"  width="750"></>

Setup A: Collision at chest height. Robot mass: 60 kg.

<p align="center">
<img src="https://github.com/epfl-lasa/service_robots_collisions/blob/master/figures/Impact%20Q3-Chest-Robot%5B60Kg%5D.png"  width="750"></>

<p align="center">
<img src="https://github.com/epfl-lasa/service_robots_collisions/blob/master/figures/Deflection%20Q3-Chest-Robot%20%5B60Kg%5D.png"  width="750"></>


Setup B: Collision at head height. Robot mass: 133 kg.

Impact Forces
<p align="center">
<img src="https://github.com/epfl-lasa/service_robots_collisions/blob/master/figures/Impact%20Q3-Head-Robot%20%5B133Kg%5D.png"  width="750"></>

Head Acceleration at Blunt Direct Impact
<p align="center">
<img src="https://github.com/epfl-lasa/service_robots_collisions/blob/master/figures/Head-Acceleration-Impact%20Q3-Head-Robot%5B133Kg%5D.png"  width="750"></>

Head Acceleration at Ground Impact
<p align="center">
<img src="https://github.com/epfl-lasa/service_robots_collisions/blob/master/figures/Head-Acceleration-Ground%20Q3-Head-Robot%5B133Kg%5D.png"  width="750"></>


Setup C: Collision at Legs height. Robot mass: 133 kg.
<p align="center">
<img src="https://github.com/epfl-lasa/service_robots_collisions/blob/master/figures/Impact%20Q3-Legs-Robot%20%5B133Kg%5D.png"  width="750"></>

### Collision Scenarios with H3 Dummy (Male Adult 50% percentile)

Qolo robot with dummy drive H3
Robot mass: 133 Kg
Differential velocity at collision time: [1.0, 1.5, 3.0] [m/s]

Impact Forces
<p align="center">
<img src="https://github.com/epfl-lasa/service_robots_collisions/blob/master/figures/Impact%20H3_Legs%20-%20Robot%20%5B133Kg%5D.png"  width="750"></>

Right-leg Tibia Compression Forces
<p align="center">
<img src="https://github.com/epfl-lasa/service_robots_collisions/blob/master/figures/Injury-Tibia-loRFz-H3_Legs-Robot-%5B133Kg%5D.png"  width="750"></>

Right-leg Tibia Lateral Forces
<p align="center">
<img src="https://github.com/epfl-lasa/service_robots_collisions/blob/master/figures/Tibia-loRFy-H3_Legs-Robot-%5B133Kg%5D.png"  width="750"></>

Left-leg Tibia Compression Forces
<p align="center">
<img src="https://github.com/epfl-lasa/service_robots_collisions/blob/master/figures/Injury-Tibia-loLFz-H3_Legs-Robot-%5B133Kg%5D.png"  width="750"></>

Left-leg Tibia Lateral Forces
<p align="center">
<img src="https://github.com/epfl-lasa/service_robots_collisions/blob/master/figures/Tibia-loLFy-H3_Legs-Robot-%5B133Kg%5D.png"  width="750"></>


Head Acceleration at Ground Impact
<p align="center">
<img src="https://github.com/epfl-lasa/service_robots_collisions/blob/master/figures/Head-Acceleration-Ground%20H3-Legs-Robot%5B133Kg%5D.png"  width="750"></>


**References**

[1] Paez-Granados D., and Billard, A. “Risks posed by new mobility devices and service robots to pedestrians”. 2021. (Under review)

[2] Paez-Granados, Diego, & Billard, Aude. (2021). Service Robots Crash Testing with Pedestrians: Children and Adult Dummies (1.0) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.5266447.

**Contact**: 
[Diego Paez] 


**Acknowledgments**
This project was partially funded by the EU Horizon 2020 Project CROWDBOT (Grant No. 779942).
