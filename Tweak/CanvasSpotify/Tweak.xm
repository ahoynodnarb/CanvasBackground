#import <MRYIPCCenter.h>
#import <UIKit/UIKit.h>
#import "Spotify.h"

// viewDidLoad only gets called on allocation
//REMEMBER TO USE AN IPC DUMBASS
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

static UIView *canvasVideo;
static MRYIPCCenter *center;
%hook CSCoverSheetViewController
-(void)viewWillAppear:(BOOL)arg1 {
	// This next part taken from  https://github.com/schneelittchen/Violet
	%orig;
	NSLog(@"spotifycanvas canvasVideo before: %@", canvasVideo);
	NSArray *data = [center callExternalMethod:@selector(getCanvas) withArguments:nil];
	canvasVideo = [NSKeyedUnarchiver unarchiveObjectWithData: data[0]];
	if(!canvasVideo)
		canvasVideo = [[UIView alloc] initWithFrame:[[self view] bounds]];
	[canvasVideo setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[canvasVideo setContentMode:UIViewContentModeScaleAspectFill];
	[canvasVideo setClipsToBounds:YES];
	if(![canvasVideo isDescendantOfView:[self view]])
		[[self view] insertSubview:canvasVideo atIndex:0];
	NSLog(@"spotifycanvas canvasVideo after: %@", canvasVideo);

}
%end
%hook SPTCanvasNowPlayingContentLayerCellCollectionViewCell
-(void)setCanvasView:(id)arg1 {
	//keep spotify canvas in memory so that it changes the ls
	//as soon as this ends, it gets rid of arg1
	//pass canvasVideo as value, rather than reference
	%orig;
	NSLog(@"spotifycanvas before call: %@", canvasVideo);
	if(arg1) {
		canvasVideo = arg1;
		UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 250)];
		[testView addSubview: canvasVideo];
		[[[UIApplication sharedApplication] keyWindow] addSubview:testView];
		//NSDictionary *data = @{@"canvas" : [NSKeyedArchiver archivedDataWithRootObject:canvasVideo]};
		[center callExternalVoidMethod:@selector(updateCanvas:)withArguments:canvasVideo];
		NSLog(@"spotifycanvas after call: %@", canvasVideo);
	}
	else
		NSLog(@"spotifycanvas canvas null: %@ ", arg1);
}
%end

%ctor {
	center = [MRYIPCCenter centerNamed:@"com.popsicletreehouse.CanvasIPCServer"];
}
#pragma clang diagnostic pop