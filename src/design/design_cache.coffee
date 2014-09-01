assert = require('../modules/logging/assert')
Design = require('./design')

module.exports = do ->

  designs: {}

  # Can load a design synchronously if you include the
  # design.js file before livingdocs.
  # doc.design.load(designs['yourDesign'])
  #
  # Will be extended to load designs remotely from a server:
  # Load from the default source:
  # doc.design.load('ghibli')
  #
  # Load from a custom server:
  # doc.design.load('http://yourserver.io/designs/ghibli/design.json')
  load: (designSpec) ->
    if typeof designSpec == 'string'
      assert false, 'Load design by name is not implemented yet.'
    else
      name = designSpec.config?.namespace
      return if not name? or @has(name)

      design = new Design(designSpec)
      @add(design)


  add: (design) ->
    name = design.namespace
    @designs[name] = design


  has: (name) ->
    @designs[name]?


  get: (name) ->
    assert @has(name), "Error: design '#{ name }' is not loaded."
    @designs[name]


  resetCache: ->
    @designs = {}

