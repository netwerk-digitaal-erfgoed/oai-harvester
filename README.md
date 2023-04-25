# oai-harvester

Node based OAI-PMH harverster with additional processing. 

Basic Node and Bash script to perform the following actions:

- harvest a dataset from a specified OAI-PMH endpoint (see mapping/config.json)
- automatic conversion to RDF (ntriples) using a simple one-to-one transformation (see mapping/dcn-mapping.json)
- RDF to RDF semantic transformation using SPARQL construct queries (see bin/transform-rce-beeldbank.sh)
- including automatic enrichment with exact matches from extern terminology sources

This setup requires the JENA commandline tools (SPARQL tool) to be installed, Node.js and the jq tool.

To run the pipeline:
```
$ export DATASET=<dataset name>
$ export CONFIG=mappings/config.json
$ bin/harvester-and-transform.sh 
```

The 'dataset name' must be defined in the ./mapping/config.json.

A more convient way to run this software is to use docker, follow the instructions below.

## Install
Clone the repository and build the Docker image.
```
$ git clone https://github.com/netwerk-digitaal-erfgoed/oai-harvester.git
$ docker compose build
```

## Configure

Adjust the settings in the config.json file in the mappings directory. 

Repeat the docker compose build command after each change. 

Tip: specify a harvest from date to the 'oaiOptions' object like 'from: 2023-03-01' to run the pipeline with small batches.

Note: the 'dataset name' is also used in docker-compose.yml

## Run
Start the harvest and conversion with the following command:
```
$ docker-compose up
```
