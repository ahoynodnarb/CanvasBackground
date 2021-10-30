#import "Spotify.h"

%hook SPTCanvasCompatibilityManager
+ (_Bool)shouldEnableCanvasForDevice {
	return YES;
}
%end

%hook SPTStatefulPlayerImplementation
%new
- (void)sendNotification {
    // adds canvas to userInfo, then sends notification
    SPTPlayerTrack *track = [self currentTrack];
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
	NSURL *fallbackURL = [contentLoader canvasViewControllerViewModelForTrack:track].canvasModel.contentURL;
	NSURL *localURL = [assetLoader localURLForAssetURL:fallbackURL];
    if(![localURL.absoluteString hasSuffix:@"com.spotify.service.network/"]) {
        [userInfo setObject:localURL.absoluteString forKey:@"currentURL"];
        // [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:userInfo];
    }
    else if(fallbackURL) {
        [userInfo setObject:fallbackURL.absoluteString forKey:@"currentURL"];
        // [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:userInfo];
    }
    else {
        [imageLoader loadImageForURL:track.imageURL imageSize:CGSizeMake(600, 600) completion:^(UIImage *artwork) {
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
- (id)initWithNetworkConnectivityController:(id)arg1 requestAccountant:(id)arg2 serviceIdentifier:(id)arg3 HTTPMaximumConnectionsPerHost:(long long)arg4 timeoutIntervalForRequest:(double)arg5 timeoutIntervalForResource:(double)arg6 {
	return assetLoader = %orig;
}
%end
%hook SPTCanvasNowPlayingContentLoader
- (id)initWithCanvasTrackChecker:(id)arg1 viewModelFactory:(id)arg2 contentReloader:(id)arg3 contentLoaderTracker:(id)arg4 nowPlayingState:(id)arg5 {
	return contentLoader = %orig;
}
%end
%hook SPTGLUEImageLoader
- (SPTGLUEImageLoader *)initWithImageLoader:(id)arg1 sourceIdentifier:(id)arg2 {
    return imageLoader = %orig;
}
%end