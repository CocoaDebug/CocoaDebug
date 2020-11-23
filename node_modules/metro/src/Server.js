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

function asyncGeneratorStep(gen, resolve, reject, _next, _throw, key, arg) {
  try {
    var info = gen[key](arg);
    var value = info.value;
  } catch (error) {
    reject(error);
    return;
  }
  if (info.done) {
    resolve(value);
  } else {
    Promise.resolve(value).then(_next, _throw);
  }
}

function _asyncToGenerator(fn) {
  return function() {
    var self = this,
      args = arguments;
    return new Promise(function(resolve, reject) {
      var gen = fn.apply(self, args);
      function _next(value) {
        asyncGeneratorStep(gen, resolve, reject, _next, _throw, "next", value);
      }
      function _throw(err) {
        asyncGeneratorStep(gen, resolve, reject, _next, _throw, "throw", err);
      }
      _next(undefined);
    });
  };
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

const IncrementalBundler = require("./IncrementalBundler");

const MultipartResponse = require("./Server/MultipartResponse");

const ResourceNotFoundError = require("./IncrementalBundler/ResourceNotFoundError");

const baseJSBundle = require("./DeltaBundler/Serializers/baseJSBundle");

const bundleToString = require("./lib/bundleToString");

const _require = require("@babel/code-frame"),
  codeFrameColumns = _require.codeFrameColumns;

const debug = require("debug")("Metro:Server");

const formatBundlingError = require("./lib/formatBundlingError");

const fs = require("graceful-fs");

const getAllFiles = require("./DeltaBundler/Serializers/getAllFiles");

const getAssets = require("./DeltaBundler/Serializers/getAssets");

const getGraphId = require("./lib/getGraphId");

const getRamBundleInfo = require("./DeltaBundler/Serializers/getRamBundleInfo");

const mime = require("mime-types");

const parseOptionsFromUrl = require("./lib/parseOptionsFromUrl");

const parsePlatformFilePath = require("./node-haste/lib/parsePlatformFilePath");

const path = require("path");

const sourceMapString = require("./DeltaBundler/Serializers/sourceMapString");

const splitBundleOptions = require("./lib/splitBundleOptions");

const symbolicate = require("./Server/symbolicate");

const transformHelpers = require("./lib/transformHelpers");

const url = require("url");

const _require2 = require("./Assets"),
  getAsset = _require2.getAsset;

const _require3 = require("./DeltaBundler/Serializers/getExplodedSourceMap"),
  getExplodedSourceMap = _require3.getExplodedSourceMap;

const _require4 = require("metro-core"),
  Logger = _require4.Logger,
  _require4$Logger = _require4.Logger,
  createActionStartEntry = _require4$Logger.createActionStartEntry,
  createActionEndEntry = _require4$Logger.createActionEndEntry,
  log = _require4$Logger.log;

const DELTA_ID_HEADER = "X-Metro-Delta-ID";
const FILES_CHANGED_COUNT_HEADER = "X-Metro-Files-Changed-Count";

class Server {
  constructor(config, options) {
    var _this = this;

    _defineProperty(this, "processRequest", (req, res, next) => {
      this._processRequest(req, res, next).catch(next);
    });

    _defineProperty(
      this,
      "_processBundleRequest",
      this._createRequestProcessor({
        createStartEntry(context) {
          return {
            action_name: "Requesting bundle",
            bundle_url: context.req.url,
            entry_point: context.entryFile,
            bundler: "delta",
            build_id: context.buildID,
            bundle_options: context.bundleOptions,
            bundle_hash: context.graphId
          };
        },

        createEndEntry(context) {
          return {
            outdated_modules: context.result.numModifiedFiles
          };
        },

        build: (function() {
          var _ref = _asyncToGenerator(function*(_ref2) {
            let entryFile = _ref2.entryFile,
              graphId = _ref2.graphId,
              graphOptions = _ref2.graphOptions,
              onProgress = _ref2.onProgress,
              serializerOptions = _ref2.serializerOptions,
              transformOptions = _ref2.transformOptions;

            const revPromise = _this._bundler.getRevisionByGraphId(graphId);

            const _ref3 = yield revPromise != null
                ? _this._bundler.updateGraph(yield revPromise, false)
                : _this._bundler.initializeGraph(entryFile, transformOptions, {
                    onProgress,
                    shallow: graphOptions.shallow
                  }),
              delta = _ref3.delta,
              revision = _ref3.revision;

            const serializer =
              _this._config.serializer.customSerializer ||
              function() {
                return bundleToString(baseJSBundle.apply(void 0, arguments))
                  .code;
              };

            const bundle = serializer(
              entryFile,
              revision.prepend,
              revision.graph,
              {
                asyncRequireModulePath:
                  _this._config.transformer.asyncRequireModulePath,
                processModuleFilter:
                  _this._config.serializer.processModuleFilter,
                createModuleId: _this._createModuleId,
                getRunModuleStatement:
                  _this._config.serializer.getRunModuleStatement,
                dev: transformOptions.dev,
                projectRoot: _this._config.projectRoot,
                modulesOnly: serializerOptions.modulesOnly,
                runBeforeMainModule: _this._config.serializer.getModulesRunBeforeMainModule(
                  path.relative(_this._config.projectRoot, entryFile)
                ),
                runModule: serializerOptions.runModule,
                sourceMapUrl: serializerOptions.sourceMapUrl,
                sourceUrl: serializerOptions.sourceUrl,
                inlineSourceMap: serializerOptions.inlineSourceMap
              }
            );
            const bundleCode =
              typeof bundle === "string" ? bundle : bundle.code;
            return {
              numModifiedFiles: delta.reset
                ? delta.added.size + revision.prepend.length
                : delta.added.size + delta.modified.size + delta.deleted.size,
              lastModifiedDate: revision.date,
              nextRevId: revision.id,
              bundle: bundleCode
            };
          });

          return function build(_x) {
            return _ref.apply(this, arguments);
          };
        })(),

        finish(_ref4) {
          let req = _ref4.req,
            mres = _ref4.mres,
            result = _ref4.result;

          if (
            // We avoid parsing the dates since the client should never send a more
            // recent date than the one returned by the Delta Bundler (if that's the
            // case it's fine to return the whole bundle).
            req.headers["if-modified-since"] ===
            result.lastModifiedDate.toUTCString()
          ) {
            debug("Responding with 304");
            mres.writeHead(304);
            mres.end();
          } else {
            mres.setHeader(
              FILES_CHANGED_COUNT_HEADER,
              String(result.numModifiedFiles)
            );
            mres.setHeader(DELTA_ID_HEADER, String(result.nextRevId));
            mres.setHeader("Content-Type", "application/javascript");
            mres.setHeader(
              "Last-Modified",
              result.lastModifiedDate.toUTCString()
            );
            mres.setHeader(
              "Content-Length",
              String(Buffer.byteLength(result.bundle))
            );
            mres.end(result.bundle);
          }
        }
      })
    );

    _defineProperty(
      this,
      "_processSourceMapRequest",
      this._createRequestProcessor({
        createStartEntry(context) {
          return {
            action_name: "Requesting sourcemap",
            bundle_url: context.req.url,
            entry_point: context.entryFile,
            bundler: "delta"
          };
        },

        createEndEntry(context) {
          return {
            bundler: "delta"
          };
        },

        build: (function() {
          var _ref5 = _asyncToGenerator(function*(_ref6) {
            let entryFile = _ref6.entryFile,
              graphId = _ref6.graphId,
              graphOptions = _ref6.graphOptions,
              onProgress = _ref6.onProgress,
              serializerOptions = _ref6.serializerOptions,
              transformOptions = _ref6.transformOptions;
            let revision;

            const revPromise = _this._bundler.getRevisionByGraphId(graphId);

            if (revPromise == null) {
              var _ref7 = yield _this._bundler.initializeGraph(
                entryFile,
                transformOptions,
                {
                  onProgress,
                  shallow: graphOptions.shallow
                }
              );

              revision = _ref7.revision;
            } else {
              revision = yield revPromise;
            }

            let _revision = revision,
              prepend = _revision.prepend,
              graph = _revision.graph;

            if (serializerOptions.modulesOnly) {
              prepend = [];
            }

            return sourceMapString(
              _toConsumableArray(prepend).concat(
                _toConsumableArray(_this._getSortedModules(graph))
              ),
              {
                excludeSource: serializerOptions.excludeSource,
                processModuleFilter:
                  _this._config.serializer.processModuleFilter
              }
            );
          });

          return function build(_x2) {
            return _ref5.apply(this, arguments);
          };
        })(),

        finish(_ref8) {
          let mres = _ref8.mres,
            result = _ref8.result;
          mres.setHeader("Content-Type", "application/json");
          mres.end(result.toString());
        }
      })
    );

    _defineProperty(
      this,
      "_processAssetsRequest",
      this._createRequestProcessor({
        createStartEntry(context) {
          return {
            action_name: "Requesting assets",
            bundle_url: context.req.url,
            entry_point: context.entryFile,
            bundler: "delta"
          };
        },

        createEndEntry(context) {
          return {
            bundler: "delta"
          };
        },

        build: (function() {
          var _ref9 = _asyncToGenerator(function*(_ref10) {
            let entryFile = _ref10.entryFile,
              transformOptions = _ref10.transformOptions,
              onProgress = _ref10.onProgress;

            const _ref11 = yield _this._bundler.buildGraph(
                entryFile,
                transformOptions,
                {
                  onProgress,
                  shallow: false
                }
              ),
              graph = _ref11.graph;

            return yield getAssets(graph, {
              processModuleFilter: _this._config.serializer.processModuleFilter,
              assetPlugins: _this._config.transformer.assetPlugins,
              platform: transformOptions.platform,
              publicPath: _this._config.transformer.publicPath,
              projectRoot: _this._config.projectRoot
            });
          });

          return function build(_x3) {
            return _ref9.apply(this, arguments);
          };
        })(),

        finish(_ref12) {
          let mres = _ref12.mres,
            result = _ref12.result;
          mres.setHeader("Content-Type", "application/json");
          mres.end(JSON.stringify(result));
        }
      })
    );

    this._config = config;

    if (this._config.resetCache) {
      this._config.cacheStores.forEach(store => store.clear());

      this._config.reporter.update({
        type: "transform_cache_reset"
      });
    }

    this._reporter = config.reporter;
    this._logger = Logger;
    this._platforms = new Set(this._config.resolver.platforms);
    this._isEnded = false; // TODO(T34760917): These two properties should eventually be instantiated
    // elsewhere and passed as parameters, since they are also needed by
    // the HmrServer.
    // The whole bundling/serializing logic should follow as well.

    this._createModuleId = config.serializer.createModuleIdFactory();
    this._bundler = new IncrementalBundler(config, {
      watch: options ? options.watch : undefined
    });
    this._nextBundleBuildID = 1;
  }

  end() {
    if (!this._isEnded) {
      this._bundler.end();

      this._isEnded = true;
    }
  }

  getBundler() {
    return this._bundler;
  }

  getCreateModuleId() {
    return this._createModuleId;
  }

  build(options) {
    var _this2 = this;

    return _asyncToGenerator(function*() {
      const _splitBundleOptions = splitBundleOptions(options),
        entryFile = _splitBundleOptions.entryFile,
        graphOptions = _splitBundleOptions.graphOptions,
        onProgress = _splitBundleOptions.onProgress,
        serializerOptions = _splitBundleOptions.serializerOptions,
        transformOptions = _splitBundleOptions.transformOptions;

      const _ref13 = yield _this2._bundler.buildGraph(
          entryFile,
          transformOptions,
          {
            onProgress,
            shallow: graphOptions.shallow
          }
        ),
        prepend = _ref13.prepend,
        graph = _ref13.graph;

      const entryPoint = path.resolve(_this2._config.projectRoot, entryFile);
      const bundleOptions = {
        asyncRequireModulePath:
          _this2._config.transformer.asyncRequireModulePath,
        processModuleFilter: _this2._config.serializer.processModuleFilter,
        createModuleId: _this2._createModuleId,
        getRunModuleStatement: _this2._config.serializer.getRunModuleStatement,
        dev: transformOptions.dev,
        projectRoot: _this2._config.projectRoot,
        modulesOnly: serializerOptions.modulesOnly,
        runBeforeMainModule: _this2._config.serializer.getModulesRunBeforeMainModule(
          path.relative(_this2._config.projectRoot, entryPoint)
        ),
        runModule: serializerOptions.runModule,
        sourceMapUrl: serializerOptions.sourceMapUrl,
        sourceUrl: serializerOptions.sourceUrl,
        inlineSourceMap: serializerOptions.inlineSourceMap
      };
      let bundleCode = null;
      let bundleMap = null;

      if (_this2._config.serializer.customSerializer) {
        const bundle = _this2._config.serializer.customSerializer(
          entryPoint,
          prepend,
          graph,
          bundleOptions
        );

        if (typeof bundle === "string") {
          bundleCode = bundle;
        } else {
          bundleCode = bundle.code;
          bundleMap = bundle.map;
        }
      } else {
        bundleCode = bundleToString(
          baseJSBundle(entryPoint, prepend, graph, bundleOptions)
        ).code;
      }

      if (!bundleMap) {
        bundleMap = sourceMapString(
          _toConsumableArray(prepend).concat(
            _toConsumableArray(_this2._getSortedModules(graph))
          ),
          {
            excludeSource: serializerOptions.excludeSource,
            processModuleFilter: _this2._config.serializer.processModuleFilter
          }
        );
      }

      return {
        code: bundleCode,
        map: bundleMap
      };
    })();
  }

  getRamBundleInfo(options) {
    var _this3 = this;

    return _asyncToGenerator(function*() {
      const _splitBundleOptions2 = splitBundleOptions(options),
        entryFile = _splitBundleOptions2.entryFile,
        graphOptions = _splitBundleOptions2.graphOptions,
        onProgress = _splitBundleOptions2.onProgress,
        serializerOptions = _splitBundleOptions2.serializerOptions,
        transformOptions = _splitBundleOptions2.transformOptions;

      const _ref14 = yield _this3._bundler.buildGraph(
          entryFile,
          transformOptions,
          {
            onProgress,
            shallow: graphOptions.shallow
          }
        ),
        prepend = _ref14.prepend,
        graph = _ref14.graph;

      const entryPoint = path.resolve(_this3._config.projectRoot, entryFile);
      return yield getRamBundleInfo(entryPoint, prepend, graph, {
        asyncRequireModulePath:
          _this3._config.transformer.asyncRequireModulePath,
        processModuleFilter: _this3._config.serializer.processModuleFilter,
        createModuleId: _this3._createModuleId,
        dev: transformOptions.dev,
        excludeSource: serializerOptions.excludeSource,
        getRunModuleStatement: _this3._config.serializer.getRunModuleStatement,
        getTransformOptions: _this3._config.transformer.getTransformOptions,
        platform: transformOptions.platform,
        projectRoot: _this3._config.projectRoot,
        modulesOnly: serializerOptions.modulesOnly,
        runBeforeMainModule: _this3._config.serializer.getModulesRunBeforeMainModule(
          path.relative(_this3._config.projectRoot, entryPoint)
        ),
        runModule: serializerOptions.runModule,
        sourceMapUrl: serializerOptions.sourceMapUrl,
        sourceUrl: serializerOptions.sourceUrl,
        inlineSourceMap: serializerOptions.inlineSourceMap
      });
    })();
  }

  getAssets(options) {
    var _this4 = this;

    return _asyncToGenerator(function*() {
      const _splitBundleOptions3 = splitBundleOptions(options),
        entryFile = _splitBundleOptions3.entryFile,
        transformOptions = _splitBundleOptions3.transformOptions,
        onProgress = _splitBundleOptions3.onProgress;

      const _ref15 = yield _this4._bundler.buildGraph(
          entryFile,
          transformOptions,
          {
            onProgress,
            shallow: false
          }
        ),
        graph = _ref15.graph;

      return yield getAssets(graph, {
        processModuleFilter: _this4._config.serializer.processModuleFilter,
        assetPlugins: _this4._config.transformer.assetPlugins,
        platform: transformOptions.platform,
        projectRoot: _this4._config.projectRoot,
        publicPath: _this4._config.transformer.publicPath
      });
    })();
  }

  getOrderedDependencyPaths(options) {
    var _this5 = this;

    return _asyncToGenerator(function*() {
      const _splitBundleOptions4 = splitBundleOptions(
          _objectSpread({}, Server.DEFAULT_BUNDLE_OPTIONS, options, {
            bundleType: "bundle"
          })
        ),
        entryFile = _splitBundleOptions4.entryFile,
        transformOptions = _splitBundleOptions4.transformOptions,
        onProgress = _splitBundleOptions4.onProgress;

      const _ref16 = yield _this5._bundler.buildGraph(
          entryFile,
          transformOptions,
          {
            onProgress,
            shallow: false
          }
        ),
        prepend = _ref16.prepend,
        graph = _ref16.graph;

      const platform =
        transformOptions.platform ||
        parsePlatformFilePath(entryFile, _this5._platforms).platform;
      return yield getAllFiles(prepend, graph, {
        platform,
        processModuleFilter: _this5._config.serializer.processModuleFilter
      });
    })();
  }

  _rangeRequestMiddleware(req, res, data, assetPath) {
    if (req.headers && req.headers.range) {
      const _req$headers$range$re = req.headers.range
          .replace(/bytes=/, "")
          .split("-"),
        _req$headers$range$re2 = _slicedToArray(_req$headers$range$re, 2),
        rangeStart = _req$headers$range$re2[0],
        rangeEnd = _req$headers$range$re2[1];

      const dataStart = parseInt(rangeStart, 10);
      const dataEnd = rangeEnd ? parseInt(rangeEnd, 10) : data.length - 1;
      const chunksize = dataEnd - dataStart + 1;
      res.writeHead(206, {
        "Accept-Ranges": "bytes",
        "Content-Length": chunksize.toString(),
        "Content-Range": `bytes ${dataStart}-${dataEnd}/${data.length}`,
        "Content-Type": mime.lookup(path.basename(assetPath))
      });
      return data.slice(dataStart, dataEnd + 1);
    }

    return data;
  }

  _processSingleAssetRequest(req, res) {
    var _this6 = this;

    return _asyncToGenerator(function*() {
      const urlObj = url.parse(decodeURI(req.url), true);
      const assetPath =
        urlObj && urlObj.pathname && urlObj.pathname.match(/^\/assets\/(.+)$/);

      if (!assetPath) {
        throw new Error("Could not extract asset path from URL");
      }

      const processingAssetRequestLogEntry = log(
        createActionStartEntry({
          action_name: "Processing asset request",
          asset: assetPath[1]
        })
      );

      try {
        const data = yield getAsset(
          assetPath[1],
          _this6._config.projectRoot,
          _this6._config.watchFolders,
          /* $FlowFixMe: query may be empty for invalid URLs */
          urlObj.query.platform,
          _this6._config.resolver.assetExts
        ); // Tell clients to cache this for 1 year.
        // This is safe as the asset url contains a hash of the asset.

        if (process.env.REACT_NATIVE_ENABLE_ASSET_CACHING === true) {
          res.setHeader("Cache-Control", "max-age=31536000");
        }

        res.end(_this6._rangeRequestMiddleware(req, res, data, assetPath[1]));
        process.nextTick(() => {
          log(createActionEndEntry(processingAssetRequestLogEntry));
        });
      } catch (error) {
        console.error(error.stack);
        res.writeHead(404);
        res.end("Asset not found");
      }
    })();
  }

  _processRequest(req, res, next) {
    var _this7 = this;

    return _asyncToGenerator(function*() {
      const urlObj = url.parse(req.url, true);
      const host = req.headers.host;
      debug(`Handling request: ${host ? "http://" + host : ""}${req.url}`);
      /* $FlowFixMe: Could be empty if the URL is invalid. */

      const pathname = urlObj.pathname;

      if (pathname.match(/\.bundle$/)) {
        yield _this7._processBundleRequest(req, res);
      } else if (pathname.match(/\.map$/)) {
        // Chrome dev tools may need to access the source maps.
        res.setHeader("Access-Control-Allow-Origin", "devtools://devtools");
        yield _this7._processSourceMapRequest(req, res);
      } else if (pathname.match(/\.assets$/)) {
        yield _this7._processAssetsRequest(req, res);
      } else if (pathname.match(/^\/assets\//)) {
        yield _this7._processSingleAssetRequest(req, res);
      } else if (pathname === "/symbolicate") {
        yield _this7._symbolicate(req, res);
      } else {
        next();
      }
    })();
  }

  _createRequestProcessor(_ref17) {
    let createStartEntry = _ref17.createStartEntry,
      createEndEntry = _ref17.createEndEntry,
      build = _ref17.build,
      finish = _ref17.finish;
    return (
      /*#__PURE__*/
      (function() {
        var _requestProcessor = _asyncToGenerator(function*(req, res) {
          const mres = MultipartResponse.wrap(req, res);
          const bundleOptions = parseOptionsFromUrl(
            url.format(
              _objectSpread({}, url.parse(req.url), {
                protocol: "http",
                host: req.headers.host
              })
            ),
            new Set(this._config.resolver.platforms)
          );

          const _splitBundleOptions5 = splitBundleOptions(bundleOptions),
            entryFile = _splitBundleOptions5.entryFile,
            graphOptions = _splitBundleOptions5.graphOptions,
            transformOptions = _splitBundleOptions5.transformOptions,
            serializerOptions = _splitBundleOptions5.serializerOptions;
          /**
           * `entryFile` is relative to projectRoot, we need to use resolution function
           * to find the appropriate file with supported extensions.
           */

          const resolutionFn = yield transformHelpers.getResolveDependencyFn(
            this._bundler.getBundler(),
            transformOptions.platform
          );
          const resolvedEntryFilePath = resolutionFn(
            `${this._config.projectRoot}/.`,
            entryFile
          );
          const graphId = getGraphId(resolvedEntryFilePath, transformOptions, {
            shallow: graphOptions.shallow,
            experimentalImportBundleSupport: this._config.transformer
              .experimentalImportBundleSupport
          });
          const buildID = this.getNewBuildID();
          let onProgress = null;

          if (this._config.reporter) {
            onProgress = (transformedFileCount, totalFileCount) => {
              mres.writeChunk(
                {
                  "Content-Type": "application/json"
                },
                JSON.stringify({
                  done: transformedFileCount,
                  total: totalFileCount
                })
              );

              this._reporter.update({
                buildID,
                type: "bundle_transform_progressed",
                transformedFileCount,
                totalFileCount
              });
            };
          }

          this._reporter.update({
            buildID,
            bundleDetails: {
              entryFile: resolvedEntryFilePath,
              platform: transformOptions.platform,
              dev: transformOptions.dev,
              minify: transformOptions.minify,
              bundleType: bundleOptions.bundleType
            },
            type: "bundle_build_started"
          });

          const startContext = {
            buildID,
            bundleOptions,
            entryFile: resolvedEntryFilePath,
            graphId,
            graphOptions,
            mres,
            onProgress,
            req,
            serializerOptions,
            transformOptions
          };
          const logEntry = log(
            createActionStartEntry(createStartEntry(startContext))
          );
          let result;

          try {
            result = yield build(startContext);
          } catch (error) {
            const formattedError = formatBundlingError(error);
            const status = error instanceof ResourceNotFoundError ? 404 : 500;
            mres.writeHead(status, {
              "Content-Type": "application/json; charset=UTF-8"
            });
            mres.end(JSON.stringify(formattedError));

            this._reporter.update({
              buildID,
              type: "bundle_build_failed",
              bundleOptions
            });

            this._reporter.update({
              error,
              type: "bundling_error"
            });

            log({
              action_name: "bundling_error",
              error_type: formattedError.type,
              log_entry_label: "bundling_error",
              bundle_id: graphId,
              build_id: buildID,
              stack: formattedError.message
            });
            return;
          }

          const endContext = _objectSpread({}, startContext, {
            result
          });

          finish(endContext);

          this._reporter.update({
            buildID,
            type: "bundle_build_done"
          });

          log(
            createActionEndEntry(
              _objectSpread({}, logEntry, createEndEntry(endContext))
            )
          );
        });

        function requestProcessor(_x4, _x5) {
          return _requestProcessor.apply(this, arguments);
        }

        return requestProcessor;
      })()
    );
  }

  // This function ensures that modules in source maps are sorted in the same
  // order as in a plain JS bundle.
  _getSortedModules(graph) {
    const modules = _toConsumableArray(graph.dependencies.values()); // Assign IDs to modules in a consistent order

    for (const module of modules) {
      this._createModuleId(module.path);
    } // Sort by IDs

    return modules.sort(
      (a, b) => this._createModuleId(a.path) - this._createModuleId(b.path)
    );
  }

  _symbolicate(req, res) {
    var _this8 = this;

    return _asyncToGenerator(function*() {
      const getCodeFrame = (urls, symbolicatedStack) => {
        for (let i = 0; i < symbolicatedStack.length; i++) {
          const _symbolicatedStack$i = symbolicatedStack[i],
            collapse = _symbolicatedStack$i.collapse,
            column = _symbolicatedStack$i.column,
            file = _symbolicatedStack$i.file,
            lineNumber = _symbolicatedStack$i.lineNumber;

          if (collapse || lineNumber == null || urls.has(file)) {
            continue;
          }

          return {
            content: codeFrameColumns(
              fs.readFileSync(file, "utf8"),
              {
                // Metro returns 0 based columns but codeFrameColumns expects 1-based columns
                start: {
                  column: column + 1,
                  line: lineNumber
                }
              },
              {
                forceColor: true
              }
            ),
            location: {
              row: lineNumber,
              column
            },
            fileName: file
          };
        }

        return null;
      };

      try {
        const symbolicatingLogEntry = log(
          createActionStartEntry("Symbolicating")
        );
        debug("Start symbolication");
        /* $FlowFixMe: where is `rawBody` defined? Is it added by the `connect` framework? */

        const body = yield req.rawBody;
        const stack = JSON.parse(body).stack; // In case of multiple bundles / HMR, some stack frames can have different URLs from others

        const urls = new Set();
        stack.forEach(frame => {
          const sourceUrl = frame.file; // Skip `/debuggerWorker.js` which does not need symbolication.

          if (
            sourceUrl != null &&
            !urls.has(sourceUrl) &&
            !sourceUrl.endsWith("/debuggerWorker.js") &&
            sourceUrl.startsWith("http")
          ) {
            urls.add(sourceUrl);
          }
        });
        debug("Getting source maps for symbolication");
        const sourceMaps = yield Promise.all(
          Array.from(urls.values()).map(_this8._explodedSourceMapForURL, _this8)
        );
        debug("Performing fast symbolication");
        const symbolicatedStack = yield symbolicate(
          stack,
          zip(urls.values(), sourceMaps),
          _this8._config
        );
        debug("Symbolication done");
        res.end(
          JSON.stringify({
            codeFrame: getCodeFrame(urls, symbolicatedStack),
            stack: symbolicatedStack
          })
        );
        process.nextTick(() => {
          log(createActionEndEntry(symbolicatingLogEntry));
        });
      } catch (error) {
        console.error(error.stack || error);
        res.statusCode = 500;
        res.end(
          JSON.stringify({
            error: error.message
          })
        );
      }
    })();
  }

  _explodedSourceMapForURL(reqUrl) {
    var _this9 = this;

    return _asyncToGenerator(function*() {
      const options = parseOptionsFromUrl(
        reqUrl,
        new Set(_this9._config.resolver.platforms)
      );

      const _splitBundleOptions6 = splitBundleOptions(options),
        entryFile = _splitBundleOptions6.entryFile,
        transformOptions = _splitBundleOptions6.transformOptions,
        serializerOptions = _splitBundleOptions6.serializerOptions,
        graphOptions = _splitBundleOptions6.graphOptions,
        onProgress = _splitBundleOptions6.onProgress;
      /**
       * `entryFile` is relative to projectRoot, we need to use resolution function
       * to find the appropriate file with supported extensions.
       */

      const resolutionFn = yield transformHelpers.getResolveDependencyFn(
        _this9._bundler.getBundler(),
        transformOptions.platform
      );
      const resolvedEntryFilePath = resolutionFn(
        `${_this9._config.projectRoot}/.`,
        entryFile
      );
      const graphId = getGraphId(resolvedEntryFilePath, transformOptions, {
        shallow: graphOptions.shallow,
        experimentalImportBundleSupport:
          _this9._config.transformer.experimentalImportBundleSupport
      });
      let revision;

      const revPromise = _this9._bundler.getRevisionByGraphId(graphId);

      if (revPromise == null) {
        var _ref18 = yield _this9._bundler.initializeGraph(
          resolvedEntryFilePath,
          transformOptions,
          {
            onProgress,
            shallow: graphOptions.shallow
          }
        );

        revision = _ref18.revision;
      } else {
        revision = yield revPromise;
      }

      let _revision2 = revision,
        prepend = _revision2.prepend,
        graph = _revision2.graph;

      if (serializerOptions.modulesOnly) {
        prepend = [];
      }

      return getExplodedSourceMap(
        _toConsumableArray(prepend).concat(
          _toConsumableArray(_this9._getSortedModules(graph))
        ),
        {
          processModuleFilter: _this9._config.serializer.processModuleFilter
        }
      );
    })();
  }

  getNewBuildID() {
    return (this._nextBundleBuildID++).toString(36);
  }

  getPlatforms() {
    return this._config.resolver.platforms;
  }

  getWatchFolders() {
    return this._config.watchFolders;
  }
}

_defineProperty(Server, "DEFAULT_GRAPH_OPTIONS", {
  customTransformOptions: Object.create(null),
  dev: true,
  hot: false,
  minify: false
});

_defineProperty(
  Server,
  "DEFAULT_BUNDLE_OPTIONS",
  _objectSpread({}, Server.DEFAULT_GRAPH_OPTIONS, {
    excludeSource: false,
    inlineSourceMap: false,
    modulesOnly: false,
    onProgress: null,
    runModule: true,
    shallow: false,
    sourceMapUrl: null,
    sourceUrl: null
  })
);

function* zip(xs, ys) {
  //$FlowIssue #9324959
  const ysIter = ys[Symbol.iterator]();

  for (const x of xs) {
    const y = ysIter.next();

    if (y.done) {
      return;
    }

    yield [x, y.value];
  }
}

module.exports = Server;
