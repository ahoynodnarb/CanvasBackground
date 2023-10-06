#import "CBViewController.h"

@interface CBViewController ()
@property (nonatomic, strong) AVQueuePlayer *canvasPlayer;
@property (nonatomic, strong) AVPlayerLayer *canvasPlayerLayer;
@property (nonatomic, strong) AVPlayerLooper *canvasPlayerLooper;
@property (nonatomic, strong) UIImageView *thumbnailView;
@end

@implementation CBViewController
- (instancetype)initWithCanvasServer:(CBInfoTunnel *)server {
    if (self = [super init]) {
        self.server = server;
        [server addObserver:self];
    }
    return self;
}

- (void)invalidate {
<<<<<<< HEAD
    _playing = NO;
=======
    self.playing = NO;
>>>>>>> 43925e42021a369867eca44cae74def1d272e228
    [self animateFade:NO completion:^{
        [self.canvasPlayer removeAllItems];
        self.thumbnailView.image = nil;
    }];
}

- (void)animateFade:(BOOL)fadeIn completion:(void (^)(void))completion {
    [CATransaction begin];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
<<<<<<< HEAD
    CGFloat currentOpacity = self.view.layer.opacity;
    animation.duration = 0.25f;
    animation.fromValue = @(currentOpacity);
    if (fadeIn) {
        if (currentOpacity == 1.0f) return;
        animation.toValue = @(1.0f);
        self.view.layer.opacity = 1;
    }
    else if (currentOpacity) {
        if (currentOpacity == 0.0f) return;
=======
    animation.duration = 0.25f;
    if (fadeIn) {
        animation.fromValue = @(0.0f);
        animation.toValue = @(1.0f);
        self.view.layer.opacity = 1;
    }
    else {
        animation.fromValue = @(1.0f);
>>>>>>> 43925e42021a369867eca44cae74def1d272e228
        animation.toValue = @(0.0f);
        self.view.layer.opacity = 0;
    }
    [CATransaction setCompletionBlock:^{
        if (completion) completion();
    }];
    [self.view.layer addAnimation:animation forKey:nil];
    [CATransaction commit];
}

- (void)setPlaying:(BOOL)playing {
    if (playing == _playing) return;
    _playing = playing;
    if (self.view.hidden) return;
    if (playing) {
        [self animateFade:YES completion:nil];
        if (self.canvasPlayerLayer.readyForDisplay) [_canvasPlayer play];
    }
    else {
        [self animateFade:NO completion:^{
            if (self.canvasPlayerLayer.readyForDisplay) {
                [_canvasPlayer pause];
            }
        }];
    }
}

- (void)updateWithImage:(UIImage *)image {
    [self.canvasPlayer removeAllItems];
    self.thumbnailView.image = image;
}

- (void)updateWithVideoItem:(AVPlayerItem *)item {
    [self.canvasPlayer removeAllItems];
    self.canvasPlayerLooper = [AVPlayerLooper playerLooperWithPlayer:self.canvasPlayer templateItem:item];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:[item asset]];
    [imageGenerator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:CMTimeMakeWithSeconds(0, 1)]] completionHandler:^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        dispatch_sync(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithCGImage:im];
            self.thumbnailView.image = image;
        });
    }];
}

- (void)observeValueForKeyPath:(NSString *)path ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    self.thumbnailView.hidden = self.canvasPlayerLayer.readyForDisplay;
}

- (void)setSuspended:(BOOL)suspended {
    if (suspended) [self.canvasPlayer pause];
    else if (self.playing) [self.canvasPlayer play];
}

- (void)viewDidLoad {
	[super viewDidLoad];
    NSError *e1;
    NSError *e2;
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&e1];
    [[AVAudioSession sharedInstance] setActive:YES error:&e2];
	self.thumbnailView = [[UIImageView alloc] initWithFrame:self.view.frame];
	self.thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
	self.canvasPlayer = [[AVQueuePlayer alloc] init];
    self.canvasPlayer.muted = YES;
	// self.canvasPlayer.volume = 0;
	self.canvasPlayer.preventsDisplaySleepDuringVideoPlayback = NO;
	self.canvasPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.canvasPlayer];
	self.canvasPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	self.canvasPlayerLayer.frame = self.view.bounds;
    self.view.clipsToBounds = YES;
    self.view.contentMode = UIViewContentModeScaleAspectFill;
    self.view.layer.opacity = 0.0f;
	[self.view insertSubview:self.thumbnailView atIndex:0];
	[self.view.layer insertSublayer:self.canvasPlayerLayer atIndex:0];
    [self.canvasPlayerLayer addObserver:self forKeyPath:@"readyForDisplay" options:0 context:nil];
    NSLog(@"canvasBackground %@ %@", e1, e2);
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
    [self setSuspended:YES];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    [self setSuspended:NO];
}

- (BOOL)_canShowWhileLocked {
    return YES;
}
@end