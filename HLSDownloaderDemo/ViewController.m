//
//  ViewController.m
//  HLSDownloaderDemo
//
//  Created by Alex_Wu on 5/8/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import "ViewController.h"
#import "DownloadingTableViewCell.h"
#import <HLSDownloader/HLSDownloader.h>

static NSString *const kCacheDownloadingTableViewIdf = @"kCacheDownloadingTableViewIdf";

@interface ViewController ()
@property (nonatomic, strong) NSArray<HLSDownloadItem *> *datas;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, strong) HLSDownloader *downloader;
- (IBAction)addDownloadItem:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"DownloadingTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:kCacheDownloadingTableViewIdf];
    
    self.urlString = @"http://61.138.254.167:5000/nn_vod/nn_x64/aWQ9NWJiZWM1OWExODM2OTg1NWJjOWQ0NWFmMDMxYjM2ZDUmdXJsX2MxPTdhNjg2ZjZlNjc2Nzc1NjE2ZTY3NjM2ODc1NjE2ZTYyNmYyZjMyMzAzMTM4MzEzMDMxMzEyZjM1NjI2MjY1NjMzNTY0MzUzMzYxMzAzMTY0MzgzMTYxNjUzOTYzMzE2MjM0MzA2NDYzMzAzNjY1MzAzMDMxMzUyZjM1NjI2MjY1NjMzNTM5NjEzMTM4MzMzNjM5MzgzNTM1NjI2MzM5NjQzNDM1NjE2NjMwMzMzMTYyMzMzNjY0MzUyZTc0NzMwMCZubl9haz0wMTljNjFlZjk5MDFmNjUyNjkyODA2NjYyNGQwMzlhZjBiJm50dGw9MyZucGlwcz0xOTIuMTY4LjIwNC4xMTI6NTEwMCZuY21zaWQ9MTYwMTAxJm5ncz01Y2MyNzUzNDIzNDY0MThhYTY2YjE0ZjRkMWY0NDY1NyZubmQ9dGVzdC50cy5zdGFyY29yJm5zZD1jbi56Z2R4LmFsbCZuZnQ9dHMmbm5fdXNlcl9pZD13dXl1amluZyZuZHQ9cGhvbmUmbmRpPTBjYjMyZjNlNmJlZWRkMWU5ODhlNTE2NTMxY2IxMTc3Jm5kdj0xLjUuMC4wLjIuU0MtSHVhQ2FpVFYtSVBIT05FLjAuMF9SZWxlYXNlJm5zdD1pcHR2Jm5jYT0lMjZuYWklM2Q1NDc5NjElMjZubl9jcCUzZHpob25nZ3VhbmdjaHVhbmJvJm5hbD0wMTM0NzVjMjVjMDYwN2UwMzU5OTkzOGJmYTNiODExNzg0MTdlNWEzZGM1ZDQy/5bbec59a18369855bc9d45af031b36d5.m3u8";

    self.downloader = [HLSDownloader shareDownloader];
}

#pragma mark - tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DownloadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCacheDownloadingTableViewIdf forIndexPath:indexPath];
    cell.tintColor = [UIColor whiteColor];
    cell.selectedBackgroundView = [UIView new];
    
    HLSDownloadItem *item = self.datas[indexPath.item];
    [cell setItem:item];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 86;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.isEditing) {
        return;
    }else{
        NSLog(@"%s",__FUNCTION__);
    }
}

- (IBAction)addDownloadItem:(id)sender {
    HLSDownloadItem *item = [[HLSDownloadItem alloc] initWithUrl:self.urlString uniqueId:nil priority:0];
    [self.downloader startDownload:item];
    
    self.datas = [self.downloader downloadingItems];
    [self.tableView reloadData];
}
@end
