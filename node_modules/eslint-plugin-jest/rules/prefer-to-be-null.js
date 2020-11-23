'use strict';

const {
  getDocsUrl,
  argument,
  argument2,
  expectToBeCase,
  expectToEqualCase,
  expectNotToEqualCase,
  expectNotToBeCase,
  method,
  method2,
} = require('./util');

module.exports = {
  meta: {
    docs: {
      url: getDocsUrl(__filename),
    },
    fixable: 'code',
  },
  create(context) {
    return {
      CallExpression(node) {
        const is = expectToBeCase(node, null) || expectToEqualCase(node, null);
        const isNot =
          expectNotToEqualCase(node, null) || expectNotToBeCase(node, null);

        if (is || isNot) {
          context.report({
            fix(fixer) {
              if (is) {
                return [
                  fixer.replaceText(method(node), 'toBeNull'),
                  fixer.remove(argument(node)),
                ];
              }
              return [
                fixer.replaceText(method2(node), 'toBeNull'),
                fixer.remove(argument2(node)),
              ];
            },
            message: 'Use toBeNull() instead',
            node: is ? method(node) : method2(node),
          });
        }
      },
    };
  },
};
