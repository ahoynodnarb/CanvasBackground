/* 
TODO: Add transition to AVQueuePlayer switching tracks
Can possibly achieve this by adding the AVPlayerLayer to our 
own UIView instead of directly to the ViewController's view

TODO: Add functionality for home screen

TODO: Fix bug where it doesn't refresh canvas when new song plays
*/

#import "Spotify.h"
//gets the path of the spotify mp4
NSString *const canvasVideoPath = [[[[%c(LSApplicationProxy) applicationProxyForIdentifier:@"com.spotify.client"] containerURL] path] stringByAppendingPathComponent:@"Documents/CanvasBackground.mp4"];

%hook SpringBoard
-(void)noteInterfaceOrientationChanged:(long long)arg1 duration:(double)arg2 logMessage:(id)arg3 {
	%orig;
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:nil];
}
%end

%hook CSCoverSheetViewController
%property(nonatomic, strong) AVQueuePlayer *canvasPlayer;
%property(nonatomic, strong) AVPlayerLayer *canvasPlayerLayer;
%property(nonatomic, strong) AVPlayerLooper *canvasPlayerLooper;
%new
-(void)clearCanvas {
	[self.canvasPlayer removeAllItems];
}
%new
-(void)recreateCanvasPlayer {
	NSLog(@"canvasBackground recreating player");
	SBMediaController *mediaController = [%c(SBMediaController) sharedInstance];
	if([mediaController isPlaying] || [mediaController isPaused]) {
		AVPlayerItem *nextItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:canvasVideoPath]];
		[self.canvasPlayerLayer setFrame:[[[self view] layer] bounds]];
		[self.canvasPlayer removeAllItems];
		// [self.canvasPlayer insertItem:nextItem afterItem:nil];
		self.canvasPlayerLooper = [AVPlayerLooper playerLooperWithPlayer:self.canvasPlayer templateItem:nextItem];
	}
}
-(void)viewDidLoad {
	%orig;
	[[NSFileManager defaultManager] removeItemAtPath:canvasVideoPath error:nil];
	self.canvasPlayer = [[AVQueuePlayer alloc] init];
	self.canvasPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.canvasPlayer];
	[self.canvasPlayer setVolume:0];
	[self.canvasPlayer setPreventsDisplaySleepDuringVideoPlayback:NO];
	[self.canvasPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	[self.canvasPlayerLayer setFrame:[[[self view] layer] bounds]];
	[[[self view] layer] insertSublayer:self.canvasPlayerLayer atIndex:0];
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(recreateCanvasPlayer) name:@"recreateCanvas" object:nil];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCanvas) name:@"clearCanvas" object:nil];
}
-(void)viewWillAppear:(BOOL)animated {
	%orig;
	[self recreateCanvasPlayer];
	[self.canvasPlayer play];
}
- (void)viewDidDisappear:(BOOL)animated {
	%orig;
	[self.canvasPlayer pause];
}
%end
%hook SPTStatefulPlayer
%new
-(void)deleteCachedPlayer {
	[[NSFileManager defaultManager] removeItemAtPath:canvasVideoPath error:nil];
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"clearCanvas" object:nil];
	NSLog(@"canvasBackground deleting cache");
}
// - (id)nextTrack {
// 	id orig = %orig;
// 	[self deleteCachedPlayer];
// 	return orig;
// }
// - (id)currentTrack {
// 	// called too often to be used in place of next track
// 	id orig = %orig;
// 	currentTrack = orig;
// 	return orig;
// }
- (SPTPlayerTrack *)playingTrack {
	SPTPlayerTrack *orig = %orig;
	// NSLog(@"canvasBackground currentTrack: %@ orig: %@ equal: %d", currentTrack.URI, orig.URI, [currentTrack.URI isEqual:orig.URI]);
	if([[NSFileManager defaultManager] fileExistsAtPath:canvasVideoPath] && ![currentTrack.URI isEqual:orig.URI]) {
		[self deleteCachedPlayer];
	}
	currentTrack = orig;
	return orig;
}
%end
%hook SPTCanvasTrackCheckerImplementation
%new
-(void)saveCanvasWithURL:(NSURL *)canvasURL {
	NSLog(@"canvasBackground saving canvas");
	NSData *canvasData = [NSData dataWithContentsOfURL:canvasURL];
	[canvasData writeToFile:canvasVideoPath atomically:YES];
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:nil];
}
- (_Bool)isCanvasEnabledForTrackMetadata:(id)arg1 {
	NSLog(@"canvasBackground %@", NSStringFromSelector(_cmd));
	BOOL shouldSaveCanvas = [self isCanvasEnabledForTrack:currentTrack];
	NSString *trackURI = [arg1 objectForKey:@"canvas.entityUri"];
	if(shouldSaveCanvas && [trackURI isEqualToString:currentTrack.URI.absoluteString] && ![[NSFileManager defaultManager] fileExistsAtPath:canvasVideoPath]) {
		NSURL *downloadedItem = [NSURL URLWithString:[arg1 objectForKey:@"canvas.url"]];
		[self performSelectorInBackground:@selector(saveCanvasWithURL:) withObject:downloadedItem];
	}
	return %orig;
}
%end