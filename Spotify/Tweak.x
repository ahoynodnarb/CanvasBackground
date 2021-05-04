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
	// NSLog(@"canvasBackground track: %@", track);
	SPTCanvasContentLayerViewControllerViewModel *viewModel = [loader canvasViewControllerViewModelForTrack:track];
	SPTCanvasModelImplementation *canvasModel = viewModel.canvasModel;
	NSString *returnedURL = canvasModel.contentURL.absoluteString;
	// NSLog(@"canvasBackground returnedURL: %@", returnedURL);
	return returnedURL ? returnedURL : @"remove";
}
%new
-(void)sendNotification {
	// NSLog(@"canvasBackground nextTrack: %@", nextTrack);
	NSString *currentTrackURL = [self getCanvasURLForTrack:[self currentTrack]];
	shouldSend = YES;
	NSString *nextTrackURL = [self getCanvasURLForTrack:[self nextTrack]];
	NSLog(@"canvasBackground currentTrackURL: %@ nextTrackURL: %@", currentTrackURL, nextTrackURL);
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:@{@"currentURL": currentTrackURL, @"nextURL": nextTrackURL}];
}
- (void)skipToPreviousTrack {
	%orig;
	// NSLog(@"canvasBackground previousTrack");
}
-(SPTPlayerTrack *)nextTrack {
	if(!shouldSend) {
		[self sendNotification];
	}
	shouldSend = NO;
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