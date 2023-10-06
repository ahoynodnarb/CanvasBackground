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