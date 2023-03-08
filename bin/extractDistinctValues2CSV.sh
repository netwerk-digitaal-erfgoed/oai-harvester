#! /bin/bash

SPARQL_FILTER_CHAR_ONLY="FILTER(!REGEX(?o,'[0-9]'))"
includeNumbers="0"

# parse arguments
for ARGUMENT in "$@"
do
   KEY=$(echo $ARGUMENT | cut -f1 -d=)

   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+1}"

   export "$KEY"="$VALUE"
done

if [ -z $inputfile ] || [ -z $property ] || [ -z $outputfile ] || [ -z $colname ]
then 
  echo "Error: one or more parameters missing, required argumements are:
  inputfile='name of RDF input file'
  property='source property to select'
  outputfile='name of CSV output file'
  colname='header of result column in CSV'

Optional parameter:
  includeNumbers=1 (default=0: ignore values with numbers)"

  exit
fi

if [ $includeNumbers == "1" ]
then
  # clear the FILTER statement 
  SPARQL_FILTER_CHAR_ONLY=""
fi

# build the query 
QUERY=$(cat <<EOF
SELECT DISTINCT ?$colname (COUNT(?s) as ?total) {
    ?s $property ?o .
    BIND(CONCAT("'",REPLACE(LCASE(?o),","," "),"'") as ?$colname)
    $SPARQL_FILTER_CHAR_ONLY
} GROUP BY ?$colname ORDER BY ?$colname
EOF
)

# write the query to a temp file to pass it to the Jena sparql command
echo $QUERY > temp.rq

# execute the query and write the result as a CSV file 
sparql -q --data $inputfile --results=CSV --query=temp.rq > $outputfile

# remove temp file
rm temp.rq