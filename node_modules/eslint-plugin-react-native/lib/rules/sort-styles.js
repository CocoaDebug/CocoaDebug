/**
 * @fileoverview Rule to require StyleSheet object keys to be sorted
 * @author Mats Byrkjeland
 */

'use strict';

//------------------------------------------------------------------------------
// Requirements
//------------------------------------------------------------------------------

const { astHelpers } = require('../util/stylesheet');

const {
  getStyleDeclarationsChunks,
  getPropertiesChunks,
  getStylePropertyIdentifier,
  isStyleSheetDeclaration,
  isEitherShortHand,
} = astHelpers;

//------------------------------------------------------------------------------
// Rule Definition
//------------------------------------------------------------------------------

module.exports = (context) => {
  const order = context.options[0] || 'asc';
  const options = context.options[1] || {};
  const { ignoreClassNames } = options;
  const { ignoreStyleProperties } = options;
  const isValidOrder = order === 'asc' ? (a, b) => a <= b : (a, b) => a >= b;

  const sourceCode = context.getSourceCode();

  function sort(array) {
    return [].concat(array).sort((a, b) => {
      const identifierA = getStylePropertyIdentifier(a);
      const identifierB = getStylePropertyIdentifier(b);

      let sortOrder = 0;
      if (isEitherShortHand(identifierA, identifierB)) {
        return a.range[0] - b.range[0];
      } if (identifierA < identifierB) {
        sortOrder = -1;
      } else if (identifierA > identifierB) {
        sortOrder = 1;
      }
      return sortOrder * (order === 'asc' ? 1 : -1);
    });
  }

  function report(array, type, node, prev, current) {
    const currentName = getStylePropertyIdentifier(current);
    const prevName = getStylePropertyIdentifier(prev);
    const hasComments = array
      .map((prop) => sourceCode.getComments(prop))
      .reduce(
        (hasComment, comment) => hasComment || comment.leading.length > 0 || comment.trailing > 0,
        false
      );

    context.report({
      node,
      message: `Expected ${type} to be in ${order}ending order. '${currentName}' should be before '${prevName}'.`,
      loc: current.key.loc,
      fix: hasComments ? undefined : (fixer) => {
        const sortedArray = sort(array);
        return array
          .map((item, i) => {
            if (item !== sortedArray[i]) {
              return fixer.replaceText(
                item,
                sourceCode.getText(sortedArray[i])
              );
            }
            return null;
          })
          .filter(Boolean);
      },
    });
  }

  function checkIsSorted(array, arrayName, node) {
    for (let i = 1; i < array.length; i += 1) {
      const previous = array[i - 1];
      const current = array[i];

      if (previous.type !== 'Property' || current.type !== 'Property') {
        return;
      }

      const prevName = getStylePropertyIdentifier(previous);
      const currentName = getStylePropertyIdentifier(current);

      if (
        arrayName === 'style properties'
        && isEitherShortHand(prevName, currentName)
      ) {
        return;
      }

      if (!isValidOrder(prevName, currentName)) {
        return report(array, arrayName, node, previous, current);
      }
    }
  }

  return {
    CallExpression: function (node) {
      if (!isStyleSheetDeclaration(node, context.settings)) {
        return;
      }

      const classDefinitionsChunks = getStyleDeclarationsChunks(node);

      if (!ignoreClassNames) {
        classDefinitionsChunks.forEach((classDefinitions) => {
          checkIsSorted(classDefinitions, 'class names', node);
        });
      }

      if (ignoreStyleProperties) return;

      classDefinitionsChunks.forEach((classDefinitions) => {
        classDefinitions.forEach((classDefinition) => {
          const styleProperties = classDefinition.value.properties;
          if (!styleProperties || styleProperties.length < 2) {
            return;
          }
          const stylePropertyChunks = getPropertiesChunks(styleProperties);
          stylePropertyChunks.forEach((stylePropertyChunk) => {
            checkIsSorted(stylePropertyChunk, 'style properties', node);
          });
        });
      });
    },
  };
};

module.exports.fixable = 'code';
module.exports.schema = [
  {
    enum: ['asc', 'desc'],
  },
  {
    type: 'object',
    properties: {
      ignoreClassNames: {
        type: 'boolean',
      },
      ignoreStyleProperties: {
        type: 'boolean',
      },
    },
    additionalProperties: false,
  },
];
