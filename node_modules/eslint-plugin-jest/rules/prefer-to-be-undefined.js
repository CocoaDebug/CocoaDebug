'use strict';

const {
  argument,
  argument2,
  expectToBeCase,
  expectNotToBeCase,
  expectToEqualCase,
  expectNotToEqualCase,
  getDocsUrl,
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
        const is =
          expectToBeCase(node, undefined) || expectToEqualCase(node, undefined);
        const isNot =
          expectNotToEqualCase(node, undefined) ||
          expectNotToBeCase(node, undefined);

        if (is || isNot) {
          context.report({
            fix(fixer) {
              if (is) {
                return [
                  fixer.replaceText(method(node), 'toBeUndefined'),
                  fixer.remove(argument(node)),
                ];
              }
              return [
                fixer.replaceText(method2(node), 'toBeUndefined'),
                fixer.remove(argument2(node)),
              ];
            },
            message: 'Use toBeUndefined() instead',
            node: is ? method(node) : method2(node),
          });
        }
      },
    };
  },
};
