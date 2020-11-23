
'use strict'

if (process.env.NODE_ENV === 'production') {
  module.exports = require('./hermes-profile-transformer.cjs.production.min.js')
} else {
  module.exports = require('./hermes-profile-transformer.cjs.development.js')
}
