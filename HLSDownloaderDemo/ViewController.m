//
//  ViewController.m
//  HLSDownloaderDemo
//
//  Created by Alex_Wu on 5/8/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import "ViewController.h"
#import <HLSDownloader/HLSDownloader.h>
#import <HLSDownloader/HLSDownloadOperation.h>

@interface ViewController ()<HLSDownloadOperationDelegate>
@property (weak, nonatomic) IBOutlet UIProgressView *progressA;
@property (weak, nonatomic) IBOutlet UIProgressView *progressB;

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, strong) HLSDownloader *downloader;
@property (nonatomic, strong) HLSDownloadOperation *operation;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.urlString = @"http://61.138.254.167:5000/nn_vod/nn_x64/aWQ9NWJiZWM1OWExODM2OTg1NWJjOWQ0NWFmMDMxYjM2ZDUmdXJsX2MxPTdhNjg2ZjZlNjc2Nzc1NjE2ZTY3NjM2ODc1NjE2ZTYyNmYyZjMyMzAzMTM4MzEzMDMxMzEyZjM1NjI2MjY1NjMzNTY0MzUzMzYxMzAzMTY0MzgzMTYxNjUzOTYzMzE2MjM0MzA2NDYzMzAzNjY1MzAzMDMxMzUyZjM1NjI2MjY1NjMzNTM5NjEzMTM4MzMzNjM5MzgzNTM1NjI2MzM5NjQzNDM1NjE2NjMwMzMzMTYyMzMzNjY0MzUyZTc0NzMwMCZubl9haz0wMTljNjFlZjk5MDFmNjUyNjkyODA2NjYyNGQwMzlhZjBiJm50dGw9MyZucGlwcz0xOTIuMTY4LjIwNC4xMTI6NTEwMCZuY21zaWQ9MTYwMTAxJm5ncz01Y2MyNzUzNDIzNDY0MThhYTY2YjE0ZjRkMWY0NDY1NyZubmQ9dGVzdC50cy5zdGFyY29yJm5zZD1jbi56Z2R4LmFsbCZuZnQ9dHMmbm5fdXNlcl9pZD13dXl1amluZyZuZHQ9cGhvbmUmbmRpPTBjYjMyZjNlNmJlZWRkMWU5ODhlNTE2NTMxY2IxMTc3Jm5kdj0xLjUuMC4wLjIuU0MtSHVhQ2FpVFYtSVBIT05FLjAuMF9SZWxlYXNlJm5zdD1pcHR2Jm5jYT0lMjZuYWklM2Q1NDc5NjElMjZubl9jcCUzZHpob25nZ3VhbmdjaHVhbmJvJm5hbD0wMTM0NzVjMjVjMDYwN2UwMzU5OTkzOGJmYTNiODExNzg0MTdlNWEzZGM1ZDQy/5bbec59a18369855bc9d45af031b36d5.m3u8";

    /*
    self.downloader = [HLSDownloader shareDownloader];
    [self.downloader startDownloadWith:self.urlString
                              uniqueId:@"123"
                              priority:0];
     */
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    HLSDownloadOperation *operationA = [[HLSDownloadOperation alloc] initWithUrlStr:self.urlString tsStartIndex:40];
    operationA.opUniqueId = @"A";
    operationA.delegate = self;
    
    HLSDownloadOperation *operationB = [[HLSDownloadOperation alloc] initWithUrlStr:self.urlString];
    operationB.opUniqueId = @"B";
    operationB.delegate = self;
    
    [queue addOperation:operationA];
    [queue addOperation:operationB];
}

#pragma mark - HLSDownloadOperationDelegate
- (void)hlsDownloadOperation:(HLSDownloadOperation *)op downloadStatusChanged:(HLSOperationState)status
{
    if (status == HLSOperationStateReady) {
        NSLog(@">>>>>>>>>等待中");
    }else if (status == HLSOperationStateExcuting) {
        NSLog(@">>>>>>>>>下载中");
    }else if (status == HLSOperationStateFinished){
        NSLog(@">>>>>>>>>下载完成");
    }
}

- (void)hlsDownloadOperation:(HLSDownloadOperation *)op m3u8:(nullable NSString *)m3u8Str error:(nullable NSError *)error;
{
    //NSLog(@">>>uniqueId:%@,error:%@",op.opUniqueId,error);
}

- (void)hlsDownloadOperation:(HLSDownloadOperation *)op downloadedSize:(int64_t)downloaded totalSize:(int64_t)total;
{
    float progress = downloaded * 1.0 / total;
    if ([op.opUniqueId isEqualToString:@"A"]) {
        self.progressA.progress = progress;
        //NSLog(@">>>uniqueId:%@,progress:%.2f",op.opUniqueId,(float)downloaded / total * 100);
    }else{
        self.progressB.progress = progress;
        //NSLog(@">>>uniqueId:%@,progress:%.2f",op.opUniqueId,(float)downloaded / total * 100);
    }
}

- (void)hlsDownloadOperation:(HLSDownloadOperation *)op estimateSpeed:(NSString *)speed;
{
    NSLog(@">>>uniqueId:%@,speed:%@",op.opUniqueId,speed);
}

- (void)hlsDownloadOperation:(HLSDownloadOperation *)op tsDownloadedIn:(NSUInteger)tsIndex fromRemoteUrl:(NSURL *)from toLocal:(NSURL *)localUrl;
{
    //NSLog(@">>>uniqueId:%@,tsIndex:%lu,localUrl:%@",op.opUniqueId,(unsigned long)tsIndex,localUrl);
}

- (void)hlsDownloadOperation:(HLSDownloadOperation *)op failedAtIndex:(NSUInteger)tsIndex error:(NSError *)error;
{
    //NSLog(@">>>uniqueId:%@,errorCode:%@",op.opUniqueId,(long)error.code);
}
@end
