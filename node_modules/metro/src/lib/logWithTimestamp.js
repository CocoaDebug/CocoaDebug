/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 *
 * @format
 */
"use strict";

function _toConsumableArray(arr) {
  return (
    _arrayWithoutHoles(arr) || _iterableToArray(arr) || _nonIterableSpread()
  );
}

function _nonIterableSpread() {
  throw new TypeError("Invalid attempt to spread non-iterable instance");
}

function _iterableToArray(iter) {
  if (
    Symbol.iterator in Object(iter) ||
    Object.prototype.toString.call(iter) === "[object Arguments]"
  )
    return Array.from(iter);
}

function _arrayWithoutHoles(arr) {
  if (Array.isArray(arr)) {
    for (var i = 0, arr2 = new Array(arr.length); i < arr.length; i++)
      arr2[i] = arr[i];
    return arr2;
  }
}

const chalk = require("chalk");

const formatLogTimestamp = require("./formatLogTimestamp");

const groupStack = [];
let collapsedGuardTimer;
/**
 * Automatically adds a timestamp and color-coded level tag and handles
 * grouping like console.
 */

function logWithTimestamp(terminal, level) {
  if (level === "group") {
    groupStack.push(level);
  } else if (level === "groupCollapsed") {
    groupStack.push(level);
    clearTimeout(collapsedGuardTimer); // Inform users that logs get swallowed if they forget to call `groupEnd`.

    collapsedGuardTimer = setTimeout(() => {
      if (groupStack.includes("groupCollapsed")) {
        terminal.log(
          chalk.inverse.yellow.bold(" WARN "),
          "Expected `console.groupEnd` to be called after `console.groupCollapsed`."
        );
        groupStack.length = 0;
      }
    }, 3000);
  } else if (level === "groupEnd") {
    const popped = groupStack.pop();

    if (popped == null) {
      terminal.log(
        chalk.inverse.yellow.bold(" WARN "),
        "`console.groupEnd` called with no group started."
      );
    }

    if (groupStack.length === 0) {
      clearTimeout(collapsedGuardTimer);
    }

    return;
  }

  if (level === "groupCollapsed" || !groupStack.includes("groupCollapsed")) {
    const ci = chalk.inverse;
    const color =
      level === "error" ? ci.red : level === "warn" ? ci.yellow : ci.white;
    const levelTag = color.bold(` ${level.toUpperCase()} `);
    const justify = "".padEnd(5 - level.length, " ") + " ";
    const groupInset = "".padEnd(groupStack.length * 2, ".") + " ";

    for (
      var _len = arguments.length,
        args = new Array(_len > 2 ? _len - 2 : 0),
        _key = 2;
      _key < _len;
      _key++
    ) {
      args[_key - 2] = arguments[_key];
    }

    terminal.log.apply(
      terminal,
      [formatLogTimestamp(new Date()) + levelTag + justify + groupInset].concat(
        _toConsumableArray(
          level === "groupCollapsed"
            ? args.concat([chalk.dim(" (viewable in debugger)")])
            : args
        )
      )
    );
  }
}

module.exports = logWithTimestamp;
