#import "Spotify.h"

%hook SPTNowPlayingModel
%property (nonatomic, strong) SPTPlayerTrack *previousTrack;
%new
- (void)sendNotification {
    SPTPlayerTrack *track = self.currentTrack;
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    NSURL *fallbackURL = [NSURL URLWithString:track.metadata[@"canvas.url"]];
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [[[fallbackURL path] stringByReplacingOccurrencesOfString:@"/" withString:@"-"] substringFromIndex:1];
    NSString *filePath = [NSString stringWithFormat:@"%@/Caches/Canvases/%@",libraryPath,fileName];
    NSURL *localURL = [[NSFileManager defaultManager] fileExistsAtPath:filePath] ? [NSURL fileURLWithPath:filePath] : nil;
    /*
      Sometimes the localURL gives us the folder, so we check if it's a file or folder. 
      If the canvas hasn't been cached before it still gives us a technically valid file 
      but it doesn't exist yet. If localURL is a folder or there is no local asset, then
      download the URL to a cached file. If there's no fallback then the track must not
      have a canvas to play.
    */
    if(fallbackURL) {
        [userInfo setObject:[NSNumber numberWithBool:[fallbackURL.absoluteString containsString:@"/image/"]] forKey:@"canvasIsStatic"];
        if(!localURL) [userInfo setObject:fallbackURL.absoluteString forKey:@"currentURL"];
        else {
            [userInfo setObject:localURL.absoluteString forKey:@"currentURL"];
            if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                NSData *URLData = [NSData dataWithContentsOfURL:fallbackURL];
                if(URLData) [URLData writeToFile:filePath atomically:YES];
            }
        }
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:userInfo];
        return;
    }
    [imageLoader loadImageForURL:track.imageURL imageSize:CGSizeMake(640, 640) completion:^(UIImage *artwork) {
        if(artwork) [userInfo setObject:UIImagePNGRepresentation(artwork) forKey:@"artwork"];
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:userInfo];
    }];
}
- (void)playerDidUpdateTrackPosition:(SPTStatefulPlayerImplementation *)arg1 {
	%orig;
    if(![self.previousTrack isEqual:arg1.currentTrack]) {
        self.previousTrack = arg1.currentTrack;
        [self sendNotification];
    }
}
- (void)playerDidUpdatePlaybackControls:(SPTStatefulPlayerImplementation *)arg1 {
    %orig;
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"togglePlayer" object:@"com.spotify.client" userInfo:@{@"isPlaying": [NSNumber numberWithBool:!arg1.isPaused]}];
}
- (id)initWithPlayer:(id)arg1 collectionPlatform:(id)arg2 playlistDataLoader:(id)arg3 radioPlaybackService:(id)arg4 adsManager:(id)arg5 productState:(id)arg6 queueService:(id)arg7 testManager:(id)arg8 collectionTestManager:(id)arg9 statefulPlayer:(id)arg10 yourEpisodesSaveManager:(id)arg11 educationEligibility:(id)arg12 {
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(sendNotification) name:@"sendNotification" object:@"com.spotify.client"];
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

%hook SPTGLUEImageLoader
- (SPTGLUEImageLoader *)initWithImageLoader:(id)arg1 sourceIdentifier:(id)arg2 {
    if(!imageLoader) imageLoader = %orig;
    return %orig;
}
%end