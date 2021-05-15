#import "Spotify.h"

%hook SPTStatefulPlayer
%property (nonatomic, strong) NSMutableDictionary *userInfo;
%new
-(void)addCanvasToUserInfo:(SPTPlayerTrack *)track key:(NSString *)key {
	SPTCanvasContentLayerViewControllerViewModel *viewModel = [loader canvasViewControllerViewModelForTrack:track];
	SPTCanvasModelImplementation *canvasModel = viewModel.canvasModel;
	NSURL *canvasModelURL = canvasModel.contentURL;
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
	[self performSelectorInBackground:@selector(sendNotification) withObject:nil];
	return %orig;
}
-(void)setPaused:(_Bool)arg1 {
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		[self performSelectorInBackground:@selector(sendNotification) withObject:nil];
	});
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"togglePlayer" object:nil userInfo:@{@"isPlaying": [NSNumber numberWithBool:!arg1]}];
	return %orig;
}
%end
%hook SPTVideoURLAssetLoaderImplementation
- (id)initWithNetworkConnectivityController:(id)arg1 requestAccountant:(id)arg2 serviceIdentifier:(id)arg3 HTTPMaximumConnectionsPerHost:(long long)arg4 timeoutIntervalForRequest:(double)arg5 timeoutIntervalForResource:(double)arg6 {
	assetLoader = self;
	return %orig;
}
%end
%hook SPTCanvasNowPlayingContentLoader
-(id)initWithCanvasTrackChecker:(id)arg1 viewModelFactory:(id)arg2 contentReloader:(id)arg3 contentLoaderTracker:(id)arg4 nowPlayingState:(id)arg5 {
	loader = self;
	return %orig;
}
%end