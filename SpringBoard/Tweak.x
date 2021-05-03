#import "../Shared.h"


%hook SBMediaController
-(BOOL)isApplicationActivityActive {
	if(!%orig) {
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:@{@"url": @"remove"}];
	}
	return %orig;
}
-(void)_setNowPlayingApplication:(id)arg1 {
	if(!arg1) {
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:@{@"url": @"remove"}];
	}
	return %orig;
}
%end
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
		self.canvasPlayerLooper = [AVPlayerLooper playerLooperWithPlayer:self.canvasPlayer templateItem:nextItem];
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
-(void)viewDidDisappear:(BOOL)animated {
	%orig;
	[self.canvasPlayer pause];
}
%end

%hook SBHomeScreenViewController
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
		self.canvasPlayerLooper = [AVPlayerLooper playerLooperWithPlayer:self.canvasPlayer templateItem:nextItem];
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
-(void)viewDidDisappear:(BOOL)animated {
	%orig;
	[self.canvasPlayer pause];
}
%end