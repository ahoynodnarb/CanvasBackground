//@TODO: Figure out how to programatticaly get spotify's Documents directory
//@TODO: Add transition to AVQueuePlayer switching tracks

#import "Spotify.h"

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
-(void)recreateCanvasPlayer {
	[self.canvasPlayerLayer removeFromSuperlayer];
	SBMediaController *mediaController = [%c(SBMediaController) sharedInstance];
	if([mediaController isPlaying] || [mediaController isPaused]) {
		NSURL *canvasVideoPath = [NSURL fileURLWithPath:@"/var/mobile/Containers/Data/Application/38FB9497-1C3A-4195-B301-4350AA699059/Documents/CanvasBackground.mp4"];
		self.canvasPlayer = [AVQueuePlayer playerWithURL:canvasVideoPath];
		[self.canvasPlayer setVolume:0];
		[self.canvasPlayer setPreventsDisplaySleepDuringVideoPlayback:NO];
		self.canvasPlayerLooper = [AVPlayerLooper playerLooperWithPlayer:self.canvasPlayer templateItem:self.canvasPlayer.currentItem];
		self.canvasPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.canvasPlayer];
		[self.canvasPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
		[self.canvasPlayerLayer setFrame:[[[self view] layer] bounds]];
		[[[self view] layer] insertSublayer:self.canvasPlayerLayer atIndex:0];
		[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
		[self.canvasPlayer play];
	}
}
-(void)viewDidLoad {
	%orig;
	[self recreateCanvasPlayer];
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(recreateCanvasPlayer) name:@"recreateCanvas" object:nil];
}
-(void)viewWillAppear:(BOOL)animated {
	%orig;
	[self.canvasPlayer play];
}
- (void)viewWillDisappear:(BOOL)animated {
	%orig;
	[self.canvasPlayer pause];
}
%end
%hook SPTStatefulPlayer
%new
-(void)deleteCachedPlayer {
	NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
	documents = [documents stringByAppendingPathComponent:@"CanvasBackground.mp4"];
	[[NSFileManager defaultManager] removeItemAtPath:documents error:nil];
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:nil];
}
- (id)currentTrack {
	id orig = %orig;
	currentTrack = orig;
	return orig;	
}	
- (void)skipToPreviousTrackTimes:(long long)arg1 {
	%orig; 
	[self deleteCachedPlayer];
}
- (void)skipToPreviousTrack {
	%orig; 
	[self deleteCachedPlayer];
}
- (void)skipToNextTrackTimes:(long long)arg1 {
	%orig; 
	[self deleteCachedPlayer];
}
- (void)skipToNextTrack {
	%orig; 
	[self deleteCachedPlayer];
}
%end
%hook SPTCanvasTrackCheckerImplementation
%new
-(void)saveCanvasWithURL:(NSURL *)canvasURL {
	NSData *canvasData = [NSData dataWithContentsOfURL:canvasURL];
	NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
	documents = [documents stringByAppendingPathComponent:@"CanvasBackground.mp4"];
	[canvasData writeToFile:documents atomically:YES];
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:nil];
}
- (_Bool)isCanvasEnabledForTrackMetadata:(id)arg1 {
	_Bool orig = %orig;
	NSString *trackURI = [arg1 objectForKey:@"canvas.entityUri"];
	if(orig && [trackURI isEqualToString:currentTrack.URI.absoluteString]) {
		[self performSelectorInBackground:@selector(saveCanvasWithURL:) withObject:[NSURL URLWithString:[arg1 objectForKey:@"canvas.url"]]];
	}
	return orig;
}
%end