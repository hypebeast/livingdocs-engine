// Chai
chai = require('chai');
expect = chai.expect;

// Jsdom
// Define window for jQuery.
jsdom = require("jsdom");
window = jsdom.jsdom().parentWindow;

// Livingdocs Test Helpers
require('../support/setup');

// Setup global variables for tests
log = require('../../src/modules/logging/log')
assert = require('../../src/modules/logging/assert')

test = require('../support/test_helpers');

$ = test.$;
_ = require('underscore')

config = require('../../src/configuration/defaults')
docClass = config.docClass

