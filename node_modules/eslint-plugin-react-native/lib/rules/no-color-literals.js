/**
 * @fileoverview Detects color literals
 * @author Aaron Greenwald
 */

'use strict';

const util = require('util');
const Components = require('../util/Components');
const styleSheet = require('../util/stylesheet');

const { StyleSheets } = styleSheet;
const { astHelpers } = styleSheet;

module.exports = Components.detect((context) => {
  const styleSheets = new StyleSheets();

  function reportColorLiterals(colorLiterals) {
    if (colorLiterals) {
      colorLiterals.forEach((style) => {
        if (style) {
          const expression = util.inspect(style.expression);
          context.report({
            node: style.node,
            message: 'Color literal: {{expression}}',
            data: { expression },
          });
        }
      });
    }
  }

  return {
    CallExpression: (node) => {
      if (astHelpers.isStyleSheetDeclaration(node, context.settings)) {
        const styles = astHelpers.getStyleDeclarations(node);

        if (styles) {
          styles.forEach((style) => {
            const literals = astHelpers.collectColorLiterals(style.value, context);
            styleSheets.addColorLiterals(literals);
          });
        }
      }
    },

    JSXAttribute: (node) => {
      if (astHelpers.isStyleAttribute(node)) {
        const literals = astHelpers.collectColorLiterals(node.value, context);
        styleSheets.addColorLiterals(literals);
      }
    },

    'Program:exit': () => reportColorLiterals(styleSheets.getColorLiterals()),
  };
});

module.exports.schema = [];
