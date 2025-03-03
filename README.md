# LESPERANCE_Capstone

## Determining locality and collection information on GBIF sample collections 

This README details how to identify the percent of records that have locality information for a given dataset of sample collections, as well as count data for which museums hold certain specimens/data, and when the data was collected.

Part A and B for capstone 3 are below. These parts detail how to determine the locality, museum, and specimen type information from a database. Capstone 4, which does the same thing as well as generating a map of the data, is detailed below capstone 3. The tables and graphics for Capstone 4 were generated in R. In this repository, you can find the script for both linux and R. 


### Part A -- Capstone 3 
Part A of the project was geared towards improving efficiency of the script; more pipes were incorporated into this script than the previous one for capstone 2, as well as improved comments and confidence checks within the loop ensuring that the input file for each species exists and is not empty. 

### Part B -- Capstone 3
You will want to have all of the data files within your working directory and a text file with a list of all the files you want to analyze and filter with this script. This text file will be your `input_file` . 

The script creates a few different text files containing data from the csv files: Filtered.txt, museum_count.txt, specimen_count.txt, citizen_count_per_year.txt, and museum_count_filtered.txt. 
Species names and corresponding filtered records from each species will be directed into these files once the script is run, given that the appropriate input file is incorporated. 

Once these have been defined, you can create an array. This step looks like: 

`files=$(cat $1)` 

where $1 is the input file that contains a list of all the data files for processing. Then, when you create a for loop, you can set your loop variable as your array and it will read each document that is associated with the ID in the array. 

A variable with the species name from each file is also created. A directory will be made for each species. 

To remove the headers from the files, a tail command is used, moving the data into a file named species_alldata.txt. That data file will then be searched through via grep to ensure that ONLY the species (defined as the variable $species) you want is represented in that data set. Data from other species will not be incorporated into the new file, `${species}.txt` . 

#### Table 1
The museum_count.txt table can be made by creating variables for each museum name. The general format for this is: 
`museum_name=$(grep -F "museum_name" ${species}.txt | wc -l)`
For the AMNH museum, this looks like: 
`AMNH=$(grep -F "AMNH" ${species}.txt | wc -l)`

Grep looks through the filtered species.txt file for the occurrance of "museum_name", then pipes that into wc -l to generate the number of times that museum name appears in the data file for that species. 
An echo statement follows, printing each museum variable in the appropriate order to match the columns named outside of the loop. 

#### Table 2 
The specimen_count.txt is created in a similar fashion to table 1, but the variables are changed to specimen types (preserved, material, etc.). This has the same grep syntax piped into wc -l, then printed to the .txt file. The table is shown below: 

| Specimen Type | PRESERVED SPECIMEN | HUMAN OBSERVATION | OCCURRENCE | MATERIAL SAMPLE |
| ---------- | ------ | ----- | ----- | ----- |
| castaneus | 1690 | 10 | 1314 | 37 |
| domesticus | 202 | 486 | 193 | 0|
| musculus | 83026 | 98791 | 18287 | 1825 |
| molossinus | 47 | 0 | 0 | 0 |
| spretus | 16101 | 9137 | 15264 | 580 |


#### Table 3 
The citizen_count_per_year.txt file is slightly different because it focuses on a singular data file. Since this is inside of the loop, we need a conditional statement so that this analysis is not run during each iteration of the loop. The conditional statement is set up to where it will only run if the $species = musculus
If it is, then grep will search for iNaturalist data, print the year of data collection, then count the unique instances of this, printing the year and number of data collections produced during that year to the .txt file. 


Next, we are looking for data that includes location. Sorting the files by columns 22 and 23 (latitude and longitude coordinates) and piping them into uniq will ensure that they are organized before piped into awk to produce the species_locality.txt file. The conditions for awk here are set so that only columns with data in fields 22 and 23 are put into the locality file. This locality file will be the input to generate table 4. 

After these have been sorted, `awk` will extract the latitude and longitude columns ONLY IF there is data in these columns. The syntax for awk to print the columns if they are not empty is: 
`awk -F'\t' -v species="$species" '($22 != "" && $Y != "") {print species, $22, $23}' ${species}_locality.txt > ${species}_latlong.txt`
the -v species="$species" tells awk that there is a variable included in the print statement to be included in the output file. This is necessary for the final combined latitude and longitude file. 

#### Table 4 
Museum_count_filtered.txt is then created the exact same way as table 1 was, except I have added the letter "l" in front of each museum code when creating the variables in order to differentiate from the variables created in table 1. Here is what it looks like: 
`lAMNH=$(grep -F "AMNH" ${species}_locality.txt | wc -l)` 

The total and filterd files are calculated and stored as variables $tot and $filt from the original text file (species_alldata.txt) and the filtered locality file (species_locality.txt), respectively. The percent of unique records is calculated with bc calculator, which is then echoed to standard out, as well as echoed to the filtered.txt file. 

Finally, before the loop ends, the intermediate files are removed. In this script, there is only one text file produced as an intermediate: species_alldata.txt . 

The last line of the script is a concatenation command to combine all of the species_latlong.txt files into a singular Lat_Long_combined.txt file in the main directory. 

The output file (Filtered.txt) is below in a table. 


| Species | Percent Filtered |
| ---------- | ------ |
| castaneus | 18.06% |
| domesticus | 98.83% |
| musculus | 83.19% |
| molossinus | 23.4% |
| spretus | 94.78% |

### Part A -- Capstone 4
#### Map of species locality 
This map was generated using R (see Part A script for details). Each of the five species with locality data are plotted on the map, represented by different shades of pink/purple. 

![species_map](https://github.com/user-attachments/assets/d70abf46-33d0-4377-a528-e5bbae7febf0)

To generate this map, the locality data (latitude and longitude columns) for each species/subspecies was subsetted. Each axis was labeled, as well as the graph as a whole. With the dimensions required by the instructions for class, the latitude title was cut off, if you expand the width of the graph, this will be fixed. Each species/subspecies was assigned a color for representation on the map. When doing this, make sure that the individual with the largest number of data points is run first in the commands so that those with less population data can be shown on top. If you do it the other way around, you will not be able to visualize all of the data.  

### Part B -- Capstone 4
This section does the same as capstone 3, except the linux script has been translated into R so that it is executable with Rstudio. 
When you look at the code and compare it to capstone 3, you can see a lot of similarities. For example, you still define the species list, museums, and specimen types, as well as creating variables for input into the tables. The code utilizes a loop again, with the data being parsed appropriately and attributed to its corresponding data frames prior to writing the final csv data tables. 

### Motivation for usage 
This can be used for a multidude of reasons! The script can be modified to filter data so that it isn't just based on locality. For instance, if your files contain phenotypic data, you can adjust the awk columns to only look at and filter by a specific phenotype! 
