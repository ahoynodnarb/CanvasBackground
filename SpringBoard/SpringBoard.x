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
    self.canvasController.view.opaque = NO;
    [self.view insertSubview:self.canvasController.view atIndex:0];
    [self addChildViewController:self.canvasController];
}
- (void)setIconControllerHidden:(BOOL)hidden {
    %orig;
    [self.canvasController setSuspended:hidden];
}
%end


%hook SBCoverSheetPrimarySlidingViewController
%property (nonatomic, strong) CBViewController *canvasController;
- (void)viewDidLoad {
	%orig;
	self.canvasController = [[%c(CBViewController) alloc] initWithCanvasServer:[CBInfoTunnel sharedTunnel]];
    self.canvasController.view.contentMode = UIViewContentModeScaleAspectFill;
    [self.panelBackgroundContainerView addSubview:self.canvasController.view];
    [self addChildViewController:self.canvasController];
}

- (void)_beginTransitionFromAppeared:(BOOL)arg1 {
    self.contentViewController.canvasController.view.hidden = YES;
    %orig;
}

- (void)_endTransitionToAppeared:(BOOL)arg1 {
    %orig;
    self.contentViewController.canvasController.view.hidden = NO;
}

%end

%hook CSCoverSheetViewController
%property (nonatomic, strong) CBViewController *canvasController;
- (void)viewDidLoad {
	%orig;
	self.canvasController = [[%c(CBViewController) alloc] initWithCanvasServer:[CBInfoTunnel sharedTunnel]];
    self.canvasController.view.contentMode = UIViewContentModeScaleAspectFill;
    [self.view.slideableContentView addSubview:self.canvasController.view];
    [self addChildViewController:self.canvasController];
}
%end

%hook FBProcessManager
- (void)noteProcessDidExit:(FBProcess *)process {
    %orig;
    if ([process.bundleIdentifier isEqualToString:@"com.spotify.client"]) [[CBInfoTunnel sharedTunnel] invalidate];
}
%end