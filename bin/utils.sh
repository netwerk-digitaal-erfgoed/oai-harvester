#! /bin/bash

# function for creating exact matches with reference sources
createExactMatches () {

  UNIQUEVALUES="./data/distinctValues.nt"
  NORMALIZEDVALUES="./data/normalizedValues.nt"
  # extract distinct values for the specified field
  echo "Extract all the distinct $TARGETFIELD values from the sources data..."
  sparql -q --data=$SOURCEFILE --results=N-Triples "
      PREFIX schema: <http://schema.org/>
      CONSTRUCT { [] schema:name ?$TARGETFIELD }
      WHERE {
        SELECT DISTINCT ?$TARGETFIELD {
          ?s $SRCPROPERTY ?o .
          BIND(LCASE(?o) as ?$TARGETFIELD)
          FILTER(!REGEX(?o,'[0-9]'))
         }
      }" > $UNIQUEVALUES

  # find exact matches for every distinct subject and store the CHT uri
  echo "Find the exact matches using the $MATCHQUERY query..."
  sparql -q --results N-Triples\
    --data $UNIQUEVALUES \
    --query $MATCHQUERY > $NORMALIZEDVALUES

  # create create a 'schema:about' record for each occurrence of the subject
  echo "Create additional normalized triples for the $TARGETFIELD values..."
  sparql -q --results N-Triples\
    --data $NORMALIZEDVALUES \
    --data $SOURCEFILE \
    --query $GENQUERY > $RECONFILE

  echo "Finished, results written to $RECONFILE"
  rm $UNIQUEVALUES $NORMALIZEDVALUES
}

readconfig() {
    #VAR=`jq  ".[].$DATASET.$1" $CONFIG`
    #--arg keyvar "$bash_var" 
    VAR=`jq ".[]|select(has(\"$DATASET\"))|.[].$1" $CONFIG` 
    VAR=$(eval echo $VAR)
    echo $VAR
}