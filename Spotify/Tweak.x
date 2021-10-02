#import "Spotify.h"

%hook SPTCanvasCompatibilityManager
+(_Bool)shouldEnableCanvasForDevice {
	return YES;
}
%end

%hook SPTStatefulPlayerImplementation
%new
-(NSDictionary *)generateUserInfoWithTrack:(SPTPlayerTrack *)track {
    // handles finding the cached canvas
    // if it can't find it, it'll use a fallback url to download it
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
	NSURL *canvasModelURL = [contentLoader canvasViewControllerViewModelForTrack:track].canvasModel.contentURL;
	NSURL *localURL = [assetLoader localURLForAssetURL:canvasModelURL];
	NSString *fallbackURLString = canvasModelURL.absoluteString;
	NSString *localURLString = localURL.absoluteString;
	if(![[NSFileManager defaultManager] fileExistsAtPath:localURL.path] && fallbackURLString) [userInfo setObject:fallbackURLString forKey:@"currentURL"];
	else if(localURLString) [userInfo setObject:localURLString forKey:@"currentURL"];
    [imageLoader loadImageForURL:track.imageURL imageSize:CGSizeMake(640, 640) completion:^(UIImage *artwork) {
        NSLog(@"canvasBackground artwork block: %@", artwork);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Image.png"];
        [UIImagePNGRepresentation(artwork) writeToFile:filePath atomically:YES];
        [userInfo setObject:UIImagePNGRepresentation(artwork) forKey:@"artwork"];
    }];
    return userInfo;
}
%new
-(void)sendNotification {
    // adds canvas to userInfo, then sends notification
	// self.userInfo = [[NSMutableDictionary alloc] init];
	// NSDictionary *userInfo = [self generateUserInfoWithTrack:[self currentTrack]];
	// [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:userInfo];
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
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Image.png"];
        [UIImagePNGRepresentation(artwork) writeToFile:filePath atomically:YES];
        [userInfo setObject:UIImagePNGRepresentation(artwork) forKey:@"artwork"];
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:userInfo];
    }];
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
%hook SPTGLUEImageLoader
- (SPTGLUEImageLoader *)initWithImageLoader:(id)arg1 sourceIdentifier:(id)arg2 {
    return imageLoader = %orig;
}
%end