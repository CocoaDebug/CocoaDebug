'use strict';

const { getDocsUrl, getNodeName, scopeHasLocalReference } = require('./util');

module.exports = {
  meta: {
    docs: {
      url: getDocsUrl(__filename),
    },
    fixable: 'code',
    messages: {
      illegalGlobal:
        'Illegal usage of global `{{ global }}`, prefer `{{ replacement }}`',
      illegalMethod:
        'Illegal usage of `{{ method }}`, prefer `{{ replacement }}`',
      illegalFail:
        'Illegal usage of `fail`, prefer throwing an error, or the `done.fail` callback',
      illegalPending:
        'Illegal usage of `pending`, prefer explicitly skipping a test using `test.skip`',
      illegalJasmine: 'Illegal usage of jasmine global',
    },
  },
  create(context) {
    return {
      CallExpression(node) {
        const calleeName = getNodeName(node.callee);

        if (!calleeName) {
          return;
        }
        if (
          calleeName === 'spyOn' ||
          calleeName === 'spyOnProperty' ||
          calleeName === 'fail' ||
          calleeName === 'pending'
        ) {
          if (scopeHasLocalReference(context.getScope(), calleeName)) {
            // It's a local variable, not a jasmine global.
            return;
          }

          switch (calleeName) {
            case 'spyOn':
            case 'spyOnProperty':
              context.report({
                node,
                messageId: 'illegalGlobal',
                data: { global: calleeName, replacement: 'jest.spyOn' },
              });
              break;
            case 'fail':
              context.report({
                node,
                messageId: 'illegalFail',
              });
              break;
            case 'pending':
              context.report({
                node,
                messageId: 'illegalPending',
              });
              break;
          }
          return;
        }

        if (calleeName.startsWith('jasmine.')) {
          const functionName = calleeName.replace('jasmine.', '');

          if (
            functionName === 'any' ||
            functionName === 'anything' ||
            functionName === 'arrayContaining' ||
            functionName === 'objectContaining' ||
            functionName === 'stringMatching'
          ) {
            context.report({
              fix(fixer) {
                return [fixer.replaceText(node.callee.object, 'expect')];
              },
              node,
              messageId: 'illegalMethod',
              data: {
                method: calleeName,
                replacement: `expect.${functionName}`,
              },
            });
            return;
          }

          if (functionName === 'addMatchers') {
            context.report({
              node,
              messageId: 'illegalMethod',
              data: {
                method: calleeName,
                replacement: `expect.extend`,
              },
            });
            return;
          }

          if (functionName === 'createSpy') {
            context.report({
              node,
              messageId: 'illegalMethod',
              data: {
                method: calleeName,
                replacement: 'jest.fn',
              },
            });
            return;
          }

          context.report({
            node,
            messageId: 'illegalJasmine',
          });
        }
      },
      MemberExpression(node) {
        if (node.object.name === 'jasmine') {
          if (node.parent.type === 'AssignmentExpression') {
            if (node.property.name === 'DEFAULT_TIMEOUT_INTERVAL') {
              context.report({
                fix(fixer) {
                  return [
                    fixer.replaceText(
                      node.parent,
                      `jest.setTimeout(${node.parent.right.value})`
                    ),
                  ];
                },
                node,
                message: 'Illegal usage of jasmine global',
              });
              return;
            }

            context.report({
              node,
              message: 'Illegal usage of jasmine global',
            });
          }
        }
      },
    };
  },
};
