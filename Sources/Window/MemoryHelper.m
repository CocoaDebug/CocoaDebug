//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import "MemoryHelper.h"
#include <mach/mach.h>
#include <malloc/malloc.h>

static vm_size_t            jPageSize = 0;
static vm_statistics_data_t jVMStats;

#define KB    (1024)
#define MB    (KB * 1024)
#define GB    (MB * 1024)

@implementation MemoryHelper

+ (instancetype)shared
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (NSString *)appUsedMemoryAndPercentage
{
    unsigned long long total = [self bytesOfTotalMemory];
    unsigned long long used = [self bytesOfAppUsedMemory];
    NSString *appUsedStr = [self number2String:used];
    
    float proportion = (float)used / (float)total;
    NSString *percentStr = [NSString stringWithFormat:@"%@%@", [NSString stringWithFormat:@"%.2f", proportion * 100], @"%"];
    
    return [NSString stringWithFormat:@"%@  (%@)", appUsedStr, percentStr];
}

- (NSString *)appUsedMemoryAndFreeMemory
{
    unsigned long long used = [self bytesOfAppUsedMemory];
    NSString *appUsedStr = [self number2String:used];
    
//    unsigned long long free = [self bytesOfFreeMemory];
//    NSString *freeStr = [self number2String:free];
//
//    return [NSString stringWithFormat:@"%@  %@ Free", appUsedStr, freeStr];
    
    return [NSString stringWithFormat:@"%@  ", appUsedStr];
}

- (NSString* )number2String:(int64_t)n
{
    if ( n < KB )
    {
        return [NSString stringWithFormat:@"%lldB", n];
    }
    else if ( n < MB )
    {
        return [NSString stringWithFormat:@"%.1fK", (float)n / (float)KB];
    }
    else if ( n < GB )
    {
        return [NSString stringWithFormat:@"%.1fM", (float)n / (float)MB];
    }
    else
    {
        return [NSString stringWithFormat:@"%.1fG", (float)n / (float)GB];
    }
}

#pragma mark - helper
- (unsigned long long)bytesOfAppUsedMemory
{
    struct mstats stat = mstats();
    return  stat.bytes_used;
}

//- (unsigned long long)bytesOfFreeMemory //Deprecated
//{
//    return NSRealMemoryAvailable();
//}

- (unsigned long long)bytesOfFreeMemory
{
    [self updateHostStatistics];
    
    //free是空闲内存;
    //active是已使用,但可被分页的（在iOS中,只有在磁盘上静态存在的才能被分页,例如文件的内存映射,而动态分配的内存是不能被分页的）;
    //inactive是不活跃的,也就是程序退出后却没释放的内存,以便加快再次启动,而当内存不足时,就会被回收,因此也可看作空闲内存;
    //wire就是已使用,且不可被分页的.
    unsigned long long free_count   = (unsigned long long)jVMStats.free_count;
//    unsigned long long active_count = (unsigned long long)jVMStats.active_count;
//    unsigned long long inactive_count = (unsigned long long)jVMStats.inactive_count;
//    unsigned long long wire_count =  (unsigned long long)jVMStats.wire_count;
    unsigned long long pageSize = (unsigned long long)jPageSize;
    
    unsigned long long mem_free = (free_count /*+ active_count + inactive_count + wire_count*/) * pageSize;
    return mem_free;
}

- (unsigned long long)bytesOfTotalMemory
{
    [self updateHostStatistics];
    
    //free是空闲内存;
    //active是已使用,但可被分页的（在iOS中,只有在磁盘上静态存在的才能被分页,例如文件的内存映射,而动态分配的内存是不能被分页的）;
    //inactive是不活跃的,也就是程序退出后却没释放的内存,以便加快再次启动,而当内存不足时,就会被回收,因此也可看作空闲内存;
    //wire就是已使用,且不可被分页的.
    unsigned long long free_count   = (unsigned long long)jVMStats.free_count;
    unsigned long long active_count = (unsigned long long)jVMStats.active_count;
    unsigned long long inactive_count = (unsigned long long)jVMStats.inactive_count;
    unsigned long long wire_count =  (unsigned long long)jVMStats.wire_count;
    unsigned long long pageSize = (unsigned long long)jPageSize;
    
    unsigned long long mem_free = (free_count + active_count + inactive_count + wire_count) * pageSize;
    return mem_free;
}

//for internal use
- (BOOL)updateHostStatistics {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &jPageSize);
    return (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&jVMStats, &host_size)
            == KERN_SUCCESS);
}

@end
