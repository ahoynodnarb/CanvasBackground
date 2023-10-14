#import "SpringBoard.h"

%hook SBMediaController
- (void)_setNowPlayingApplication:(SBApplication *)application {
	%orig;
	if (application && ![application.bundleIdentifier isEqualToString:@"com.spotify.client"]) [[%c(CBInfoTunnel) sharedTunnel] invalidate];
}
%end

%hook SBHomeScreenViewController
%property (nonatomic, strong) CBViewController *canvasController;
- (void)viewDidLoad {
	%orig;
	self.canvasController = [[%c(CBViewController) alloc] initWithCanvasServer:[%c(CBInfoTunnel) sharedTunnel]];
    self.canvasController.view.contentMode = UIViewContentModeScaleAspectFill;
    self.canvasController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:self.canvasController.view atIndex:0];
    [self addChildViewController:self.canvasController];
    [NSLayoutConstraint activateConstraints:@[
        [self.canvasController.view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.canvasController.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.canvasController.view.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
        [self.canvasController.view.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
    ]];
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
	self.canvasController = [[%c(CBViewController) alloc] initWithCanvasServer:[%c(CBInfoTunnel) sharedTunnel]];
    self.canvasController.view.contentMode = UIViewContentModeScaleAspectFill;
    self.canvasController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.panelBackgroundContainerView addSubview:self.canvasController.view];
    [self addChildViewController:self.canvasController];
    [NSLayoutConstraint activateConstraints:@[
        [self.canvasController.view.topAnchor constraintEqualToAnchor:self.panelBackgroundContainerView.topAnchor],
        [self.canvasController.view.bottomAnchor constraintEqualToAnchor:self.panelBackgroundContainerView.bottomAnchor],
        [self.canvasController.view.leftAnchor constraintEqualToAnchor:self.panelBackgroundContainerView.leftAnchor],
        [self.canvasController.view.rightAnchor constraintEqualToAnchor:self.panelBackgroundContainerView.rightAnchor],
    ]];
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
	self.canvasController = [[%c(CBViewController) alloc] initWithCanvasServer:[%c(CBInfoTunnel) sharedTunnel]];
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

%hook FBProcessManager
- (void)noteProcessDidExit:(FBProcess *)process {
    %orig;
    if ([process.bundleIdentifier isEqualToString:@"com.spotify.client"]) [[%c(CBInfoTunnel) sharedTunnel] invalidate];
}
%end