import { CpuProfilerModel } from './profiler/cpuProfilerModel';
import { DurationEvent } from './types/EventInterfaces';
import { readFileAsync } from './utils/fileSystem';
import { HermesCPUProfile } from './types/HermesProfile';
import applySourceMapsToEvents from './profiler/applySourceMapsToEvents';
import { SourceMap } from './types/SourceMap';

/**
 * This transformer can take in the path of the profile, the source map (optional) and the bundle file name (optional)
 * and return a promise which resolves to Chrome Dev Tools compatible events
 * @param profilePath string
 * @param sourceMapPath string
 * @param bundleFileName string
 * @return Promise<DurationEvent[]>
 */
const transformer = async (
  profilePath: string,
  sourceMapPath: string | undefined,
  bundleFileName: string | undefined
): Promise<DurationEvent[]> => {
  const hermesProfile: HermesCPUProfile = await readFileAsync(profilePath);
  const profileChunk = CpuProfilerModel.collectProfileEvents(hermesProfile);
  const profiler = new CpuProfilerModel(profileChunk);
  const chromeEvents = profiler.createStartEndEvents();
  if (sourceMapPath) {
    const sourceMap: SourceMap = await readFileAsync(sourceMapPath);
    const events = applySourceMapsToEvents(
      sourceMap,
      chromeEvents,
      bundleFileName
    );
    return events;
  }
  return chromeEvents;
};

export default transformer;
export { SourceMap } from './types/SourceMap';
