#import "Spotify.h"

%hook SPTNowPlayingModel
%property (nonatomic, strong) MRYIPCCenter *center;
%property (nonatomic, strong) SPTGLUEImageLoader *imageLoader;
%new
+ (NSURL *)localURLForCanvas:(NSURL *)canvasURL {
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [[canvasURL.path stringByReplacingOccurrencesOfString:@"/" withString:@"-"] substringFromIndex:1];
    NSString *filePath = [NSString stringWithFormat:@"%@/Caches/Canvases/%@",libraryPath,fileName];
    return [NSURL fileURLWithPath:filePath];
}

%new
- (void)sendTrackImage:(SPTPlayerTrack *)track {
    [self.imageLoader loadImageForURL:track.imageURL imageSize:CGSizeMake(640, 640) completion:^(UIImage *artwork, NSError *error) {
        if (!artwork) return;
        NSData *imageData = UIImagePNGRepresentation(artwork);
        [self.center callExternalVoidMethod:@selector(updateWithImageData:) withArguments:imageData];
    }];
}

%new
- (void)sendUpdateMessage {
    SPTPlayerTrack *track = [self currentTrack];
    NSURL *originalURL = [NSURL URLWithString:track.metadata[@"canvas.url"]];
    if (!originalURL) {
        [self sendTrackImage:track];
        return;
    }
    NSURL *fileURL = [%c(SPTNowPlayingModel) localURLForCanvas:originalURL];
    NSURL *URL = [[NSFileManager defaultManager] fileExistsAtPath:fileURL.path] ? fileURL : originalURL;
    BOOL canvasStatic = [track.metadata[@"canvas.type"] isEqualToString:@"IMAGE"];
    if (canvasStatic) {
        NSData *imageData = [NSData dataWithContentsOfURL:URL];
        [self.center callExternalVoidMethod:@selector(updateWithImageData:) withArguments:imageData];
    }
    else [self.center callExternalVoidMethod:@selector(updateWithVideoURL:) withArguments:URL.absoluteString];
}

- (void)player:(id)arg1 didMoveToRelativeTrack:(id)arg2 {
    %orig;
    [self sendUpdateMessage];
}

- (void)playerDidUpdatePlaybackControls:(SPTStatefulPlayerImplementation *)arg1 {
    %orig;
    [self.center callExternalVoidMethod:@selector(setPlaying:) withArguments:@(!arg1.isPaused)];
}

- (id)initWithPlayer:(id)arg1 collectionPlatform:(id)arg2 playlistDataLoader:(id)arg3 radioPlaybackService:(id)arg4 adsManager:(id)arg5 productState:(id)arg6 queueService:(SPTQueueServiceImplementation *)queueService testManager:(id)arg8 collectionTestManager:(id)arg9 statefulPlayer:(id)arg10 yourEpisodesSaveManager:(id)arg11 educationEligibility:(id)arg12 reinventFreeConfiguration:(id)arg13 curationPlatform:(id)arg14 {
    id<SPTGLUEImageLoaderFactory> factory = queueService.glueImageLoaderFactory;
    self.center = [%c(MRYIPCCenter) centerNamed:@"CanvasBackground.CanvasServer"];
    self.imageLoader = [factory createImageLoaderForSourceIdentifier:@"com.popsicletreehouse.CanvasBackground"];
    return %orig;
}
%end