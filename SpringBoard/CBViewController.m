#import "CBViewController.h"

@implementation CBViewController
-(void)togglePlayer:(NSNotification *)note {
	NSNumber *isPlaying = [[note userInfo] objectForKey:@"isPlaying"];
	[isPlaying boolValue] ? [self.canvasPlayer play] : [self.canvasPlayer pause];
	self.shouldPlayCanvas = [isPlaying boolValue];
}
-(void)resizeCanvas {
	NSLog(@"canvasBackground resizing canvas");
	// [self.view.superview setFrame:[[self view].superview.superview frame]];
	// [self.firstFrameView setFrame:[[self view].superview frame]];
	// [self.canvasPlayerLayer setFrame:[[[self view].superview layer] bounds]];
	[self.firstFrameView setFrame:[[UIScreen mainScreen] bounds]];
	[self.canvasPlayerLayer setFrame:[[UIScreen mainScreen] bounds]];
}
-(void)recreateCanvasPlayer:(NSNotification *)note {
	NSString *currentVideoURL = [[note userInfo] objectForKey:@"currentURL"];
	if(currentVideoURL) {
		AVPlayerItem *currentItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:currentVideoURL]];
		[self.firstFrameView setHidden:NO];
		AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[(AVURLAsset *)currentItem.asset URL] options:nil];
		AVAssetImageGenerator* imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
		UIImage *firstFrame = [UIImage imageWithCGImage:[imageGenerator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:nil error:nil]];
		[self.firstFrameView setImage:firstFrame];
		self.canvasPlayerLooper = [AVPlayerLooper playerLooperWithPlayer:self.canvasPlayer templateItem:currentItem];
		if(self.isVisible) {
			[self.canvasPlayer play];
		}
	}
	else {
		[self.firstFrameView setHidden:YES];
		[self.canvasPlayer removeAllItems];
	}
}
-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewDidLoad {
	[super viewDidLoad];
	self.firstFrameView = [[UIImageView alloc] init];
	[self.firstFrameView setFrame:[[self view] frame]];
	[self.firstFrameView setContentMode:UIViewContentModeScaleAspectFill];
	[self.firstFrameView setClipsToBounds:YES];
	[self.firstFrameView setHidden:YES];
	self.canvasPlayer = [[AVQueuePlayer alloc] init];
	self.canvasPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.canvasPlayer];
	[self.canvasPlayer setVolume:0];
	[self.canvasPlayer setPreventsDisplaySleepDuringVideoPlayback:NO];
	[self.canvasPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	[self.canvasPlayerLayer setFrame:[[[self view] layer] bounds]];
	[self.canvasPlayerLayer setHidden:YES];
	[[[self view] layer] insertSublayer:self.canvasPlayerLayer atIndex:0];
	[[[self view] layer] setSecurityMode:@"secure"];
	// NSLog(@"canvasBackground securityMode: %@", [self.view layer].securityMode);
	[[self view] insertSubview:self.firstFrameView atIndex:0];
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
	// [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(recreateCanvasPlayer:) name:@"recreateCanvas" object:@"com.spotify.client"];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(togglePlayer:) name:@"togglePlayer" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeCanvas) name:@"resizeCanvas" object:nil];
}
-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.isVisible = YES;
	[self.canvasPlayerLayer setHidden:NO];
	[self resizeCanvas];
	SBMediaController *controller = [objc_getClass("SBMediaController") sharedInstance];
	if(![controller isPaused] && ![controller isPlaying]) {
		[self.canvasPlayer removeAllItems];
	}
	if(self.shouldPlayCanvas)
		[self.canvasPlayer play];
}
-(void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	self.isVisible = NO;
	[self.canvasPlayerLayer setHidden:YES];
	[self.canvasPlayer pause];
}
@end