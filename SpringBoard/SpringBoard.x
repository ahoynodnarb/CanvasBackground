#import "SpringBoard.h"

%hook SBMediaController
%property (nonatomic, readonly) NSString *nowPlayingBundleID;
%new
- (NSString *)nowPlayingBundleID {
    return [self.nowPlayingApplication bundleIdentifier];
}
- (void)_setNowPlayingApplication:(SBApplication *)application {
	%orig;
    CBInfoForwarder *forwarder = [%c(CBInfoForwarder) sharedForwarder];
    if (![forwarder bundleRegistered:self.nowPlayingBundleID] && !application) [forwarder invalidate];
}
%end

%group Home
%hook SBHomeScreenViewController
%property (nonatomic, strong) CBViewController *canvasController;
- (void)viewDidLoad {
	%orig;
	self.canvasController = [[%c(CBViewController) alloc] initWithInfoForwarder:[%c(CBInfoForwarder) sharedForwarder]];
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
    self.canvasController.shouldSuspend = hidden;
}
%end
%end

%group Lock
%hook SBCoverSheetPrimarySlidingViewController
%property (nonatomic, strong) CBViewController *canvasController;
- (void)viewDidLoad {
	%orig;
	self.canvasController = [[%c(CBViewController) alloc] initWithInfoForwarder:[%c(CBInfoForwarder) sharedForwarder]];
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

- (void)_beginTransitionFromAppeared:(BOOL)appeared {
    %orig;
    if (!appeared) {
        self.contentViewController.canvasController.shouldSuspend = NO;
    }
    self.canvasController.shouldSuspend = NO;
    self.contentViewController.canvasController.view.hidden = YES;
}

- (void)_endTransitionToAppeared:(BOOL)appeared {
    %orig;
    if (!appeared) {
        self.contentViewController.canvasController.shouldSuspend = YES;
    }
    self.canvasController.shouldSuspend = YES;
    self.contentViewController.canvasController.view.hidden = NO;
}

%end

%hook CSCoverSheetViewController
%property (nonatomic, strong) CBViewController *canvasController;
- (void)viewDidLoad {
	%orig;
	self.canvasController = [[%c(CBViewController) alloc] initWithInfoForwarder:[%c(CBInfoForwarder) sharedForwarder]];
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
%end

%hook SBBacklightController
- (void)setBacklightFactorPending:(float)backlightFactor  {
    %orig;
    BOOL screenOff = backlightFactor == 0.0f;
    [[CBInfoForwarder sharedForwarder] setSuspended:screenOff];
}
%end

%ctor {
    NSDictionary *bundleDefaults = [[NSUserDefaults standardUserDefaults]persistentDomainForName:@"com.popsicletreehouse.canvasbackgroundprefs"];
    BOOL lockEnabled = [bundleDefaults objectForKey:@"lockEnabled"] ? [[bundleDefaults objectForKey:@"lockEnabled"] boolValue] : YES;
    BOOL homeEnabled = [bundleDefaults objectForKey:@"homeEnabled"] ? [[bundleDefaults objectForKey:@"homeEnabled"] boolValue] : YES;
    if (lockEnabled) %init(Lock);
    if (homeEnabled) %init(Home);
    %init(_ungrouped);
}