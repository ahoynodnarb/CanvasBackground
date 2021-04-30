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
	// AVQueuePlayer *canvasPlayer = [note userInfo][@"player"];
	// AVPlayerLayer *canvasLayer = [note userInfo][@"layer"];
	NSLog(@"canvasbackground callback called");
	AVPlayer *canvasPlayer = [AVPlayer playerWithURL:[[note userInfo] objectForKey:@"URL"]];
	AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.player = canvasPlayer;
    playerViewController.player.volume = 0;
    playerViewController.view.frame = self.view.bounds;
    [self.view addSubview:playerViewController.view];
    [canvasPlayer play];
    // canvasPlayer.volume = 0.0;
	// [canvasPlayer setPreventsDisplaySleepDuringVideoPlayback:NO];
	// [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];

    // [canvasLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    // [canvasLayer setFrame:[[[self view] layer] bounds]];
    // [[[self view] layer] insertSublayer:canvasLayer atIndex:0];
	// [canvasPlayer play];
}
-(void)viewWillAppear:(BOOL)arg1 {
// -(id)initWithNibName:(id)arg1 bundle:(id)arg2 {
	%orig;
	NSLog(@"canvasbackground CSCoverSheetViewController");
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(setCanvas:) name:@"canvasUpdated" object:nil];
	// [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"testNotification" object:nil];
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
%new
-(void)test {
	NSLog(@"canvasbackground beginning background task");
	CFRunLoopStop(CFRunLoopGetCurrent());
	// for(int i = 0; i < 20; i++) {
	// 	sleep(2);
	// 	NSLog(@"canvasbackground test called");
	// 	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	// 	// [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(test) name:@"testNotification" object:nil];
	// 	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"canvasUpdated" object:nil userInfo:@{@"URL": canvasURL}];
	// }
}
-(void)didMoveToWindow {
	%orig;
	NSLog(@"canvasbackground layoutSubviews called");
	AVAsset *videoAsset = self.player.currentItem.asset;
	NSURL *canvasURL = [(AVURLAsset *)videoAsset URL];
	if(self.player && canvasURL) {
		[self performSelectorInBackground:@selector(test) withObject:nil];
		[[NSRunLoop currentRunLoop] run];
	}
}
%end

#pragma clang diagnostic pop