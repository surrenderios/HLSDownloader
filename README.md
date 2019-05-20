# HLSDownloader

HLSDownloader is used for downloading m3u8 videos, Save downloaded ts file into cache folder in order to play offline

# Todo
1. Support played video auto cache
2. Support multi playlist download 
3. Optimize code and bug fix

# How to use

## Use Cocoapods 

```
pod 'HLSDownloader'
```
## Download Movies

*  Import supported  header files

```
#import <HLSDownloader/HLSDownloader.h>
```

*  Download with url

```
NSString *url = @"xxx";
[self.downloader startDownloadWith:url uniqueId:nil priority:0];
```

## Play Cached Movies
*    Get local cached url with your remote url

```    
NSString *localUrl = [self.downloader localCachedUrlForUrlStr:item.downloadUrl uniqueId:nil];
```

*   Set localUrl to your player

```
NSURL *url = [NSURL URLWithString:localUrl];
AVPlayer *avPlayer= [AVPlayer playerWithURL:url];
```

## More
* Please see HLSDownloaderDemo


