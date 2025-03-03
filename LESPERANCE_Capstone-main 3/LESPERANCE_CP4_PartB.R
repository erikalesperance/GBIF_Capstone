## Capstone 4, Part B 
## November 19, 2024 

#load packages needed for script to run 
library(dplyr)
library(tidyr)
library(stringr)
library(data.table)

#set working directory 
setwd('/Users/erikalesperance/Desktop/Grad_school/Computational_bio/Capstone4/')

#read in the data files 
#Bcastaneus=read.table("castaneus.txt", sep = "\t", headers=FALSE, fill=TRUE, quote="")
#Bdomesticus=read.table("domesticus.txt", sep = "\t", headers=FALSE, fill=TRUE)
#Bmolossinus=read.table("molossinus.txt", sep = "\t", headers=FALSE, fill=TRUE)
#Bmusculus=read.table("musculus.txt", sep = "\t", headers=FALSE, fill=TRUE, quote="")
#Bspretus=read.table("spretus.txt", sep = "\t", headers=FALSE, fill=TRUE)

#define the species file names and museum names 
#list of files into species_list for loop creation 
species_list=c("castaneus.txt", "domesticus.txt", "molossinus.txt", "musculus.txt", "spretus.txt")
#list museums to count 
museums=c("AMNH", "FMNH" ,"iNaturalist", "KU", "MVZ", "NHMUK", 
          "NMR", "SMF", "USNM", "YPM")
#list specimen types for counts 
specimen_types=c("PRESERVED_SPECIMEN", "HUMAN_OBSERVATION", "OCCURRENCE", "MATERIAL_SAMPLE")

#create empty tables 
museum_count=data.frame(Species=character(), Museum=character(), Count=integer())
specimen_count=data.frame(Species=character(), SpecimenType=character(), Count=integer())
citizen_count_per_year=data.frame(Species=character(), year=integer(), Count=integer())
museum_count_filtered=data.frame(Species=character(), Museum=character(), Count=integer())


#list to store rows for results
museum_count_rows=list()
specimen_count_rows=list()
citizen_count_rows=list()
filtered_museum_count_rows=list()

#loop through each of the files! 
for (file in species_list) {
  species_data=read.delim(file, header=FALSE, stringsAsFactors = FALSE, fill=TRUE)
  species=sub("\\.txt$", "", basename(file))
  message ("Yay!!! Proeccesing species: ", species)
  
  #museum counts
  museum_counts = sapply(museums, function(museum) sum(grepl(museum, species_data[[37]])))
  #combine species and counts into data frame row 
  row=data.frame(Species=species, t(as.data.frame(museum_counts)))
  museum_count_rows[[length(museum_count_rows) +1]] = row 
  
  #specimen counts 
  specimen_count=sapply(specimen_types, function(specimen_types) sum(grepl(specimen_types, species_data[[36]])))
  #combine species and counts into data frame row 
  row=data.frame(Species=species, t(as.data.frame(specimen_count)))
  specimen_count_rows[[length(specimen_count_rows) +1 ]] = row 
  
  #citizen data for iNaturalist records with musculus 
  if (species == "musculus") {
    iNaturalist_data = subset(species_data, grepl("iNaturalist", species_data[[37]]))
    years = iNaturalist_data[[33]]
    year_counts = as.data.frame(table(years))
    year_counts = setNames(year_counts, c("Year", "Count"))
    year_counts$Species = species
    citizen_count_rows[[length(citizen_count_rows) + 1]] = year_counts
  }
  
  #filtered museum counts 
  validated_rows = !is.na(species_data[[22]]) & species_data[[22]] != "" &
    !is.na(species_data[[23]]) & species_data[[23]] != ""
  filt_data = species_data[validated_rows, ]
  #use sum and grepl to count occurrences of museums
  filtered_counts = sapply(museums, function(museum) sum(grepl(museum, filt_data[[37]])))
  
  #combine species and counts into data frame row, same way as above for the unfiltered museum counts 
  row = data.frame(Species = species, t(as.data.frame(filtered_counts)))
  filtered_museum_count_rows[[length(filtered_museum_count_rows) + 1]] = row
}

#museum count results 
museum_count_table=do.call(rbind, museum_count_rows)
colnames(museum_count_table) = c("Species", museums)

write.csv2(museum_count_table, "museum_count.csv", row.names=FALSE, quote=FALSE) 
print(museum_count_table)

#specimen type results 
specimen_count_table=do.call(rbind, specimen_count_rows)
colnames(specimen_count_table) = c("Species", specimen_types)
write.csv2(specimen_count_table, "specimen_count.csv", row.names=FALSE, quote=FALSE)
print(specimen_count_table)

#citizen iNaturalist results 
citizen_count_per_year = do.call(rbind, citizen_count_rows)
write.csv2(citizen_count_per_year, "citizen_count_per_year.csv", row.names = FALSE, quote = FALSE)
print(citizen_count_per_year)

#filtered museum count results 
filtered_museum_count = do.call(rbind, filtered_museum_count_rows)
colnames(filtered_museum_count) = c("Species", museums)
write.csv2(filtered_museum_count, "museum_count_filtered.csv", row.names = FALSE, quote = FALSE)
print(filtered_museum_count)
