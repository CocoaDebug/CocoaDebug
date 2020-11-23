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

const chalk = require("chalk");

const stripAnsi = require("strip-ansi");

const util = require("util");

const _require = require("metro-core"),
  Terminal = _require.Terminal;

/**
 * A standard way to log a warning to the terminal. This should not be called
 * from some arbitrary Metro logic, only from the reporters. Instead of
 * calling this, add a new type of ReportableEvent instead, and implement a
 * proper handler in the reporter(s).
 */
function logWarning(terminal, format) {
  for (
    var _len = arguments.length,
      args = new Array(_len > 2 ? _len - 2 : 0),
      _key = 2;
    _key < _len;
    _key++
  ) {
    args[_key - 2] = arguments[_key];
  }

  const str = util.format.apply(util, [format].concat(args));
  terminal.log("%s: %s", chalk.yellow("warning"), str);
}
/**
 * Similar to `logWarning`, but for messages that require the user to act.
 */

function logError(terminal, format) {
  for (
    var _len2 = arguments.length,
      args = new Array(_len2 > 2 ? _len2 - 2 : 0),
      _key2 = 2;
    _key2 < _len2;
    _key2++
  ) {
    args[_key2 - 2] = arguments[_key2];
  }

  terminal.log(
    "%s: %s",
    chalk.red("error"), // Syntax errors may have colors applied for displaying code frames
    // in various places outside of where Metro is currently running.
    // If the current terminal does not support color, we'll strip the colors
    // here.
    util.format.apply(
      util,
      [chalk.supportsColor ? format : stripAnsi(format)].concat(args)
    )
  );
}
/**
 * A reporter that does nothing. Errors and warnings will be swallowed, that
 * is generally not what you want.
 */

const nullReporter = {
  update() {}
};
module.exports = {
  logWarning,
  logError,
  nullReporter
};
