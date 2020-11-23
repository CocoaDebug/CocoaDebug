'use strict';

const { RuleTester } = require('eslint');
const rule = require('../no-truthy-falsy');

const ruleTester = new RuleTester();

ruleTester.run('no-truthy-falsy', rule, {
  valid: [
    'expect(true).toBe(true);',
    'expect(false).toBe(false);',
    'expect("anything").toBe(true);',
    'expect("anything").toEqual(false);',
    'expect("anything").not.toBe(true);',
    'expect("anything").not.toEqual(true);',
    'expect(Promise.resolve({})).resolves.toBe(true);',
    'expect(Promise.reject({})).rejects.toBe(true);',
  ],

  invalid: [
    {
      code: 'expect(true).toBeTruthy();',
      errors: [
        {
          message: 'Avoid toBeTruthy',
          column: 14,
          line: 1,
        },
      ],
    },
    {
      code: 'expect(false).not.toBeTruthy();',
      errors: [
        {
          message: 'Avoid toBeTruthy',
          column: 19,
          line: 1,
        },
      ],
    },
    {
      code: 'expect(Promise.resolve({})).resolves.toBeTruthy()',
      errors: [
        {
          message: 'Avoid toBeTruthy',
          column: 38,
          line: 1,
        },
      ],
    },
    {
      code: 'expect(Promise.resolve({})).rejects.toBeTruthy()',
      errors: [
        {
          message: 'Avoid toBeTruthy',
          column: 37,
          line: 1,
        },
      ],
    },
    {
      code: 'expect(false).toBeFalsy();',
      errors: [
        {
          message: 'Avoid toBeFalsy',
          column: 15,
          line: 1,
        },
      ],
    },
    {
      code: 'expect(true).not.toBeFalsy();',
      errors: [
        {
          message: 'Avoid toBeFalsy',
          column: 18,
          line: 1,
        },
      ],
    },
    {
      code: 'expect(Promise.resolve({})).resolves.toBeFalsy()',
      errors: [
        {
          message: 'Avoid toBeFalsy',
          column: 38,
          line: 1,
        },
      ],
    },
    {
      code: 'expect(Promise.resolve({})).rejects.toBeFalsy()',
      errors: [
        {
          message: 'Avoid toBeFalsy',
          column: 37,
          line: 1,
        },
      ],
    },
  ],
});
