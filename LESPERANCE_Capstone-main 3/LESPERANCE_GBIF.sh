#! /bin/sh

#check to ensure file was given as input
if [ $# != 1 ]
then
echo "Usage: Please input a list of files when running this script"
exit
fi

#check to see if given file exists and is not empty.
if [ -s $1 ]
then
echo "$1 exists and is not empty...Continuing"
else
echo "$1 does not exists or is an empty file...aborting"
exit
fi

#count how many files to process within input 
num=`wc -l $1 | awk '{print $1}'`
echo "This program will process $num files"

#create an array to store file names 
files=(`cat $1`)
echo "The files to process are: ${files[@]}"

touch Filtered.txt
echo -e "Species name\tPercentage filtered" >Filtered.txt

touch museum_count.txt
echo -e "Museum\tAMNH\tFMNH\tiNaturalist\tKU\tMVZ\tNHMUK\tNMR\tSMF\tUSNM\tYPM" >museum_count.txt

touch specimen_count.txt
echo -e "Specimen Type\tPRESERVED_SPECIMEN\tHUMAN_OBSERVATION\tOCCURRENCE\tMATERIAL_SAMPLE" >specimen_count.txt

touch citizen_count_per_year.txt
echo -e "Years\tCount in Mus musculus musculus records" >citizen_count_per_year.txt

touch museum_count_filtered.txt
echo -e "Museum\tAMNH\tFMNH\tiNaturalist\tKU\tMVZ\tNHMUK\tNMR\tSMF\tUSNM\tYPM" >museum_count_filtered.txt



#initialize loop 
for ((i=0; i<$num; i++))
do

    #confidence check of loop variable, file name, and that file is not empty 
    echo "Loop count: $i
    file: ${files[$i]}"   
    if [ -s ${files[$i]} ]
    then 
	    echo "${files[$i]} exists and is not empty" 
    fi 
    
    species=`awk -F'\t' 'NR==2 {print $10, $11}' ${files[$i]} | awk '{print $NF}'`
    echo "This is the mouse species Mus musculus $species"
    
    #code goes here
    mkdir -p $species
    #echo "here1"
    
    #move into species directory  
    cd $species
    #echo "here2"

    #copy the correct dataset in the corresponding subdirectory
    cp ../${files[$i]} .
    #echo "here3"

    #copying header into new file, remove header, grep for species name to ensure singular species represented in each file
    tail -n+2 ${files[$i]} > ${species}_alldata.txt
    grep -F "${species}" ${species}_alldata.txt > ${species}.txt
    #echo "worked to here!"


    #museum names as count variable 
    AMNH=$(grep -F "AMNH" ${species}.txt | wc -l)
    #echo "AMNH count is $AMNH" 
    FMNH=$(grep -F "FMNH" ${species}.txt | wc -l)
    iNaturalist=$(grep -F "iNaturalist" ${species}.txt | wc -l)
    KU=$(grep -F "KU" ${species}.txt | wc -l)
    MVZ=$(grep -F "MVZ" ${species}.txt | wc -l)
    NHMUK=$(grep -F "NHMUK" ${species}.txt | wc -l)
    NMR=$(grep -F "NMR" ${species}.txt | wc -l)
    SMF=$(grep -F "SMF" ${species}.txt | wc -l)
    USNM=$(grep -F "USNM" ${species}.txt | wc -l)
    YPM=$(grep -F "YPM" ${species}.txt | wc -l)


    echo -e "$species\t$AMNH\t$FMNH\t$iNaturalist\t$KU\t$MVZ\t$NHMUK\t$NMR\t$SMF\t$USNM\t$YPM" >>../museum_count.txt   

    #table 2 creation
    PRESERVED_SPECIMEN=$(grep -F "PRESERVED_SPECIMEN" ${species}.txt | wc -l)
    HUMAN_OBSERVATION=$(grep -F "HUMAN_OBSERVATION" ${species}.txt | wc -l)
    OCCURRENCE=$(grep -F "OCCURRENCE" ${species}.txt | wc -l)
    MATERIAL_SAMPLE=$(grep -F "MATERIAL_SAMPLE" ${species}.txt | wc -l)
    echo -e "$species\t$PRESERVED_SPECIMEN\t$HUMAN_OBSERVATION\t$OCCURRENCE\t$MATERIAL_SAMPLE" >>../specimen_count.txt

    #table 3 creation; iNaturalist for mus musculus musculus records 
    if [[ "$species" == "musculus" ]]; then 
	    grep -F "iNaturalist" ${species}.txt | awk -F'\t' '{print $33}' | sort | uniq -c | awk '{print $2 "\t" $1}' >>../citizen_count_per_year.txt
    fi 

     
	    
    #total data entries 
    tot=$(wc -l ${species}_alldata.txt | awk '{print $1}')
    echo "Total: $tot"
    
    #sort by latitude, longitude, then print name, lat, long, and museum count  
    sort -t $'\t' -k22 ${species}.txt | uniq | sort -t $'\t' -k23 | uniq | awk -F'\t' '($22 != "" && $23 != "")' > ${species}_locality.txt
    #filter for only species and lat long for the lat_long_combined file 
    awk -F'\t' -v species="$species" '($22 != "" && $23 != "") {print species, $22, $23}' ${species}_locality.txt > ${species}_latlong.txt 
    

    #table 4 
    lAMNH=$(grep -F "AMNH" ${species}_locality.txt | wc -l)
    #echo "AMNH locality count is $lAMNH" 
    lFMNH=$(grep -F "FMNH" ${species}_locality.txt | wc -l)
    liNaturalist=$(grep -F "iNaturalist" ${species}_locality.txt | wc -l)
    lKU=$(grep -F "KU" ${species}_locality.txt | wc -l)
    lMVZ=$(grep -F "MVZ" ${species}_locality.txt | wc -l)
    lNHMUK=$(grep -F "NHMUK" ${species}_locality.txt | wc -l)
    lNMR=$(grep -F "NMR" ${species}_locality.txt | wc -l)
    lSMF=$(grep -F "SMF" ${species}_locality.txt | wc -l)
    lUSNM=$(grep -F "USNM" ${species}_locality.txt | wc -l)
    lYPM=$(grep -F "YPM" ${species}_locality.txt | wc -l)

    echo -e "$species\t$lAMNH\t$lFMNH\t$liNaturalist\t$lKU\t$lMVZ\t$lNHMUK\t$lNMR\t$lSMF\t$lUSNM\t$lYPM" >>../museum_count_filtered.txt
    
   
    #count number of lines in original and filtered locality files
    filt=$(wc -l ${species}_locality.txt | awk '{print $1}')
    echo Filtered: $filt
    
    #using BC calculator to find percentage of duplicated records
    peruni=$(echo "scale=4; ($filt/$tot)* 100"| bc)
    
    echo "Percent with locality records: $peruni %" 

    echo -e "$species\t$peruni" >>../Filtered.txt

    #remove intermediate files created during the loop
    rm ${files[$i]} ${species}_alldata.txt  
    
    #return to home directory 
    cd ../
    
done


#nav to main directory to concatenate lat and long files
cat ./*/*_latlong.txt > Lat_Long_combined.txt
