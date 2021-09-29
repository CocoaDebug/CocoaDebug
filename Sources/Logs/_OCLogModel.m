//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

#import "_OCLogModel.h"
#import "_OCLoggerFormat.h"
#import "_NetworkHelper.h"

@implementation _OCLogModel

- (instancetype)initWithContent:(NSString *)content color:(UIColor *)color fileInfo:(NSString *)fileInfo isTag:(BOOL)isTag type:(CocoaDebugToolType)type
{
    if (self = [super init]) {
        
        if ([fileInfo isEqualToString:@"XXX|XXX|1"]) {
            if (type == CocoaDebugToolTypeProtobuf) {
                fileInfo = @"Protobuf\n";
            } else {
                fileInfo = @"\n";
            }
        }
        
        //
        if (type == CocoaDebugToolTypeNone) {
            if ([fileInfo isEqualToString:@" \n"]) {//nslog
                fileInfo = @"NSLog\n";
            } else if ([fileInfo isEqualToString:@"\n"]) {//color
                fileInfo = @"\n";
            }
        }
        
        //RN (java script)
        if ([fileInfo isEqualToString:@"[RCTLogError]\n"]) {
            fileInfo = @"[error]\n";
        } else if ([fileInfo isEqualToString:@"[RCTLogInfo]\n"]) {
            fileInfo = @"[log]\n";
        }
        
        //
        self.Id = [[NSUUID UUID] UUIDString];
        self.fileInfo = fileInfo;
        self.date = [NSDate date];
        self.color = color;
        self.isTag = isTag;
        
        if ([content isKindOfClass:[NSString class]]) {
            self.contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        //避免日志数量过多导致卡顿
        if (content.length > 1000) {
            content = [content substringToIndex:1000];
        }
        self.content = content;
        
        /////////////////////////////////////////////////////////////////////////
        
        NSInteger startIndex = 0;
        NSInteger lenghtDate = 0;
        NSString *stringContent = @"";
        
        stringContent = [stringContent stringByAppendingFormat:@"[%@]", [_OCLoggerFormat formatDate:self.date]];
        lenghtDate = [stringContent length];
        startIndex = [stringContent length];
        
        if (self.fileInfo) {
            stringContent = [stringContent stringByAppendingFormat:@"%@%@", self.fileInfo, self.content];
        } else {
            stringContent = [stringContent stringByAppendingFormat:@"%@", self.content];
        }
        
        NSMutableAttributedString *attstr = [[NSMutableAttributedString alloc] initWithString:stringContent];
        [attstr addAttribute:NSForegroundColorAttributeName value:self.color range:NSMakeRange(0, [stringContent length])];
        
        NSRange range = NSMakeRange(0, lenghtDate);
        [attstr addAttribute:NSForegroundColorAttributeName value: [[_NetworkHelper shared] mainColor] range: range];
        [attstr addAttribute:NSFontAttributeName value: [UIFont boldSystemFontOfSize:12] range: range];
        
        NSRange range2 = NSMakeRange(startIndex, self.fileInfo.length);
        
        if ([self.fileInfo isEqualToString:@"[error]\n"]) {
            [attstr addAttribute: NSForegroundColorAttributeName value: [UIColor systemRedColor]  range: range2];
        } else {
            [attstr addAttribute: NSForegroundColorAttributeName value: [UIColor systemGrayColor]  range: range2];
        }
        
        [attstr addAttribute: NSFontAttributeName value: [UIFont boldSystemFontOfSize:12] range: range2];
        
        
        //换行
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        
        NSRange rang3 = NSMakeRange(0, attstr.length);
        [attstr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:rang3];
        
        
        //
        self.str = stringContent;
        self.attr = [attstr copy];
    }
    
    return self;
}

@end
