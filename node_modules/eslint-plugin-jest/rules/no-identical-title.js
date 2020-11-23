'use strict';

const {
  getDocsUrl,
  isDescribe,
  isTestCase,
  isString,
  hasExpressions,
  getStringValue,
} = require('./util');

const newDescribeContext = () => ({
  describeTitles: [],
  testTitles: [],
});

const handleTestCaseTitles = (context, titles, node, title) => {
  if (isTestCase(node)) {
    if (titles.indexOf(title) !== -1) {
      context.report({
        message:
          'Test title is used multiple times in the same describe block.',
        node,
      });
    }
    titles.push(title);
  }
};

const handleDescribeBlockTitles = (context, titles, node, title) => {
  if (!isDescribe(node)) {
    return;
  }
  if (titles.indexOf(title) !== -1) {
    context.report({
      message:
        'Describe block title is used multiple times in the same describe block.',
      node,
    });
  }
  titles.push(title);
};

const isFirstArgValid = arg => {
  if (!arg || !isString(arg)) {
    return false;
  }
  if (arg.type === 'TemplateLiteral' && hasExpressions(arg)) {
    return false;
  }
  return true;
};

module.exports = {
  meta: {
    docs: {
      url: getDocsUrl(__filename),
    },
  },
  create(context) {
    const contexts = [newDescribeContext()];
    return {
      CallExpression(node) {
        const currentLayer = contexts[contexts.length - 1];
        if (isDescribe(node)) {
          contexts.push(newDescribeContext());
        }
        const [firstArgument] = node.arguments;
        if (!isFirstArgValid(firstArgument)) {
          return;
        }
        const title = getStringValue(firstArgument);
        handleTestCaseTitles(context, currentLayer.testTitles, node, title);
        handleDescribeBlockTitles(
          context,
          currentLayer.describeTitles,
          node,
          title
        );
      },
      'CallExpression:exit'(node) {
        if (isDescribe(node)) {
          contexts.pop();
        }
      },
    };
  },
};
