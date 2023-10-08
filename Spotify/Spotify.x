#import "Spotify.h"

SPTPlayerTrack *previousTrack;

%hook SPTNowPlayingModel
%property (nonatomic, strong) MRYIPCCenter *center;
// %property (nonatomic, strong) SPTGLUEImageLoader *imageLoader;
%new
+ (NSURL *)localURLForCanvas:(NSURL *)canvasURL {
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [[canvasURL.path stringByReplacingOccurrencesOfString:@"/" withString:@"-"] substringFromIndex:1];
    NSString *filePath = [NSString stringWithFormat:@"%@/Caches/Canvases/%@",libraryPath,fileName];
    return [NSURL fileURLWithPath:filePath];
}

%new
- (void)loadImageForTrack:(SPTPlayerTrack *)track completion:(void (^)(UIImage *, NSError *))completion {
    [self.imageLoader loadImageForURL:track.imageURL imageSize:CGSizeMake(640, 640) completion:^(UIImage *image, NSError *error) {
        completion(image, error);
    }];
}

%new
- (void)sendTrackImage:(SPTPlayerTrack *)track {
    [self loadImageForTrack:track completion:^(UIImage *image, NSError *error){
        if (!image) return;
        NSData *imageData = UIImagePNGRepresentation(image);
        [self.center callExternalVoidMethod:@selector(updateWithImageData:) withArguments:imageData];
    }];
}

%new
- (NSDictionary *)requestCanvasInfo {
    NSURL *originalURL = [NSURL URLWithString:track.metadata[@"canvas.url"]];
    if (!originalURL) {
        [self sendTrackImage:track];
        return;
    }
    NSURL *fileURL = [%c(SPTNowPlayingModel) localURLForCanvas:originalURL];
    NSURL *URL = [[NSFileManager defaultManager] fileExistsAtPath:fileURL.path] ? fileURL : originalURL;
    BOOL canvasStatic = [track.metadata[@"canvas.type"] isEqualToString:@"IMAGE"];
    if (canvasStatic) {
        NSData *imageData = [NSData dataWithContentsOfURL:URL];
        if (imageData) [self.center callExternalVoidMethod:@selector(updateWithImageData:) withArguments:imageData];
        else [self sendTrackImage:track];
    }
    else {
        [self loadImageForTrack:track completion:^(UIImage *image, NSError *error){
            NSDictionary *userInfo = @{@"url": URL.absoluteString, @"fallback": UIImagePNGRepresentation(image)};
            [self.center callExternalVoidMethod:@selector(updateWithVideoInfo:) withArguments:userInfo];
        }];
    }
}

// - (void)player:(id)player didMoveToRelativeTrack:(id)track {
//     %orig;
//     [self sendUpdateWithTrack:self.currentTrack];
// }

// - (void)playerDidUpdatePlaybackControls:(SPTStatefulPlayerImplementation *)arg1 {
//     %orig;
//     [self.center callExternalVoidMethod:@selector(setPlaying:) withArguments:@(!arg1.isPaused)];
// }

// %new
// - (NSDictionary *)requestCanvasInfo {
//     NSURL *originalURL = [NSURL URLWithString:self.currentTrack.metadata[@"canvas.url"]];
//     if (!originalURL) {
//         return @{};
//     }
//     NSURL *fileURL = [%c(SPTNowPlayingModel) localURLForCanvas:originalURL];
//     NSURL *URL = [[NSFileManager defaultManager] fileExistsAtPath:fileURL.path] ? fileURL : originalURL;
//     BOOL canvasStatic = [self.currentTrack.metadata[@"canvas.type"] isEqualToString:@"IMAGE"];
//     if (canvasStatic) {
//         NSData *imageData = [NSData dataWithContentsOfURL:URL];
//         if (imageData) {
//             return @{@"canvas-image-data": imageData};
//         }
//         return @{};
//     }
//     return @{@"canvas-url": URL.absoluteString};
// }

- (id)initWithPlayer:(id)arg1 collectionPlatform:(id)arg2 playlistDataLoader:(id)arg3 radioPlaybackService:(id)arg4 adsManager:(id)arg5 productState:(id)arg6 queueService:(SPTQueueServiceImplementation *)queueService  testManager:(id)arg8 collectionTestManager:(id)arg9 statefulPlayer:(id)arg10 yourEpisodesSaveManager:(id)arg11 educationEligibility:(id)arg12 reinventFreeConfiguration:(id)arg13 curationPlatform:(id)arg14 smartShuffleHandler:(id)arg15 {
    self.center = [%c(MRYIPCCenter) centerNamed:@"CanvasBackground.CanvasServer"];
    [self.center addTarget:self action:@selector(requestCanvasInfo)];
    return %orig;
}
%end