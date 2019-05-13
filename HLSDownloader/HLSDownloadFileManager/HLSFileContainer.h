//
//  HLSFileContainer.h
//  HLSDownloader
//
//  Created by Alex_Wu on 5/8/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLSFileContainer : NSObject
+ (HLSFileContainer *)shareFileContainer;
- (instancetype)initWithHLSContainerName:(nullable NSString *)containerName;
- (void)clearContainer;

#pragma mark - childContainer
- (void)clearChildContainerWithUniqueId:(NSString *)uniqueId;

- (id)readM3U8WithUniqueId:(NSString *)uniqueId;
- (void)cacheM3U8:(NSString *)m3u8 withUniqueId:(NSString *)uniqueId;

- (NSURL *)readTsInContainer:(NSString *)uniqueId url:(NSString *)tsUrl index:(NSUInteger)tsIndex;

- (void)cacheTsInContainer:(NSString *)uniqueId url:(NSURL *)tsUrl index:(NSUInteger)tsIndex content:(id)data;
- (void)cacheTsInContainer:(NSString *)uniqueId url:(NSURL *)tsUrl index:(NSUInteger)tsIndex tempLocalUrl:(NSURL *)local;

- (void)removeTsInContainder:(NSString *)uniqueId url:(NSString *)tsUrl index:(NSUInteger)tsIndex;
@end

NS_ASSUME_NONNULL_END
