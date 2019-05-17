//
//  DownloadedTableViewCell.m
//  MKTV
//
//  Created by Alex_Wu on 4/9/19.
//  Copyright © 2019 北京视达科科技有限公司. All rights reserved.
//

#import "DownloadedTableViewCell.h"

@implementation DownloadedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -
- (void)setItem:(HLSDownloadItem *)item
{
    [super setItem:item];
    
    [self.posterImageView sd_setImageWithURL:[NSURL URLWithString:nil] placeholderImage:nil];
    self.nameLabel.text = item.uniqueId;
}
@end
