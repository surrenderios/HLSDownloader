//
//  DownloadedTableViewCell.h
//  MKTV
//
//  Created by Alex_Wu on 4/9/19.
//  Copyright © 2019 北京视达科科技有限公司. All rights reserved.
//
#import "BaseDownloadTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface DownloadedTableViewCell : BaseDownloadTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UIImageView *seriseImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *seriseLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalSizeLabel;
@end

NS_ASSUME_NONNULL_END
