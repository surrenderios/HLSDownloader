//
//  DownloadingTableViewCell.h
//  MKTV
//
//  Created by Alex_Wu on 4/9/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import "BaseDownloadTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface DownloadingTableViewCell : BaseDownloadTableViewCell<HLSDownloadItemDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UIButton *stateButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *speedOrStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadedSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalSizeLabel;
@end

NS_ASSUME_NONNULL_END
