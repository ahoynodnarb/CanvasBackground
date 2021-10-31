#import "SpringBoard.h"

%hook SBMediaController
- (void)_setNowPlayingApplication:(id)arg1 {
	%orig;
    // removes video from lockscreen when there's no now playing app
    // if there is, it asks spotify to send the notification
	if(!arg1) [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client"];
    else [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"sendNotification" object:@"com.spotify.client"];
}
%end
%hook SBHomeScreenViewController
- (void)loadView {
	%orig;
    [self.view setClipsToBounds:YES];
	homescreenController = [[CBViewController alloc] init];
	if(!homescreenController.view) homescreenController.view = [[UIView alloc] initWithFrame:[[self view] bounds]];
    [[self view] insertSubview:[homescreenController view] atIndex:0];
}
%end

%hook CSFixedFooterViewController
- (void)loadView {
    %orig;
    [self.view setClipsToBounds:YES];
    lockscreenController = [[CBViewController alloc] init];
	if(!lockscreenController.view) lockscreenController.view = [[UIView alloc] initWithFrame:[[self view] bounds]];
    [[self view] addSubview:[lockscreenController view]];
    [[self view] bringSubviewToFront:[lockscreenController view]];
}
%end