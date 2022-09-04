#import "SpringBoard.h"

%hook SBMediaController
- (void)_setNowPlayingApplication:(SBApplication *)application {
	%orig;
    // removes video from lockscreen when there's no now playing app
    // if there is, it asks spotify to send the notification
	if(![application.bundleIdentifier isEqualToString:@"com.spotify.client"]) [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client"];
    else if(application) [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"sendNotification" object:@"com.spotify.client"];
}
%end

%hook SBHomeScreenViewController
- (void)loadView {
	%orig;
    self.view.clipsToBounds = YES;
	homescreenController = [[CBViewController alloc] init];
	if(!homescreenController.view) homescreenController.view = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:homescreenController.view atIndex:0];
}
-(void)setIconControllerHidden:(BOOL)arg1 {
    %orig;
    if(arg1) [homescreenController viewDidDisappear:NO];
    else [homescreenController viewWillAppear:NO];
}
%end

%hook CSFixedFooterViewController
- (void)loadView {
    %orig;
    self.view.clipsToBounds = YES;
    lockscreenController = [[CBViewController alloc] init];
	if(!lockscreenController.view) lockscreenController.view = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:lockscreenController.view];
    [self addChildViewController:lockscreenController];
}
%end