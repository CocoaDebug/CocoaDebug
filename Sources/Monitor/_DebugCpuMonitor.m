////
////  Example
////  man.li
////
////  Created by man.li on 11/11/2018.
////  Copyright © 2020 man.li. All rights reserved.
////
//
//#import "_DebugCpuMonitor.h"
//#import <mach/mach.h>
//
//@implementation _DebugCpuMonitor
//
//+ (instancetype)sharedInstance {
//    static id sharedInstance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        sharedInstance = [[self alloc] init];
//    });
//    return sharedInstance;
//}
//
//- (float)getValue {
//    kern_return_t kr;
//    task_info_data_t tinfo;
//    mach_msg_type_number_t task_info_count;
//
//    task_info_count = TASK_INFO_MAX;
//    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
//    if (kr != KERN_SUCCESS) {
//        return -1;
//    }
//
//    task_basic_info_t      basic_info;
//    thread_array_t         thread_list;
//    mach_msg_type_number_t thread_count;
//
//    thread_info_data_t     thinfo;
//    mach_msg_type_number_t thread_info_count;
//
//    thread_basic_info_t basic_info_th;
//    uint32_t stat_thread = 0;
//
//    basic_info = (task_basic_info_t)tinfo;
//
//    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
//    if (kr != KERN_SUCCESS) {
//        return -1;
//    }
//    if (thread_count > 0)
//        stat_thread += thread_count;
//
//    long tot_sec = 0;
//    long tot_usec = 0;
//    float tot_cpu = 0;
//    int j;
//
//    for (j = 0; j < thread_count; j++)
//    {
//        thread_info_count = THREAD_INFO_MAX;
//        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
//                         (thread_info_t)thinfo, &thread_info_count);
//        if (kr != KERN_SUCCESS) {
//            return -1;
//        }
//
//        basic_info_th = (thread_basic_info_t)thinfo;
//
//        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
//            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
//            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
//            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
//        }
//
//    }
//    
//    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
//    assert(kr == KERN_SUCCESS);
//
//    return tot_cpu;
//}
//
//@end
