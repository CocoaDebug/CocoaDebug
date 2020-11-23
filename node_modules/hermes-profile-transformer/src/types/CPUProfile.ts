/**
 * The CPUProfileChunk is the intermediate file that Lighthouse can interpret and
 *  hence subsequently convert to events supported by Chrome Dev Tools
 */
export interface CPUProfileChunk {
  id: string;
  pid: number;
  tid: string;
  startTime: number;
  nodes: CPUProfileChunkNode[];
  samples: number[];
  timeDeltas: number[];
}

/**
 * The CPUProfileChunkNode is an individual element of the nodes[] property in the CPUProfileChunk
 * @see CPUProfileChunk
 */
export interface CPUProfileChunkNode {
  id: number;
  callFrame: {
    line: string;
    column: string;
    funcLine: string;
    funcColumn: string;
    name: string;
    url?: string;
    category: string;
  };
  parent?: number;
}

/**
 * The process of conversion of Hermes Profile Events to Lighthouse supported events are primarily focussed
 * around generating the correct values of the properties in CPUProfileChunker.
 */
export type CPUProfileChunker = {
  nodes: CPUProfileChunkNode[];
  sampleNumbers: number[];
  timeDeltas: number[];
};
