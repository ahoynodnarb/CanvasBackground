#import "CBViewController.h"

@interface CBViewController () {
    AVQueuePlayer *canvasPlayer;
    AVPlayerLayer *canvasPlayerLayer;
}
@property (nonatomic, strong) UIImageView *canvasImageView;
@end

@implementation CBViewController
- (instancetype)initWithInfoTunnel:(CBInfoTunnel *)infoTunnel {
    if (self = [super init]) {
        self.infoTunnel = infoTunnel;
        canvasPlayer = [self.infoTunnel player];
        [infoTunnel addObserver:self];
    }
    return self;
}

- (void)setShouldSuspend:(BOOL)shouldSuspend {
    _shouldSuspend = shouldSuspend;
    [self.infoTunnel observerChangedSuspension:self];
}

- (void)invalidate {
    [self animateFade:NO completion:^{
        [self updateWithImage:nil];
    }];
}

- (void)animateFade:(BOOL)fadeIn completion:(void (^)(void))completion {
    CGFloat currentOpacity = [self.view.layer opacity];
    CGFloat targetOpacity = fadeIn ? 1.0f : 0.0f;
    if (currentOpacity == targetOpacity) return;
    [CATransaction begin];
    if (completion) [CATransaction setCompletionBlock:completion];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 0.25f;
    animation.fromValue = @(currentOpacity);
    animation.toValue = @(targetOpacity);
    self.view.layer.opacity = targetOpacity;
    [self.view.layer addAnimation:animation forKey:nil];
    [CATransaction commit];
}

- (void)updateWithImage:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.canvasImageView.image = image;
    });
}

- (void)observeValueForKeyPath:(NSString *)path ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([path isEqualToString:@"readyForDisplay"]) {
        self.canvasImageView.hidden = [canvasPlayerLayer isReadyForDisplay];
        return;
    }
}

- (void)setPlaying:(BOOL)playing {
    // if we're not visible then we shouldn't wait
    if (self.shouldSuspend || playing || [NSThread isMainThread]) {
        [self animateFade:playing completion:nil];
        return;
    }
    dispatch_semaphore_t signal = dispatch_semaphore_create(0);
    [self animateFade:playing completion:^{
        dispatch_semaphore_signal(signal);
    }];
    dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER);
}

- (void)viewDidLoad {
	[super viewDidLoad];
    self.view.clipsToBounds = YES;
    self.view.contentMode = UIViewContentModeScaleAspectFill;
    self.view.layer.opacity = 0.0f;
	self.canvasImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
	self.canvasImageView.contentMode = UIViewContentModeScaleAspectFill;
	[self.view addSubview:self.canvasImageView];
	canvasPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:canvasPlayer];
	[self.view.layer addSublayer:canvasPlayerLayer];
	canvasPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	canvasPlayerLayer.frame = self.view.bounds;
    [canvasPlayerLayer addObserver:self forKeyPath:@"readyForDisplay" options:0 context:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    canvasPlayerLayer.frame = [self.view bounds];
}

- (BOOL)_canShowWhileLocked {
    return YES;
}

@end