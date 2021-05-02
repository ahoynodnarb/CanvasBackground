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
	if(![canvasVideoURL isEqualToString:@""]) {
		NSLog(@"canvasBackground recreating player");
		AVPlayerItem *nextItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:canvasVideoURL]];
		[self.canvasPlayer removeAllItems];
		self.canvasPlayerLooper = [AVPlayerLooper playerLooperWithPlayer:self.canvasPlayer templateItem:nextItem];
	}
	else {
		NSLog(@"canvasBackground removing player");
		[self.canvasPlayer removeAllItems];
	}
}
-(void)viewDidLoad {
	%orig;
	NSLog(@"canvasBackground viewDidLoad called");
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
	[self clearCanvasIfNeeded];
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
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:@{@"url": downloadedItem}];
	NSLog(@"canvasBackground nextTrack sending notification... %@", downloadedItem);
	downloadedItem = @"";
}
- (id)nextTrack {
	NSLog(@"canvasBackground nextTrack");
	[self performSelector:@selector(sendNotification) withObject:nil afterDelay:0.5];
	return %orig;
}
- (SPTPlayerTrack *)playingTrack {
	currentTrack = %orig;
	return %orig;
}
%end
%hook SPTCanvasTrackCheckerImplementation
%property (nonatomic, strong) NSURL *canvasURL;
- (_Bool)isCanvasEnabledForTrackMetadata:(id)arg1 {
	NSString *trackURI = [arg1 objectForKey:@"canvas.entityUri"];
	NSLog(@"canvasBackground trackURI: %@ currentTrack: %@", trackURI, currentTrack.URI.absoluteString);
	if(%orig && ([trackURI isEqualToString:currentTrack.URI.absoluteString] ^ !currentTrack)) {
		downloadedItem = [arg1 objectForKey:@"canvas.url"];
		NSLog(@"canvasBackground downloadedItem: %@", downloadedItem);
		if(![downloadedItem isEqualToString:@""]) {
			static dispatch_once_t onceToken;
			dispatch_once(&onceToken, ^{
				[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:@{@"url": downloadedItem}];
				downloadedItem = @"";
				NSLog(@"canvasBackground sending notification... %@", downloadedItem);
			});
		}
	}
	return %orig;
}
%end