#import "SpringBoard.h"

%hook SpringBoard
-(void)noteInterfaceOrientationChanged:(long long)arg1 duration:(double)arg2 logMessage:(id)arg3 {
	%orig;
	NSLog(@"canvasBackground posting notification to resize");
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"resizeCanvas" object:nil];
}
%end

%hook SBMediaController
-(BOOL)isApplicationActivityActive {
	if(!%orig) {
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:@{@"url": @"remove"}];
	}
	return %orig;
}
-(void)_setNowPlayingApplication:(id)arg1 {
	if(!arg1) {
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"recreateCanvas" object:@"com.spotify.client" userInfo:@{@"url": @"remove"}];
	}
	return %orig;
}
%end

%hook SBHomeScreenViewController
-(void)viewDidLoad {
	%orig;
	NSLog(@"canvasBackground SBHomeScreenViewController viewDidLoad called");
	homescreenController = [[CBViewController alloc] init];
	homescreenController.view = [[UIView alloc] initWithFrame:[self.view bounds]];
	// [controller.view setBackgroundColor:[UIColor redColor]]	;
	[self.view insertSubview:homescreenController.view atIndex:0];
	[homescreenController viewDidLoad];
	// [self.view addSubview:controller.view];
}
%end
%hook CSCoverSheetViewController
-(void)viewDidLoad {
	%orig;
	NSLog(@"canvasBackground CSCoverSheetViewController viewDidLoad called");
	lockscreenController = [[CBViewController alloc] init];
	lockscreenController.view = [[UIView alloc] initWithFrame:[self.view bounds]];
	// [controller.view setBackgroundColor:[UIColor redColor]]	;
	[self.view insertSubview:lockscreenController.view atIndex:0];
	[lockscreenController viewDidLoad];
	// [self.view addSubview:controller.view];
}
%end