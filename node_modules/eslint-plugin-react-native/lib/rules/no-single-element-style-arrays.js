/**
 * @fileoverview Enforce no single element style arrays
 * @author Michael Gall
 */

'use strict';

module.exports = {
  meta: {
    docs: {
      description:
        'Disallow single element style arrays. These cause unnecessary re-renders as the identity of the array always changes',
      category: 'Stylistic Issues',
      recommended: false,
      url: '',
    },
    fixable: 'code',
  },

  create(context) {
    function reportNode(JSXExpressionNode) {
      context.report({
        node: JSXExpressionNode,
        message:
          'Single element style arrays are not necessary and cause unnecessary re-renders',
        fix(fixer) {
          const realStyleNode = JSXExpressionNode.value.expression.elements[0];
          const styleSource = context.getSourceCode().getText(realStyleNode);
          return fixer.replaceText(JSXExpressionNode.value.expression, styleSource);
        },
      });
    }

    // --------------------------------------------------------------------------
    // Public
    // --------------------------------------------------------------------------
    return {
      JSXAttribute(node) {
        if (node.name.name !== 'style') return;
        if (node.value.expression.type !== 'ArrayExpression') return;
        if (node.value.expression.elements.length === 1) {
          reportNode(node);
        }
      },
    };
  },
};
