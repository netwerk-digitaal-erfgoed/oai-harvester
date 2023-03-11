#! /bin/bash

source ./bin/utils.sh

# this script expects the dataset name as argument
if [ -z "$DATASET" ]
then
  echo "Error: a environment variable with dataset name must be set"
  exit
fi 

DATASETOBJ=`jq  ".[].$DATASET" $CONFIG`
if [ "$DATASETOBJ" == null ]
then
  echo "Error: Dataset definition not found in config.json"
  exit
fi

# harvest the dataset as configured in $CONFIG
npm run harvester -- --dataset=$DATASET

# the source and destination file names are read from $CONFIG
DESTFILE=$(readconfig resultFile)
SOURCEFILE=$(readconfig outputFile)
if [[ "$SOURCEFILE" == null ||  "$DESTFILE" == null ]]
then
  echo "Error: 'outputFile' or 'resultFile' not set in config.json"
  exit
fi

# define some intermediate file names
BASEFILE="./data/$DATASET-base.nt"
BASEQUERY=$(readconfig mappingQuery)
# perform the generic transformation without reconciled properties
echo "Perform a basic mapping of the raw RDF data."
sparql -q --results N-Triples\
 --data $SOURCEFILE\
 --query $BASEQUERY > $BASEFILE

# loop through the defined refinements in $CONFIG
NUMREFINEMENTS=`jq ".[].$DATASET.refinements | length" $CONFIG`
for (( i=0 ; i< $NUMREFINEMENTS; i++ ))
do 
  # read the vars for the refinement/matching form $CONFIG
  SRCPROPERTY=$(readconfig refinements[$i].srcproperty)
  TARGETFIELD=$(readconfig refinements[$i].targetfield)
  MATCHQUERY=$(readconfig refinements[$i].matchQuery)
  GENQUERY=$(readconfig refinements[$i].genQuery)
  eval RECONFILE="./data/$DATASET-refinement${i}.nt"
  if [[ "SCRPROPERTY" == null || $TARGETFIELD == null || $MATCHQUERY == null || $GENQUERY == null ]]
  then 
    echo "Error: not all required properties for refinement are defined"
    exit
  fi
  createExactMatches
done

# merge the separate refinement files in to one
rm -f "./data/$DATASET-refinement.nt"
for (( i=0 ; i< $NUMREFINEMENTS; i++ ))
do 
  cat "./data/$DATASET-refinement${i}.nt" >> "./data/$DATASET-refinement.nt"
  rm "./data/$DATASET-refinement${i}.nt"
done

# concated the intermediate result into the final resultfile
cat $BASEFILE "./data/$DATASET-refinement.nt" > $DESTFILE

# remove the intermediate results
rm $BASEFILE "./data/$DATASET-refinement.nt"

