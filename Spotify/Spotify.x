#import "Spotify.h"

%hook SPTNowPlayingModel
%property (nonatomic, strong) CBInfoSource *source;
%property (nonatomic, strong) SPTGLUEImageLoader *imageLoader;
%new
+ (NSString *)localPathForCanvas:(NSString *)canvasURL {
    if ([canvasURL hasPrefix:@"https"]) {
        NSRange range = [canvasURL rangeOfString:@"//"];
        canvasURL = [canvasURL substringFromIndex:range.location + [@"canvaz.scdn.co/" length] + 1];
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
        [self.source sendImageData:imageData];
    }];
}

%new
- (void)sendStaticCanvas:(NSURL *)imageURL {
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    if (!imageData) {
        [self sendTrackImage:imageURL];
        return;
    }
    [self.source sendImageData:imageData];
}

%new
- (void)writeCanvasToFile:(NSURL *)canvasURL filePath:(NSURL *)fileURL {
    NSData *canvasData = [NSData dataWithContentsOfURL:canvasURL];
    [canvasData writeToURL:fileURL atomically:YES];
}

%new
- (void)sendUpdateWithTrack:(SPTPlayerTrack *)track {
    NSDictionary *metadata = [track metadata];
    NSString *originalURL = [metadata objectForKey:@"canvas.url"];
    if (!originalURL) {
        [self sendTrackImage:track.imageURL];
        return;
    }
    NSString *canvasType = [metadata objectForKey:@"canvas.type"];
    if ([canvasType isEqualToString:@"IMAGE"]) {
        [self sendStaticCanvas:track.imageURL];
        return;
    }
    NSString *filePath = [%c(SPTNowPlayingModel) localPathForCanvas:originalURL];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (!fileExists) {
        [self.source sendVideoURL:originalURL];
        [self writeCanvasToFile:[NSURL URLWithString:originalURL] filePath:[NSURL fileURLWithPath:filePath]];
        return;
    }
    [self.source sendVideoPath:filePath];
}

- (void)player:(id)player didMoveToRelativeTrack:(id)track {
    %orig;
    [self sendUpdateWithTrack:self.currentTrack];
}

- (void)playerDidUpdatePlaybackControls:(SPTStatefulPlayerImplementation *)player {
    %orig;
    [self.source sendPlaybackState:!player.isPaused];
}
- (id)initWithPlayer:(id)arg0 collectionPlatform:(id)arg1 playlistDataLoader:(id)arg2 radioPlaybackService:(id)arg3 adsManager:(id)arg4 productState:(id)arg5 testManager:(id)arg6 collectionTestManager:(id)arg7 statefulPlayer:(id)arg8 yourEpisodesSaveManager:(id)arg9 educationEligibility:(id)arg10 reinventFreeConfiguration:(id)arg11 curationPlatform:(id)arg12 smartShuffleHandler:(id)arg13 {
    self.source = [%c(CBInfoSource) sourceWithBundleID:@"com.spotify.client"];
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