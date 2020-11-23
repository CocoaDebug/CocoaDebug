'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

function _interopDefault (ex) { return (ex && (typeof ex === 'object') && 'default' in ex) ? ex['default'] : ex; }

var fs = require('fs');
var util = require('util');
var path = _interopDefault(require('path'));
var sourceMap = require('source-map');

function _extends() {
  _extends = Object.assign || function (target) {
    for (var i = 1; i < arguments.length; i++) {
      var source = arguments[i];

      for (var key in source) {
        if (Object.prototype.hasOwnProperty.call(source, key)) {
          target[key] = source[key];
        }
      }
    }

    return target;
  };

  return _extends.apply(this, arguments);
}

function _unsupportedIterableToArray(o, minLen) {
  if (!o) return;
  if (typeof o === "string") return _arrayLikeToArray(o, minLen);
  var n = Object.prototype.toString.call(o).slice(8, -1);
  if (n === "Object" && o.constructor) n = o.constructor.name;
  if (n === "Map" || n === "Set") return Array.from(o);
  if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen);
}

function _arrayLikeToArray(arr, len) {
  if (len == null || len > arr.length) len = arr.length;

  for (var i = 0, arr2 = new Array(len); i < len; i++) arr2[i] = arr[i];

  return arr2;
}

function _createForOfIteratorHelperLoose(o, allowArrayLike) {
  var it;

  if (typeof Symbol === "undefined" || o[Symbol.iterator] == null) {
    if (Array.isArray(o) || (it = _unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") {
      if (it) o = it;
      var i = 0;
      return function () {
        if (i >= o.length) return {
          done: true
        };
        return {
          done: false,
          value: o[i++]
        };
      };
    }

    throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.");
  }

  it = o[Symbol.iterator]();
  return it.next.bind(it);
}

var EventsPhase;

(function (EventsPhase) {
  EventsPhase["DURATION_EVENTS_BEGIN"] = "B";
  EventsPhase["DURATION_EVENTS_END"] = "E";
  EventsPhase["COMPLETE_EVENTS"] = "X";
  EventsPhase["INSTANT_EVENTS"] = "I";
  EventsPhase["COUNTER_EVENTS"] = "C";
  EventsPhase["ASYNC_EVENTS_NESTABLE_START"] = "b";
  EventsPhase["ASYNC_EVENTS_NESTABLE_INSTANT"] = "n";
  EventsPhase["ASYNC_EVENTS_NESTABLE_END"] = "e";
  EventsPhase["FLOW_EVENTS_START"] = "s";
  EventsPhase["FLOW_EVENTS_STEP"] = "t";
  EventsPhase["FLOW_EVENTS_END"] = "f";
  EventsPhase["SAMPLE_EVENTS"] = "P";
  EventsPhase["OBJECT_EVENTS_CREATED"] = "N";
  EventsPhase["OBJECT_EVENTS_SNAPSHOT"] = "O";
  EventsPhase["OBJECT_EVENTS_DESTROYED"] = "D";
  EventsPhase["METADATA_EVENTS"] = "M";
  EventsPhase["MEMORY_DUMP_EVENTS_GLOBAL"] = "V";
  EventsPhase["MEMORY_DUMP_EVENTS_PROCESS"] = "v";
  EventsPhase["MARK_EVENTS"] = "R";
  EventsPhase["CLOCK_SYNC_EVENTS"] = "c";
  EventsPhase["CONTEXT_EVENTS_ENTER"] = "(";
  EventsPhase["CONTEXT_EVENTS_LEAVE"] = ")"; // Deprecated

  EventsPhase["ASYNC_EVENTS_START"] = "S";
  EventsPhase["ASYNC_EVENTS_STEP_INTO"] = "T";
  EventsPhase["ASYNC_EVENTS_STEP_PAST"] = "p";
  EventsPhase["ASYNC_EVENTS_END"] = "F";
  EventsPhase["LINKED_ID_EVENTS"] = "=";
})(EventsPhase || (EventsPhase = {}));

var CpuProfilerModel = /*#__PURE__*/function () {
  function CpuProfilerModel(profile) {
    this._profile = profile;
    this._nodesById = this._createNodeMap();
    this._activeNodeArraysById = this._createActiveNodeArrays();
  }
  /**
   * Initialization function to enable O(1) access to nodes by node ID.
   * @return {Map<number, CPUProfileChunkNode}
   */


  var _proto = CpuProfilerModel.prototype;

  _proto._createNodeMap = function _createNodeMap() {
    /** @type {Map<number, CpuProfile['nodes'][0]>} */
    var map = new Map();

    for (var _iterator = _createForOfIteratorHelperLoose(this._profile.nodes), _step; !(_step = _iterator()).done;) {
      var node = _step.value;
      map.set(node.id, node);
    }

    return map;
  }
  /**
   * Initialization function to enable O(1) access to the set of active nodes in the stack by node ID.
   * @return Map<number, number[]>
   */
  ;

  _proto._createActiveNodeArrays = function _createActiveNodeArrays() {
    var _this = this;

    var map = new Map();
    /**
     * Given a nodeId, `getActiveNodes` gets all the parent nodes in reversed call order
     * @param {number} id
     */

    var getActiveNodes = function getActiveNodes(id) {
      if (map.has(id)) return map.get(id) || [];

      var node = _this._nodesById.get(id);

      if (!node) throw new Error("No such node " + id);

      if (node.parent) {
        var array = getActiveNodes(node.parent).concat([id]);
        map.set(id, array);
        return array;
      } else {
        return [id];
      }
    };

    for (var _iterator2 = _createForOfIteratorHelperLoose(this._profile.nodes), _step2; !(_step2 = _iterator2()).done;) {
      var node = _step2.value;
      map.set(node.id, getActiveNodes(node.id));
    }

    return map;
  }
  /**
   * Returns all the node IDs in a stack when a specific nodeId is at the top of the stack
   * (i.e. a stack's node ID and the node ID of all of its parents).
   */
  ;

  _proto._getActiveNodeIds = function _getActiveNodeIds(nodeId) {
    var activeNodeIds = this._activeNodeArraysById.get(nodeId);

    if (!activeNodeIds) throw new Error("No such node ID " + nodeId);
    return activeNodeIds;
  }
  /**
   * Generates the necessary B/E-style trace events for a single transition from stack A to stack B
   * at the given timestamp.
   *
   * Example:
   *
   *    timestamp 1234
   *    previousNodeIds 1,2,3
   *    currentNodeIds 1,2,4
   *
   *    yields [end 3 at ts 1234, begin 4 at ts 1234]
   *
   * @param {number} timestamp
   * @param {Array<number>} previousNodeIds
   * @param {Array<number>} currentNodeIds
   * @returns {Array<DurationEvent>}
   */
  ;

  _proto._createStartEndEventsForTransition = function _createStartEndEventsForTransition(timestamp, previousNodeIds, currentNodeIds) {
    var _this2 = this;

    // Start nodes are the nodes which are present only in the currentNodeIds and not in PreviousNodeIds
    var startNodes = currentNodeIds.filter(function (id) {
      return !previousNodeIds.includes(id);
    }).map(function (id) {
      return _this2._nodesById.get(id);
    }); // End nodes are the nodes which are present only in the PreviousNodeIds and not in CurrentNodeIds

    var endNodes = previousNodeIds.filter(function (id) {
      return !currentNodeIds.includes(id);
    }).map(function (id) {
      return _this2._nodesById.get(id);
    });
    /**
     * The name needs to be modified if `http://` is present as this directs us to bundle files which does not add any information for the end user
     * @param name
     */

    var removeLinksIfExist = function removeLinksIfExist(name) {
      // If the name includes `http://`, we can filter the name
      if (name.includes('http://')) {
        name = name.substring(0, name.lastIndexOf('('));
      }

      return name || 'anonymous';
    };
    /**
     * Create a Duration Event from CPUProfileChunkNodes.
     * @param {CPUProfileChunkNode} node
     * @return {DurationEvent} */


    var createEvent = function createEvent(node) {
      return {
        ts: timestamp,
        pid: _this2._profile.pid,
        tid: Number(_this2._profile.tid),
        ph: EventsPhase.DURATION_EVENTS_BEGIN,
        name: removeLinksIfExist(node.callFrame.name),
        cat: node.callFrame.category,
        args: _extends({}, node.callFrame)
      };
    };

    var startEvents = startNodes.map(createEvent).map(function (evt) {
      return _extends({}, evt, {
        ph: EventsPhase.DURATION_EVENTS_BEGIN
      });
    });
    var endEvents = endNodes.map(createEvent).map(function (evt) {
      return _extends({}, evt, {
        ph: EventsPhase.DURATION_EVENTS_END
      });
    });
    return [].concat(endEvents.reverse(), startEvents);
  }
  /**
   * Creates B/E-style trace events from a CpuProfile object created by `collectProfileEvents()`
   * @return {DurationEvent}
   * @throws If the length of timeDeltas array or the samples array does not match with the length of samples in Hermes Profile
   */
  ;

  _proto.createStartEndEvents = function createStartEndEvents() {
    var profile = this._profile;
    var length = profile.samples.length;
    if (profile.timeDeltas.length !== length || profile.samples.length !== length) throw new Error("Invalid CPU profile length");
    var events = [];
    var timestamp = profile.startTime;
    var lastActiveNodeIds = [];

    for (var i = 0; i < profile.samples.length; i++) {
      var nodeId = profile.samples[i];
      var timeDelta = Math.max(profile.timeDeltas[i], 0);

      var node = this._nodesById.get(nodeId);

      if (!node) throw new Error("Missing node " + nodeId);
      timestamp += timeDelta;

      var activeNodeIds = this._getActiveNodeIds(nodeId);

      events.push.apply(events, this._createStartEndEventsForTransition(timestamp, lastActiveNodeIds, activeNodeIds));
      lastActiveNodeIds = activeNodeIds;
    }

    events.push.apply(events, this._createStartEndEventsForTransition(timestamp, lastActiveNodeIds, []));
    return events;
  }
  /**
   * Creates B/E-style trace events from a CpuProfile object created by `collectProfileEvents()`
   * @param {CPUProfileChunk} profile
   */
  ;

  CpuProfilerModel.createStartEndEvents = function createStartEndEvents(profile) {
    var model = new CpuProfilerModel(profile);
    return model.createStartEndEvents();
  }
  /**
   * Converts the Hermes Sample into a single CpuProfileChunk object for consumption
   * by `createStartEndEvents()`.
   *
   * @param {HermesCPUProfile} profile
   * @throws Profile must have at least one sample
   * @return {CPUProfileChunk}
   */
  ;

  CpuProfilerModel.collectProfileEvents = function collectProfileEvents(profile) {
    if (profile.samples.length >= 0) {
      var samples = profile.samples,
          stackFrames = profile.stackFrames; // Assumption: The sample will have a single process

      var pid = samples[0].pid; // Assumption: Javascript is single threaded, so there should only be one thread throughout

      var tid = samples[0].tid; // TODO: What role does id play in string parsing

      var id = '0x1';
      var startTime = Number(samples[0].ts);

      var _this$constructNodes = this.constructNodes(samples, stackFrames),
          nodes = _this$constructNodes.nodes,
          sampleNumbers = _this$constructNodes.sampleNumbers,
          timeDeltas = _this$constructNodes.timeDeltas;

      return {
        id: id,
        pid: pid,
        tid: tid,
        startTime: startTime,
        nodes: nodes,
        samples: sampleNumbers,
        timeDeltas: timeDeltas
      };
    } else {
      throw new Error('The hermes profile has zero samples');
    }
  }
  /**
   * Constructs CPUProfileChunk Nodes and the resultant samples and time deltas to be inputted into the
   * CPUProfileChunk object which will be processed to give createStartEndEvents()
   *
   * @param {HermesSample} samples
   * @param {<string, HermesStackFrame>} stackFrames
   * @return {CPUProfileChunker}
   */
  ;

  CpuProfilerModel.constructNodes = function constructNodes(samples, stackFrames) {
    samples = samples.map(function (sample) {
      sample.stackFrameData = stackFrames[sample.sf];
      return sample;
    });
    var stackFrameIds = Object.keys(stackFrames);
    var profileNodes = stackFrameIds.map(function (stackFrameId) {
      var stackFrame = stackFrames[stackFrameId];
      return {
        id: Number(stackFrameId),
        callFrame: _extends({}, stackFrame, {
          url: stackFrame.name
        }),
        parent: stackFrames[stackFrameId].parent
      };
    });
    var returnedSamples = [];
    var timeDeltas = [];
    var lastTimeStamp = Number(samples[0].ts);
    samples.forEach(function (sample, idx) {
      returnedSamples.push(sample.sf);

      if (idx === 0) {
        timeDeltas.push(0);
      } else {
        var timeDiff = Number(sample.ts) - lastTimeStamp;
        lastTimeStamp = Number(sample.ts);
        timeDeltas.push(timeDiff);
      }
    });
    return {
      nodes: profileNodes,
      sampleNumbers: returnedSamples,
      timeDeltas: timeDeltas
    };
  };

  return CpuProfilerModel;
}();

// A type of promise-like that resolves synchronously and supports only one observer

const _iteratorSymbol = /*#__PURE__*/ typeof Symbol !== "undefined" ? (Symbol.iterator || (Symbol.iterator = Symbol("Symbol.iterator"))) : "@@iterator";

const _asyncIteratorSymbol = /*#__PURE__*/ typeof Symbol !== "undefined" ? (Symbol.asyncIterator || (Symbol.asyncIterator = Symbol("Symbol.asyncIterator"))) : "@@asyncIterator";

// Asynchronously call a function and send errors to recovery continuation
function _catch(body, recover) {
	try {
		var result = body();
	} catch(e) {
		return recover(e);
	}
	if (result && result.then) {
		return result.then(void 0, recover);
	}
	return result;
}

var readFileAsync = function readFileAsync(path) {
  try {
    return Promise.resolve(_catch(function () {
      var readFileAsync = util.promisify(fs.readFile);
      return Promise.resolve(readFileAsync(path, 'utf-8')).then(function (fileString) {
        if (fileString.length === 0) {
          throw new Error(path + " is an empty file");
        }

        var obj = JSON.parse(fileString);
        return obj;
      });
    }, function (err) {
      throw err;
    }));
  } catch (e) {
    return Promise.reject(e);
  }
};

/**
 * This function is a helper to the applySourceMapsToEvents. The category allocation logic is implemented here based on the sourcemap url (if available)
 * @param defaultCategory The category the event is of by default without the use of Source maps
 * @param url The URL which can be parsed to interpret the new category of the event (depends on node_modules)
 */

var improveCategories = function improveCategories(defaultCategory, url) {
  var obtainCategory = function obtainCategory(url) {
    var dirs = url.substring(url.lastIndexOf(path.sep + "node_modules" + path.sep)).split(path.sep);
    return dirs.length > 2 && dirs[1] === 'node_modules' ? dirs[2] : defaultCategory;
  };

  return url ? obtainCategory(url) : defaultCategory;
};
/**
 * Enhances the function line, column and params information and event categories
 * based on JavaScript source maps to make it easier to associate trace events with
 * the application code
 *
 * Throws error if args not set up in ChromeEvents
 * @param {SourceMap} sourceMap
 * @param {DurationEvent[]} chromeEvents
 * @param {string} indexBundleFileName
 * @throws If `args` for events are not populated
 * @returns {DurationEvent[]}
 */


var applySourceMapsToEvents = function applySourceMapsToEvents(sourceMap$1, chromeEvents, indexBundleFileName) {
  try {
    // SEE: Should file here be an optional parameter, so take indexBundleFileName as a parameter and use
    // a default name of `index.bundle`
    var rawSourceMap = {
      version: Number(sourceMap$1.version),
      file: indexBundleFileName || 'index.bundle',
      sources: sourceMap$1.sources,
      mappings: sourceMap$1.mappings,
      names: sourceMap$1.names
    };
    return Promise.resolve(new sourceMap.SourceMapConsumer(rawSourceMap)).then(function (consumer) {
      var events = chromeEvents.map(function (event) {
        if (event.args) {
          var sm = consumer.originalPositionFor({
            line: Number(event.args.line),
            column: Number(event.args.column)
          });
          /**
           * The categories can help us better visualise the profile if we modify the categories.
           * We change these categories only in the root level and not deeper inside the args, just so we have our
           * original categories as well as these modified categories (as the modified categories simply help with visualisation)
           */

          event.cat = improveCategories(event.cat, sm.source);
          event.args = _extends({}, event.args, {
            url: sm.source,
            line: sm.line,
            column: sm.column,
            params: sm.name,
            allocatedCategory: event.cat,
            allocatedName: event.name
          });
        } else {
          throw new Error("Source maps could not be derived for an event at " + event.ts + " and with stackFrame ID " + event.sf);
        }

        return event;
      });
      consumer.destroy();
      return events;
    });
  } catch (e) {
    return Promise.reject(e);
  }
};

/**
 * This transformer can take in the path of the profile, the source map (optional) and the bundle file name (optional)
 * and return a promise which resolves to Chrome Dev Tools compatible events
 * @param profilePath string
 * @param sourceMapPath string
 * @param bundleFileName string
 * @return Promise<DurationEvent[]>
 */

var transformer = function transformer(profilePath, sourceMapPath, bundleFileName) {
  try {
    return Promise.resolve(readFileAsync(profilePath)).then(function (hermesProfile) {
      var _exit = false;
      var profileChunk = CpuProfilerModel.collectProfileEvents(hermesProfile);
      var profiler = new CpuProfilerModel(profileChunk);
      var chromeEvents = profiler.createStartEndEvents();

      var _temp = function () {
        if (sourceMapPath) {
          return Promise.resolve(readFileAsync(sourceMapPath)).then(function (sourceMap) {
            var events = applySourceMapsToEvents(sourceMap, chromeEvents, bundleFileName);
            _exit = true;
            return events;
          });
        }
      }();

      return _temp && _temp.then ? _temp.then(function (_result) {
        return _exit ? _result : chromeEvents;
      }) : _exit ? _temp : chromeEvents;
    });
  } catch (e) {
    return Promise.reject(e);
  }
};

exports.default = transformer;
//# sourceMappingURL=hermes-profile-transformer.cjs.development.js.map
