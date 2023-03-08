#! /bin/bash
SOURCEFILE="./data/rce-beeldbank-raw.nt"
BASEFILE="./data/rce-beeldbank-base.nt"
RECONFILE1="./data/recon-contentLocation.nt"
RECONFILE2="./data/recon-about.nt"
DESTFILE="./data/rce-beeldbank.nt" 

# perform the generic transformation without reconciled properties
sparql -q --results N-Triples\
 --data $SOURCEFILE\
 --query ./mapping/toSchema.rq > $BASEFILE

# function for creating exact matches with reference sources
createExactMatches () {

  UNIQUEVALUES="./data/distinctValues.nt"
  NORMALIZEDVALUES="./data/normalizedValues.nt"

  # extract distinct values for the subject field
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

# define vars for matching the 'spatial' field
SRCPROPERTY="<http://example.org/edm_providedCHO_spatial>"
TARGETFIELD="spatial"
MATCHQUERY="./mapping/exactMatchGeoNames.rq"
GENQUERY="./mapping/genContentLocation.rq"
RECONFILE=$RECONFILE1
# generate the additional triples using the variable defined above
createExactMatches

# define vars for matching the 'subject' field
SRCPROPERTY="<http://example.org/edm_providedCHO_subject>"
TARGETFIELD="subject"
MATCHQUERY="./mapping/exactMatchCHT.rq"
GENQUERY="./mapping/genAbout.rq"
RECONFILE=$RECONFILE2
# generate the additional triples using the variable defined above
createExactMatches  

# concated the intermediate result into the resultfile
cat $BASEFILE $RECONFILE1 $RECONFILE2 > $DESTFILE

# remove the intermediate results
rm $BASEFILE $RECONFILE1 $RECONFILE2