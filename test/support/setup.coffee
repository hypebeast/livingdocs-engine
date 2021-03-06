# Load jquery extensions for easier testing
require('./jquery_extensions')

config = require('../../src/configuration/config')
log = require('../../src/modules/logging/log')
assert = require('../../src/modules/logging/assert')
testHelpers = require('./test_helpers')
InstanceInjector = require('./factories/instance_injector')
_ = require('underscore')


# Load chai extensions
require('./chai_helpers')
require('../../src/modules/html_compare/chai_extensions')




# Supress logs
log.debugDisabled = true
log.warningsDisabled = true

# prevent
config.loadResources = false


# Export Globals
# --------------
#
# Export globals in a browser environment
exportGlobals = (global) ->
  global.test = testHelpers


# Exports for node are done in test/node/test_globals
if window?
  exportGlobals(window)

