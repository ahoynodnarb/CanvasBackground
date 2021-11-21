#import "Spotify.h"

%hook SPTNowPlayingModel
%property (nonatomic, strong) SPTPlayerTrack *previousTrack;
%new
- (void)sendNotification {
    SPTPlayerTrack *track = self.currentTrack;
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    NSURL *fallbackURL = [NSURL URLWithString:track.metadata[@"canvas.url"]];
	NSURL *localURL = [assetLoader localURLForAssetURL:fallbackURL];
    /*
      sometimes the localURL gives us the folder, so we check if it's a file or folder. 
      If the canvas hasn't been cached before it still gives us a technically valid file 
      but it doesn't exist yet. in the event that both flags are false, we use a fallback url 
      which downloads the canvas from an outside source, and if all are false the song must not have a canvas
    */
    if(fallbackURL) {
        if(localURL.hasDirectoryPath || ![assetLoader hasLocalAssetForURL:fallbackURL]) {
            // I have no idea why, but this is faster than downloading it later
            NSData *URLData = [NSData dataWithContentsOfURL:fallbackURL];
            if(URLData) [URLData writeToFile:localURL.path atomically:YES];
        }
        [userInfo setObject:localURL.absoluteString forKey:@"currentURL"];
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:userInfo];
    }
    else {
        [imageLoader loadImageForURL:track.imageURL imageSize:CGSizeMake(640, 640) completion:^(UIImage *artwork) {
            if(artwork) [userInfo setObject:UIImagePNGRepresentation(artwork) forKey:@"artwork"];
            [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:userInfo];
        }];
    }
}
- (void)playerDidReceiveStateUpdate:(SPTStatefulPlayerImplementation *)arg1 {
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
- (id)initWithPlayer:(id)arg1 collectionPlatform:(id)arg2 playlistDataLoader:(id)arg3 radioManager:(id)arg4 adsManager:(id)arg5 productState:(id)arg6 queueService:(id)arg7 testManager:(id)arg8 collectionTestManager:(id)arg9 statefulPlayer:(id)arg10 {
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(sendNotification) name:@"sendNotification" object:@"com.spotify.client"];
    return %orig;
}
%end

%hook SPTCanvasCompatibilityManager
+ (BOOL)shouldEnableCanvasForDevice {
	return YES;
}
%end

%hook _TtC15ContainerWiring18SpotifyAppDelegate
- (void)applicationWillTerminate:(id)arg1 {
    %orig;
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client"];
}
%end

%hook SPTCanvasSettingsSection
- (void)settingChanged:(id)arg1 {
    %orig;
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"sendNotification" object:@"com.spotify.client"];
}
%end

%hook SPTVideoURLAssetLoaderImplementation
- (SPTVideoURLAssetLoaderImplementation *)initWithNetworkConnectivityController:(id)arg1 requestAccountant:(id)arg2 serviceIdentifier:(id)arg3 HTTPMaximumConnectionsPerHost:(long long)arg4 timeoutIntervalForRequest:(double)arg5 timeoutIntervalForResource:(double)arg6 {
	return assetLoader = %orig;
}
%end

%hook SPTGLUEImageLoader
- (SPTGLUEImageLoader *)initWithImageLoader:(id)arg1 sourceIdentifier:(id)arg2 {
    return imageLoader = %orig;
}
%end