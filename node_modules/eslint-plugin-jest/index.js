'use strict';

const fs = require('fs');
const path = require('path');

const rules = fs
  .readdirSync(path.join(__dirname, 'rules'))
  .filter(rule => rule !== '__tests__' && rule !== 'util.js')
  .map(rule => path.basename(rule, '.js'))
  .reduce(
    (acc, curr) => Object.assign(acc, { [curr]: require(`./rules/${curr}`) }),
    {}
  );

const snapshotProcessor = require('./processors/snapshot-processor');

module.exports = {
  configs: {
    recommended: {
      plugins: ['jest'],
      env: {
        'jest/globals': true,
      },
      rules: {
        'jest/no-alias-methods': 'warn',
        'jest/no-disabled-tests': 'warn',
        'jest/no-focused-tests': 'error',
        'jest/no-identical-title': 'error',
        'jest/no-jest-import': 'error',
        'jest/no-jasmine-globals': 'warn',
        'jest/no-test-prefixes': 'error',
        'jest/valid-describe': 'error',
        'jest/valid-expect': 'error',
        'jest/valid-expect-in-promise': 'error',
      },
    },
    style: {
      plugins: ['jest'],
      rules: {
        'jest/prefer-to-be-null': 'error',
        'jest/prefer-to-be-undefined': 'error',
        'jest/prefer-to-contain': 'error',
        'jest/prefer-to-have-length': 'error',
      },
    },
  },
  environments: {
    globals: {
      globals: {
        afterAll: false,
        afterEach: false,
        beforeAll: false,
        beforeEach: false,
        describe: false,
        expect: false,
        fit: false,
        it: false,
        jasmine: false,
        jest: false,
        pending: false,
        pit: false,
        require: false,
        test: false,
        xdescribe: false,
        xit: false,
        xtest: false,
      },
    },
  },
  processors: {
    '.snap': snapshotProcessor,
  },
  rules,
};
