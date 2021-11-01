#import "Spotify.h"

%hook _TtC15ContainerWiring18SpotifyAppDelegate
- (void)applicationWillTerminate:(id)arg1 {
    %orig;
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client"];
}
%end

%hook SPTCanvasCompatibilityManager
+ (BOOL)shouldEnableCanvasForDevice {
	return YES;
}
%end

%hook SPTCanvasSettingsSection
- (void)settingChanged:(id)arg1 {
    %orig;
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"sendNotification" object:@"com.spotify.client"];
}
%end

%hook SPTStatefulPlayerImplementation
%new
- (void)sendNotification {
    SPTPlayerTrack *track = self.currentTrack;
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
	NSURL *fallbackURL = [contentLoader canvasViewControllerViewModelForTrack:track].canvasModel.contentURL;
	NSURL *localURL = [assetLoader localURLForAssetURL:fallbackURL];
    /*
      sometimes the localURL gives us the folder, so we check if it's a file or folder. 
      If the canvas hasn't been cached before it still gives us a technically valid file 
      but it doesn't exist yet. in the event that both flags are false, we use a fallback url 
      which downloads the canvas from an outside source, and if all are false the song must not have a canvas
    */
    if(!localURL.hasDirectoryPath && [[NSFileManager defaultManager] fileExistsAtPath:localURL.path]) {
        [userInfo setObject:localURL.absoluteString forKey:@"currentURL"];
    }
    else if(fallbackURL) {
        // I have no idea why, but this is faster than downloading it later
        NSData *URLData = [NSData dataWithContentsOfURL:fallbackURL];
        if(URLData) [URLData writeToFile:localURL.path atomically:YES];
        [userInfo setObject:localURL.absoluteString forKey:@"currentURL"];
    }
    else {
        [imageLoader loadImageForURL:track.imageURL imageSize:CGSizeMake(640, 640) completion:^(UIImage *artwork) {
            if(artwork) [userInfo setObject:UIImagePNGRepresentation(artwork) forKey:@"artwork"];
            [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:userInfo];
        }];
        return;
    }
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:userInfo];
}
- (void)playerQueue:(id)arg1 didMoveToRelativeTrack:(id)arg2 {
    [self sendNotification];
	%orig;
}
- (void)setIsPaused:(_Bool)arg1 {
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"togglePlayer" object:@"com.spotify.client" userInfo:@{@"isPlaying": [NSNumber numberWithBool:!arg1]}];
	%orig;
}
- (id)initWithPlayer:(id)arg1 {
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(sendNotification) name:@"sendNotification" object:@"com.spotify.client"];
    return %orig;
}
%end

%hook SPTVideoURLAssetLoaderImplementation
- (SPTVideoURLAssetLoaderImplementation *)initWithNetworkConnectivityController:(id)arg1 requestAccountant:(id)arg2 serviceIdentifier:(id)arg3 HTTPMaximumConnectionsPerHost:(long long)arg4 timeoutIntervalForRequest:(double)arg5 timeoutIntervalForResource:(double)arg6 {
	return assetLoader = %orig;
}
%end

%hook SPTCanvasNowPlayingContentLoader
- (SPTCanvasNowPlayingContentLoader *)initWithCanvasTrackChecker:(id)arg1 viewModelFactory:(id)arg2 contentReloader:(id)arg3 contentLoaderTracker:(id)arg4 nowPlayingState:(id)arg5 {
	return contentLoader = %orig;
}
%end

%hook SPTGLUEImageLoader
- (SPTGLUEImageLoader *)initWithImageLoader:(id)arg1 sourceIdentifier:(id)arg2 {
    return imageLoader = %orig;
}
%end