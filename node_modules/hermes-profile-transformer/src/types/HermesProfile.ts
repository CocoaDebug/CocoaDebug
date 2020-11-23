import { SharedEventProperties } from './EventInterfaces';

/**
 * Each item in the stackFrames object of the hermes profile
 */
export interface HermesStackFrame {
  line: string;
  column: string;
  funcLine: string;
  funcColumn: string;
  name: string;
  category: string;
  /**
   * A parent function may or may not exist
   */
  parent?: number;
}
/**
 * Each item in the samples array of the hermes profile
 */
export interface HermesSample {
  cpu: string;
  name: string;
  ts: string;
  pid: number;
  tid: string;
  weight: string;
  /**
   * Will refer to an element in the stackFrames object of the Hermes Profile
   */
  sf: number;
  stackFrameData?: HermesStackFrame;
}

/**
 * Hermes Profile Interface
 */
export interface HermesCPUProfile {
  traceEvents: SharedEventProperties[];
  samples: HermesSample[];
  stackFrames: { [key in string]: HermesStackFrame };
}
