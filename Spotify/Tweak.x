#import "Spotify.h"

%hook SPTCanvasCompatibilityManager
+(_Bool)shouldEnableCanvasForDevice {
	return YES;
}
%end

%hook SPTStatefulPlayerImplementation
%new
-(void)sendNotification {
    // adds canvas to userInfo, then sends notification
    SPTPlayerTrack *track = [self currentTrack];
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
	NSURL *canvasModelURL = [contentLoader canvasViewControllerViewModelForTrack:track].canvasModel.contentURL;
	NSURL *localURL = [assetLoader localURLForAssetURL:canvasModelURL];
	NSString *fallbackURLString = canvasModelURL.absoluteString;
	NSString *localURLString = localURL.absoluteString;
	if(![[NSFileManager defaultManager] fileExistsAtPath:localURL.path] && fallbackURLString) [userInfo setObject:fallbackURLString forKey:@"currentURL"];
	else if(localURLString) [userInfo setObject:localURLString forKey:@"currentURL"];
    [imageLoader loadImageForURL:track.imageURL imageSize:CGSizeMake(640, 640) completion:^(UIImage *artwork) {
        if(!artwork) return;
        [userInfo setObject:UIImagePNGRepresentation(artwork) forKey:@"artwork"];
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:userInfo];
    }];
}
- (void)playerQueue:(id)arg1 didMoveToRelativeTrack:(id)arg2 {
    [self sendNotification];
	return %orig;
}
-(void)setIsPaused:(_Bool)arg1 {
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"togglePlayer" object:@"com.spotify.client" userInfo:@{@"isPlaying": [NSNumber numberWithBool:!arg1]}];
	return %orig;
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
-(id)initWithCanvasTrackChecker:(id)arg1 viewModelFactory:(id)arg2 contentReloader:(id)arg3 contentLoaderTracker:(id)arg4 nowPlayingState:(id)arg5 {
	return contentLoader = %orig;
}
%end
%hook SPTGLUEImageLoader
- (SPTGLUEImageLoader *)initWithImageLoader:(id)arg1 sourceIdentifier:(id)arg2 {
    return imageLoader = %orig;
}
%end