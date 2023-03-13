const fs = require('fs');
const { OaiPmh } = require('oai-pmh2');

const DATASET=process.env.DATASET
const CONFIG=process.env.CONFIG
let config = {}
if (!DATASET || !CONFIG) {
  console.log("Please set environment vars DATASET and CONFIG") ;
  return
} else {
  console.log(`Config used: ${CONFIG}`) ;
  console.log(`Dataset used: ${DATASET}`) ;
  const configfile = JSON.parse( fs.readFileSync(process.env.CONFIG) );
  for(index in configfile) {
    if(configfile[index][DATASET]) {
      config = configfile[index][DATASET] ;
    }
  }
  if( config == {} ) {
    console.log("No valid dataset definition found!") ;
    return ;
  }
}

async function createSample () {
  const oaiPmh = new OaiPmh( config.oaiUrl ) ;
  const oaiRecords = oaiPmh.listRecords( config.oaiOptions ) ;
  const outputFile = "./data/sample.json" ;
  fs.writeFileSync( outputFile,'',(err) => { 
    if (err) throw err;
  });
  let count=1;
  for await ( const record of oaiRecords ) {
    fs.appendFileSync( outputFile, JSON.stringify(record)+"\n" );
    if(count++>10) {
     console.log(`The first 10 records are written as JSON objects to ${outputFile}`)
     return }
  }
}

createSample() ;