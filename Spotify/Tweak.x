#import "Spotify.h"

SPTPlayerTrack *nextTrack;
%hook SPTCanvasNowPlayingContentLoader
-(id)initWithCanvasTrackChecker:(id)arg1 viewModelFactory:(id)arg2 contentReloader:(id)arg3 contentLoaderTracker:(id)arg4 nowPlayingState:(id)arg5 {
	loader = self;
	return %orig;
}
%end
%hook SPTStatefulPlayer
%new
-(NSString *)getCanvasURLForTrack:(SPTPlayerTrack *)track {
	// NSLog(@"canvasBackground test track: %@", track);
	SPTCanvasContentLayerViewControllerViewModel *viewModel = [loader canvasViewControllerViewModelForTrack:track];
	SPTCanvasModelImplementation *canvasModel = viewModel.canvasModel;
	NSURL *canvasModelURL = canvasModel.contentURL;
	NSURL *returnedURL = [assetLoader localURLForAssetURL:canvasModelURL];
	NSString *fallbackURL = (canvasModelURL.absoluteString) ? canvasModelURL.absoluteString : @"remove";
	if(![[NSFileManager defaultManager] fileExistsAtPath:returnedURL.path]) {
		NSLog(@"canvasBackground using fallback: %@", fallbackURL);
		return fallbackURL;
	}
	NSString *returnedString = (returnedURL) ? returnedURL.absoluteString : @"remove";
	NSLog(@"canvasBackground using returnedString: %@", returnedString);
	return returnedString;
}
%new
-(void)sendNotification {
	// NSLog(@"canvasBackground nextTrack: %@", nextTrack);
	SPTPlayerTrack *previousTrack = [self.queue trackAtRelativePosition:-1 forState:self.playerState];
	// SPTPlayerTrack *currentTrack = [self.queue trackAtRelativePosition:0 forState:self.playerState];
	// SPTPlayerTrack *nextTrack = [self.queue trackAtRelativePosition:1 forState:self.playerState];
	BOOL isPrevious = [previousTrack isEqual:[self currentTrack]];
	previousTrack = (isPrevious) ? [self.queue trackAtRelativePosition:-2 forState:self.playerState] : previousTrack;
	// NSLog(@"canvasBackground previousTrack: %@", previousTrack);
	// NSLog(@"canvasBackground currentTrack: %@", [self currentTrack]);
	// NSString *previousTrackURL = [self getCanvasURLForTrack:previousTrack];
	NSString *previousTrackURL = [self getCanvasURLForTrack:previousTrack];
	NSString *currentTrackURL = [self getCanvasURLForTrack:[self currentTrack]];
	shouldSend = NO;
	NSString *nextTrackURL = [self getCanvasURLForTrack:[self nextTrack]];
	NSLog(@"canvasBackground currentTrackURL: %@ nextTrackURL: %@ previousTrackURL: %@", currentTrackURL, nextTrackURL, previousTrackURL);
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" 
	userInfo:@{@"isPrevious": @(isPrevious), @"previousURL": previousTrackURL, @"currentURL": currentTrackURL, @"nextURL": nextTrackURL}];
}
-(SPTPlayerTrack *)nextTrack {
	if(shouldSend) {
		[self sendNotification];
	}
	shouldSend = YES;
	return %orig;
}
-(void)setPaused:(_Bool)arg1 {
	if(!sentNotificationOnce) {
		[self sendNotification];
		sentNotificationOnce = YES;
	}
	// NSLog(@"canvasBackground setPaused arg1: %d numberValue: %@", arg1, [NSNumber numberWithBool:arg1]);
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"togglePlayer" object:nil userInfo:@{@"isPlaying": [NSNumber numberWithBool:!arg1]}];
	return %orig;
}
%end
%hook SPTVideoURLAssetLoaderImplementation
- (id)initWithNetworkConnectivityController:(id)arg1 requestAccountant:(id)arg2 serviceIdentifier:(id)arg3 {
	assetLoader = self;
	return %orig;
}
- (id)initWithNetworkConnectivityController:(id)arg1 requestAccountant:(id)arg2 serviceIdentifier:(id)arg3 HTTPMaximumConnectionsPerHost:(long long)arg4 timeoutIntervalForRequest:(double)arg5 timeoutIntervalForResource:(double)arg6 {
	assetLoader = self;
	return %orig;
}
%end
