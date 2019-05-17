//
//  DownloadedSeriesViewController.m
//  MKTV
//
//  Created by Alex_Wu on 4/9/19.
//  Copyright © 2019 北京视达科科技有限公司. All rights reserved.
//

#import "DownloadedSeriesViewController.h"
#import <AVKit/AVPlayerViewController.h>
#import <HLSDownloader/HLSDownloader.h>

#import "DownloadingTableViewCell.h"
#import "DownloadedTableViewCell.h"

static NSString *const kDownloadedSeriesCellIdf = @"kDownloadedSeriesCellIdf";
static NSString *const kDownloadingSeriesCellIdf = @"kDownloadingSeriesCellIdf";

@interface DownloadedSeriesViewController ()
@property (nonatomic, strong) NSArray *urls;
@property (nonatomic, assign) NSUInteger urlIndex;

@property (nonatomic, strong) HLSDownloader *downloader;
@end

@implementation DownloadedSeriesViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"下载列表";
    NSString *testUrlFilePath = [[NSBundle mainBundle] pathForResource:@"HLSDemoTestUrls" ofType:@"plist"];
    self.urls = [[NSArray alloc] initWithContentsOfFile:testUrlFilePath];
    
    UINib *downloadedNib = [UINib nibWithNibName:@"DownloadedTableViewCell" bundle:nil];
    [self.tableView registerNib:downloadedNib forCellReuseIdentifier:kDownloadedSeriesCellIdf];
    
    UINib *downloadingNib = [UINib nibWithNibName:@"DownloadingTableViewCell" bundle:nil];
    [self.tableView registerNib:downloadingNib forCellReuseIdentifier:kDownloadingSeriesCellIdf];
    
    [self setNavigationBarBackButtonWithTitle:@"Add" selector:NSStringFromSelector(@selector(addDownloadItem:))];
    
    [self reloadData];
}

- (HLSDownloader *)downloader
{
    if (!_downloader) {
        _downloader = [HLSDownloader shareDownloader];
    }
    return _downloader;
}

- (void)reloadData
{
    self.datas = [[NSMutableArray alloc] initWithArray:self.downloader.AllItems];
    [self.tableView reloadData];
}

- (void)addDownloadItem:(id)sender
{
    if (self.urlIndex < self.urls.count) {
        NSString *url = [self.urls objectAtIndex:self.urlIndex];
        [self.downloader startDownloadWith:url uniqueId:nil priority:0];
        [self reloadData];
        
        self.urlIndex ++;
        if (self.urlIndex >= self.urls.count) {
            [self setNavigationBarBackButtonWithTitle:nil selector:nil];
        }
    }
}

#pragma mark - tableview

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HLSDownloadItem *item = [self.datas objectAtIndex:indexPath.row];
    
    if (item.status == HLSDownloadItemStatusFinished) {
        DownloadedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDownloadedSeriesCellIdf forIndexPath:indexPath];
        cell.tintColor = deleteSelectedTitleColor();
        cell.selectedBackgroundView = [UIView new];
        
        cell.item = item;
        return cell;
    }else{
        DownloadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDownloadingSeriesCellIdf forIndexPath:indexPath];
        cell.tintColor = deleteSelectedTitleColor();
        cell.selectedBackgroundView = [UIView new];
        
        cell.item = item;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.isEditing) {
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        [self updateWithSelectedCount:selectedRows.count totalCount:self.datas.count];
        return;
    }
    
    HLSDownloadItem *item = [self.datas objectAtIndex:indexPath.row];
    NSString *localUrl = [self.downloader localCachedUrlForUrlStr:item.downloadUrl uniqueId:nil];
    NSLog(@">>>>>%@",localUrl);
    
    NSURL *url = [NSURL URLWithString:localUrl];
    AVPlayer *avPlayer= [AVPlayer playerWithURL:url];
    
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.player = avPlayer;
    playerViewController.videoGravity = AVLayerVideoGravityResizeAspect;
    playerViewController.showsPlaybackControls = YES;
    [playerViewController.player play];
    [self.navigationController pushViewController:playerViewController animated:YES];
}

#pragma mark - edit
- (void)deleteSelected:(id)sender;
{
    [super deleteSelected:sender];
    
    //删除数据
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    if (selectedRows.count == 0)
    {
        return;
    }
    else
    {
        __block NSMutableArray *delArray = [[NSMutableArray alloc] init];
        
        [selectedRows enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
            HLSDownloadItem *item = self.datas[indexPath.row];
            [delArray addObject:item];
        }];
        
        [self.downloader stopDownloads:delArray];
        [self reloadData];
    }
}

#pragma mark - nav
- (void)setNavigationBarBackButtonWithTitle:(NSString *)titleName
                                   selector:(NSString *)selectorName;
{
    if (!titleName || titleName.length == 0) { self.navigationItem.leftBarButtonItem = nil; return; }
    
    SEL selector = NSSelectorFromString(selectorName);
    NSAssert(selector != nil, @"selector is nil");
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [btn setTitle:titleName forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *nvBar_leftItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nvBar_leftItem;
}
@end
