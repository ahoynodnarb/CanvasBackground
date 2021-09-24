#import "Spotify.h"

%hook SPTCanvasCompatibilityManager
+(_Bool)shouldEnableCanvasForDevice {
	return YES;
}
%end

%hook SPTCanvasVideoLoaderImplementation
- (id)initWithCanvasTrackChecker:(id)arg1 videoAssetLoader:(id)arg2 metadataResolver:(id)arg3 track:(id)arg4 exporterBlock:(id)arg5 {
    NSLog(@"cBack %@", NSStringFromSelector(_cmd));
    return %orig;
}
%end

%hook SPTStatefulPlayerImplementation
%property (nonatomic, strong) NSMutableDictionary *userInfo;
// %new
// -(void)setArtworkImage {
// 	NSLog(@"canvasBackground setArtworkImage called");
// 	MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
// 		NSDictionary* dict = (__bridge NSDictionary *)information;
// 		if (dict) {
// 			if (dict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData]) {
// 				UIImage *currentArtwork = [UIImage imageWithData:[dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtworkData]];
// 				[self.userInfo setObject:currentArtwork forKey:@"currentArtwork"];
// 				NSLog(@"canvasBackground setObject called");
// 			}
//       	}
//   	});
// }
%new
-(void)addCanvasToUserInfo:(SPTPlayerTrack *)track key:(NSString *)key {
	// SPTCanvasContentLayerViewControllerViewModel *viewModel = [loader canvasViewControllerViewModelForTrack:track];
	// SPTCanvasModelImplementation *canvasModel = viewModel.canvasModel;
    // NSLog(@"cBack file: %@", [(AVURLAsset *)currentSource.playerItem.asset URL]);
    // handles finding the cached canvas
    // if it can't find it, it'll use a fallback url to download it
	NSURL *canvasModelURL = [contentLoader canvasViewControllerViewModelForTrack:track].canvasModel.contentURL;
	NSURL *localURL = [assetLoader localURLForAssetURL:canvasModelURL];
	NSString *fallbackURLString = canvasModelURL.absoluteString;
	NSString *localURLString = localURL.absoluteString;
    NSLog(@"canvasBackground URLs: %@ %@ %@ %@", canvasModelURL, localURL, fallbackURLString, localURLString);
	if(![[NSFileManager defaultManager] fileExistsAtPath:localURL.path] && fallbackURLString) {
        NSLog(@"canvasBackground setting object");
        [self.userInfo setObject:fallbackURLString forKey:key];
    }
	else if(localURLString) {
        NSLog(@"canvasBackground setting object");
        [self.userInfo setObject:localURLString forKey:key];
    }
}
%new
-(void)sendNotification {
	self.userInfo = [[NSMutableDictionary alloc] init];
	// [self setArtworkImage];
	[self addCanvasToUserInfo:[self currentTrack] key:@"currentURL"];
	NSLog(@"canvasBackground sending notification");
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:self.userInfo];
	[self.userInfo removeAllObjects];
}
-(SPTPlayerTrack *)nextTrack {
	[self performSelectorInBackground:@selector(sendNotification) withObject:nil];
	return %orig;
}
-(void)setIsPaused:(_Bool)arg1 {
	// static dispatch_once_t once;
	// dispatch_once(&once, ^{
	// });
    NSLog(@"canvasBackground pausing");
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"togglePlayer" object:@"com.spotify.client" userInfo:@{@"isPlaying": [NSNumber numberWithBool:!arg1]}];
    // [self performSelectorInBackground:@selector(sendNotification) withObject:nil];
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