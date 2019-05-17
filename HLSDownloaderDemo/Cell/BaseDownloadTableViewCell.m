//
//  BaseDownloadTableViewCell.m
//  MKTV
//
//  Created by Alex_Wu on 4/15/19.
//  Copyright © 2019 北京视达科科技有限公司. All rights reserved.
//

#import "BaseDownloadTableViewCell.h"

@implementation BaseDownloadTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    if (_item) {
        _item.delegate = nil;
        _item = nil;
    }
}
@end
