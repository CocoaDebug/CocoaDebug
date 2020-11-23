import path from 'path';
import { SourceMapConsumer, RawSourceMap } from 'source-map';
import { DurationEvent } from '../types/EventInterfaces';
import { SourceMap } from '../types/SourceMap';

/**
 * This function is a helper to the applySourceMapsToEvents. The category allocation logic is implemented here based on the sourcemap url (if available)
 * @param defaultCategory The category the event is of by default without the use of Source maps
 * @param url The URL which can be parsed to interpret the new category of the event (depends on node_modules)
 */
const improveCategories = (
  defaultCategory: string,
  url: string | null
): string => {
  const obtainCategory = (url: string): string => {
    const dirs = url
      .substring(url.lastIndexOf(`${path.sep}node_modules${path.sep}`))
      .split(path.sep);
    return dirs.length > 2 && dirs[1] === 'node_modules'
      ? dirs[2]
      : defaultCategory;
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
const applySourceMapsToEvents = async (
  sourceMap: SourceMap,
  chromeEvents: DurationEvent[],
  indexBundleFileName: string | undefined
): Promise<DurationEvent[]> => {
  // SEE: Should file here be an optional parameter, so take indexBundleFileName as a parameter and use
  // a default name of `index.bundle`
  const rawSourceMap: RawSourceMap = {
    version: Number(sourceMap.version),
    file: indexBundleFileName || 'index.bundle',
    sources: sourceMap.sources,
    mappings: sourceMap.mappings,
    names: sourceMap.names,
  };

  const consumer = await new SourceMapConsumer(rawSourceMap);
  const events = chromeEvents.map((event: DurationEvent) => {
    if (event.args) {
      const sm = consumer.originalPositionFor({
        line: Number(event.args.line),
        column: Number(event.args.column),
      });
      /**
       * The categories can help us better visualise the profile if we modify the categories.
       * We change these categories only in the root level and not deeper inside the args, just so we have our
       * original categories as well as these modified categories (as the modified categories simply help with visualisation)
       */
      event.cat = improveCategories(event.cat!, sm.source);
      event.args = {
        ...event.args,
        url: sm.source,
        line: sm.line,
        column: sm.column,
        params: sm.name,
        allocatedCategory: event.cat,
        allocatedName: event.name,
      };
    } else {
      throw new Error(
        `Source maps could not be derived for an event at ${event.ts} and with stackFrame ID ${event.sf}`
      );
    }
    return event;
  });
  consumer.destroy();
  return events;
};

export default applySourceMapsToEvents;
