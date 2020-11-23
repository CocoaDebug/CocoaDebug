/**
 * @fileoverview Android and IOS components should be
 * used in platform specific React Native components.
 * @author Tom Hastjarjanto
 */

'use strict';

module.exports = function (context) {
  let reactComponents = [];
  const androidMessage = 'Android components should be placed in android files';
  const iosMessage = 'IOS components should be placed in ios files';
  const conflictMessage = 'IOS and Android components can\'t be mixed';
  const iosPathRegex = context.options[0] && context.options[0].iosPathRegex
    ? new RegExp(context.options[0].iosPathRegex)
    : /\.ios\.js$/;
  const androidPathRegex = context.options[0] && context.options[0].androidPathRegex
    ? new RegExp(context.options[0].androidPathRegex)
    : /\.android\.js$/;

  function getName(node) {
    if (node.type === 'Property') {
      const key = node.key || node.argument;
      return key.type === 'Identifier' ? key.name : key.value;
    } if (node.type === 'Identifier') {
      return node.name;
    }
  }

  function hasNodeWithName(nodes, name) {
    return nodes.some((node) => {
      const nodeName = getName(node);
      return nodeName && nodeName.includes(name);
    });
  }

  function reportErrors(components, filename) {
    const containsAndroidAndIOS = (
      hasNodeWithName(components, 'IOS')
      && hasNodeWithName(components, 'Android')
    );

    components.forEach((node) => {
      const propName = getName(node);

      if (propName.includes('IOS') && !filename.match(iosPathRegex)) {
        context.report(node, containsAndroidAndIOS ? conflictMessage : iosMessage);
      }

      if (propName.includes('Android') && !filename.match(androidPathRegex)) {
        context.report(node, containsAndroidAndIOS ? conflictMessage : androidMessage);
      }
    });
  }

  return {
    VariableDeclarator: function (node) {
      const destructuring = node.init && node.id && node.id.type === 'ObjectPattern';
      const statelessDestructuring = destructuring && node.init.name === 'React';
      if (destructuring && statelessDestructuring) {
        reactComponents = reactComponents.concat(node.id.properties);
      }
    },
    ImportDeclaration: function (node) {
      if (node.source.value === 'react-native') {
        node.specifiers.forEach((importSpecifier) => {
          if (importSpecifier.type === 'ImportSpecifier') {
            reactComponents = reactComponents.concat(importSpecifier.imported);
          }
        });
      }
    },
    'Program:exit': function () {
      const filename = context.getFilename();
      reportErrors(reactComponents, filename);
    },
  };
};

module.exports.schema = [{
  type: 'object',
  properties: {
    androidPathRegex: {
      type: 'string',
    },
    iosPathRegex: {
      type: 'string',
    },
  },
  additionalProperties: false,
}];
