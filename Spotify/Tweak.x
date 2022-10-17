#import "Spotify.h"

%hook SPTNowPlayingModel
%property (nonatomic, strong) SPTPlayerTrack *previousTrack;
%new
- (void)sendNotification {
    SPTPlayerTrack *track = self.currentTrack;
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    NSURL *fallbackURL = [NSURL URLWithString:track.metadata[@"canvas.url"]];
    BOOL isStatic = [track.metadata[@"canvas.type"] isEqualToString:@"IMAGE"];
    NSLog(@"canvsBackground %@", fallbackURL);
    if(!fallbackURL) {
        [imageLoader loadImageForURL:track.imageURL imageSize:CGSizeMake(640, 640) completion:^(UIImage *artwork) {
            if(artwork) [userInfo setObject:UIImagePNGRepresentation(artwork) forKey:@"artwork"];
            [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:userInfo];
        }];
        return;
    }
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [[fallbackURL.path stringByReplacingOccurrencesOfString:@"/" withString:@"-"] substringFromIndex:1];
    NSString *filePath = [NSString stringWithFormat:@"%@/Caches/Canvases/%@",libraryPath,fileName];
    NSURL *localURL = [NSURL fileURLWithPath:filePath];
    BOOL useCache = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if(!useCache) {
        NSData *URLData = [NSData dataWithContentsOfURL:fallbackURL];
        if(URLData) [URLData writeToFile:filePath atomically:YES];
    }
    if(isStatic) {
        if(useCache) {
            NSData *imageData = [NSData dataWithContentsOfFile:filePath];
            [userInfo setObject:imageData forKey:@"artwork"];
        }
        else {
            NSData *URLData = [NSData dataWithContentsOfURL:fallbackURL];
            [userInfo setObject:URLData forKey:@"artwork"];
        }
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:userInfo];
        return;
    }
    [userInfo setObject:localURL.absoluteString forKey:@"currentURL"];
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:userInfo];
}
- (void)player:(id)arg1 didMoveToRelativeTrack:(id)arg2 {
    %orig;
    [self sendNotification];
}
- (void)playerDidUpdatePlaybackControls:(SPTStatefulPlayerImplementation *)arg1 {
    %orig;
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"togglePlayer" object:@"com.spotify.client" userInfo:@{@"isPlaying": [NSNumber numberWithBool:!arg1.isPaused]}];
}
- (id)initWithPlayer:(id)arg1 collectionPlatform:(id)arg2 playlistDataLoader:(id)arg3 radioPlaybackService:(id)arg4 adsManager:(id)arg5 productState:(id)arg6 queueService:(SPTQueueServiceImplementation *)queueService testManager:(id)arg8 collectionTestManager:(id)arg9 statefulPlayer:(id)arg10 yourEpisodesSaveManager:(id)arg11 educationEligibility:(id)arg12 {
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(sendNotification) name:@"sendNotification" object:@"com.spotify.client"];
    id<SPTGLUEImageLoaderFactory> factory = queueService.glueImageLoaderFactory;
    imageLoader = [factory createImageLoaderForSourceIdentifier:@"com.popsicletreehouse.CanvasBackground"];
    return %orig;
}
%end

// Makes sure that canvas will disappear once app closes
%hook _TtC15ContainerWiring18SpotifyAppDelegate
- (void)applicationWillTerminate:(id)arg1 {
    %orig;
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client"];
}
%end