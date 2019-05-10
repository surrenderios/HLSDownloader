//
//  HLSDownloaderTest.m
//  HLSDownloaderTest
//
//  Created by Alex_Wu on 5/8/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <HLSDownloader/HLSDownloader.h>

@interface HLSDownloaderTest : XCTestCase
@property (nonatomic, strong) HLSDownloader *downloader;
@property (nonatomic, copy) NSString *urlString;
@end

@implementation HLSDownloaderTest

- (void)setUp {
    
    self.urlString = @"http://61.138.254.167:5000/nn_vod/nn_x64/aWQ9NWJiZWM1OWExODM2OTg1NWJjOWQ0NWFmMDMxYjM2ZDUmdXJsX2MxPTdhNjg2ZjZlNjc2Nzc1NjE2ZTY3NjM2ODc1NjE2ZTYyNmYyZjMyMzAzMTM4MzEzMDMxMzEyZjM1NjI2MjY1NjMzNTY0MzUzMzYxMzAzMTY0MzgzMTYxNjUzOTYzMzE2MjM0MzA2NDYzMzAzNjY1MzAzMDMxMzUyZjM1NjI2MjY1NjMzNTM5NjEzMTM4MzMzNjM5MzgzNTM1NjI2MzM5NjQzNDM1NjE2NjMwMzMzMTYyMzMzNjY0MzUyZTc0NzMwMCZubl9haz0wMTljNjFlZjk5MDFmNjUyNjkyODA2NjYyNGQwMzlhZjBiJm50dGw9MyZucGlwcz0xOTIuMTY4LjIwNC4xMTI6NTEwMCZuY21zaWQ9MTYwMTAxJm5ncz01Y2MyNzUzNDIzNDY0MThhYTY2YjE0ZjRkMWY0NDY1NyZubmQ9dGVzdC50cy5zdGFyY29yJm5zZD1jbi56Z2R4LmFsbCZuZnQ9dHMmbm5fdXNlcl9pZD13dXl1amluZyZuZHQ9cGhvbmUmbmRpPTBjYjMyZjNlNmJlZWRkMWU5ODhlNTE2NTMxY2IxMTc3Jm5kdj0xLjUuMC4wLjIuU0MtSHVhQ2FpVFYtSVBIT05FLjAuMF9SZWxlYXNlJm5zdD1pcHR2Jm5jYT0lMjZuYWklM2Q1NDc5NjElMjZubl9jcCUzZHpob25nZ3VhbmdjaHVhbmJvJm5hbD0wMTM0NzVjMjVjMDYwN2UwMzU5OTkzOGJmYTNiODExNzg0MTdlNWEzZGM1ZDQy/5bbec59a18369855bc9d45af031b36d5.m3u8";
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testInit
{
    self.downloader = [HLSDownloader shareDownloader];
    XCTAssertNotNil(self.downloader);
    
    XCTAssertEqual(self.downloader.allowCellular, NO);
    XCTAssertEqual(self.downloader.maxTaskCount, 1);
    XCTAssertEqual(self.downloader.enableSpeed, NO);
    
    self.downloader.allowCellular = YES;
    self.downloader.maxTaskCount = 2;
    self.downloader.enableSpeed = YES;
    
    XCTAssertNotEqual(self.downloader.allowCellular, NO);
    XCTAssertNotEqual(self.downloader.maxTaskCount, 1);
    XCTAssertNotEqual(self.downloader.enableSpeed, NO);
}

- (void)testStartDownload
{
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
