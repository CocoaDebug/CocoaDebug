import { DurationEvent } from '../types/EventInterfaces';
import { SourceMap } from '../types/SourceMap';
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
declare const applySourceMapsToEvents: (sourceMap: SourceMap, chromeEvents: DurationEvent[], indexBundleFileName: string | undefined) => Promise<DurationEvent[]>;
export default applySourceMapsToEvents;
