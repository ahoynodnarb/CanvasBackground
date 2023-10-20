#import "SpringBoard.h"

%hook SBMediaController
- (void)_setNowPlayingApplication:(SBApplication *)application {
	%orig;
	if (application && ![application.bundleIdentifier isEqualToString:@"com.spotify.client"]) [[CBInfoTunnel sharedTunnel] invalidate];
}
%end

%hook FBProcessManager
- (void)noteProcessDidExit:(FBProcess *)process {
    %orig;
    if ([process.bundleIdentifier isEqualToString:@"com.spotify.client"]) [[%c(CBInfoTunnel) sharedTunnel] invalidate];
}
%end

%hook SBHomeScreenViewController
%property (nonatomic, strong) CBViewController *canvasController;
- (void)viewDidLoad {
	%orig;
	self.canvasController = [[%c(CBViewController) alloc] initWithInfoTunnel:[%c(CBInfoTunnel) sharedTunnel]];
    self.canvasController.view.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:self.canvasController.view atIndex:0];
    [self addChildViewController:self.canvasController];
}

- (void)setIconControllerHidden:(BOOL)hidden {
    %orig;
    self.canvasController.shouldSuspend = hidden;
}
%end

%hook CSMainPageContentViewController
%property (nonatomic, strong) CBViewController *canvasController;
- (void)viewDidLoad {
	%orig;
	self.canvasController = [[%c(CBViewController) alloc] initWithInfoTunnel:[%c(CBInfoTunnel) sharedTunnel]];
    self.canvasController.view.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:self.canvasController.view atIndex:0];
    [self addChildViewController:self.canvasController];
}

- (void)_beginTransitionFromAppeared:(BOOL)appeared {
    %orig;
    if (!appeared) {
        self.canvasController.shouldSuspend = NO;
        self.contentViewController.canvasController.shouldSuspend = NO;
    }
    self.contentViewController.canvasController.view.hidden = YES;
}

- (void)_endTransitionToAppeared:(BOOL)appeared {
    %orig;
    if (!appeared) {
        self.canvasController.shouldSuspend = YES;
        self.contentViewController.canvasController.shouldSuspend = YES;
    }
    self.contentViewController.canvasController.view.hidden = NO;
}

%end

%hook CSCoverSheetViewController
%property (nonatomic, strong) CBViewController *canvasController;
- (void)viewDidLoad {
	%orig;
	self.canvasController = [[%c(CBViewController) alloc] initWithInfoTunnel:[%c(CBInfoTunnel) sharedTunnel]];
    self.canvasController.view.contentMode = UIViewContentModeScaleAspectFill;
    self.canvasController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view.slideableContentView addSubview:self.canvasController.view];
    [self addChildViewController:self.canvasController];
    [NSLayoutConstraint activateConstraints:@[
        [self.canvasController.view.topAnchor constraintEqualToAnchor:self.view.slideableContentView.topAnchor],
        [self.canvasController.view.bottomAnchor constraintEqualToAnchor:self.view.slideableContentView.bottomAnchor],
        [self.canvasController.view.leftAnchor constraintEqualToAnchor:self.view.slideableContentView.leftAnchor],
        [self.canvasController.view.rightAnchor constraintEqualToAnchor:self.view.slideableContentView.rightAnchor],
    ]];
}

%end

%hook SBBacklightController
- (void)setBacklightFactorPending:(float)backlightFactor  {
    %orig;
    BOOL screenOff = backlightFactor == 0.0f;
    [[CBInfoTunnel sharedTunnel] setSuspended:screenOff];
}
%end

@interface MPCMediaRemoteController : NSObject
- (id)contentItemArtworkForContentItemIdentifier:(id)arg1 artworkIdentifier:(id)arg2 size:(CGSize)arg3;
@end

@interface MRContentItemMetdata
@property (nonatomic, strong) NSString *contentIdentifier;
@property (nonatomic, strong) NSString *artworkIdentifier;
@end

@interface MRContentItem
@property (nonatomic, strong) MRContentItemMetdata *metadata;
@property (nonatomic, strong) NSDictionary *nowPlayingInfo;
@end

@interface MPCFuture
- (id)onCompletion:(void (^)(id, NSError *))completion;
@end

%hook MPCMediaRemoteController
- (void)_playbackQueueChangedNotification:(NSNotification *)note {
    %orig;
    // CBInfoTunnel *tunnel = [CBInfoTunnel sharedTunnel];
    // BOOL success = [tunnel updateCanvas];
    // if (!success) {
    //     NSArray *artworks = [[self valueForKey:@"_contentItemArtwork"] allValues];
    //     // NSLog(@"canvasBackground %lu %lu", (unsigned long)[artworks[0] count], (unsigned long)[artworks[1] count]);
    //     // for (id key in artworks[0]) {
    //     //     NSLog(@"canvasBackground %@ %@", key, artworks[0][key]);
    //     // }
    //     // NSLog(@"canvasBackground %@", [artworks[0] allValues]);
    //     UIImage *artworkImage = artworks[0][@"{1000, 1000}"];
    //     [tunnel updateWithImage:artworkImage];
    // }
    CBInfoTunnel *tunnel = [CBInfoTunnel sharedTunnel];
    BOOL success = [tunnel updateCanvas];
    if (success) return;
    // NSDictionary *userInfo = [note userInfo];
    // MRContentItem *contentItem = userInfo[@"kMRMediaRemoteUpdatedContentItemsUserInfoKey"][0];
    // MRContentItemMetdata *metadata = [contentItem metadata];
    // NSString *contentIdentifier = [metadata contentIdentifier];
    // NSString *artworkIdentifier = [metadata artworkIdentifier];
    // NSLog(@"canvasBackground %@ %@", contentIdentifier, artworkIdentifier);
    // MPCFuture *future = [self contentItemArtworkForContentItemIdentifier:contentIdentifier artworkIdentifier:artworkIdentifier size:CGSizeMake(1000, 1000)];
    // [future onCompletion:^(UIImage *artworkImage, NSError *error) {
    //     if (error || !artworkImage) return;
    //     [tunnel updateWithImage:artworkImage];
    // }];
}

// - (id)contentItemArtworkForContentItemIdentifier:(id)arg1 artworkIdentifier:(id)arg2 size:(CGSize)arg3  {
//     NSLog(@"canvasBackground %@ %@ %@ %@", NSStringFromSelector(_cmd), arg1, arg2, NSStringFromCGSize(arg3));
//     return %orig;
// }

- (void)_playbackQueueContentItemsChangedNotification:(NSNotification *)note {
    %orig;
    NSDictionary *userInfo = [note userInfo];
    MRContentItem *contentItem = userInfo[@"kMRMediaRemoteUpdatedContentItemsUserInfoKey"][0];
    int playbackRate = [contentItem.nowPlayingInfo[@"kMRMediaRemoteNowPlayingInfoPlaybackRate"] intValue];
    [[CBInfoTunnel sharedTunnel] setPlaying:(playbackRate != 0)];
}

%end