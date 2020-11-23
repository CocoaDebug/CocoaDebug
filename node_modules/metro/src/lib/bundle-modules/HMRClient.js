/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 *  strict-local
 * @format
 */
"use strict";

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

const EventEmitter = require("eventemitter3");

const inject = _ref => {
  let _ref$module = _slicedToArray(_ref.module, 2),
    id = _ref$module[0],
    code = _ref$module[1],
    sourceURL = _ref.sourceURL;

  // Some engines do not support `sourceURL` as a comment. We expose a
  // `globalEvalWithSourceUrl` function to handle updates in that case.
  if (global.globalEvalWithSourceUrl) {
    global.globalEvalWithSourceUrl(code, sourceURL);
  } else {
    // eslint-disable-next-line no-eval
    eval(code);
  }
};

const injectUpdate = update => {
  update.added.forEach(inject);
  update.modified.forEach(inject);
};

class HMRClient extends EventEmitter {
  constructor(url) {
    super(); // Access the global WebSocket object only after enabling the client,
    // since some polyfills do the initialization lazily.

    _defineProperty(this, "_isEnabled", false);

    _defineProperty(this, "_pendingUpdate", null);

    _defineProperty(this, "_queue", []);

    _defineProperty(this, "_state", "opening");

    this._ws = new global.WebSocket(url);

    this._ws.onopen = () => {
      this._state = "open";
      this.emit("open");

      this._flushQueue();
    };

    this._ws.onerror = error => {
      this.emit("connection-error", error);
    };

    this._ws.onclose = () => {
      this._state = "closed";
      this.emit("close");
    };

    this._ws.onmessage = message => {
      const data = JSON.parse(message.data);

      switch (data.type) {
        case "bundle-registered":
          this.emit("bundle-registered");
          break;

        case "update-start":
          this.emit("update-start", data.body);
          break;

        case "update":
          this.emit("update", data.body);
          break;

        case "update-done":
          this.emit("update-done");
          break;

        case "error":
          this.emit("error", data.body);
          break;

        default:
          this.emit("error", {
            type: "unknown-message",
            message: data
          });
      }
    };

    this.on("update", update => {
      if (this._isEnabled) {
        injectUpdate(update);
      } else if (this._pendingUpdate == null) {
        this._pendingUpdate = update;
      } else {
        this._pendingUpdate = mergeUpdates(this._pendingUpdate, update);
      }
    });
  }

  close() {
    this._ws.close();
  }

  send(message) {
    switch (this._state) {
      case "opening":
        this._queue.push(message);

        break;

      case "open":
        this._ws.send(message);

        break;

      case "closed":
        // Ignore.
        break;

      default:
        throw new Error("[WebSocketHMRClient] Unknown state: " + this._state);
    }
  }

  _flushQueue() {
    this._queue.forEach(message => this.send(message));

    this._queue.length = 0;
  }

  enable() {
    this._isEnabled = true;
    const update = this._pendingUpdate;
    this._pendingUpdate = null;

    if (update != null) {
      injectUpdate(update);
    }
  }

  disable() {
    this._isEnabled = false;
  }

  isEnabled() {
    return this._isEnabled;
  }

  hasPendingUpdates() {
    return this._pendingUpdate != null;
  }
}

function mergeUpdates(base, next) {
  const addedIDs = new Set();
  const deletedIDs = new Set();
  const moduleMap = new Map(); // Fill in the temporary maps and sets from both updates in their order.

  applyUpdateLocally(base);
  applyUpdateLocally(next);

  function applyUpdateLocally(update) {
    update.deleted.forEach(id => {
      if (addedIDs.has(id)) {
        addedIDs.delete(id);
      } else {
        deletedIDs.add(id);
      }

      moduleMap.delete(id);
    });
    update.added.forEach(item => {
      const id = item.module[0];

      if (deletedIDs.has(id)) {
        deletedIDs.delete(id);
      } else {
        addedIDs.add(id);
      }

      moduleMap.set(id, item);
    });
    update.modified.forEach(item => {
      const id = item.module[0];
      moduleMap.set(id, item);
    });
  } // Now reconstruct a unified update from our in-memory maps and sets.
  // Applying it should be equivalent to applying both of them individually.

  const result = {
    isInitialUpdate: next.isInitialUpdate,
    revisionId: next.revisionId,
    added: [],
    modified: [],
    deleted: []
  };
  deletedIDs.forEach(id => {
    result.deleted.push(id);
  });
  moduleMap.forEach((item, id) => {
    if (deletedIDs.has(id)) {
      return;
    }

    if (addedIDs.has(id)) {
      result.added.push(item);
    } else {
      result.modified.push(item);
    }
  });
  return result;
}

module.exports = HMRClient;
