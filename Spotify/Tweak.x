#import "Spotify.h"

%hook SPTCanvasCompatibilityManager
+(_Bool)shouldEnableCanvasForDevice {
	return YES;
}
%end

%hook SPTStatefulPlayerImplementation
%property (nonatomic, strong) NSMutableDictionary *userInfo;
%new
-(void)addCanvasToUserInfo:(SPTPlayerTrack *)track key:(NSString *)key {
    // handles finding the cached canvas
    // if it can't find it, it'll use a fallback url to download it
	NSURL *canvasModelURL = [contentLoader canvasViewControllerViewModelForTrack:track].canvasModel.contentURL;
	NSURL *localURL = [assetLoader localURLForAssetURL:canvasModelURL];
	NSString *fallbackURLString = canvasModelURL.absoluteString;
	NSString *localURLString = localURL.absoluteString;
	if(![[NSFileManager defaultManager] fileExistsAtPath:localURL.path] && fallbackURLString) {
        [self.userInfo setObject:fallbackURLString forKey:key];
    }
	else if(localURLString) {
        [self.userInfo setObject:localURLString forKey:key];
    }
}
%new
-(void)sendNotification {
	self.userInfo = [[NSMutableDictionary alloc] init];
	[self addCanvasToUserInfo:[self currentTrack] key:@"currentURL"];
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:self.userInfo];
	[self.userInfo removeAllObjects];
}
-(SPTPlayerTrack *)nextTrack {
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