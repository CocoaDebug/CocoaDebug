//
//  DebugTool.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "FileTableViewCell.h"
#import "Sandbox.h"

NSString *const FileTableViewCellReuseIdentifier = @"FileTableViewCell";

@implementation FileTableViewCell

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

//liman
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.image = [UIImage imageNamed:self.fileInfo.typeImageName inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    self.textLabel.text = [Sandbox shared].isExtensionHidden ? self.fileInfo.displayName.stringByDeletingPathExtension : self.fileInfo.displayName;
    self.accessoryType = self.fileInfo.isDirectory ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    //    cell.detailTextLabel.text = fileInfo.modificationDateText;
    
    //liman
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.fileInfo.modificationDateText];
    if ([attributedString length] >= 21) {
        [attributedString setAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:66/255.0 green:212/255.0 blue:89/255.0 alpha:1.0], NSFontAttributeName: [UIFont boldSystemFontOfSize:12]} range:NSMakeRange(0, 21)];
    }
    self.detailTextLabel.attributedText = [attributedString copy];
}

@end
