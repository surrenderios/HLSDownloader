//
//  BaseDownloadedSeriesViewController.h
//  MKTV
//
//  Created by Alex_Wu on 4/16/19.
//  Copyright © 2019 北京视达科科技有限公司. All rights reserved.
//

#import "EditViewController.h"
#import <HLSDownloader/HLSDownloader.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseDownloadedSeriesViewController : EditViewController<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong) HLSDownloadItem *downloadItem;
@end

NS_ASSUME_NONNULL_END
