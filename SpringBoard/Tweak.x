#import "SpringBoard.h"

%hook SBMediaController
-(void)_setNowPlayingApplication:(id)arg1 {
	%orig;
    // removes video from lockscreen when there's no now playing app
    // if there is, it asks spotify to send the notification
	if(!arg1) [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client"];
    else [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"sendNotification" object:@"com.spotify.client"];
}
%end

// %hook SBFStaticWallpaperView
// -(void)layoutSubviews {
//     %orig;
//     [self setClipsToBounds:YES];
//     if(!lockscreenController) {
//         lockscreenController = [[CBViewController alloc] init];
//         if(!lockscreenController.view) lockscreenController.view = [[UIView alloc] initWithFrame:[self bounds]];
//         [self addSubview:[lockscreenController view]];
//         [self bringSubviewToFront:[lockscreenController view]];
//     }
//     else if(!homescreenController) {
//         homescreenController = [[CBViewController alloc] init];
//         if(!homescreenController.view) homescreenController.view = [[UIView alloc] initWithFrame:[self bounds]];
//         [self addSubview:[homescreenController view]];
//         [self bringSubviewToFront:[homescreenController view]];
//     }
// }
// %end

// %hook _SBFakeBlurView
// -(UIView *)initWithVariant:(long long)arg1 wallpaperViewController:(id)arg2 transformOptions:(unsigned long long)arg3 reachabilityCoordinator:(id)arg4 {
//     [%orig setClipsToBounds:YES];
//     if(!homescreenController) {
//         homescreenController = [[CBViewController alloc] init];
//         if(!homescreenController.view) homescreenController.view = [[UIView alloc] initWithFrame:[%orig bounds]];
//         [%orig addSubview:[homescreenController view]];
//         [%orig bringSubviewToFront:[homescreenController view]];
//     }
//     return %orig;
// }
// %end
%hook SBHomeScreenViewController
-(void)loadView {
	%orig;
    [self.view setClipsToBounds:YES];
	homescreenController = [[CBViewController alloc] init];
	if(!homescreenController.view) homescreenController.view = [[UIView alloc] initWithFrame:[[self view] bounds]];
    [[self view] insertSubview:[homescreenController view] atIndex:0];
}
%end

%hook CSFixedFooterViewController
-(void)loadView {
    %orig;
    [self.view setClipsToBounds:YES];
    lockscreenController = [[CBViewController alloc] init];
	if(!lockscreenController.view) lockscreenController.view = [[UIView alloc] initWithFrame:[[self view] bounds]];
    [[self view] addSubview:[lockscreenController view]];
    [[self view] bringSubviewToFront:[lockscreenController view]];
}
%end