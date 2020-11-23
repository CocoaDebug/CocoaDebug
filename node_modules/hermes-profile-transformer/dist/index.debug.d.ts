import { DurationEvent } from './types/EventInterfaces';
/**
 * This transformer can take in the path of the profile, the source map (optional) and the bundle file name (optional)
 * and return a promise which resolves to Chrome Dev Tools compatible events
 * @param profilePath string
 * @param sourceMapPath string
 * @param bundleFileName string
 * @return Promise<DurationEvent[]>
 */
declare const transformer: (profilePath: string, sourceMapPath: string | undefined, bundleFileName: string | undefined) => Promise<DurationEvent[]>;
export default transformer;
export { SourceMap } from './types/SourceMap';
