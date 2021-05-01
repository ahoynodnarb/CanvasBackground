/* 
TODO: Add transition to AVQueuePlayer switching tracks
Can possibly achieve this by adding the AVPlayerLayer to our 
own UIView instead of directly to the ViewController's view

TODO: Add functionality for home screen

TODO: Fix bug where changing orientation adds the cached canvas
*/

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
	NSLog(@"canvasBackground recreateCanvasPlayer called");
	SBMediaController *mediaController = [%c(SBMediaController) sharedInstance];
	if([mediaController isPlaying] || [mediaController isPaused]) {	
		NSString *canvasVideoPath = [[[%c(LSApplicationProxy) applicationProxyForIdentifier:@"com.spotify.client"] containerURL] path];
		canvasVideoPath = [canvasVideoPath stringByAppendingPathComponent:@"Documents/CanvasBackground.mp4"];
		AVPlayerItem *nextItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:canvasVideoPath]];
		[self.canvasPlayerLayer setFrame:[[[self view] layer] bounds]];
		[self.canvasPlayer removeAllItems];
		[self.canvasPlayer insertItem:nextItem afterItem:nil];
		self.canvasPlayerLooper = [AVPlayerLooper playerLooperWithPlayer:self.canvasPlayer templateItem:self.canvasPlayer.currentItem];
	}
}
-(void)viewDidLoad {
	%orig;
	NSString *canvasVideoPath = [[[%c(LSApplicationProxy) applicationProxyForIdentifier:@"com.spotify.client"] containerURL] path];
	canvasVideoPath = [canvasVideoPath stringByAppendingPathComponent:@"Documents/CanvasBackground.mp4"];
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
	NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
	documents = [documents stringByAppendingPathComponent:@"CanvasBackground.mp4"];
	[[NSFileManager defaultManager] removeItemAtPath:documents error:nil];
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:nil];
}
-(void)setPaused:(_Bool)arg1 {
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		return;
    });
	currentTrack = nil;
	%orig;
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
- (void)skipToNextTrackTimes:(long long)arg1 {
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
	BOOL shouldSaveCanvas = [self isCanvasEnabledForTrack:currentTrack];
	NSString *trackURI = [arg1 objectForKey:@"canvas.entityUri"];
	if(shouldSaveCanvas && [trackURI isEqualToString:currentTrack.URI.absoluteString]) {
		NSURL *downloadedItem = [NSURL URLWithString:[arg1 objectForKey:@"canvas.url"]];
		[self performSelectorInBackground:@selector(saveCanvasWithURL:) withObject:downloadedItem];
	}
	return %orig;
}
%end