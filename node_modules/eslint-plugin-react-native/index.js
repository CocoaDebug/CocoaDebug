/* eslint-disable global-require */

'use strict';

const allRules = {
  'no-unused-styles': require('./lib/rules/no-unused-styles'),
  'no-inline-styles': require('./lib/rules/no-inline-styles'),
  'no-color-literals': require('./lib/rules/no-color-literals'),
  'sort-styles': require('./lib/rules/sort-styles'),
  'split-platform-components': require('./lib/rules/split-platform-components'),
  'no-raw-text': require('./lib/rules/no-raw-text'),
  'no-single-element-style-arrays': require('./lib/rules/no-single-element-style-arrays'),
};

function configureAsError(rules) {
  const result = {};
  for (const key in rules) {
    if (!rules.hasOwnProperty(key)) {
      continue;
    }
    result['react-native/' + key] = 2;
  }
  return result;
}

const allRulesConfig = configureAsError(allRules);

module.exports = {
  deprecatedRules: {},
  rules: allRules,
  rulesConfig: {
    'no-unused-styles': 0,
    'no-inline-styles': 0,
    'no-color-literals': 0,
    'sort-styles': 0,
    'split-platform-components': 0,
    'no-raw-text': 0,
    'no-single-element-style-arrays': 0
  },
  environments: {
    'react-native': {
      globals: require('eslint-plugin-react-native-globals').environments.all.globals,
    },
  },
  configs: {
    all: {
      plugins: [
        'react-native',
      ],
      parserOptions: {
        ecmaFeatures: {
          jsx: true,
        },
      },
      rules: allRulesConfig,
    },
  },
};
