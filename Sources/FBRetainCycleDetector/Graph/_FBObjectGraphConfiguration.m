//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_FBObjectGraphConfiguration.h"

@implementation _FBObjectGraphConfiguration

- (instancetype)initWithFilterBlocks:(NSArray<_FBGraphEdgeFilterBlock> *)filterBlocks
                 shouldInspectTimers:(BOOL)shouldInspectTimers
                    transformerBlock:(nullable _FBObjectiveCGraphElementTransformerBlock)transformerBlock
           shouldIncludeBlockAddress:(BOOL)shouldIncludeBlockAddress
{
  if (self = [super init]) {
    _filterBlocks = [filterBlocks copy];
    _shouldInspectTimers = shouldInspectTimers;
    _shouldIncludeBlockAddress = shouldIncludeBlockAddress;
    _transformerBlock = [transformerBlock copy];
    _layoutCache = [NSMutableDictionary new];
  }

  return self;
}

- (instancetype)initWithFilterBlocks:(NSArray<_FBGraphEdgeFilterBlock> *)filterBlocks
                 shouldInspectTimers:(BOOL)shouldInspectTimers
                    transformerBlock:(nullable _FBObjectiveCGraphElementTransformerBlock)transformerBlock
{
  return [self initWithFilterBlocks:filterBlocks
                shouldInspectTimers:shouldInspectTimers
                   transformerBlock:transformerBlock
          shouldIncludeBlockAddress:NO];
}

- (instancetype)initWithFilterBlocks:(NSArray<_FBGraphEdgeFilterBlock> *)filterBlocks
                 shouldInspectTimers:(BOOL)shouldInspectTimers
{
  return [self initWithFilterBlocks:filterBlocks
                shouldInspectTimers:shouldInspectTimers
                   transformerBlock:nil];
}

- (instancetype)init
{
  // By default we are inspecting timers
  return [self initWithFilterBlocks:@[]
                shouldInspectTimers:YES];
}

@end
