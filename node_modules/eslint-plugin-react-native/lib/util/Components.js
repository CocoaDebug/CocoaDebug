/**
 * @fileoverview Utility class and functions for React components detection
 * @author Yannick Croissant
 */

'use strict';

/**
 * Components
 * @class
 */
function Components() {
  this.list = {};
  this.getId = function (node) {
    return node && node.range.join(':');
  };
}

/**
 * Add a node to the components list, or update it if it's already in the list
 *
 * @param {ASTNode} node The AST node being added.
 * @param {Number} confidence Confidence in the component detection (0=banned, 1=maybe, 2=yes)
 */
Components.prototype.add = function (node, confidence) {
  const id = this.getId(node);
  if (this.list[id]) {
    if (confidence === 0 || this.list[id].confidence === 0) {
      this.list[id].confidence = 0;
    } else {
      this.list[id].confidence = Math.max(this.list[id].confidence, confidence);
    }
    return;
  }
  this.list[id] = {
    node: node,
    confidence: confidence,
  };
};

/**
 * Find a component in the list using its node
 *
 * @param {ASTNode} node The AST node being searched.
 * @returns {Object} Component object, undefined if the component is not found
 */
Components.prototype.get = function (node) {
  const id = this.getId(node);
  return this.list[id];
};

/**
 * Update a component in the list
 *
 * @param {ASTNode} node The AST node being updated.
 * @param {Object} props Additional properties to add to the component.
 */
Components.prototype.set = function (node, props) {
  let currentNode = node;
  while (currentNode && !this.list[this.getId(currentNode)]) {
    currentNode = node.parent;
  }
  if (!currentNode) {
    return;
  }
  const id = this.getId(currentNode);
  this.list[id] = { ...this.list[id], ...props };
};

/**
 * Return the components list
 * Components for which we are not confident are not returned
 *
 * @returns {Object} Components list
 */
Components.prototype.all = function () {
  const list = {};
  Object.keys(this.list).forEach((i) => {
    if ({}.hasOwnProperty.call(this.list, i) && this.list[i].confidence >= 2) {
      list[i] = this.list[i];
    }
  });
  return list;
};

/**
 * Return the length of the components list
 * Components for which we are not confident are not counted
 *
 * @returns {Number} Components list length
 */
Components.prototype.length = function () {
  let length = 0;
  Object.keys(this.list).forEach((i) => {
    if ({}.hasOwnProperty.call(this.list, i) && this.list[i].confidence >= 2) {
      length += 1;
    }
  });
  return length;
};

function componentRule(rule, context) {
  const sourceCode = context.getSourceCode();
  const components = new Components();

  // Utilities for component detection
  const utils = {

    /**
     * Check if the node is a React ES5 component
     *
     * @param {ASTNode} node The AST node being checked.
     * @returns {Boolean} True if the node is a React ES5 component, false if not
     */
    isES5Component: function (node) {
      if (!node.parent) {
        return false;
      }
      return /^(React\.)?createClass$/.test(sourceCode.getText(node.parent.callee));
    },

    /**
     * Check if the node is a React ES6 component
     *
     * @param {ASTNode} node The AST node being checked.
     * @returns {Boolean} True if the node is a React ES6 component, false if not
     */
    isES6Component: function (node) {
      if (!node.superClass) {
        return false;
      }
      return /^(React\.)?(Pure)?Component$/.test(sourceCode.getText(node.superClass));
    },

    /**
     * Check if the node is returning JSX
     *
     * @param {ASTNode} node The AST node being checked (must be a ReturnStatement).
     * @returns {Boolean} True if the node is returning JSX, false if not
     */
    isReturningJSX: function (node) {
      let property;
      switch (node.type) {
        case 'ReturnStatement':
          property = 'argument';
          break;
        case 'ArrowFunctionExpression':
          property = 'body';
          break;
        default:
          return false;
      }

      const returnsJSX = node[property]
        && node[property].type === 'JSXElement';
      const returnsReactCreateElement = node[property]
        && node[property].callee
        && node[property].callee.property
        && node[property].callee.property.name === 'createElement';
      return Boolean(returnsJSX || returnsReactCreateElement);
    },

    /**
     * Get the parent component node from the current scope
     *
     * @returns {ASTNode} component node, null if we are not in a component
     */
    getParentComponent: function () {
      return (
        utils.getParentES6Component()
        || utils.getParentES5Component()
        || utils.getParentStatelessComponent()
      );
    },

    /**
     * Get the parent ES5 component node from the current scope
     *
     * @returns {ASTNode} component node, null if we are not in a component
     */
    getParentES5Component: function () {
      // eslint-disable-next-line react/destructuring-assignment
      let scope = context.getScope();
      while (scope) {
        const node = scope.block && scope.block.parent && scope.block.parent.parent;
        if (node && utils.isES5Component(node)) {
          return node;
        }
        scope = scope.upper;
      }
      return null;
    },

    /**
     * Get the parent ES6 component node from the current scope
     *
     * @returns {ASTNode} component node, null if we are not in a component
     */
    getParentES6Component: function () {
      let scope = context.getScope();
      while (scope && scope.type !== 'class') {
        scope = scope.upper;
      }
      const node = scope && scope.block;
      if (!node || !utils.isES6Component(node)) {
        return null;
      }
      return node;
    },

    /**
     * Get the parent stateless component node from the current scope
     *
     * @returns {ASTNode} component node, null if we are not in a component
     */
    getParentStatelessComponent: function () {
      // eslint-disable-next-line react/destructuring-assignment
      let scope = context.getScope();
      while (scope) {
        const node = scope.block;
        // Ignore non functions
        const isFunction = /Function/.test(node.type);
        // Ignore classes methods
        const isNotMethod = !node.parent || node.parent.type !== 'MethodDefinition';
        // Ignore arguments (callback, etc.)
        const isNotArgument = !node.parent || node.parent.type !== 'CallExpression';
        if (isFunction && isNotMethod && isNotArgument) {
          return node;
        }
        scope = scope.upper;
      }
      return null;
    },

    /**
     * Get the related component from a node
     *
     * @param {ASTNode} node The AST node being checked (must be a MemberExpression).
     * @returns {ASTNode} component node, null if we cannot find the component
     */
    getRelatedComponent: function (node) {
      let currentNode = node;
      let i;
      let j;
      let k;
      let l;
      // Get the component path
      const componentPath = [];
      while (currentNode) {
        if (currentNode.property && currentNode.property.type === 'Identifier') {
          componentPath.push(currentNode.property.name);
        }
        if (currentNode.object && currentNode.object.type === 'Identifier') {
          componentPath.push(currentNode.object.name);
        }
        currentNode = currentNode.object;
      }
      componentPath.reverse();

      // Find the variable in the current scope
      const variableName = componentPath.shift();
      if (!variableName) {
        return null;
      }
      let variableInScope;
      const { variables } = context.getScope();
      for (i = 0, j = variables.length; i < j; i++) { // eslint-disable-line no-plusplus
        if (variables[i].name === variableName) {
          variableInScope = variables[i];
          break;
        }
      }
      if (!variableInScope) {
        return null;
      }

      // Find the variable declaration
      let defInScope;
      const { defs } = variableInScope;
      for (i = 0, j = defs.length; i < j; i++) { // eslint-disable-line no-plusplus
        if (
          defs[i].type === 'ClassName'
          || defs[i].type === 'FunctionName'
          || defs[i].type === 'Variable'
        ) {
          defInScope = defs[i];
          break;
        }
      }
      if (!defInScope) {
        return null;
      }
      currentNode = defInScope.node.init || defInScope.node;

      // Traverse the node properties to the component declaration
      for (i = 0, j = componentPath.length; i < j; i++) { // eslint-disable-line no-plusplus
        if (!currentNode.properties) {
          continue; // eslint-disable-line no-continue
        }
        for (k = 0, l = currentNode.properties.length; k < l; k++) { // eslint-disable-line no-plusplus, max-len
          if (currentNode.properties[k].key.name === componentPath[i]) {
            currentNode = currentNode.properties[k];
            break;
          }
        }
        if (!currentNode) {
          return null;
        }
        currentNode = currentNode.value;
      }

      // Return the component
      return components.get(currentNode);
    },
  };

  // Component detection instructions
  const detectionInstructions = {
    ClassDeclaration: function (node) {
      if (!utils.isES6Component(node)) {
        return;
      }
      components.add(node, 2);
    },

    ClassProperty: function () {
      const node = utils.getParentComponent();
      if (!node) {
        return;
      }
      components.add(node, 2);
    },

    ObjectExpression: function (node) {
      if (!utils.isES5Component(node)) {
        return;
      }
      components.add(node, 2);
    },

    FunctionExpression: function () {
      const node = utils.getParentComponent();
      if (!node) {
        return;
      }
      components.add(node, 1);
    },

    FunctionDeclaration: function () {
      const node = utils.getParentComponent();
      if (!node) {
        return;
      }
      components.add(node, 1);
    },

    ArrowFunctionExpression: function () {
      const node = utils.getParentComponent();
      if (!node) {
        return;
      }
      if (node.expression && utils.isReturningJSX(node)) {
        components.add(node, 2);
      } else {
        components.add(node, 1);
      }
    },

    ThisExpression: function () {
      const node = utils.getParentComponent();
      if (!node || !/Function/.test(node.type)) {
        return;
      }
      // Ban functions with a ThisExpression
      components.add(node, 0);
    },

    ReturnStatement: function (node) {
      if (!utils.isReturningJSX(node)) {
        return;
      }
      const parentNode = utils.getParentComponent();
      if (!parentNode) {
        return;
      }
      components.add(parentNode, 2);
    },
  };

  // Update the provided rule instructions to add the component detection
  const ruleInstructions = rule(context, components, utils);
  const updatedRuleInstructions = { ...ruleInstructions };
  Object.keys(detectionInstructions).forEach((instruction) => {
    updatedRuleInstructions[instruction] = (node) => {
      detectionInstructions[instruction](node);
      return ruleInstructions[instruction] ? ruleInstructions[instruction](node) : undefined;
    };
  });
  // Return the updated rule instructions
  return updatedRuleInstructions;
}

Components.detect = function (rule) {
  return componentRule.bind(this, rule);
};

module.exports = Components;
