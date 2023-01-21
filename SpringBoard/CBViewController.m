#import "CBViewController.h"

@interface CBViewController ()
@property (nonatomic, strong) AVQueuePlayer *canvasPlayer;
@property (nonatomic, strong) AVPlayerLayer *canvasPlayerLayer;
@property (nonatomic, strong) AVPlayerLooper *canvasPlayerLooper;
@property (nonatomic, strong) UIImageView *thumbnailView;
@end

@implementation CBViewController
- (instancetype)initWithCanvasServer:(CBCanvasServer *)server {
    if (self = [super init]) {
        self.server = server;
        [server addObserver:self];
    }
    return self;
}

- (void)invalidate {
    self.playing = NO;
    [self updateWithImage:nil];
}

- (void)setPlaying:(BOOL)playing {
    _playing = playing;
    if (self.view.hidden) return;
    if (playing) [self.canvasPlayer play];
    else [self.canvasPlayer pause];
}

- (void)updateWithImage:(UIImage *)image {
    [self.canvasPlayer removeAllItems];
    self.thumbnailView.image = image;
}

- (void)updateWithVideoURL:(NSURL *)URL {
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:URL options:nil];
    AVPlayerItem *currentItem = [AVPlayerItem playerItemWithAsset:asset];
    self.canvasPlayerLooper = [AVPlayerLooper playerLooperWithPlayer:self.canvasPlayer templateItem:currentItem];
    [self.canvasPlayer play];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    UIImage *image = [UIImage imageWithCGImage:[imageGenerator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:nil error:nil]];
    self.thumbnailView.image = image;
}

- (void)observeValueForKeyPath:(NSString *)path ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    self.thumbnailView.hidden = self.canvasPlayerLayer.readyForDisplay;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.thumbnailView = [[UIImageView alloc] initWithFrame:self.view.frame];
	self.thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
	self.canvasPlayer = [[AVQueuePlayer alloc] init];
	self.canvasPlayer.volume = 0;
	self.canvasPlayer.preventsDisplaySleepDuringVideoPlayback = NO;
	self.canvasPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.canvasPlayer];
	self.canvasPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	self.canvasPlayerLayer.frame = self.view.bounds;
    self.view.clipsToBounds = YES;
    self.view.contentMode = UIViewContentModeScaleAspectFill;
	[self.view insertSubview:self.thumbnailView atIndex:0];
	[self.view.layer insertSublayer:self.canvasPlayerLayer atIndex:0];
    [self.canvasPlayerLayer addObserver:self forKeyPath:@"readyForDisplay" options:0 context:nil];
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
    self.view.hidden = YES;
    [self.canvasPlayer pause];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    self.view.hidden = NO;
    if (self.playing) [self.canvasPlayer play];
}

- (BOOL)_canShowWhileLocked {
    return YES;
}
@end