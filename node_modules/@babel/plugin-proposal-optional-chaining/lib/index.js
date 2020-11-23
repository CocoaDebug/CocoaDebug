'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

var helperPluginUtils = require('@babel/helper-plugin-utils');
var helperSkipTransparentExpressionWrappers = require('@babel/helper-skip-transparent-expression-wrappers');
var syntaxOptionalChaining = require('@babel/plugin-syntax-optional-chaining');
var core = require('@babel/core');

function _interopDefaultLegacy (e) { return e && typeof e === 'object' && 'default' in e ? e : { 'default': e }; }

var syntaxOptionalChaining__default = /*#__PURE__*/_interopDefaultLegacy(syntaxOptionalChaining);

function willPathCastToBoolean(path) {
  const maybeWrapped = findOutermostTransparentParent(path);
  const {
    node,
    parentPath
  } = maybeWrapped;

  if (parentPath.isLogicalExpression()) {
    const {
      operator,
      right
    } = parentPath.node;

    if (operator === "&&" || operator === "||" || operator === "??" && node === right) {
      return willPathCastToBoolean(parentPath);
    }
  }

  if (parentPath.isSequenceExpression()) {
    const {
      expressions
    } = parentPath.node;

    if (expressions[expressions.length - 1] === node) {
      return willPathCastToBoolean(parentPath);
    } else {
      return true;
    }
  }

  return parentPath.isConditional({
    test: node
  }) || parentPath.isUnaryExpression({
    operator: "!"
  }) || parentPath.isLoop({
    test: node
  });
}
function findOutermostTransparentParent(path) {
  let maybeWrapped = path;
  path.findParent(p => {
    if (!helperSkipTransparentExpressionWrappers.isTransparentExprWrapper(p)) return true;
    maybeWrapped = p;
  });
  return maybeWrapped;
}

const {
  ast
} = core.template.expression;
var index = helperPluginUtils.declare((api, options) => {
  api.assertVersion(7);
  const {
    loose = false
  } = options;

  function isSimpleMemberExpression(expression) {
    expression = helperSkipTransparentExpressionWrappers.skipTransparentExprWrappers(expression);
    return core.types.isIdentifier(expression) || core.types.isSuper(expression) || core.types.isMemberExpression(expression) && !expression.computed && isSimpleMemberExpression(expression.object);
  }

  function needsMemoize(path) {
    let optionalPath = path;
    const {
      scope
    } = path;

    while (optionalPath.isOptionalMemberExpression() || optionalPath.isOptionalCallExpression()) {
      const {
        node
      } = optionalPath;
      const childKey = optionalPath.isOptionalMemberExpression() ? "object" : "callee";
      const childPath = helperSkipTransparentExpressionWrappers.skipTransparentExprWrappers(optionalPath.get(childKey));

      if (node.optional) {
        return !scope.isStatic(childPath.node);
      }

      optionalPath = childPath;
    }
  }

  return {
    name: "proposal-optional-chaining",
    inherits: syntaxOptionalChaining__default['default'],
    visitor: {
      "OptionalCallExpression|OptionalMemberExpression"(path) {
        const {
          scope
        } = path;
        const maybeWrapped = findOutermostTransparentParent(path);
        const {
          parentPath
        } = maybeWrapped;
        const willReplacementCastToBoolean = willPathCastToBoolean(maybeWrapped);
        let isDeleteOperation = false;
        const parentIsCall = parentPath.isCallExpression({
          callee: maybeWrapped.node
        }) && path.isOptionalMemberExpression();
        const optionals = [];
        let optionalPath = path;

        if (scope.path.isPattern() && needsMemoize(optionalPath)) {
          path.replaceWith(core.template.ast`(() => ${path.node})()`);
          return;
        }

        while (optionalPath.isOptionalMemberExpression() || optionalPath.isOptionalCallExpression()) {
          const {
            node
          } = optionalPath;

          if (node.optional) {
            optionals.push(node);
          }

          if (optionalPath.isOptionalMemberExpression()) {
            optionalPath.node.type = "MemberExpression";
            optionalPath = helperSkipTransparentExpressionWrappers.skipTransparentExprWrappers(optionalPath.get("object"));
          } else if (optionalPath.isOptionalCallExpression()) {
            optionalPath.node.type = "CallExpression";
            optionalPath = helperSkipTransparentExpressionWrappers.skipTransparentExprWrappers(optionalPath.get("callee"));
          }
        }

        let replacementPath = path;

        if (parentPath.isUnaryExpression({
          operator: "delete"
        })) {
          replacementPath = parentPath;
          isDeleteOperation = true;
        }

        for (let i = optionals.length - 1; i >= 0; i--) {
          const node = optionals[i];
          const isCall = core.types.isCallExpression(node);
          const replaceKey = isCall ? "callee" : "object";
          const chainWithTypes = node[replaceKey];
          let chain = chainWithTypes;

          while (helperSkipTransparentExpressionWrappers.isTransparentExprWrapper(chain)) {
            chain = chain.expression;
          }

          let ref;
          let check;

          if (isCall && core.types.isIdentifier(chain, {
            name: "eval"
          })) {
            check = ref = chain;
            node[replaceKey] = core.types.sequenceExpression([core.types.numericLiteral(0), ref]);
          } else if (loose && isCall && isSimpleMemberExpression(chain)) {
            check = ref = chainWithTypes;
          } else {
            ref = scope.maybeGenerateMemoised(chain);

            if (ref) {
              check = core.types.assignmentExpression("=", core.types.cloneNode(ref), chainWithTypes);
              node[replaceKey] = ref;
            } else {
              check = ref = chainWithTypes;
            }
          }

          if (isCall && core.types.isMemberExpression(chain)) {
            if (loose && isSimpleMemberExpression(chain)) {
              node.callee = chainWithTypes;
            } else {
              const {
                object
              } = chain;
              let context = scope.maybeGenerateMemoised(object);

              if (context) {
                chain.object = core.types.assignmentExpression("=", context, object);
              } else if (core.types.isSuper(object)) {
                context = core.types.thisExpression();
              } else {
                context = object;
              }

              node.arguments.unshift(core.types.cloneNode(context));
              node.callee = core.types.memberExpression(node.callee, core.types.identifier("call"));
            }
          }

          let replacement = replacementPath.node;

          if (i === 0 && parentIsCall) {
            var _baseRef;

            const object = helperSkipTransparentExpressionWrappers.skipTransparentExprWrappers(replacementPath.get("object")).node;
            let baseRef;

            if (!loose || !isSimpleMemberExpression(object)) {
              baseRef = scope.maybeGenerateMemoised(object);

              if (baseRef) {
                replacement.object = core.types.assignmentExpression("=", baseRef, object);
              }
            }

            replacement = core.types.callExpression(core.types.memberExpression(replacement, core.types.identifier("bind")), [core.types.cloneNode((_baseRef = baseRef) != null ? _baseRef : object)]);
          }

          if (willReplacementCastToBoolean) {
            const nonNullishCheck = loose ? ast`${core.types.cloneNode(check)} != null` : ast`
            ${core.types.cloneNode(check)} !== null && ${core.types.cloneNode(ref)} !== void 0`;
            replacementPath.replaceWith(core.types.logicalExpression("&&", nonNullishCheck, replacement));
            replacementPath = helperSkipTransparentExpressionWrappers.skipTransparentExprWrappers(replacementPath.get("right"));
          } else {
            const nullishCheck = loose ? ast`${core.types.cloneNode(check)} == null` : ast`
            ${core.types.cloneNode(check)} === null || ${core.types.cloneNode(ref)} === void 0`;
            const returnValue = isDeleteOperation ? ast`true` : ast`void 0`;
            replacementPath.replaceWith(core.types.conditionalExpression(nullishCheck, returnValue, replacement));
            replacementPath = helperSkipTransparentExpressionWrappers.skipTransparentExprWrappers(replacementPath.get("alternate"));
          }
        }
      }

    }
  };
});

exports.default = index;
//# sourceMappingURL=index.js.map
