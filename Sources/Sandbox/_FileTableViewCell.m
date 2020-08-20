//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_FileTableViewCell.h"

NSString *const _FileTableViewCellReuseIdentifier = @"_FileCell";

@implementation _FileTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews {
    
    //liman
    self.backgroundColor = [UIColor blackColor];
    self.contentView.backgroundColor = [UIColor blackColor];
    
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.adjustsFontSizeToFitWidth = YES;
    
    self.detailTextLabel.textColor = [UIColor grayColor];
    self.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    self.detailTextLabel.font = [UIFont boldSystemFontOfSize:12];
    //    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView *selectedView = [[UIView alloc] init];
    selectedView.backgroundColor = [UIColor clearColor];
    self.selectedBackgroundView = selectedView;
}

#pragma mark - Action



#pragma mark - Public Methods



@end
