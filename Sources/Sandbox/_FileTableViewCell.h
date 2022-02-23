//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const _FileTableViewCellReuseIdentifier;

@class _FileTableViewCell;
@protocol _FileTableViewCellDelegate <NSObject>

- (void)didLongPressCell:(_FileTableViewCell *)cell index:(NSInteger)index;

@end

@interface _FileTableViewCell : UITableViewCell

@property (nonatomic, weak) id<_FileTableViewCellDelegate> delegate;
@property (nonatomic, assign) NSInteger index;

@end
