'use strict'

// Node core modules
const fs = require('fs')
const path = require('path')

// npm modules; you will need to `npm install`
const _ = require('highland')
const ld = require('lodash')
const obo = require('bionode-obo')
const graph = require('graph.js/dist/graph.full.js')

// Settings
const INPUT_FILE = process.argv[2]
const OUTPUT_STREAM = fs.createWriteStream(process.argv[3])

// Initializing an empty graph
const g = new graph()
let counter = 0
let termNums = {}

const writeEdge = (source, target) => {
  return '\tedge [\n' +
    '\t\tsource ' + termNums[source] + '\n' +
    '\t\ttarget ' + termNums[target] + '\n' +
    '\t\tlabel "' + source+'-'+target + '"\n' +
  '\t]\n'
}

const doneReading = () => {
  let it = g.vertices()
  let kv = it.next()
  let term

  while (!kv.done) {
    term = kv.value[1] 
    
    if (term.is_a) {
      const parent = ld.trim(term.is_a.split('!')[0])
      g.addNewEdge(term.id, parent)
      OUTPUT_STREAM.write(writeEdge(term.id, parent))
    } else {
      console.log('Root node: ', term.name)
    }
    
    kv = it.next()
  }

  OUTPUT_STREAM.write(']')
}

const termWriter = (term, id) => {
  const props = [
    'alt_id',
    'comment',
    'created_by',
    'creation_date',
    'def',
    'disjoint_from',
    'equivalent_to',
    'format-version',
    // 'id',
    'intersection_of',
    'is_a',
    'is_transitive',
    'name',
    'namespace',
    'ontology',
    'relationship',
    'subset',
    'subsetdef',
    'synonym',
    'transitive_over',
    'union_of',
    'xref'
  ]

  let str = '\tnode [\n'
  str += '\t\tid ' + id + '\n'

  props.forEach( (prop) => {
    if (term[prop]) {
      str += '\t\t' + prop + ' "' + term[prop] + '"\n'
    } 
  })

  str += '\t]\n'
  return str
}

const main = () => {
  OUTPUT_STREAM.write('graph [\n')
  _(obo.terms(fs.createReadStream(__dirname + '/' + INPUT_FILE)))
    .each( (term) => {
      termNums[term.id] = counter
      g.addNewVertex(term.id, term)
      OUTPUT_STREAM.write(termWriter(term, counter))
      
      counter++

      // .done() not working since my stream emits events..which
      // there is no way to tell when its finished..so sketchily
      // check array length for now
      if (g.vertexCount() === 6170) {
        doneReading()
      } 
    })
    //.done(() => console.log('done'))
}

main()
