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
        [infoTunnel addObserver:self];
    }
    return self;
}

- (void)setShouldSuspend:(BOOL)shouldSuspend {
    _shouldSuspend = shouldSuspend;
    [self.infoTunnel observerChangedSuspension:self];
    [self animateFade:!shouldSuspend completion:nil];
}

- (void)invalidate {
    [self animateFade:NO completion:^{
        self.canvasImageView.image = nil;
    }];
}

- (void)animateFade:(BOOL)fadeIn completion:(void (^)(void))completion {
    [CATransaction begin];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
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
        animation.toValue = @(0.0f);
        self.view.layer.opacity = 0;
    }
    [CATransaction setCompletionBlock:^{
        if (completion) completion();
    }];
    [self.view.layer addAnimation:animation forKey:nil];
    [CATransaction commit];
    // [CATransaction begin];
    // if (completion) [CATransaction setCompletionBlock:completion];
    // CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    // CGFloat currentOpacity = self.view.layer.opacity;
    // animation.duration = 0.25f;
    // animation.fromValue = @(currentOpacity);
    // if (fadeIn) {
    //     if (currentOpacity == 1.0f) return;
    //     animation.toValue = @(1.0f);
    //     self.view.layer.opacity = 1;
    //     // self.view.hidden = NO;
    // }
    // else if (currentOpacity != 0) {
    //     animation.toValue = @(0.0f);
    //     self.view.layer.opacity = 0;
    //     // self.view.hidden = YES;
    //     // NSLog(@"canvasBackground fading out %f %@", self.view.layer.opacity, self.view.superview);
    // }
    // [self.view.layer addAnimation:animation forKey:nil];
    // [CATransaction commit];
    // dispatch_async(dispatch_get_main_queue(), ^{
    //     [self.view setNeedsLayout];
    //     [self.view layoutIfNeeded];
    // });
}

- (void)updateWithImage:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.canvasImageView.image = image;
    });
}

- (void)observeValueForKeyPath:(NSString *)path ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    self.canvasImageView.hidden = canvasPlayerLayer.readyForDisplay;
}

- (void)setPlaying:(BOOL)playing {
    // if we're not visible then we shouldn't wait
    // if (shouldSuspend) return;
    NSLog(@"canvasBackground %@", self.view.superview);
    [self animateFade:playing completion:nil];
    // if (self.shouldSuspend || playing || [NSRunLoop currentRunLoop] == [NSRunLoop mainRunLoop]) {
    // dispatch_sync(dispatch_get_main_queue(), ^{
    //     self.view.layer.opacity = playing ? 1.0f : 0.0f;
    // if (self.shouldSuspend) {
    //     self.view.layer.opacity = playing ? 1.0f : 0.0f;
    //     return;
    // }
    // NSLog(@"canvasBackground fading");
    //     [self animateFade:playing completion:nil];
    // });
        // dispatch_async(dispatch_get_main_queue(), ^{
        //     self.view.layer.opacity = playing ? 1.0f : 0.0f;
        // });
        // return;
    // }
    // if () {
    //     [self animateFade:playing completion:nil];
    //     return;
    // }
    // only wait if we're trying to pause the player
    // NSLog(@"canvasBackground %d", );
    // dispatch_semaphore_t signal = dispatch_semaphore_create(0);
    // dispatch_sync(dispatch_get_main_queue(), ^{
    //     [self animateFade:playing completion:nil];
        // [self animateFade:playing completion:^{
        //     dispatch_semaphore_signal(signal);
        // }];
    // });
    // dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER);
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.canvasImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
	self.canvasImageView.contentMode = UIViewContentModeScaleAspectFill;
	[self.view addSubview:self.canvasImageView];
	canvasPlayer = [self.infoTunnel player];
	canvasPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:canvasPlayer];
	[self.view.layer addSublayer:canvasPlayerLayer];
	canvasPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	canvasPlayerLayer.frame = self.view.bounds;
    [canvasPlayerLayer addObserver:self forKeyPath:@"readyForDisplay" options:0 context:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    canvasPlayerLayer.frame = self.view.bounds;
}

- (BOOL)_canShowWhileLocked {
    return YES;
}

@end