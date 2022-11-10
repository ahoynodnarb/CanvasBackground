#import "CBViewController.h"

@implementation CBViewController
- (void)togglePlayer:(NSNotification *)note {
	BOOL isPlaying = [[note.userInfo objectForKey:@"isPlaying"] boolValue];
    self.playerPlaying = isPlaying;
	if(isPlaying && !self.view.hidden) [self.canvasPlayer play];
	else [self.canvasPlayer pause];
}

- (void)updateCanvasForURL:(NSURL *)URL {
    AVPlayerItem *currentItem = [AVPlayerItem playerItemWithURL:URL];
    self.canvasPlayerLooper = [AVPlayerLooper playerLooperWithPlayer:self.canvasPlayer templateItem:currentItem];
    [self.canvasPlayer play];
}

- (void)updateThumbnailForURL:(NSURL *)URL {
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:URL options:nil];
    AVAssetImageGenerator* imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    UIImage *image = [UIImage imageWithCGImage:[imageGenerator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:nil error:nil]];
    self.thumbnailView.image = image;
}

- (void)recreateNotificationReceived:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    NSURL *currentVideoURL = [NSURL URLWithString:[userInfo objectForKey:@"currentURL"]];
    NSData *currentImageData = [userInfo objectForKey:@"artwork"];
    [self recreateCanvasWithVideoURL:currentVideoURL imageData:currentImageData];
}
/*
  Called whenever Spotify changes the current song
  This just updates the canvas based on the userInfo
  containing the thumbnail and canvas URL
*/
- (void)recreateCanvasWithVideoURL:(NSURL *)currentVideoURL imageData:(NSData *)imageData {
    NSURL *previousTrackURL = [(AVURLAsset *)self.canvasPlayer.currentItem.asset URL];
    if(!currentVideoURL) {
        [self.canvasPlayer removeAllItems];
        self.thumbnailView.image = [UIImage imageWithData:imageData];
        return;
    }
    if(![currentVideoURL isEqual:previousTrackURL]) {
        [self updateCanvasForURL:currentVideoURL];
        [self updateThumbnailForURL:currentVideoURL];
    }
}

- (void)observeValueForKeyPath:(NSString *)path ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    self.thumbnailView.hidden = self.canvasPlayerLayer.readyForDisplay;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    self.playerPlaying = YES;
	self.thumbnailView = [[UIImageView alloc] initWithFrame:self.view.frame];
	self.thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
	self.canvasPlayer = [[AVQueuePlayer alloc] init];
	self.canvasPlayer.volume = 0;
	self.canvasPlayer.preventsDisplaySleepDuringVideoPlayback = NO;
	self.canvasPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.canvasPlayer];
	self.canvasPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	self.canvasPlayerLayer.frame = self.view.bounds;
    [self.canvasPlayerLayer addObserver:self forKeyPath:@"readyForDisplay" options:0 context:nil];
    self.view.clipsToBounds = YES;
    self.view.contentMode = UIViewContentModeScaleAspectFill;
	[self.view insertSubview:self.thumbnailView atIndex:0];
	[self.view.layer insertSublayer:self.canvasPlayerLayer atIndex:0];
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(recreateNotificationReceived:) name:@"recreateCanvas" object:@"com.spotify.client"];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(togglePlayer:) name:@"togglePlayer" object:@"com.spotify.client"];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
    self.view.hidden = YES;
    [self.canvasPlayer pause];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    self.view.hidden = NO;
    if(self.playerPlaying) [self.canvasPlayer play];
}

- (BOOL)_canShowWhileLocked {
    return YES;
}
@end