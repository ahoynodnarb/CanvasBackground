#import "../Shared.h"
%hook SPTCanvasNowPlayingContentLoader
-(id)initWithCanvasTrackChecker:(id)arg1 viewModelFactory:(id)arg2 contentReloader:(id)arg3 contentLoaderTracker:(id)arg4 nowPlayingState:(id)arg5 {
	loader = self;
	return %orig;
}
%end
%hook SPTStatefulPlayer
%new
-(void)sendNotification {
	SPTCanvasContentLayerViewControllerViewModel *viewModel = [loader canvasViewControllerViewModelForTrack:[self currentTrack]];
	SPTCanvasModelImplementation *canvasModel = viewModel.canvasModel;
	NSString *downloadedItem = canvasModel.contentURL.absoluteString ? canvasModel.contentURL.absoluteString : @"remove";
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:@{@"url": downloadedItem}];
	NSLog(@"canvasBackground posted notification downloadedItem: %@", downloadedItem);
}
-(id)nextTrack {
	[self sendNotification];
	return %orig;
}
-(void)setPaused:(_Bool)arg1 {
	if(!sentNotificationOnce) {
		[self sendNotification];
		sentNotificationOnce = YES;
	}
	NSLog(@"canvasBackground setPaused arg1: %d numberValue: %@", arg1, [NSNumber numberWithBool:arg1]);
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"togglePlayer" object:nil userInfo:@{@"isPlaying": [NSNumber numberWithBool:!arg1]}];
	return %orig;
}
%end