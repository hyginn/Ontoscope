'use strict'

// npm modules
const co = require('co')
const rp = require('request-promise')
const htmlparser = require('htmlparser2')

// co(routine).wrap a generator function so we can yield promises
// try/catch is nicer for error handling than .then,.catch
// async/await coming to ES8!
const getJaspar = co.wrap(function *(FFID) {
  const baseSStarUri = 'http://fantom.gsc.riken.jp/5/sstar/'

  // Attempt page retrieval
  let body
  try {
    body = yield rp(baseSStarUri + FFID)
  } catch (err) {
    return JSON.stringify({success: false, message: 'Request failed'})
  }

  // Flags to switch while parsing HTML
  let inTable = false
  let inMotifCell = false
  let inPValCell = false

  // Results to build
  let motifs = []
  let pvals = []

  // Helper function to check if element has a class
  const hasClass = (attr, className) => attr.class && attr.class.indexOf(className) >= 0

  const parser = new htmlparser.Parser({
    onopentag: (tagname, attr) => {
      switch (tagname) {
        case 'table':
          if (hasClass(attr, 'jaspar_motif_pval'))
            inTable = true
          break
        case 'td':
          if (hasClass(attr, 'Jaspar-motif'))
            inMotifCell = true
          else if (hasClass(attr, 'P-value'))
            inPValCell = true
          break
        default: break
      }
    },
    ontext: (text) => {
      if (inTable) {
        if (inMotifCell)
          motifs.push(text)
        else if (inPValCell)
          pvals.push(text)
      }
    },
    onclosetag: (tagname) => {
      switch (tagname) {
        case 'table':
          inTable = false
          break
        case 'td':
          if (inMotifCell)
            inMotifCell = false
          else if (inPValCell)
            inPValCell = false
          break
        default: break;
      }
    }
  }, {decodeEntities: true})

  // Run the parser
  parser.write(body)
  parser.end()

  // Reduce motifs/pvals into [{motif, pval}]
  const results = motifs.reduce((results, currentMotif, i) => {
    results.push({motif: currentMotif, pVal: pvals[i]})

    return results
  }, [])

  return JSON.stringify(results)
})

// example: node getJaspar.js FF:10017-101C8
getJaspar(process.argv[2])
  .then((val) => console.log(val))
