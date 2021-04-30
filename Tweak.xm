#import "Spotify.h"

%hook CSCoverSheetViewController
%property(nonatomic, strong) AVQueuePlayer *canvasPlayer;
%property(nonatomic, strong) AVPlayerLayer *playerLayer;
%property(nonatomic, strong) AVPlayerLooper *playerLooper;
%new
-(void)setCanvas {
    // [self.canvasPlayer play];
}
// -(void)viewWillAppear:(BOOL)arg1 {
-(void)viewDidLoad {
	%orig;
	NSLog(@"canvasBackground viewDidLoad called");
	// NSLog(@"canvasBackground setCanvas called");
}
- (void)viewWillAppear:(BOOL)animated { // play wallpaper when lockscreen appears
	%orig;
	[self.playerLayer removeFromSuperlayer];
	NSLog(@"canvasBackground viewWillAppear called");
	SBMediaController *mediaController = [%c(SBMediaController) sharedInstance];
	if([mediaController isPlaying] || [mediaController isPaused]) {
		NSURL *canvasVideoPath = [NSURL fileURLWithPath:@"/var/mobile/Containers/Data/Application/38FB9497-1C3A-4195-B301-4350AA699059/Documents/CanvasBackground.mp4"];
		// self.canvasPlayer = [AVQueuePlayer playerWithURL:canvasVideoPath];
		self.canvasPlayer = [AVQueuePlayer playerWithURL:canvasVideoPath];
		[self.canvasPlayer setVolume:0];
		[self.canvasPlayer setPreventsDisplaySleepDuringVideoPlayback:NO];
		self.playerLooper = [AVPlayerLooper playerLooperWithPlayer:self.canvasPlayer templateItem:self.canvasPlayer.currentItem];
		self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.canvasPlayer];
		[self.playerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
		[self.playerLayer setFrame:[[[self view] layer] bounds]];
		[[[self view] layer] insertSublayer:self.playerLayer atIndex:0];
		[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
		[self.canvasPlayer play];
		// [self.playerLayer setHidden:YES];
		%orig;
		// [self.canvasPlayer replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:canvasVideoPath]];
		// [self.canvasPlayer seekToTime:CMTimeMakeWithSeconds(0.0 , 1)];
		// [self.playerLayer setHidden:NO];
	}

}
%end
%hook SPTVideoDisplayView
%new
-(void)createCanvasVideo {
	NSLog(@"canvasBackground createCanvasVideo called");
	AVAsset *videoAsset = self.player.currentItem.asset;
	NSURL *canvasURL = [(AVURLAsset *)videoAsset URL];
	NSError *error = nil;
	NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
	documents = [documents stringByAppendingPathComponent:@"CanvasBackground.mp4"];
	[[NSFileManager defaultManager] removeItemAtPath:documents error:&error];
	if(self.player && canvasURL) {
		[[NSFileManager defaultManager] copyItemAtPath:canvasURL.path toPath:documents error:&error];
	}
}
-(void)layoutSubviews {
	%orig;
	[self performSelectorInBackground:@selector(createCanvasVideo) withObject:nil];
}
%end