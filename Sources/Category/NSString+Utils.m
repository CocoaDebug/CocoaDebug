
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

#import "NSString+Utils.h"

@implementation NSString (Utils)

- (CGFloat)heightWithFont:(UIFont *)font constraintToWidth:(CGFloat)width
{
    CGRect rect;
    
    float iosVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (iosVersion >= 7.0)
    {
        rect = [self boundingRectWithSize:CGSizeMake(width, 3000) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil];
    }
    else
    {
        CGSize size = [self sizeWithFont:font constrainedToSize:CGSizeMake(width, 3000) lineBreakMode:NSLineBreakByWordWrapping];
        rect = CGRectMake(0, 0, size.width, size.height);
    }
    
    return rect.size.height;
}

@end
