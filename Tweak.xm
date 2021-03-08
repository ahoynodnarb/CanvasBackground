//#import <MRYIPCCenter.h>
#import "Spotify.h"
//#import <Foundation/NSKeyedArchiver.h>
// #import <Spotify/SPTCanvasAttributionView.h>

// @implementation CanvasBackgroundServer
// {
//     MRYIPCCenter *_center;
//     NSData *_data;
// }

// + (void)load
// {
//     [self sharedInstance];
// }

// + (instancetype)sharedInstance
// {
//     static dispatch_once_t onceToken = 0;
//     __strong static CanvasBackgroundServer *sharedInstance = nil;
//     dispatch_once(&onceToken, ^{
//       sharedInstance = [[self alloc] init];
//     });
//     return sharedInstance;
// }

// - (instancetype)init
// {
//     if ((self = [super init]))
//     {
//         _center = [MRYIPCCenter centerNamed:@"com.popsicletreehouse.CanvasIPCServer"];
//         [_center addTarget:self action:@selector(getCanvas:)];
//         [_center addTarget:self action:@selector(updateCanvas:)];
//     }
//     return self;
// }
// - (NSData *)getCanvas
// {
//     return _data;
// }
// - (void)updateCanvas:(NSData *)args
// {
//     _data = args;
// }
// @end
// viewDidLoad only gets called on allocation
// REMEMBER TO USE AN IPC DUMBASS
// try getting the property of canvasView instead of calling method
// maybe update everytime CSCoverSheetViewController appears?
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

//static UIView *canvasVideo;
//static MRYIPCCenter *center;
%hook CSCoverSheetViewController
%new
-(void)setCanvas:(NSNotification *)note {
	NSLog(@"spotifycanvas notification selector called");
	//[NSKeyedArchiver setClass:SPTCanvasAttributionView.self forClassName: @"SPTCanvasAttributionView"];
	AVQueuePlayer *canvasPlayer = [NSKeyedUnarchiver unarchiveObjectWithData:[note userInfo][@"player"]];
	AVPlayerLayer *canvasLayer = [NSKeyedUnarchiver unarchiveObjectWithData:[note userInfo][@"layer"]];
	// AVQueuePlayer *canvasPlayer = [note userInfo][@"player"];
	// AVPlayerLayer *canvasLayer = [note userInfo][@"layer"];
    canvasPlayer.volume = 0.0;
	[canvasPlayer setPreventsDisplaySleepDuringVideoPlayback:NO];
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];

	//AVPlayerLooper *playerLooper = [AVPlayerLooper playerLooperWithPlayer:canvasPlayer templateItem:canvasPlayer.items[0]];

    [canvasLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [canvasLayer setFrame:[[[self view] layer] bounds]];
    [[[self view] layer] insertSublayer:canvasLayer atIndex:0];
	[canvasPlayer play];
	// [canvasVideo setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	// [canvasVideo setContentMode:UIViewContentModeScaleAspectFill];
	// [canvasVideo setClipsToBounds:YES];
	// if(![canvasVideo isDescendantOfView:[self view]])
	// 	[[self view] insertSubview:canvasVideo atIndex:0];
	//NSLog(@"spotifycanvas canvasVideo after: %@", canvasVideo);
}
-(void)viewWillAppear:(BOOL)arg1 {
	%orig;
	NSLog(@"spotifycanvas notification listener added");
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(setCanvas:) name:@"canvasUpdated" object:nil];
	// // This next part taken from  https://github.com/schneelittchen/Violet
	// %orig;
	// //NSLog(@"spotifycanvas canvasVideo before: %@", canvasVideo);
	// NSLog(@"spotifycanvas before callExternalMethod");
	// //MRYIPCCenter *center = [MRYIPCCenter centerNamed:@"com.popsicletreehouse.CanvasIPCServer"];
	// //NSData *data = [center callExternalMethod:@selector(getCanvas) withArguments:nil];
	// NSLog(@"spotifycanvas after callExternalMethod");
	// UIView *canvasVideo = [NSKeyedUnarchiver unarchiveObjectWithData: data];
	// // if(!canvasVideo) {
	// // 	NSLog(@"spotifycanvas null");
	// // 	canvasVideo = [[UIView alloc] initWithFrame:[[self view] bounds]];
	// // }
	// [canvasVideo setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	// [canvasVideo setContentMode:UIViewContentModeScaleAspectFill];
	// [canvasVideo setClipsToBounds:YES];
	// if(![canvasVideo isDescendantOfView:[self view]])
	// 	[[self view] insertSubview:canvasVideo atIndex:0];
	// //NSLog(@"spotifycanvas canvasVideo after: %@", canvasVideo);

}
%end

// %hook SPTCanvasNowPlayingContentLayerCellCollectionViewCell
// -(void)setCanvasView:(id)arg1 {
// 	%orig;
// 	//NSLog(@"spotifycanvas before call: %@", canvasVideo);
// 	if(arg1) {
// 		//canvasVideo = arg1;
// 		UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 250)];
// 		//[testView addSubview: canvasVideo];
// 		[[[UIApplication sharedApplication] keyWindow] addSubview:testView];
// 		//NSDictionary *data = @{@"canvas" : [NSKeyedArchiver archivedDataWithRootObject:canvasVideo]};
// 		NSLog(@"canvas changed, %@", arg1);
// 		//[NSKeyedArchiver setClassName:@"SPTCanvasAttributionView" forClass:%c(SPTCanvasAttributionView)];
// 		UIView *encoded = arg1;
// 		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"canvasUpdated" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSKeyedArchiver archivedDataWithRootObject:arg1.] forKey:@"player"]];
// 		//MRYIPCCenter *center = [MRYIPCCenter centerNamed:@"com.popsicletreehouse.CanvasIPCServer"];
// 		//[center callExternalVoidMethod:@selector(updateCanvas:)withArguments:[NSKeyedArchiver archivedDataWithRootObject:arg1]];
// 	}
// 	else
// 		NSLog(@"spotifycanvas canvas null: %@ ", arg1);
// }
// %end
%hook SPTVideoDisplayView
-(void)layoutSubviews {
	UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 250)];
	[[[UIApplication sharedApplication] keyWindow] addSubview:testView];
	//NSLog(@"canvas changed, %@", arg1);
	//UIView *encoded = arg1;
	NSLog(@"spotifycanvas blah");
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"canvasUpdated" object:nil userInfo:@{@"player": [NSKeyedArchiver archivedDataWithRootObject:self.player], @"layer": [NSKeyedArchiver archivedDataWithRootObject:[self playerLayer]]}];
	//[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"canvasUpdated" object:nil userInfo:@{@"player": self.player, @"layer": [self playerLayer]}];
}
%end

// %ctor {
// 	//center = [MRYIPCCenter centerNamed:@"com.popsicletreehouse.CanvasIPCServer"];
// 	[CanvasBackgroundServer sharedInstance];
// }
#pragma clang diagnostic pop