/* 
TODO: Add transition to AVQueuePlayer switching tracks
Can possibly achieve this by adding the AVPlayerLayer to our 
own UIView instead of directly to the ViewController's view

TODO: Add functionality for home screen
*/

#import "Spotify.h"

%hook SpringBoard
-(void)noteInterfaceOrientationChanged:(long long)arg1 duration:(double)arg2 logMessage:(id)arg3 {
	%orig;
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"resizeCanvas" object:nil];
}
%end

%hook CSCoverSheetViewController
%property (nonatomic, strong) AVQueuePlayer *canvasPlayer;
%property (nonatomic, strong) AVPlayerLayer *canvasPlayerLayer;
%property (nonatomic, strong) AVPlayerLooper *canvasPlayerLooper;
%new
-(void)resizeCanvas {
	[self.canvasPlayerLayer setFrame:[[[self view] layer] bounds]];
}
%new
-(void)recreateCanvasPlayer:(NSNotification *)note {
	NSString *canvasVideoURL = [[note userInfo] objectForKey:@"url"];
	if(![canvasVideoURL isEqualToString:@"remove"]) {
		NSLog(@"canvasBackground recreating");
		[self.canvasPlayerLayer setFrame:[[[self view] layer] bounds]];
		[self.canvasPlayer removeAllItems];
		AVPlayerItem *nextItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:canvasVideoURL]];
		// [self.canvasPlayer replaceCurrentItemWithPlayerItem:nextItem];
		// static dispatch_once_t once;
		// dispatch_once(&once, ^{
		self.canvasPlayerLooper = [AVPlayerLooper playerLooperWithPlayer:self.canvasPlayer templateItem:nextItem];
		// });
	}
	else {
		NSLog(@"canvasBackground removing");
		[self.canvasPlayer removeAllItems];
	}
}
-(void)viewDidLoad {
	%orig;
	self.canvasPlayer = [[AVQueuePlayer alloc] init];
	self.canvasPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.canvasPlayer];
	[self.canvasPlayer setVolume:0];
	[self.canvasPlayer setPreventsDisplaySleepDuringVideoPlayback:NO];
	[self.canvasPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	[self.canvasPlayerLayer setFrame:[[[self view] layer] bounds]];
	[[[self view] layer] insertSublayer:self.canvasPlayerLayer atIndex:0];
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(recreateCanvasPlayer:) name:@"recreateCanvas" object:@"com.spotify.client"];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeCanvas) name:@"resizeCanvas" object:nil];
}
-(void)viewWillAppear:(BOOL)animated {
	%orig;
	[self.canvasPlayer play];
	[self resizeCanvas];
	SBMediaController *controller = [%c(SBMediaController) sharedInstance];
	if(![controller isPaused] && ![controller isPlaying]) {
		[self.canvasPlayer removeAllItems];
	}
}
- (void)viewDidDisappear:(BOOL)animated {
	%orig;
	[self.canvasPlayer pause];
}
%end
// %hook SPTCanvasModelImplementation
// %property (nonatomic, strong) SPTPlayerTrack *track;
// - (id)initWithCanvasId:(id)arg1 canvasURI:(id)arg2 contentURL:(NSURL *)arg3 contentId:(id)arg4 type:(unsigned long long)arg5 artistURI:(id)arg6 artistName:(id)arg7 entityURI:(id)arg8 albumCoverURL:(id)arg9 {
// 	id orig = %orig;
// 	NSLog(@"canvasBackground currentTrack: %@ downloadedItem: %@ enabled: %d", [player currentTrack], downloadedItem, [impl isCanvasEnabledForTrack:[player currentTrack]]);
// 	if([impl isCanvasEnabledForTrack:[player currentTrack]]) {
// 		if([downloadedItem isEqual:arg3.absoluteString]) {
// 			return orig;
// 		}
// 		downloadedItem = arg3.absoluteString ? arg3.absoluteString : @"remove";
// 	}
// 	else {
// 		downloadedItem = @"remove";
// 	}
// 	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:@{@"url": downloadedItem}];
// 	return orig;
// }
// %end
// %hook SPTCanvasTrackCheckerImplementation
// - (id)initWithTestManager:(id)arg1 {
// 	NSLog(@"canvasBackground checker init");
// 	impl = self;
// 	return %orig;
// }
// %end

%hook SPTCanvasNowPlayingContentLoader
- (id)initWithCanvasTrackChecker:(id)arg1 viewModelFactory:(id)arg2 contentReloader:(id)arg3 contentLoaderTracker:(id)arg4 nowPlayingState:(id)arg5 {
	NSLog(@"canvasBackground trackChecker");
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
- (id)nextTrack {
	[self sendNotification];
	return %orig;
}
- (void)setPaused:(_Bool)arg1 {
	if(!sentNotificationOnce) {
		[self sendNotification];
		sentNotificationOnce = YES;
	}
	return %orig;
}
%end