#import "SpringBoard.h"

%hook SBMediaController
- (void)_setNowPlayingApplication:(SBApplication *)application {
	%orig;
	if (application && ![application.bundleIdentifier isEqualToString:@"com.spotify.client"]) [[CBInfoTunnel sharedTunnel] invalidate];
}
%end

%hook SBHomeScreenViewController
%property (nonatomic, strong) CBViewController *canvasController;
- (void)viewDidLoad {
	%orig;
	self.canvasController = [[%c(CBViewController) alloc] initWithCanvasServer:[CBInfoTunnel sharedTunnel]];
    self.canvasController.view.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:self.canvasController.view atIndex:0];
    [self addChildViewController:self.canvasController];
}
- (void)setIconControllerHidden:(BOOL)hidden {
    %orig;
    [self.canvasController setSuspended:hidden];
}
%end

%hook CSMainPageContentViewController
%property (nonatomic, strong) CBViewController *canvasController;
- (void)viewDidLoad {
	%orig;
	self.canvasController = [[%c(CBViewController) alloc] initWithCanvasServer:[CBInfoTunnel sharedTunnel]];
    self.canvasController.view.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:self.canvasController.view atIndex:0];
    [self addChildViewController:self.canvasController];
}
- (BOOL)handleEvent:(CSEvent *)event {
    if (event.type == 24) [self.canvasController setSuspended:YES];
    if (event.type == 23) [self.canvasController setSuspended:NO];
    return %orig;
}
%end

%hook FBProcessManager
- (void)noteProcessDidExit:(FBProcess *)process {
    %orig;
    if ([process.bundleIdentifier isEqualToString:@"com.spotify.client"]) [[CBInfoTunnel sharedTunnel] invalidate];
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