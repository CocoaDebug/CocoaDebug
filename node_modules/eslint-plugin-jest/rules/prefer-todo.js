'use strict';

const {
  getDocsUrl,
  isFunction,
  composeFixers,
  getNodeName,
  isString,
} = require('./util');

function isOnlyTestTitle(node) {
  return node.arguments.length === 1;
}

function isFunctionBodyEmpty(node) {
  return node.body.body && !node.body.body.length;
}

function isTestBodyEmpty(node) {
  const fn = node.arguments[1]; // eslint-disable-line prefer-destructuring
  return fn && isFunction(fn) && isFunctionBodyEmpty(fn);
}

function addTodo(node, fixer) {
  const testName = getNodeName(node.callee)
    .split('.')
    .shift();
  return fixer.replaceText(node.callee, `${testName}.todo`);
}

function removeSecondArg({ arguments: [first, second] }, fixer) {
  return fixer.removeRange([first.range[1], second.range[1]]);
}

function isFirstArgString({ arguments: [firstArg] }) {
  return firstArg && isString(firstArg);
}

const isTestCase = node =>
  node &&
  node.type === 'CallExpression' &&
  ['it', 'test', 'it.skip', 'test.skip'].includes(getNodeName(node.callee));

function create(context) {
  return {
    CallExpression(node) {
      if (isTestCase(node) && isFirstArgString(node)) {
        const combineFixers = composeFixers(node);

        if (isTestBodyEmpty(node)) {
          context.report({
            message: 'Prefer todo test case over empty test case',
            node,
            fix: combineFixers(removeSecondArg, addTodo),
          });
        }

        if (isOnlyTestTitle(node)) {
          context.report({
            message: 'Prefer todo test case over unimplemented test case',
            node,
            fix: combineFixers(addTodo),
          });
        }
      }
    },
  };
}

module.exports = {
  create,
  meta: {
    docs: {
      url: getDocsUrl(__filename),
    },
    fixable: 'code',
  },
};
