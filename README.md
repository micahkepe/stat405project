# NYC Crash Data Analysis

## Prerequisites and Data Setup

To run the code in this repository, you will need to have the following installed:

-   RStudio
-   R
-   git

Additionally, make sure to install `git lfs` to handle large files. If using Homebrew, you can install it with the following command:

``` bash
brew install git-lfs
```

git lfs is used to handle the large `.zip` file in the `data` folder. If you do not have `git lfs` installed, you will encounter errors when trying to clone the repository or create changes.

To populate your local repository with the data, extract the `data.zip` file in the `data` folder. This will create a folder called `data` with the three `.csv` files inside. Move the contents of the `data` folder to the `data` folder in the root of the repository and delete the empty `data` folder. The `.csv` files should now be in the `data` folder in the root of the repository and will not be tracked by `git lfs`.

If you are having trouble with `git lfs`, contact the repository owner for the direct zip file.


## About the Data

via [NYC OpenData](https://data.cityofnewyork.us/Public-Safety/Motor-Vehicle-Collisions-Crashes/h9gi-nx95/about_data):

"The Motor Vehicle Collisions crash table contains details on the crash event. Each row represents a crash event. The Motor Vehicle Collisions data tables contain information from all police reported motor vehicle collisions in NYC. The police report (MV104-AN) is required to be filled out for collisions where someone is injured or killed, or where there is at least \$1000 worth of damage."

The data sets we used are:
1.  `Motor Vehicle Collisions - Crashes`: This data set contains information about the crashes themselves, such as the date, time, and location of the crash, as well as the number of people injured and killed.
2.  `Motor Vehicle Collisions - Persons`: This data set contains information about the people involved in the crashes, such as their age, their unique identifier, etc.
3.  `Motor Vehicle Collisions - Vehicles`: This data set contains information about the vehicles involved in the crashes, such as the vehicle type, the vehicle make, etc.

For a more detailed breakdown of the data sets used and how they relate, please see the data dictionary located in the `data` folder. This file details the foreign keys and their corresponding tables, as well as the data types and descriptions of each column in the data set.

## Data Analyses

To see our incremental data analysis, please see the `reports` folder. This folder contains both the `.qmd` files and their corresponding `.pdf` files of each of our report iterations.

## Contributors

-   [Kevin Lei](https://www.linkedin.com/in/lei-kevin/)
-   [Giulia Costantini](https://www.linkedin.com/in/costantini-giulia/)
-   [Zachary Kepe](https://www.linkedin.com/in/zachary-kepe-6801b7241/)
-   [Micah Kepe](https://www.linkedin.com/in/micah-kepe/)

*This project was created as part of STAT 405 at Rice University.*
