#import "CBViewController.h"

@implementation CBViewController
// -(UIImage *)getArtworkImage {
// 	UIImage *__block nowPlayingArtwork = [[UIImage alloc] init];
// 	MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
//         NSDictionary* dict = (__bridge NSDictionary *)information;
//         nowPlayingArtwork = [UIImage imageWithData:[dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtworkData]];
// 		NSLog(@"canvasBackground image: %@", [UIImage imageWithData:[dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtworkData]]);
//     });
// 	return nowPlayingArtwork;
// }
-(void)togglePlayer:(NSNotification *)note {
	BOOL isPlaying = [[[note userInfo] objectForKey:@"isPlaying"] boolValue];
	if(isPlaying) [self.canvasPlayer play];
	else [self.canvasPlayer pause];
	self.shouldPlayCanvas = isPlaying;
}
-(void)resizeCanvas {
	[self.bufferingView setFrame:[[UIScreen mainScreen] bounds]];
	[self.canvasPlayerLayer setFrame:[[UIScreen mainScreen] bounds]];
}
-(void)recreateCanvasPlayer:(NSNotification *)note {
	NSString *currentVideoURL = [[note userInfo] objectForKey:@"currentURL"];
	NSLog(@"canvasBackground recreating: %@", currentVideoURL);
	if(currentVideoURL) {
		[self.bufferingView setHidden:NO];
		AVPlayerItem *currentItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:currentVideoURL]];
		AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[(AVURLAsset *)currentItem.asset URL] options:nil];
		AVAssetImageGenerator* imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
		UIImage *firstFrame = [UIImage imageWithCGImage:[imageGenerator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:nil error:nil]];
		[self.bufferingView setImage:firstFrame];
		self.canvasPlayerLooper = [AVPlayerLooper playerLooperWithPlayer:self.canvasPlayer templateItem:currentItem];
		if(self.isVisible) [self.canvasPlayer play];
	}
	else {
		[self.bufferingView setHidden:YES];
		[self.canvasPlayer removeAllItems];
	}
}
-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewDidLoad {
	[super viewDidLoad];
	self.bufferingView = [[UIImageView alloc] init];
	[self.bufferingView setFrame:[[self view] frame]];
	[self.bufferingView setContentMode:UIViewContentModeScaleAspectFill];
	[self.bufferingView setClipsToBounds:YES];
	[self.bufferingView setHidden:YES];
	self.canvasPlayer = [[AVQueuePlayer alloc] init];
	self.canvasPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.canvasPlayer];
	[self.canvasPlayer setVolume:0];
	[self.canvasPlayer setPreventsDisplaySleepDuringVideoPlayback:NO];
	[self.canvasPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	[self.canvasPlayerLayer setFrame:[[[self view] layer] bounds]];
	[self.canvasPlayerLayer setHidden:YES];
	[[[self view] layer] insertSublayer:self.canvasPlayerLayer atIndex:0];
	[[[self view] layer] setSecurityMode:@"secure"];
	[[self view] insertSubview:self.bufferingView atIndex:0];
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
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
	if(![controller isPaused] && ![controller isPlaying]) [self.canvasPlayer removeAllItems];
	if(self.shouldPlayCanvas) [self.canvasPlayer play];
}
-(void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	self.isVisible = NO;
	[self.canvasPlayerLayer setHidden:YES];
	[self.canvasPlayer pause];
}
@end