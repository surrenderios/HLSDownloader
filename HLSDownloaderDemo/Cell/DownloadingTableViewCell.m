//
//  DownloadingTableViewCell.m
//  MKTV
//
//  Created by Alex_Wu on 4/9/19.
//  Copyright © 2019 北京视达科科技有限公司. All rights reserved.
//

#import "DownloadingTableViewCell.h"
#import <HLSDownloader/HLSDownloadHelper.h>

NS_INLINE UIColor *kProgressLoadingColor(){
    return [UIColor greenColor];
}

NS_INLINE UIColor *kProgressNormalColor(){
    return [UIColor grayColor];
}

NS_INLINE UIColor *kProgressUnActiveColor(){
    return [UIColor darkGrayColor];
}

@interface DownloadingTableViewCell()
// property for monitor download speed
@property (nonatomic,assign) int64_t beforeDowloadSize;
@property (nonatomic, assign) NSTimeInterval lastTime;
@end

@implementation DownloadingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.stateButton addTarget:self
                         action:@selector(stateButtonClicked:)
               forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated;
{
    [super setEditing:editing animated:animated];
    
    self.stateButton.enabled = !editing;
}

- (void)stateButtonClicked:(id)sender
{
    switch (self.item.status) {
        case HLSDownloadItemStatusWaiting:
        case HLSDownloadItemStatusDownloading:
            [self pause:sender];
            break;
        case HLSDownloadItemStatusPaused:
            [self resume:sender];
            break;
        case HLSDownloadItemStatusFinished:
        case HLSDownloadItemStatusFailed:
        case HLSDownloadItemStatusLostServer:
            [self retry:sender];
            break;
        default:
            break;
    }
}

- (void)pause:(id)sender
{
    [[HLSDownloader shareDownloader] pauseDownload:self.item];
}

- (void)resume:(id)sender
{
    [[HLSDownloader shareDownloader] startDownload:self.item];
}

- (void)retry:(id)sender
{
    [[HLSDownloader shareDownloader] startDownload:self.item];
}

- (void)setItem:(HLSDownloadItem *)item
{
    [super setItem:item];
    
    if (item.delegate == nil) {
        item.delegate = self;
    }
    
    [self.posterImageView sd_setImageWithURL:[NSURL URLWithString:nil]
                            placeholderImage:[UIImage imageNamed:@"placeholder"]];
    self.nameLabel.text = item.uniqueId;
    self.progressView.trackTintColor = kProgressNormalColor();
    
    [self setDownloadStatus:item.status];
}

- (void)setDownloadStatus:(HLSDownloadItemStatus)status {
    
    switch (status) {
        case HLSDownloadItemStatusWaiting:
            [self.stateButton setImage:[UIImage imageNamed:@"ic_PauseDownload"]
                              forState:UIControlStateNormal];
            
            self.progressView.progress = 0;
            self.progressView.progressTintColor = kProgressNormalColor();
            
            self.speedOrStateLabel.text = @"等待中";
            self.speedOrStateLabel.textColor = kProgressNormalColor();
            
            self.downloadedSizeLabel.text = nil;
            self.totalSizeLabel.text = nil;
            
            break;
        case HLSDownloadItemStatusDownloading:
            [self.stateButton setImage:[UIImage imageNamed:@"ic_PauseDownload"]
                              forState:UIControlStateNormal];
            
            self.progressView.progressTintColor = kProgressLoadingColor();
            
            //self.speedOrStateLabel.text = @"下载中";
            self.speedOrStateLabel.textColor = kProgressLoadingColor();
            /*
            self.downloadedSizeLabel.text = nil;
            self.totalSizeLabel.textColor = nil;
             */
            break;
        case HLSDownloadItemStatusPaused:
            [self.stateButton setImage:[UIImage imageNamed:@"ic_Download_State"]
                              forState:UIControlStateNormal];
            
            self.progressView.progressTintColor = kProgressUnActiveColor();
            
            self.speedOrStateLabel.text =  @"暂停中";
            self.speedOrStateLabel.textColor = kProgressNormalColor();
            
            self.downloadedSizeLabel.text = nil;
            self.totalSizeLabel.text = nil;
            break;
        case HLSDownloadItemStatusFailed:
            [self.stateButton setImage:[UIImage imageNamed:@"ic_Retry"]
                              forState:UIControlStateNormal];
            
            self.progressView.progressTintColor = kProgressNormalColor();
            
            self.speedOrStateLabel.text = @"缓存失败，请重试";
            self.speedOrStateLabel.textColor = kProgressNormalColor();
            
            self.downloadedSizeLabel.text = nil;
            self.totalSizeLabel.text = nil;
            break;
        case HLSDownloadItemStatusLostServer:
            self.speedOrStateLabel.text = @"0KB/S";
            break;
        case HLSDownloadItemStatusFinished:
            [self prepareForReuse];
            break;
        default:
            break;
    }
}

#pragma mark - delegate
- (void)downloadItem:(HLSDownloadItem *)item statusChanged:(HLSDownloadItemStatus)status;
{
    [self setDownloadStatus:item.status];
    if (item.status == HLSDownloadItemStatusFinished) {
        // 刷新
    }
}

- (void)downloadItem:(HLSDownloadItem *)item size:(int64_t)downloadedSize total:(int64_t)totalSize;
{
    /*
     if download speed not stable in delegate, you can monitor speed here
     [self monitorDownloadSpeed:downloadedSize];
     */
    
    [self changeSizeLblDownloadedSize:downloadedSize totalSize:totalSize];
}

- (void)downloadItem:(HLSDownloadItem *)item speed:(NSString *)speed;
{
    [self.speedOrStateLabel setText:speed];
}

- (void)changeSizeLblDownloadedSize:(int64_t)downloadedSize totalSize:(int64_t)totalSize {
    
    float progress = 0.0f;
    if (totalSize) {
        //防止下载时的回弹效果
        if (_beforeDowloadSize > downloadedSize) {
            return;
        }
        self.downloadedSizeLabel.text = [HLSDownloadHelper fileSizeStringFromBytes:downloadedSize];
        self.totalSizeLabel.text = [NSString stringWithFormat:@"/%@",[HLSDownloadHelper fileSizeStringFromBytes:totalSize]];
        
        if (totalSize != 0) {
            progress = (float)downloadedSize / totalSize;
        }
        
        _beforeDowloadSize = downloadedSize;
    }
    
    self.progressView.progress = progress;
}


/*
 method monitor download speed
- (void)monitorDownloadSpeed:(int64_t)downloadedSize
{
    if (!self.lastTime) {
        self.lastTime = CFAbsoluteTimeGetCurrent();
        return; // 第一次不计算
    }
    
    if (self.beforeDowloadSize == 0) {
        return; // 无法计算
    }
    
    NSTimeInterval time = CFAbsoluteTimeGetCurrent() - self.lastTime;
    int64_t size = downloadedSize - self.beforeDowloadSize;
    if (size > 0) {
        
        int64_t kbSize = size / 1024;
        if(kbSize < 1024){
            float speed = kbSize/time;
            self.speedOrStateLabel.text = [NSString stringWithFormat:@"%.2f KB/S",speed];
        }else{
            float speed = kbSize / 1024 / time;
            self.speedOrStateLabel.text = [NSString stringWithFormat:@"%.2f M/S",speed];
        }
        
        self.lastTime = CFAbsoluteTimeGetCurrent();
    }
}
 */
@end
