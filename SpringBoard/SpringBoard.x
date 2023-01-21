#import "SpringBoard.h"

%hook SBMediaController
- (void)_setNowPlayingApplication:(SBApplication *)application {
	%orig;
	if (![application.bundleIdentifier isEqualToString:@"com.spotify.client"]) {
        [lockscreenController invalidate];
        [homescreenController invalidate];
    }
}
%end

%hook SBHomeScreenViewController
- (void)loadView {
	%orig;
    self.view.clipsToBounds = YES;
	homescreenController = [[%c(CBViewController) alloc] initWithCanvasServer:[CBInfoTunnel sharedTunnel]];
	if (!homescreenController.view) homescreenController.view = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:homescreenController.view atIndex:0];
}

- (void)setIconControllerHidden:(BOOL)arg1 {
    %orig;
    if (arg1) [homescreenController viewDidDisappear:NO];
    else [homescreenController viewWillAppear:NO];
}
%end

%hook CSFixedFooterViewController
- (void)loadView {
    %orig;
    self.view.clipsToBounds = YES;
    lockscreenController = [[%c(CBViewController) alloc] initWithCanvasServer:[CBInfoTunnel sharedTunnel]];
	if (!lockscreenController.view) lockscreenController.view = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:lockscreenController.view];
    [self addChildViewController:lockscreenController];
}
%end