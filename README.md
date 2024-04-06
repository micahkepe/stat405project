# NYC Crash Data Analysis

## Table of Contents
- [Prequisites](#prerequisites)
- [Data Setup](#data-setup)
- [About the Data](#about-the-data)
- [Data Analyses](#data-analyses)
- [Live Demo of the Shiny App](#live-demo-of-the-shiny-app)
- [Running the Shiny App Locally (Optional)](#running-the-shiny-app-locally-optional)
- [Contributors](#contributors)

## Prerequisites

To run the code in this repository, you will need to have the following installed:

-   RStudio
-   R
-   git

## Data Setup

The link to the SQLite database used can be found [here](https://www.dropbox.com/scl/fo/ure76b4mdginkf0b2b235/h?rlkey=4h36pnk51rj48v71ng6kbhv4d&dl=0)

To populate your local repository with the database, download the database from the link above and move it to the `data` folder in the root of the repository. The database should be named `nyc_crash_data.db`. If the `data` folder does not exist, create it in the root of the repository.

The original CSV files used to create the database were the most up-to-date data sets available at the time of the project. The data sets were downloaded from the NYC OpenData website and can be found [here](https://data.cityofnewyork.us/Public-Safety/Motor-Vehicle-Collisions-Crashes/h9gi-nx95), [here](https://data.cityofnewyork.us/Public-Safety/Motor-Vehicle-Collisions-Person/f55k-p6yu), and [here](https://data.cityofnewyork.us/Public-Safety/Motor-Vehicle-Collisions-Vehicles/xe9j-u5d6).

## About the Data

via [NYC OpenData](https://data.cityofnewyork.us/Public-Safety/Motor-Vehicle-Collisions-Crashes/h9gi-nx95/about_data):

"The Motor Vehicle Collisions crash table contains details on the crash event. Each row represents a crash event. The Motor Vehicle Collisions data tables contain information from all police reported motor vehicle collisions in NYC. The police report (MV104-AN) is required to be filled out for collisions where someone is injured or killed, or where there is at least \$1000 worth of damage."

The data sets we used are:

1\. `Motor Vehicle Collisions - Crashes`: This data set contains information about the crashes themselves, such as the date, time, and location of the crash, as well as the number of people injured and killed.

2\. `Motor Vehicle Collisions - Persons`: This data set contains information about the people involved in the crashes, such as their age, their unique identifier, etc.

3\. `Motor Vehicle Collisions - Vehicles`: This data set contains information about the vehicles involved in the crashes, such as the vehicle type, the vehicle make, etc.

For a more detailed breakdown of the data sets used and how they relate, please see the data dictionary located in the `data` folder. This file details the foreign keys and their corresponding tables, as well as the data types and descriptions of each column in the data set.

## Data Analyses

To see our incremental data analysis, please see the `reports` folder. This folder contains both the `.qmd` files and their corresponding `.pdf` files of each of our report iterations.

## Live Demo of the Shiny App
- Check out the demo of our Shiny app [here](https://micahkepe.shinyapps.io/NYC-Crashes/).

## Running the Shiny App Locally (Optional)

The Shiny app can be run by opening the `app.R` file in the in `app/` directory in RStudio and clicking the "Run App" button in the top right corner of the script editor. This will open the app in a new window in your default web browser. (Note: You will have needed to have run the code in the `report_final.qmd` file to populate the database before running the Shiny app.)

## Contributors

-   [Micah Kepe](https://www.linkedin.com/in/micah-kepe/)
-   [Zachary Kepe](https://www.linkedin.com/in/zachary-kepe-6801b7241/)
-   [Kevin Lei](https://www.linkedin.com/in/lei-kevin/)
-   [Giulia Costantini](https://www.linkedin.com/in/costantini-giulia/)
