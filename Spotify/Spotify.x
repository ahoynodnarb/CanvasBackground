#import "Spotify.h"

SPTPlayerTrack *previousTrack;

%hook SPTNowPlayingModel
%property (nonatomic, strong) MRYIPCCenter *center;
%property (nonatomic, strong) SPTGLUEImageLoader *imageLoader;
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
- (void)sendUpdateWithTrack:(SPTPlayerTrack *)track {
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

- (void)player:(id)player didMoveToRelativeTrack:(id)track {
    %orig;
    [self sendUpdateWithTrack:self.currentTrack];
}

- (void)playerDidUpdatePlaybackControls:(SPTStatefulPlayerImplementation *)arg1 {
    %orig;
    [self.center callExternalVoidMethod:@selector(setPlaying:) withArguments:@(!arg1.isPaused)];
}
- (id)initWithPlayer:(id)arg0 collectionPlatform:(id)arg1 playlistDataLoader:(id)arg2 radioPlaybackService:(id)arg3 adsManager:(id)arg4 productState:(id)arg5 testManager:(id)arg6 collectionTestManager:(id)arg7 statefulPlayer:(id)arg8 yourEpisodesSaveManager:(id)arg9 educationEligibility:(id)arg10 reinventFreeConfiguration:(id)arg11 curationPlatform:(id)arg12 smartShuffleHandler:(id)arg13 {
    self.center = [%c(MRYIPCCenter) centerNamed:@"CanvasBackground.CanvasServer"];
    self.imageLoader = [[GLUEService provideImageLoaderFactory] createImageLoaderForSourceIdentifier:@"com.popsicletreehouse.CanvasBackground"];
    return %orig;
}
%end

// %hook SPTImageLoaderService
// - (id)createImageLoaderFactory:(id)arg0 username:(id)arg1 {
//     NSLog(@"canvasBackground %@ %@ %@", NSStringFromSelector(_cmd), arg0, arg1);
//     return %orig;
// }
// %end

%hook SPTGLUEServiceImplementation
// -(void)_injectDependenciesWithProvider:(id)arg0 {
//     %orig;
//     NSLog(@"canvasBackground %@ %@", NSStringFromSelector(_cmd), [self provideImageLoaderFactory]);
// }
// -(id)imageLoadingService_propertyWrapper {
//     NSLog(@"canvasBackground %@ %@", NSStringFromSelector(_cmd), [self provideImageLoaderFactory]);
//     return %orig;
// }
// -(id)imageLoadingService {
//     NSLog(@"canvasBackground %@ %@", NSStringFromSelector(_cmd), [self provideImageLoaderFactory]);
//     return %orig;
// }
-(void)load {
    %orig;
    GLUEService = self;
}
// -(void)loadStyling {
//     %orig;
//     NSLog(@"canvasBackground %@ %@", NSStringFromSelector(_cmd), [self provideImageLoaderFactory]);
// }
// - (id)init {
//     NSLog(@"canvasBackground %@ %@", NSStringFromSelector(_cmd), [self provideImageLoaderFactory]);
//     return %orig;
// }
%end