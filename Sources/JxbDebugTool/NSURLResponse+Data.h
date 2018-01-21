//
//  NSURLResponse+Data.h
//  Pods
//
//  Created by Peter on 16/1/23.
//
//

#import <Foundation/Foundation.h>

@interface NSURLResponse (Data)

- (NSData *)responseData;
- (void)setResponseData:(NSData *)responseData;

@end
