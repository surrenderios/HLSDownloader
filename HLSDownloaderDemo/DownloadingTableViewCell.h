//
//  DownloadingTableViewCell.h
//  MKTV
//
//  Created by Alex_Wu on 4/9/19.
//  Copyright © 2019 北京视达科科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLSDownloader/HLSDownloadItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface DownloadingTableViewCell : UITableViewCell
@property (nonatomic, assign) HLSDownloadItem *item;

@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UIButton *stateButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *speedOrStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadedSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalSizeLabel;
@end

NS_ASSUME_NONNULL_END
