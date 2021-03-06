//
//  BaseDownloadTableViewCell.h
//  MKTV
//
//  Created by Alex_Wu on 4/15/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIImageView+WebCache.h>
#import <HLSDownloader/HLSDownloader.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseDownloadTableViewCell : UITableViewCell
@property (nonatomic, strong) HLSDownloadItem *item;
@end

NS_ASSUME_NONNULL_END
