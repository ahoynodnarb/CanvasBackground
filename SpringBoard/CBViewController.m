#import "CBViewController.h"

@implementation CBViewController
static NSCache *_playerCache = nil;
+ (void)setPlayerCache:(NSCache *)cache {
    _playerCache = cache;
}
+ (NSCache *)playerCache {
    return _playerCache;
}
- (void)togglePlayer:(NSNotification *)note {
	BOOL isPlaying = [[note.userInfo objectForKey:@"isPlaying"] boolValue];
	if(isPlaying) [self.canvasPlayer play];
	else [self.canvasPlayer pause];
}
/*
  Called whenever Spotify changes the current song
  This just updates the canvas based on the userInfo
  containing the thumbnail and canvas URL
*/
- (void)recreateCanvasPlayer:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    NSURL *currentVideoURL = [NSURL URLWithString:[userInfo objectForKey:@"currentURL"]];
    NSURL *previousTrackURL = [(AVURLAsset *)self.canvasPlayer.currentItem.asset URL];
    if(currentVideoURL) {
        if(![currentVideoURL isEqual:previousTrackURL]) {
            [self.thumbnailView setHidden:NO];
            [self.canvasPlayer removeAllItems];
            NSString *currentVideoKey = [currentVideoURL lastPathComponent];
            NSString *currentThumbnailKey = [currentVideoKey stringByAppendingString:@"thumbnail"];
            AVPlayerItem *currentItem;
            UIImage *firstFrame;
            if(![CBViewController.playerCache objectForKey:currentVideoKey]) {
                currentItem = [AVPlayerItem playerItemWithURL:currentVideoURL];
                [CBViewController.playerCache setObject:currentItem forKey:currentVideoKey];
            }
            else currentItem = [CBViewController.playerCache objectForKey:currentVideoKey];
            if(![CBViewController.playerCache objectForKey:currentThumbnailKey]) {
                AVURLAsset *asset = [AVURLAsset URLAssetWithURL:currentVideoURL options:nil];
                AVAssetImageGenerator* imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
                firstFrame = [UIImage imageWithCGImage:[imageGenerator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:nil error:nil]];
                NSLog(@"canvasBackground firstFrame: %@ %@ %@", asset, imageGenerator, firstFrame);
                [CBViewController.playerCache setObject:firstFrame forKey:currentThumbnailKey];
            }
            else firstFrame = [CBViewController.playerCache objectForKey:currentThumbnailKey];
            [self.thumbnailView setImage:firstFrame];
            [self.canvasPlayer play];
            self.canvasPlayerLooper = [AVPlayerLooper playerLooperWithPlayer:self.canvasPlayer templateItem:currentItem];
        }
	}
	else {
        [self.thumbnailView setHidden:NO];
        NSData *currentImageData = [userInfo objectForKey:@"artwork"];
        UIImage *image = [UIImage imageWithData:currentImageData];
        image = [UIImage imageWithCGImage:[image CGImage] scale:2.0f orientation:UIImageOrientationUp];
        [self.thumbnailView setImage:image];
		[self.canvasPlayer removeAllItems];
	}
}
/*
  We need to do this to prevent thumbnailView
  from appearing under the canvas, wasting power
*/
- (void)observeValueForKeyPath:(NSString *)path ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(self.canvasPlayer.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
        [self.thumbnailView setImage:nil];
        [self.thumbnailView setHidden:YES];
    }
}
- (void)viewDidLoad {
	[super viewDidLoad];
    if(!CBViewController.playerCache) CBViewController.playerCache = [[NSCache alloc] init];
	self.thumbnailView = [[UIImageView alloc] initWithFrame:self.view.frame];
	self.canvasPlayer = [[AVQueuePlayer alloc] init];
	self.canvasPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.canvasPlayer];
	[self.thumbnailView setContentMode:UIViewContentModeScaleAspectFill];
	[self.thumbnailView setHidden:YES];
	[self.canvasPlayer setVolume:0];
	[self.canvasPlayer setPreventsDisplaySleepDuringVideoPlayback:NO];
    [self.canvasPlayer addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];
	[self.canvasPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	[self.canvasPlayerLayer setFrame:self.view.bounds];
	[self.canvasPlayerLayer setHidden:YES];
	[self.view.layer insertSublayer:self.canvasPlayerLayer atIndex:0];
	[self.view.layer setSecurityMode:@"secure"];
	[self.view insertSubview:self.thumbnailView atIndex:0];
    [self.view setClipsToBounds:YES];
    [self.view setContentMode:UIViewContentModeScaleAspectFill];
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(recreateCanvasPlayer:) name:@"recreateCanvas" object:@"com.spotify.client"];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(togglePlayer:) name:@"togglePlayer" object:@"com.spotify.client"];
}
/*
  Called whenever screen changes rotation
  we need to do this since ios doesn't
  automatically resize UIViews
*/
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.view setFrame:self.view.superview.bounds];
    [self.thumbnailView setFrame:self.view.superview.bounds];
    [self.canvasPlayerLayer setFrame:self.view.bounds];
}
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.canvasPlayerLayer setHidden:NO];
	[self.canvasPlayer play];
}
@end