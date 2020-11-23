
'use strict';

/**
 * StyleSheets represents the StyleSheets found in the source code.
 * @constructor
 */
function StyleSheets() {
  this.styleSheets = {};
}

/**
 * Add adds a StyleSheet to our StyleSheets collections.
 *
 * @param {string} styleSheetName - The name of the StyleSheet.
 * @param {object} properties - The collection of rules in the styleSheet.
 */
StyleSheets.prototype.add = function (styleSheetName, properties) {
  this.styleSheets[styleSheetName] = properties;
};

/**
 * MarkAsUsed marks a rule as used in our source code by removing it from the
 * specified StyleSheet rules.
 *
 * @param {string} fullyQualifiedName - The fully qualified name of the rule.
 * for example 'styles.text'
 */
StyleSheets.prototype.markAsUsed = function (fullyQualifiedName) {
  const nameSplit = fullyQualifiedName.split('.');
  const styleSheetName = nameSplit[0];
  const styleSheetProperty = nameSplit[1];

  if (this.styleSheets[styleSheetName]) {
    this.styleSheets[styleSheetName] = this
      .styleSheets[styleSheetName]
      .filter((property) => property.key.name !== styleSheetProperty);
  }
};

/**
 * GetUnusedReferences returns all collected StyleSheets and their
 * unmarked rules.
 */
StyleSheets.prototype.getUnusedReferences = function () {
  return this.styleSheets;
};

/**
 * AddColorLiterals adds an array of expressions that contain color literals
 * to the ColorLiterals collection
 * @param {array} expressions - an array of expressions containing color literals
 */
StyleSheets.prototype.addColorLiterals = function (expressions) {
  if (!this.colorLiterals) {
    this.colorLiterals = [];
  }
  this.colorLiterals = this.colorLiterals.concat(expressions);
};

/**
 * GetColorLiterals returns an array of collected color literals expressions
 * @returns {Array}
 */
StyleSheets.prototype.getColorLiterals = function () {
  return this.colorLiterals;
};

/**
 * AddObjectexpressions adds an array of expressions to the ObjectExpressions collection
 * @param {Array} expressions - an array of expressions containing ObjectExpressions in
 * inline styles
 */
StyleSheets.prototype.addObjectExpressions = function (expressions) {
  if (!this.objectExpressions) {
    this.objectExpressions = [];
  }
  this.objectExpressions = this.objectExpressions.concat(expressions);
};

/**
 * GetObjectExpressions returns an array of collected object expressiosn used in inline styles
 * @returns {Array}
 */
StyleSheets.prototype.getObjectExpressions = function () {
  return this.objectExpressions;
};


let currentContent;
const getSourceCode = (node) => currentContent
  .getSourceCode(node)
  .getText(node);

const getStyleSheetObjectNames = (settings) => settings['react-native/style-sheet-object-names'] || ['StyleSheet'];

const astHelpers = {
  containsStyleSheetObject: function (node, objectNames) {
    return Boolean(
      node
      && node.type === 'CallExpression'
      && node.callee
      && node.callee.object
      && node.callee.object.name
      && objectNames.includes(node.callee.object.name)
    );
  },

  containsCreateCall: function (node) {
    return Boolean(
      node
      && node.callee
      && node.callee.property
      && node.callee.property.name === 'create'
    );
  },

  isStyleSheetDeclaration: function (node, settings) {
    const objectNames = getStyleSheetObjectNames(settings);

    return Boolean(
      astHelpers.containsStyleSheetObject(node, objectNames)
      && astHelpers.containsCreateCall(node)
    );
  },

  getStyleSheetName: function (node) {
    if (node && node.parent && node.parent.id) {
      return node.parent.id.name;
    }
  },

  getStyleDeclarations: function (node) {
    if (
      node
      && node.type === 'CallExpression'
      && node.arguments
      && node.arguments[0]
      && node.arguments[0].properties
    ) {
      return node.arguments[0].properties.filter((property) => property.type === 'Property');
    }

    return [];
  },

  getStyleDeclarationsChunks: function (node) {
    if (
      node
      && node.type === 'CallExpression'
      && node.arguments
      && node.arguments[0]
      && node.arguments[0].properties
    ) {
      const { properties } = node.arguments[0];

      const result = [];
      let chunk = [];
      for (let i = 0; i < properties.length; i += 1) {
        const property = properties[i];
        if (property.type === 'Property') {
          chunk.push(property);
        } else if (chunk.length) {
          result.push(chunk);
          chunk = [];
        }
      }
      if (chunk.length) {
        result.push(chunk);
      }
      return result;
    }

    return [];
  },

  getPropertiesChunks: function (properties) {
    const result = [];
    let chunk = [];
    for (let i = 0; i < properties.length; i += 1) {
      const property = properties[i];
      if (property.type === 'Property') {
        chunk.push(property);
      } else if (chunk.length) {
        result.push(chunk);
        chunk = [];
      }
    }
    if (chunk.length) {
      result.push(chunk);
    }
    return result;
  },

  getExpressionIdentifier: function (node) {
    if (node) {
      switch (node.type) {
        case 'Identifier':
          return node.name;
        case 'Literal':
          return node.value;
        case 'TemplateLiteral':
          return node.quasis.reduce((result, quasi, index) => result
            + quasi.value.cooked
            + astHelpers.getExpressionIdentifier(node.expressions[index]),
          '');
        default:
          return '';
      }
    }

    return '';
  },

  getStylePropertyIdentifier: function (node) {
    if (
      node
      && node.key
    ) {
      return astHelpers.getExpressionIdentifier(node.key);
    }
  },

  isStyleAttribute: function (node) {
    return Boolean(
      node.type === 'JSXAttribute'
      && node.name
      && node.name.name
      && node.name.name.toLowerCase().includes('style')
    );
  },

  collectStyleObjectExpressions: function (node, context) {
    currentContent = context;
    if (astHelpers.hasArrayOfStyleReferences(node)) {
      const styleReferenceContainers = node
        .expression
        .elements;

      return astHelpers.collectStyleObjectExpressionFromContainers(
        styleReferenceContainers
      );
    } if (node && node.expression) {
      return astHelpers.getStyleObjectExpressionFromNode(node.expression);
    }

    return [];
  },

  collectColorLiterals: function (node, context) {
    if (!node) {
      return [];
    }

    currentContent = context;
    if (astHelpers.hasArrayOfStyleReferences(node)) {
      const styleReferenceContainers = node
        .expression
        .elements;

      return astHelpers.collectColorLiteralsFromContainers(
        styleReferenceContainers
      );
    }

    if (node.type === 'ObjectExpression') {
      return astHelpers.getColorLiteralsFromNode(node);
    }

    return astHelpers.getColorLiteralsFromNode(node.expression);
  },

  collectStyleObjectExpressionFromContainers: function (nodes) {
    let objectExpressions = [];
    nodes.forEach((node) => {
      objectExpressions = objectExpressions
        .concat(astHelpers.getStyleObjectExpressionFromNode(node));
    });

    return objectExpressions;
  },

  collectColorLiteralsFromContainers: function (nodes) {
    let colorLiterals = [];
    nodes.forEach((node) => {
      colorLiterals = colorLiterals
        .concat(astHelpers.getColorLiteralsFromNode(node));
    });

    return colorLiterals;
  },

  getStyleReferenceFromNode: function (node) {
    let styleReference;
    let leftStyleReferences;
    let rightStyleReferences;

    if (!node) {
      return [];
    }

    switch (node.type) {
      case 'MemberExpression':
        styleReference = astHelpers.getStyleReferenceFromExpression(node);
        return [styleReference];
      case 'LogicalExpression':
        leftStyleReferences = astHelpers.getStyleReferenceFromNode(node.left);
        rightStyleReferences = astHelpers.getStyleReferenceFromNode(node.right);
        return [].concat(leftStyleReferences).concat(rightStyleReferences);
      case 'ConditionalExpression':
        leftStyleReferences = astHelpers.getStyleReferenceFromNode(node.consequent);
        rightStyleReferences = astHelpers.getStyleReferenceFromNode(node.alternate);
        return [].concat(leftStyleReferences).concat(rightStyleReferences);
      default:
        return [];
    }
  },

  getStyleObjectExpressionFromNode: function (node) {
    let leftStyleObjectExpression;
    let rightStyleObjectExpression;

    if (!node) {
      return [];
    }

    if (node.type === 'ObjectExpression') {
      return [astHelpers.getStyleObjectFromExpression(node)];
    }

    switch (node.type) {
      case 'LogicalExpression':
        leftStyleObjectExpression = astHelpers.getStyleObjectExpressionFromNode(node.left);
        rightStyleObjectExpression = astHelpers.getStyleObjectExpressionFromNode(node.right);
        return [].concat(leftStyleObjectExpression).concat(rightStyleObjectExpression);
      case 'ConditionalExpression':
        leftStyleObjectExpression = astHelpers.getStyleObjectExpressionFromNode(node.consequent);
        rightStyleObjectExpression = astHelpers.getStyleObjectExpressionFromNode(node.alternate);
        return [].concat(leftStyleObjectExpression).concat(rightStyleObjectExpression);
      default:
        return [];
    }
  },

  getColorLiteralsFromNode: function (node) {
    let leftColorLiterals;
    let rightColorLiterals;

    if (!node) {
      return [];
    }

    if (node.type === 'ObjectExpression') {
      return [astHelpers.getColorLiteralsFromExpression(node)];
    }

    switch (node.type) {
      case 'LogicalExpression':
        leftColorLiterals = astHelpers.getColorLiteralsFromNode(node.left);
        rightColorLiterals = astHelpers.getColorLiteralsFromNode(node.right);
        return [].concat(leftColorLiterals).concat(rightColorLiterals);
      case 'ConditionalExpression':
        leftColorLiterals = astHelpers.getColorLiteralsFromNode(node.consequent);
        rightColorLiterals = astHelpers.getColorLiteralsFromNode(node.alternate);
        return [].concat(leftColorLiterals).concat(rightColorLiterals);
      default:
        return [];
    }
  },

  hasArrayOfStyleReferences: function (node) {
    return node && Boolean(
      node.type === 'JSXExpressionContainer'
      && node.expression
      && node.expression.type === 'ArrayExpression'
    );
  },

  getStyleReferenceFromExpression: function (node) {
    const result = [];
    const name = astHelpers.getObjectName(node);
    if (name) {
      result.push(name);
    }

    const property = astHelpers.getPropertyName(node);
    if (property) {
      result.push(property);
    }

    return result.join('.');
  },

  getStyleObjectFromExpression: function (node) {
    const obj = {};
    let invalid = false;
    if (node.properties && node.properties.length) {
      node.properties.forEach((p) => {
        if (!p.value || !p.key) {
          return;
        }
        if (p.value.type === 'Literal') {
          invalid = true;
          obj[p.key.name] = p.value.value;
        } else if (p.value.type === 'ConditionalExpression') {
          const innerNode = p.value;
          if (innerNode.consequent.type === 'Literal' || innerNode.alternate.type === 'Literal') {
            invalid = true;
            obj[p.key.name] = getSourceCode(innerNode);
          }
        } else if (p.value.type === 'UnaryExpression' && p.value.operator === '-' && p.value.argument.type === 'Literal') {
          invalid = true;
          obj[p.key.name] = -1 * p.value.argument.value;
        } else if (p.value.type === 'UnaryExpression' && p.value.operator === '+' && p.value.argument.type === 'Literal') {
          invalid = true;
          obj[p.key.name] = p.value.argument.value;
        }
      });
    }
    return invalid ? { expression: obj, node: node } : undefined;
  },

  getColorLiteralsFromExpression: function (node) {
    const obj = {};
    let invalid = false;
    if (node.properties && node.properties.length) {
      node.properties.forEach((p) => {
        if (p.key && p.key.name && p.key.name.toLowerCase().indexOf('color') !== -1) {
          if (p.value.type === 'Literal') {
            invalid = true;
            obj[p.key.name] = p.value.value;
          } else if (p.value.type === 'ConditionalExpression') {
            const innerNode = p.value;
            if (innerNode.consequent.type === 'Literal' || innerNode.alternate.type === 'Literal') {
              invalid = true;
              obj[p.key.name] = getSourceCode(innerNode);
            }
          }
        }
      });
    }
    return invalid ? { expression: obj, node: node } : undefined;
  },

  getObjectName: function (node) {
    if (
      node
      && node.object
      && node.object.name
    ) {
      return node.object.name;
    }
  },

  getPropertyName: function (node) {
    if (
      node
      && node.property
      && node.property.name
    ) {
      return node.property.name;
    }
  },

  getPotentialStyleReferenceFromMemberExpression: function (node) {
    if (
      node
      && node.object
      && node.object.type === 'Identifier'
      && node.object.name
      && node.property
      && node.property.type === 'Identifier'
      && node.property.name
      && node.parent.type !== 'MemberExpression'
    ) {
      return [node.object.name, node.property.name].join('.');
    }
  },

  isEitherShortHand: function (property1, property2) {
    const shorthands = ['margin', 'padding', 'border', 'flex'];
    if (shorthands.includes(property1)) {
      return property2.startsWith(property1);
    } if (shorthands.includes(property2)) {
      return property1.startsWith(property2);
    }
    return false;
  },
};

module.exports.astHelpers = astHelpers;
module.exports.StyleSheets = StyleSheets;
