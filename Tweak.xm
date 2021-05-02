/* 
TODO: Add transition to AVQueuePlayer switching tracks
Can possibly achieve this by adding the AVPlayerLayer to our 
own UIView instead of directly to the ViewController's view

TODO: Add functionality for home screen

TODO: Fix bug where it doesn't refresh canvas when new song plays
*/

#import "Spotify.h"

NSString *const canvasVideoPath = [[[[%c(LSApplicationProxy) applicationProxyForIdentifier:@"com.spotify.client"] containerURL] path] stringByAppendingPathComponent:@"Documents/CanvasBackground.mp4"];

%hook SpringBoard
-(void)noteInterfaceOrientationChanged:(long long)arg1 duration:(double)arg2 logMessage:(id)arg3 {
	%orig;
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"resizeCanvas" object:nil];
}
%end

%hook CSCoverSheetViewController
%property(nonatomic, strong) AVQueuePlayer *canvasPlayer;
%property(nonatomic, strong) AVPlayerLayer *canvasPlayerLayer;
%property(nonatomic, strong) AVPlayerLooper *canvasPlayerLooper;
%new
-(void)resizeCanvas {
	[self.canvasPlayerLayer setFrame:[[[self view] layer] bounds]];
}
%new
-(void)recreateCanvasPlayer:(NSNotification *)note {
	NSString *canvasVideoURL = [[note userInfo] objectForKey:@"url"];
	if(![canvasVideoURL isEqualToString:@"remove"]) {
		[self.canvasPlayerLayer setFrame:[[[self view] layer] bounds]];
		AVPlayerItem *nextItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:canvasVideoURL]];
		[self.canvasPlayer removeAllItems];
		self.canvasPlayerLooper = [AVPlayerLooper playerLooperWithPlayer:self.canvasPlayer templateItem:nextItem];
	}
	else {
		[self.canvasPlayer removeAllItems];
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
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(recreateCanvasPlayer:) name:@"recreateCanvas" object:@"com.spotify.client"];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeCanvas) name:@"resizeCanvas" object:nil];
}
-(void)viewWillAppear:(BOOL)animated {
	%orig;
	[self.canvasPlayer play];
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
%hook SPTStatefulPlayer
%new
-(void)sendNotification {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:@{@"url": downloadedItem}];
	downloadedItem = @"remove";
}
- (id)nextTrack {
	NSLog(@"canvasBackground nextTrack");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendNotification) name:@"canvasAssigned" object:nil];
	return %orig;
}
- (SPTPlayerTrack *)playingTrack {
	// currentTrack = %orig;
	return %orig;
}
- (id)currentTrack {
	currentTrack = %orig;
	return %orig;
}
%end
%hook SPTCanvasModelImplementation
- (id)initWithCanvasId:(id)arg1 canvasURI:(id)arg2 contentURL:(NSURL *)arg3 contentId:(id)arg4 type:(unsigned long long)arg5 artistURI:(id)arg6 artistName:(id)arg7 entityURI:(id)arg8 albumCoverURL:(id)arg9 {
	if([impl isCanvasEnabledForTrack:currentTrack]) {
		downloadedItem = arg3.absoluteString ? arg3.absoluteString : @"remove";
		if(![downloadedItem isEqualToString:@"remove"]) {
			static dispatch_once_t onceToken;
			dispatch_once(&onceToken, ^{
				[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:@{@"url": downloadedItem}];
				downloadedItem = @"remove";
			});
		}
	}
	else {
		downloadedItem = @"remove";
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:@"canvasAssigned" object:nil];
	return %orig;
}
%end
%hook SPTCanvasTrackCheckerImplementation
// %property (nonatomic, strong) NSURL *previousURI;
// - (_Bool)isCanvasEnabledForTrackMetadata:(id)arg1 {
// 	// NSString *trackURI = [arg1 objectForKey:@"canvas.entityUri"];
// 	BOOL shouldSaveCanvas = [self isCanvasEnabledForTrack:currentTrack];
// 	if(shouldSaveCanvas) {
// 		downloadedItem = [arg1 objectForKey:@"canvas.url"];
// 		if(![downloadedItem isEqualToString:@"remove"]) {
// 			static dispatch_once_t onceToken;
// 			dispatch_once(&onceToken, ^{
// 				[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:@{@"url": downloadedItem}];
// 				downloadedItem = @"remove";
// 			});
// 		}
// 	}
// 	else {
// 		downloadedItem = @"remove";
// 	}
// 	[[NSNotificationCenter defaultCenter] postNotificationName:@"canvasAssigned" object:nil];
// 	return %orig;
// }
- (id)initWithTestManager:(id)arg1 {
	NSLog(@"canvasBackground checker init");
	impl = self;
	return %orig;
}
%end