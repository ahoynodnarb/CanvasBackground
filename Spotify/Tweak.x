#import "Spotify.h"

NSString *PathForCanvas(NSURL *canvasURL) {
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [[canvasURL.path stringByReplacingOccurrencesOfString:@"/" withString:@"-"] substringFromIndex:1];
    NSString *filePath = [NSString stringWithFormat:@"%@/Caches/Canvases/%@",libraryPath,fileName];
    return filePath;
}

%hook SPTNowPlayingModel
%property (nonatomic, strong) SPTPlayerTrack *previousTrack;
%property (nonatomic, strong) SPTGLUEImageLoader *imageLoader;

%new
- (void)loadUserInfoForImage:(NSURL *)imageURL callback:(void(^)(NSDictionary *))callback {
    [self.imageLoader loadImageForURL:imageURL imageSize:CGSizeMake(640, 640) completion:^(UIImage *artwork) {
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        if (artwork) [userInfo setObject:UIImagePNGRepresentation(artwork) forKey:@"artwork"];
        callback(userInfo);
    }];
}

%new
- (NSDictionary *)loadUserInfoForCanvas:(NSString *)filePath isImage:(BOOL)isImage {
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    NSURL *localURL = [NSURL fileURLWithPath:filePath];
    if (!isImage) {
        [userInfo setObject:localURL.absoluteString forKey:@"currentURL"];
        return userInfo;
    }
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    [userInfo setObject:imageData forKey:@"artwork"];
    return userInfo;
}

%new
- (void)sendCanvasUpdateNotification {
    SPTPlayerTrack *track = self.currentTrack;
    NSURL *fallbackURL = [NSURL URLWithString:track.metadata[@"canvas.url"]];
    NSDistributedNotificationCenter *defaultCenter = [NSDistributedNotificationCenter defaultCenter];
    if (!fallbackURL) {
        [self loadUserInfoForImage:track.imageURL callback:^(NSDictionary *userInfo){
            [defaultCenter postNotificationName:@"recreateCanvas" 
                                         object:@"com.spotify.client" 
                                       userInfo:userInfo];
        }];
        return;
    }
    BOOL isStatic = [track.metadata[@"canvas.type"] isEqualToString:@"IMAGE"];
    NSString *filePath = PathForCanvas(fallbackURL);
    NSDictionary *userInfo = [self loadUserInfoForCanvas:filePath isImage:isStatic];
    BOOL useCache = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (!useCache) {
        NSData *URLData = [NSData dataWithContentsOfURL:fallbackURL];
        if (URLData) [URLData writeToFile:filePath atomically:YES];
    }
    [defaultCenter postNotificationName:@"recreateCanvas"
                                 object:@"com.spotify.client"
                               userInfo:userInfo];
}

- (void)player:(id)arg1 didMoveToRelativeTrack:(id)arg2 {
    %orig;
    [self sendCanvasUpdateNotification];
}

- (void)playerDidUpdatePlaybackControls:(SPTStatefulPlayerImplementation *)arg1 {
    %orig;
    NSDistributedNotificationCenter *defaultCenter = [NSDistributedNotificationCenter defaultCenter];
	[defaultCenter postNotificationName:@"togglePlayer"
                                 object:@"com.spotify.client"
                               userInfo:@{@"isPlaying": [NSNumber numberWithBool:!arg1.isPaused]}];
}

- (id)initWithPlayer:(id)arg1 collectionPlatform:(id)arg2 playlistDataLoader:(id)arg3 radioPlaybackService:(id)arg4 adsManager:(id)arg5 productState:(id)arg6 queueService:(SPTQueueServiceImplementation *)queueService testManager:(id)arg8 collectionTestManager:(id)arg9 statefulPlayer:(id)arg10 yourEpisodesSaveManager:(id)arg11 educationEligibility:(id)arg12 reinventFreeConfiguration:(id)arg13 {
    id<SPTGLUEImageLoaderFactory> factory = queueService.glueImageLoaderFactory;
    self.imageLoader = [factory createImageLoaderForSourceIdentifier:@"com.popsicletreehouse.CanvasBackground"];
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(sendCanvasUpdateNotification)
                          name:UIApplicationWillEnterForegroundNotification
                        object:nil];
    return %orig;
}
%end