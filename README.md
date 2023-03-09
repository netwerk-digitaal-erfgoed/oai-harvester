# oai-harvester

Node bases OAI-PMH harverster with additional processing. 

Basic node and bash script to perform the following actions:

- harvest a dataset from a specified OAI endpoint (see mapping/config.json)
- automatic conversion to RDF (ntriples) using a simple one-to-one transformation (see mapping/dcn-mapping.json)
- RDF to RDF semantic transformation using sparql construct queries (see bin/transform-rce-beeldbank.sh)
- including automatic enrichment with exact matches from extern terminology sources

This setup requires the JENA commandline tools (sparql tool) to be installed and Node.js.

To run the harvester:
``
$ npm run harvester -- --dataset=<dataset name>
``

The 'dataset name' must be defined in the ./mapping/config.json.