#import "Spotify.h"
#import <Foundation/NSDistributedNotificationCenter.h>

SPTPlayerTrack *previousTrack;

%hook SPTNowPlayingModel
%property (nonatomic, strong) MRYIPCCenter *center;
%property (nonatomic, strong) SPTGLUEImageLoader *imageLoader;
%new
+ (NSString *)localPathForCanvas:(NSString *)canvasURL {
    if ([canvasURL hasPrefix:@"https"]) {
        NSRange range = [canvasURL rangeOfString:@"//"];
        canvasURL = [canvasURL substringFromIndex:range.location + 1];
    }
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [[canvasURL stringByReplacingOccurrencesOfString:@"/" withString:@"-"] substringFromIndex:1];
    NSString *filePath = [NSString stringWithFormat:@"%@/Caches/Canvases/%@",libraryPath,fileName];
    return filePath;
}

%new
- (void)sendTrackImage:(NSURL *)imageURL {
    [self.imageLoader loadImageForURL:imageURL imageSize:CGSizeMake(640, 640) completion:^(UIImage *image, NSError *error) {
        NSData *imageData = UIImagePNGRepresentation(image);
        [self.center callExternalVoidMethod:@selector(updateWithImageData:) withArguments:imageData];
    }];
}

%new
- (void)sendStaticCanvas:(NSURL *)imageURL {
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    if (imageData) [self.center callExternalVoidMethod:@selector(updateWithImageData:) withArguments:imageData];
    else [self sendTrackImage:imageURL];
}

%new
- (void)sendUpdateWithTrack:(SPTPlayerTrack *)track {
    NSString *originalURL = [track.metadata objectForKey:@"canvas.url"];
    if (!originalURL) {
        [self sendTrackImage:track.imageURL];
        return;
    }
    NSString *filePath = [%c(SPTNowPlayingModel) localPathForCanvas:originalURL];
    NSString *URL = [[NSFileManager defaultManager] fileExistsAtPath:filePath] ? filePath : originalURL;
    BOOL canvasStatic = [track.metadata[@"canvas.type"] isEqualToString:@"IMAGE"];
    if (canvasStatic) [self sendStaticCanvas:track.imageURL];
    else [self.center callExternalVoidMethod:@selector(updateWithVideoInfo:) withArguments:URL];
}

- (void)player:(id)player didMoveToRelativeTrack:(id)track {
    %orig;
    [self sendUpdateWithTrack:self.currentTrack];
}

- (void)playerDidUpdatePlaybackControls:(SPTStatefulPlayerImplementation *)player {
    %orig;
    [self.center callExternalVoidMethod:@selector(updatePlaybackState:) withArguments:@(!player.isPaused)];
}
- (id)initWithPlayer:(id)arg0 collectionPlatform:(id)arg1 playlistDataLoader:(id)arg2 radioPlaybackService:(id)arg3 adsManager:(id)arg4 productState:(id)arg5 testManager:(id)arg6 collectionTestManager:(id)arg7 statefulPlayer:(id)arg8 yourEpisodesSaveManager:(id)arg9 educationEligibility:(id)arg10 reinventFreeConfiguration:(id)arg11 curationPlatform:(id)arg12 smartShuffleHandler:(id)arg13 {
    self.center = [%c(MRYIPCCenter) centerNamed:@"CanvasBackground.CanvasServer"];
    self.imageLoader = [[GLUEService provideImageLoaderFactory] createImageLoaderForSourceIdentifier:@"com.popsicletreehouse.CanvasBackground"];
    return %orig;
}
%end

%hook SPTGLUEServiceImplementation
- (void)load {
    %orig;
    GLUEService = self;
}
%end