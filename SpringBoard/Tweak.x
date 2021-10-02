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

%hook SBHomeScreenViewController
-(void)loadView {
	%orig;
	homescreenController = [[CBViewController alloc] init];
	if(!homescreenController.view) homescreenController.view = [[UIView alloc] initWithFrame:[[self view] bounds]];
    [[self view] insertSubview:[homescreenController view] atIndex:0];
    homescreenController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [homescreenController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [homescreenController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [homescreenController.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [homescreenController.view.heightAnchor constraintEqualToConstant:homescreenController.view.frame.size.height].active = YES;
    homescreenController.bufferingView.translatesAutoresizingMaskIntoConstraints = NO;
    [homescreenController.bufferingView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [homescreenController.bufferingView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [homescreenController.bufferingView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [homescreenController.bufferingView.heightAnchor constraintEqualToConstant:homescreenController.bufferingView.frame.size.height].active = YES;
}
%end
%hook CSFixedFooterViewController
-(void)loadView {
    %orig;
    lockscreenController = [[CBViewController alloc] init];
	if(!lockscreenController.view) lockscreenController.view = [[UIView alloc] initWithFrame:[[self view] bounds]];
    [[self view] addSubview:[lockscreenController view]];
    [[self view] bringSubviewToFront:[lockscreenController view]];
    lockscreenController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [lockscreenController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [lockscreenController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [lockscreenController.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [lockscreenController.view.heightAnchor constraintEqualToConstant:lockscreenController.view.frame.size.height].active = YES;
    lockscreenController.bufferingView.translatesAutoresizingMaskIntoConstraints = NO;
    [lockscreenController.bufferingView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [lockscreenController.bufferingView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [lockscreenController.bufferingView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [lockscreenController.bufferingView.heightAnchor constraintEqualToConstant:lockscreenController.view.frame.size.height].active = YES;
}
%end