//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_DebugMemoryMonitor.h"
#import <mach/mach.h>

@implementation _DebugMemoryMonitor

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (float)getValue {
    int64_t memoryUsageInByte = 0;
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    memoryUsageInByte = (int64_t) vmInfo.phys_footprint;
    
    return memoryUsageInByte/1024.0/1024.0;
}

@end
