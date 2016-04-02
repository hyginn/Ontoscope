'use strict'

const co = require('co')
const rp = require('request-promise')
const htmlparser = require('htmlparser2')

const getty = co.wrap(function *(source, target) {
  const baseUri = 'http://www.mogrify.net/joint_reprogrammers'

  let body
  try {
    body = yield rp(`${baseUri}?source_ont=${source}&target_ont=${target}`)
  } catch (err) {
    return JSON.stringify({success: false, message: 'Request failed'})
  }

  let href

  const parser = new htmlparser.Parser({
    onopentag: (tagname, attr) => {
        if (tagname === 'a' && attr.href) {
          if (attr.href.indexOf('/reprogrammers') === 0) {
            href = attr.href
          }
        }
    }
  }, {decodeEntities: true})

  parser.write(body)
  parser.end()

  const reducee = (type) => (list, currentItem) => {
    list.push({type, val: currentItem})

    return list
  }

  href = href.split('/reprogrammers?')[1]
  let sources = (href.split(/&?[a-z]+=/)[1]).split(',').reduce(reducee('source'), [])
  let targets = (href.split(/&?[a-z]+=/)[2]).split(',').reduce(reducee('target'), [])

  const results = sources.concat(targets)

  return JSON.stringify(results)
})

// node get.js FF:0000004  FF:0010019
getty(process.argv[2], process.argv[3])
  .then((val) => console.log(val))
