//
//  NSData+DebugMan.h
//  DebugMan
//
//  Created by liman on 21/01/2018.
//  Copyright © 2018 liman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (debugman)

+(NSData*) dataWithInputStream:(NSInputStream*) stream;

@end
