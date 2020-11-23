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

function _slicedToArray(arr, i) {
  return (
    _arrayWithHoles(arr) || _iterableToArrayLimit(arr, i) || _nonIterableRest()
  );
}

function _nonIterableRest() {
  throw new TypeError("Invalid attempt to destructure non-iterable instance");
}

function _iterableToArrayLimit(arr, i) {
  var _arr = [];
  var _n = true;
  var _d = false;
  var _e = undefined;
  try {
    for (
      var _i = arr[Symbol.iterator](), _s;
      !(_n = (_s = _i.next()).done);
      _n = true
    ) {
      _arr.push(_s.value);
      if (i && _arr.length === i) break;
    }
  } catch (err) {
    _d = true;
    _e = err;
  } finally {
    try {
      if (!_n && _i["return"] != null) _i["return"]();
    } finally {
      if (_d) throw _e;
    }
  }
  return _arr;
}

function _arrayWithHoles(arr) {
  if (Array.isArray(arr)) return arr;
}

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

function _objectSpread(target) {
  for (var i = 1; i < arguments.length; i++) {
    var source = arguments[i] != null ? arguments[i] : {};
    var ownKeys = Object.keys(source);
    if (typeof Object.getOwnPropertySymbols === "function") {
      ownKeys = ownKeys.concat(
        Object.getOwnPropertySymbols(source).filter(function(sym) {
          return Object.getOwnPropertyDescriptor(source, sym).enumerable;
        })
      );
    }
    ownKeys.forEach(function(key) {
      _defineProperty(target, key, source[key]);
    });
  }
  return target;
}

function _defineProperty(obj, key, value) {
  if (key in obj) {
    Object.defineProperty(obj, key, {
      value: value,
      enumerable: true,
      configurable: true,
      writable: true
    });
  } else {
    obj[key] = value;
  }
  return obj;
}

const chalk = require("chalk");

const formatLogTimestamp = require("./formatLogTimestamp");

const logWithTimestamp = require("./logWithTimestamp");

const path = require("path");

const reporting = require("./reporting");

const throttle = require("lodash.throttle");

const _require = require("metro-core"),
  AmbiguousModuleResolutionError = _require.AmbiguousModuleResolutionError;

const GLOBAL_CACHE_DISABLED_MESSAGE_FORMAT =
  "The global cache is now disabled because %s";
const DARK_BLOCK_CHAR = "\u2593";
const LIGHT_BLOCK_CHAR = "\u2591";
const MAX_PROGRESS_BAR_CHAR_WIDTH = 16;
/**
 * We try to print useful information to the terminal for interactive builds.
 * This implements the `Reporter` interface from the './reporting' module.
 */

class TerminalReporter {
  /**
   * The bundle builds for which we are actively maintaining the status on the
   * terminal, ie. showing a progress bar. There can be several bundles being
   * built at the same time.
   */
  constructor(terminal) {
    this._activeBundles = new Map();
    this._scheduleUpdateBundleProgress = throttle(data => {
      this.update(
        _objectSpread({}, data, {
          type: "bundle_transform_progressed_throttled"
        })
      );
    }, 100);
    this.terminal = terminal;
  }
  /**
   * Construct a message that represents the progress of a
   * single bundle build, for example:
   *
   *     BUNDLE path/to/bundle.js ▓▓▓▓▓░░░░░░░░░░░ 36.6% (4790/7922)
   */

  _getBundleStatusMessage(_ref, phase) {
    let _ref$bundleDetails = _ref.bundleDetails,
      entryFile = _ref$bundleDetails.entryFile,
      bundleType = _ref$bundleDetails.bundleType,
      transformedFileCount = _ref.transformedFileCount,
      totalFileCount = _ref.totalFileCount,
      ratio = _ref.ratio,
      startTime = _ref.startTime;
    const localPath = path.relative(".", entryFile);
    const filledBar = Math.floor(ratio * MAX_PROGRESS_BAR_CHAR_WIDTH);
    const bundleTypeColor =
      phase === "done"
        ? chalk.green
        : phase === "failed"
        ? chalk.red
        : chalk.yellow;
    const progress =
      phase === "in_progress"
        ? chalk.green.bgGreen(DARK_BLOCK_CHAR.repeat(filledBar)) +
          chalk.bgWhite.white(
            LIGHT_BLOCK_CHAR.repeat(MAX_PROGRESS_BAR_CHAR_WIDTH - filledBar)
          ) +
          chalk.bold(` ${(100 * ratio).toFixed(1)}% `) +
          chalk.dim(`(${transformedFileCount}/${totalFileCount})`)
        : "";
    return (
      formatLogTimestamp(startTime) +
      bundleTypeColor.inverse.bold(` ${bundleType.toUpperCase()} `) +
      chalk.reset.dim(` ${path.dirname(localPath)}/`) +
      chalk.bold(path.basename(localPath)) +
      " " +
      progress +
      "\n"
    );
  }

  _logCacheDisabled(reason) {
    const format = GLOBAL_CACHE_DISABLED_MESSAGE_FORMAT;

    switch (reason) {
      case "too_many_errors":
        reporting.logWarning(
          this.terminal,
          format,
          "it has been failing too many times."
        );
        break;

      case "too_many_misses":
        reporting.logWarning(
          this.terminal,
          format,
          "it has been missing too many consecutive keys."
        );
        break;
    }
  }

  _logBundleBuildDone(buildID) {
    const progress = this._activeBundles.get(buildID);

    if (progress != null) {
      const msg = this._getBundleStatusMessage(
        _objectSpread({}, progress, {
          ratio: 1,
          transformedFileCount: progress.totalFileCount
        }),
        "done"
      );

      this.terminal.log(msg);

      this._activeBundles.delete(buildID);
    }
  }

  _logBundleBuildFailed(buildID) {
    const progress = this._activeBundles.get(buildID);

    if (progress != null) {
      const msg = this._getBundleStatusMessage(progress, "failed");

      this.terminal.log(msg);
    }
  }

  _logInitializing(port) {
    const logo = [
      "                                                          ",
      "               ######                ######               ",
      "             ###     ####        ####     ###             ",
      "            ##          ###    ###          ##            ",
      "            ##             ####             ##            ",
      "            ##             ####             ##            ",
      "            ##           ##    ##           ##            ",
      "            ##         ###      ###         ##            ",
      "             ##  ########################  ##             ",
      "          ######    ###            ###    ######          ",
      "      ###     ##    ##              ##    ##     ###      ",
      "   ###         ## ###      ####      ### ##         ###   ",
      "  ##           ####      ########      ####           ##  ",
      " ##             ###     ##########     ###             ## ",
      "  ##           ####      ########      ####           ##  ",
      "   ###         ## ###      ####      ### ##         ###   ",
      "      ###     ##    ##              ##    ##     ###      ",
      "          ######    ###            ###    ######          ",
      "             ##  ########################  ##             ",
      "            ##         ###      ###         ##            ",
      "            ##           ##    ##           ##            ",
      "            ##             ####             ##            ",
      "            ##             ####             ##            ",
      "            ##          ###    ###          ##            ",
      "             ###     ####        ####     ###             ",
      "               ######                ######               ",
      "                                                          "
    ];
    this.terminal.log(chalk.blue(logo.join("\n")));
  }

  _logInitializingFailed(port, error) {
    if (error.code === "EADDRINUSE") {
      this.terminal.log(
        chalk.bgRed.bold(" ERROR "),
        chalk.red("Metro can't listen on port", chalk.bold(String(port)))
      );
      this.terminal.log(
        "Most likely another process is already using this port"
      );
      this.terminal.log("Run the following command to find out which process:");
      this.terminal.log("\n  ", chalk.bold("lsof -i :" + port), "\n");
      this.terminal.log("Then, you can either shut down the other process:");
      this.terminal.log("\n  ", chalk.bold("kill -9 <PID>"), "\n");
      this.terminal.log("or run Metro on different port.");
    } else {
      this.terminal.log(chalk.bgRed.bold(" ERROR "), chalk.red(error.message));
      const errorAttributes = JSON.stringify(error);

      if (errorAttributes !== "{}") {
        this.terminal.log(chalk.red(errorAttributes));
      }

      this.terminal.log(chalk.red(error.stack));
    }
  }
  /**
   * This function is only concerned with logging and should not do state
   * or terminal status updates.
   */

  _log(event) {
    switch (event.type) {
      case "initialize_started":
        this._logInitializing(event.port);

        break;

      case "initialize_done":
        this.terminal.log("\nMetro is ready.\n");
        break;

      case "initialize_failed":
        this._logInitializingFailed(event.port, event.error);

        break;

      case "bundle_build_done":
        this._logBundleBuildDone(event.buildID);

        break;

      case "bundle_build_failed":
        this._logBundleBuildFailed(event.buildID);

        break;

      case "bundling_error":
        this._logBundlingError(event.error);

        break;

      case "global_cache_disabled":
        this._logCacheDisabled(event.reason);

        break;

      case "transform_cache_reset":
        reporting.logWarning(this.terminal, "the transform cache was reset.");
        break;

      case "worker_stdout_chunk":
        this._logWorkerChunk("stdout", event.chunk);

        break;

      case "worker_stderr_chunk":
        this._logWorkerChunk("stderr", event.chunk);

        break;

      case "hmr_client_error":
        this._logHmrClientError(event.error);

        break;

      case "client_log":
        logWithTimestamp.apply(
          void 0,
          [this.terminal, event.level].concat(_toConsumableArray(event.data))
        );
        break;

      case "dep_graph_loading":
        // IMPORTANT: Keep this in sync with `nuclide-metro-rpc/lib/parseMessages.tsx`
        this.terminal.log(
          chalk.blue.bold("                 Welcome to React Native!\n") +
            chalk.dim("                Learn once, write anywhere\n\n")
        );
        break;
    }
  }
  /**
   * We do not want to log the whole stacktrace for bundling error, because
   * these are operational errors, not programming errors, and the stacktrace
   * is not actionable to end users.
   */

  _logBundlingError(error) {
    if (error instanceof AmbiguousModuleResolutionError) {
      const he = error.hasteError;
      const message =
        "ambiguous resolution: module `" +
        `${error.fromModulePath}\` tries to require \`${he.hasteName}\`, ` +
        "but there are several files providing this module. You can delete " +
        "or fix them: \n\n" +
        Object.keys(he.duplicatesSet)
          .sort()
          .map(dupFilePath => `  * \`${dupFilePath}\`\n`)
          .join("");
      reporting.logError(this.terminal, message);
      return;
    }

    let message = error.message; // Do not log the stack trace for SyntaxError (because it will always be in
    // the parser, which is not helpful).

    if (!(error instanceof SyntaxError)) {
      if (error.snippet == null && error.stack != null) {
        message = error.stack;
      }
    }

    if (error.filename && !message.includes(error.filename)) {
      message += ` [${error.filename}]`;
    }

    if (error.snippet != null) {
      message += "\n" + error.snippet;
    }

    reporting.logError(this.terminal, message);
  }

  _logWorkerChunk(origin, chunk) {
    const lines = chunk.split("\n");

    if (lines.length >= 1 && lines[lines.length - 1] === "") {
      lines.splice(lines.length - 1, 1);
    }

    lines.forEach(line => {
      this.terminal.log(`transform[${origin}]: ${line}`);
    });
  }
  /**
   * We use Math.pow(ratio, 2) to as a conservative measure of progress because
   * we know the `totalCount` is going to progressively increase as well. We
   * also prevent the ratio from going backwards.
   */

  _updateBundleProgress(_ref2) {
    let buildID = _ref2.buildID,
      transformedFileCount = _ref2.transformedFileCount,
      totalFileCount = _ref2.totalFileCount;

    const currentProgress = this._activeBundles.get(buildID);

    if (currentProgress == null) {
      return;
    }

    const rawRatio = transformedFileCount / totalFileCount;
    const conservativeRatio = Math.pow(rawRatio, 2);
    const ratio = Math.max(conservativeRatio, currentProgress.ratio);
    Object.assign(currentProgress, {
      ratio,
      transformedFileCount,
      totalFileCount
    });
  }
  /**
   * This function is exclusively concerned with updating the internal state.
   * No logging or status updates should be done at this point.
   */

  _updateState(event) {
    switch (event.type) {
      case "bundle_build_done":
      case "bundle_build_failed":
        this._activeBundles.delete(event.buildID);

        break;

      case "bundle_build_started":
        const bundleProgress = {
          bundleDetails: event.bundleDetails,
          transformedFileCount: 0,
          totalFileCount: 1,
          ratio: 0,
          startTime: new Date()
        };

        this._activeBundles.set(event.buildID, bundleProgress);

        break;

      case "bundle_transform_progressed":
        if (event.totalFileCount === event.transformedFileCount) {
          this._scheduleUpdateBundleProgress.cancel();

          this._updateBundleProgress(event);
        } else {
          this._scheduleUpdateBundleProgress(event);
        }

        break;

      case "bundle_transform_progressed_throttled":
        this._updateBundleProgress(event);

        break;
    }
  }
  /**
   * Return a status message that is always consistent with the current state
   * of the application. Having this single function ensures we don't have
   * different callsites overriding each other status messages.
   */

  _getStatusMessage() {
    return Array.from(this._activeBundles.entries())
      .map(_ref3 => {
        let _ref4 = _slicedToArray(_ref3, 2),
          _ = _ref4[0],
          progress = _ref4[1];

        return this._getBundleStatusMessage(progress, "in_progress");
      })
      .filter(str => str != null)
      .join("\n");
  }

  _logHmrClientError(e) {
    reporting.logError(
      this.terminal,
      "A WebSocket client got a connection error. Please reload your device " +
        "to get HMR working again: %s",
      e
    );
  }
  /**
   * Single entry point for reporting events. That allows us to implement the
   * corresponding JSON reporter easily and have a consistent reporting.
   */

  update(event) {
    this._log(event);

    this._updateState(event);

    this.terminal.status(this._getStatusMessage());
  }
}

module.exports = TerminalReporter;
