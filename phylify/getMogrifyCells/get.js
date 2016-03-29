'use strict'

// npm modules
const co = require('co')
const rp = require('request-promise')
const htmlparser = require('htmlparser2')
const fs = require('fs')

// co(routine).wrap a generator function so we can yield promises
// try/catch is nicer for error handling than .then,.catch
// async/await coming to ES8!
const getJaspar = co.wrap(function *() {
  const baseUri = 'http://www.mogrify.net/'

  // Attempt page retrieval
  let body
  try {
    body = yield rp(baseUri)
  } catch (err) {
    return JSON.stringify({success: false, message: 'Request failed'})
  }

  // Flags to switch while parsing HTML
  let cellTypes = []

  // Helper function to check if element has a class
  const hasClass = (attr, className) => attr.class && attr.class.indexOf(className) >= 0

  const parser = new htmlparser.Parser({
    onopentag: (tagname, attr) => {
        if (tagname === 'option' && attr.value) {
          const val = attr.value
          if (cellTypes.indexOf(val) === -1) {
            cellTypes.push(val)
          }
        }
    },
    // ontext: (text) => {
    //   if (inOption) {
    //     console.log('foo')
    //   }
    // },
    // onclosetag: (tagname) => {
    //   if (inOption) {
    //     console.log('foo')
    //   }
    // }
  }, {decodeEntities: true})

  // Run the parser
  parser.write(body)
  parser.end()

  const results = cellTypes.reduce((results, currentCellID) => {
    results.push({ID: currentCellID})

    return results
  }, [])

  return JSON.stringify(results)
})

getJaspar()
  .then((val) => fs.writeFileSync('mogrify-cellIDs.json', val))
