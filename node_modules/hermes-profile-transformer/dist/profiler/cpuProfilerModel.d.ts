/**
 * @license Copyright 2020 The Lighthouse Authors. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *
 * MODIFICATION NOTICE:
 * This file is derived from `https://github.com/GoogleChrome/lighthouse/blob/0422daa9b1b8528dd8436860b153134bd0f959f1/lighthouse-core/lib/tracehouse/cpu-profile-model.js`
 * and has been modified by Saphal Patro (email: saphal1998@gmail.com)
 * The following changes have been made to the original file:
 * 1. Converted code to Typescript and defined necessary types
 * 2. Wrote a method @see collectProfileEvents to convert the Hermes Samples to Profile Chunks supported by Lighthouse Parser
 * 3. Modified @see constructNodes to work with the Hermes Samples and StackFrames
 */
/**
 * @fileoverview
 *
 * This model converts the `Profile` and `ProfileChunk` mega trace events from the `disabled-by-default-v8.cpu_profiler`
 * category into B/E-style trace events that main-thread-tasks.js already knows how to parse into a task tree.
 *
 * The CPU profiler measures where time is being spent by sampling the stack (See https://www.jetbrains.com/help/profiler/Profiling_Guidelines__Choosing_the_Right_Profiling_Mode.html
 * for a generic description of the differences between tracing and sampling).
 *
 * A `Profile` event is a record of the stack that was being executed at different sample points in time.
 * It has a structure like this:
 *
 *    nodes: [function A, function B, function C]
 *    samples: [node with id 2, node with id 1, ...]
 *    timeDeltas: [4125μs since last sample, 121μs since last sample, ...]
 *
 * Helpful prior art:
 * @see https://cs.chromium.org/chromium/src/third_party/devtools-frontend/src/front_end/sdk/CPUProfileDataModel.js?sq=package:chromium&g=0&l=42
 * @see https://github.com/v8/v8/blob/99ca333b0efba3236954b823101315aefeac51ab/tools/profile.js
 * @see https://github.com/jlfwong/speedscope/blob/9ed1eb192cb7e9dac43a5f25bd101af169dc654a/src/import/chrome.ts#L200
 */
import { CPUProfileChunk, CPUProfileChunkNode, CPUProfileChunker } from '../types/CPUProfile';
import { DurationEvent } from '../types/EventInterfaces';
import { HermesCPUProfile, HermesSample, HermesStackFrame } from '../types/HermesProfile';
export declare class CpuProfilerModel {
    _profile: CPUProfileChunk;
    _nodesById: Map<number, CPUProfileChunkNode>;
    _activeNodeArraysById: Map<number, number[]>;
    constructor(profile: CPUProfileChunk);
    /**
     * Initialization function to enable O(1) access to nodes by node ID.
     * @return {Map<number, CPUProfileChunkNode}
     */
    _createNodeMap(): Map<number, CPUProfileChunkNode>;
    /**
     * Initialization function to enable O(1) access to the set of active nodes in the stack by node ID.
     * @return Map<number, number[]>
     */
    _createActiveNodeArrays(): Map<number, number[]>;
    /**
     * Returns all the node IDs in a stack when a specific nodeId is at the top of the stack
     * (i.e. a stack's node ID and the node ID of all of its parents).
     */
    _getActiveNodeIds(nodeId: number): number[];
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
    _createStartEndEventsForTransition(timestamp: number, previousNodeIds: number[], currentNodeIds: number[]): DurationEvent[];
    /**
     * Creates B/E-style trace events from a CpuProfile object created by `collectProfileEvents()`
     * @return {DurationEvent}
     * @throws If the length of timeDeltas array or the samples array does not match with the length of samples in Hermes Profile
     */
    createStartEndEvents(): DurationEvent[];
    /**
     * Creates B/E-style trace events from a CpuProfile object created by `collectProfileEvents()`
     * @param {CPUProfileChunk} profile
     */
    static createStartEndEvents(profile: CPUProfileChunk): DurationEvent[];
    /**
     * Converts the Hermes Sample into a single CpuProfileChunk object for consumption
     * by `createStartEndEvents()`.
     *
     * @param {HermesCPUProfile} profile
     * @throws Profile must have at least one sample
     * @return {CPUProfileChunk}
     */
    static collectProfileEvents(profile: HermesCPUProfile): CPUProfileChunk;
    /**
     * Constructs CPUProfileChunk Nodes and the resultant samples and time deltas to be inputted into the
     * CPUProfileChunk object which will be processed to give createStartEndEvents()
     *
     * @param {HermesSample} samples
     * @param {<string, HermesStackFrame>} stackFrames
     * @return {CPUProfileChunker}
     */
    static constructNodes(samples: HermesSample[], stackFrames: {
        [key in string]: HermesStackFrame;
    }): CPUProfileChunker;
}
