#import "SpringBoard.h"

%hook SpringBoard
-(void)noteInterfaceOrientationChanged:(long long)arg1 duration:(double)arg2 logMessage:(id)arg3 {
	%orig;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"resizeCanvas" object:nil];
}
%end


%hook SBMediaController
-(void)_setNowPlayingApplication:(id)arg1 {
	%orig;
	if(!arg1) [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client"];
    else [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"sendNotification" object:@"com.spotify.client"];
}
%end

%hook SBHomeScreenViewController
-(void)viewDidLoad {
	%orig;
	homescreenController = [[CBViewController alloc] init];
	homescreenController.view = [[UIView alloc] initWithFrame:[self.view bounds]];
	[self.view insertSubview:homescreenController.view atIndex:0];
	[homescreenController viewDidLoad];
}
%end
%hook CSCoverSheetViewController
-(void)viewDidLoad {
	%orig;
	lockscreenController = [[CBViewController alloc] init];
	lockscreenController.view = [[UIView alloc] initWithFrame:[self.view bounds]];
	[self.view insertSubview:lockscreenController.view atIndex:0];
	[lockscreenController viewDidLoad];
}
%end