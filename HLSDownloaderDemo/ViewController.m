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

@interface ViewController ()
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
    
    self.operation = [[HLSDownloadOperation alloc] initWithUrlStr:self.urlString];
    self.operation.m3u8Block = ^(NSString *urlString, id m3u8Info, NSError *error) {
        NSLog(@">>>info:%@, error:%@",m3u8Info,error);
    };
    self.operation.progressBlock = ^(NSString *urlString, NSProgress *downloadProgress) {
        NSLog(@">>>progress:%.2f",downloadProgress.completedUnitCount/downloadProgress.totalUnitCount * 100);
    };
    self.operation.speedBlock = ^(NSString *urlString, NSString *speedDes) {
        NSLog(@">>>speed:%@",speedDes);
    };
    self.operation.tsBlock = ^(NSString *urlString, NSURL *tsUrl, NSString *targetPath, NSUInteger tsIndex, BOOL finished) {
        NSLog(@">>>tsUrl:%@ targetPath:%@",tsUrl,targetPath);
    };
    self.operation.failedBlock = ^(NSString *urlString, NSUInteger tsIndex, NSError *error) {
        NSLog(@">>>errorCode:%ld",(long)error.code);
    };
    [self.operation start];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.operation cancel];
    });
}
@end
