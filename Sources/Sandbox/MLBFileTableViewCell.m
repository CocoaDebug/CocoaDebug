//
//  MLBFileTableViewCell.m
//  Example
//
//  Created by meilbn on 18/07/2017.
//  Copyright © 2017 meilbn. All rights reserved.
//

#import "MLBFileTableViewCell.h"

NSString *const MLBFileTableViewCellReuseIdentifier = @"MLBFileCell";

@implementation MLBFileTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews {
    self.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
}

#pragma mark - Action



#pragma mark - Public Methods



@end
