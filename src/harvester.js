const traverse = require('traverse');
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

const mapping = JSON.parse( fs.readFileSync( config.mappingFile ) );

function cleanUp(rawValue,isURI=false){
  let strVal = rawValue.toString();
  strVal = strVal.replace(/\\/g,'');  // remove all backslahes 
  strVal = strVal.replace(/"/g,"'");  // replace all dubble quotes with single quotes
  strVal = strVal.replace(/(\r\n|\n|\r)/gm,''); // remove newlines
  if(isURI){
    strVal = strVal.replace(/:/g,"_");  // replace colon with underscore in URIs
  }
  return strVal;
}

async function listRecords () {
  const oaiPmh = new OaiPmh( config.oaiUrl ) ;
  const oaiRecords = oaiPmh.listRecords( config.oaiOptions ) ;
  const outputFile = config.outputFile ;
  fs.writeFileSync( outputFile,'',(err) => { 
    if (err) throw err;
  });
  for await ( const record of oaiRecords ) {
    fs.appendFileSync( outputFile, createNtriples(record) );
  }
}
 
function createNtriples ( record ) {

  let triples = "" ;
  traverse(mapping).forEach(function ( destField ) {
    let obj = record

    // the OAI-PMH record will always contain the identifier
    // and set specification in the header section
    const identifier = cleanUp(obj.header.identifier,true) ;
    const set = cleanUp(obj.header.setSpec,true) ;
    const uri = `<${config.defaultPrefix}${set}/${identifier}>` ;

    // find field strings in the mapping object
    if(this.isLeaf) {
        
      // register the path from the mapping object
      const path = this.path

      // walk trough the data object to find the
      // corresponding value for this field
      for( key in path){

        // if the key is found remove 
        // trim the data path
        if ( obj[path[key]] ) {
           obj = obj[path[key]]
        }
      }

      // only proceed if the a valid value is found
      if ( !obj ) { return }

      // if the value is a single string write the triple
      if ( typeof obj == 'string' ) {
        const prop = `<${config.defaultPrefix}${destField}>` ;
        const triple = `${uri} ${prop} "${cleanUp(obj)}" .\n` ;
        triples = triples + triple ;
      }

      // if the value is an array write a triple for each value
      if (Array.isArray(obj)) {
        for( val in obj ) {
            const prop = `<${config.defaultPrefix}${destField}>` ;
            const triple = `${uri} ${prop} "${cleanUp(obj[val])}" .\n` ;
            triples = triples + triple ; 
        }
      }
    }
  })
  return triples
}

listRecords() ;