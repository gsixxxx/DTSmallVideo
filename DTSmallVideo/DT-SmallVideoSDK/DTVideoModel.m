//
//  VideoModel.m
//  DTSmallVideo
//
//  Created by quan cui on 2016/12/15.
//  Copyright © 2016年 quan cui. All rights reserved.
//

#import "DTVideoModel.h"

#import <CommonCrypto/CommonDigest.h>

@implementation VideoPartModel

@end

@implementation DTVideoModel
- (instancetype)init{
    if(self == [super init]){
        // video Default Setting Configuration
        _videoSize = CGSizeMake(640, 640);
        _localFileDirectory = [self createLocalDirectory];
        _videoName = [self createVideoName];
        _videoExportUrl = [self createCombinedVideoExportUrl];
        _videoTempFileUrl = [self createCombinedVideoTempFileUrl:_videoName];
        _minRecordTime = 3.0f;
        _maxRecordTime = 8.0f;
        _videoParts = [[NSMutableArray alloc]init];
        _duration = kCMTimeZero;
        [self appendNewPartVideoModel];
    }
    return self;
}
- (void)appendNewPartVideoModel{
    VideoPartModel *newPart = [[VideoPartModel alloc]init];
    NSString *partName = [self createPartVideoName];
    newPart.partName = partName;
    newPart.partTempFileUrl = [self createPartVideoTempFileUrl:partName];
    [_videoParts addObject:newPart];
}
- (void)deleteLastVideoPart{
    if(_videoParts.count > 0){
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:[_videoParts lastObject].partTempFileUrl.absoluteString]){
            NSError *error = nil;
            [fileManager removeItemAtPath:[_videoParts lastObject].partTempFileUrl.absoluteString error:&error];
            if(error){
                NSLog(@"deletePartVideoFailed:%@",error);
            }else{
                NSLog(@"deletePartVideoSuccess");
            }
        }
        if([_videoParts lastObject].partDuration.timescale != 0){
            CGFloat deletedTimeSec = CMTimeGetSeconds([_videoParts lastObject].partDuration);
            CGFloat currentTotalSec = CMTimeGetSeconds(_duration);
            _duration = CMTimeMakeWithSeconds(currentTotalSec - deletedTimeSec, _duration.timescale);
        }
        [_videoParts removeLastObject];
    }
}

- (void)deleteAllVideoPart{
    
    //delete All Video Parts
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for(VideoPartModel *partModel in _videoParts){
        if([fileManager fileExistsAtPath:partModel.partTempFileUrl.absoluteString]){
            NSError *error = nil;
            [fileManager removeItemAtPath:partModel.partTempFileUrl.absoluteString error:&error];
            if(error){
                NSLog(@"deletePartVideoFailed:%@",error);
            }else{
                NSLog(@"deletePartVideoSuccess");
            }
        }
    }
    [_videoParts removeAllObjects];
    
    //delete Combined Video if Exist
    if([fileManager fileExistsAtPath:_videoExportUrl.absoluteString]){
        NSError *error = nil;
        [fileManager removeItemAtPath:_videoExportUrl.absoluteString error:&error];
        if(error){
            NSLog(@"deleteCombinedVideoFailed:%@",error);
        }else{
            NSLog(@"deleteCombinedVideoSuccess");
        }
    }
    
    _duration = kCMTimeZero;
}
- (void)resetVideoParts{
    [self deleteAllVideoPart];
    _videoName = [self createVideoName];
    _videoExportUrl = [self createCombinedVideoExportUrl];
    _videoTempFileUrl = [self createCombinedVideoTempFileUrl:_videoName];
}
- (void)deleteTempVideoFile{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:self.videoTempFileUrl.absoluteString]){
        NSError *error = nil;
        [fileManager removeItemAtPath:self.videoTempFileUrl.absoluteString error:&error];
        if(error){
            NSLog(@"deletePartVideoFailed:%@",error);
        }else{
            NSLog(@"deletePartVideoSuccess");
        }
    }
}
- (NSURL *)currentVideoPartTempFileUrl{
    return _videoParts.lastObject.partTempFileUrl;
}
-(NSString *)createLocalDirectory{
    
    static NSString *_baseDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) firstObject];
        _baseDirectory = [documentPath stringByAppendingPathComponent:@"DTSmallVideo"];
    });
    NSString *videoDirectory  = _baseDirectory;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:videoDirectory]){
        NSError *error = nil;
        [fileManager createDirectoryAtPath:videoDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if(error){
            NSLog(@"Directory Creation Failed:%@",error);
        }else{
            NSLog(@"Directory Createon Sucess");
        }
    }else{
//        NSLog(@"DirecotoryExists");
    }
    return videoDirectory;
}
- (NSString *)createPartVideoName{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd_HH:mm:ss:SSS";
    NSString *partVideoName = [dateFormatter stringFromDate:currentDate];
    return [self md5:partVideoName];
}
- (NSURL *)createPartVideoTempFileUrl:(NSString *)partName{
    NSString *videoFileUrlStr = [_localFileDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.MOV",partName]];
    NSURL *videoUrl = [NSURL fileURLWithPath:videoFileUrlStr];
    return videoUrl;
}
- (NSString *)createVideoName{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd_HH:mm:ss";
    NSString *videoName = [dateFormatter stringFromDate:currentDate];
    return videoName;
}

- (NSURL *)createCombinedVideoTempFileUrl:(NSString *)partName{
    NSString *videoFileUrlStr = [_localFileDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.MOV",partName]];
    NSURL *videoUrl = [NSURL fileURLWithPath:videoFileUrlStr];
    return videoUrl;
}

- (NSURL *)createCombinedVideoExportUrl{
    NSString *videoFileUrlStr = [_localFileDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.MP4",_videoName]];
    NSURL *videoUrl = [NSURL fileURLWithPath:videoFileUrlStr];
    return videoUrl;
}
- (void)combineVideosToSandBoxWithCompleteHandler:(combineVideoCompleteHandler)completeHandler{
    self.combineCompleteHandler = completeHandler;
    if (_videoParts.count == 0) {
        return;
    }
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];

    AVMutableCompositionTrack *combineAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *combineVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTime totalDuration = kCMTimeZero;
    for (int i = 0; i < _videoParts.count; i++) {
        
        AVURLAsset *asset = [AVURLAsset assetWithURL:_videoParts[i].partTempFileUrl];
        NSError *erroraudio = nil;
        AVAssetTrack *assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        BOOL audioInsert = [combineAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                      ofTrack:assetAudioTrack
                                       atTime:totalDuration
                                        error:&erroraudio];
        
        if(!audioInsert){
            NSLog(@"audio Insert Failed");
        }
        NSError *errorVideo = nil;
        
        AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
        BOOL videoInsert = [combineVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                                      ofTrack:assetVideoTrack
                                                       atTime:totalDuration
                                                        error:&errorVideo];
        if(!videoInsert){
            NSLog(@"video Insert Failed");
        }
        if(videoInsert && audioInsert){
            totalDuration = CMTimeAdd(totalDuration, asset.duration);
        }else{
            [combineAudioTrack removeTimeRange:CMTimeRangeMake(totalDuration, asset.duration)];
            [combineVideoTrack removeTimeRange:CMTimeRangeMake(totalDuration, asset.duration)];
        }

    }
    AVMutableVideoCompositionLayerInstruction *layerIns = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:combineVideoTrack];

    CGAffineTransform rotation = CGAffineTransformConcat(CGAffineTransformMakeRotation(M_PI_2), CGAffineTransformMakeTranslation(_videoSize.width, 0));
    [layerIns setTransform:CGAffineTransformConcat(combineAudioTrack.preferredTransform,rotation) atTime:kCMTimeZero];
    
    AVMutableVideoCompositionInstruction *videoCompositionIns = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    videoCompositionIns.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
    videoCompositionIns.layerInstructions = [NSArray arrayWithObject:layerIns];
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.instructions =[NSArray arrayWithObject:videoCompositionIns];
    videoComposition.renderSize = _videoSize;
    videoComposition.frameDuration = CMTimeMake(1, 30);

    
    NSURL *mergeFileURL = self.videoTempFileUrl;
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPreset640x480];
    exporter.outputURL = mergeFileURL;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = videoComposition;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        [self convertVideoToMP4WithURL:self.videoTempFileUrl];
    }];

}
- (void)convertVideoToMP4WithURL:(NSURL *)fileUrl{
    __block NSURL *outputFileURL = fileUrl;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:outputFileURL options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality])
        
    {
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetPassthrough];
        exportSession.outputURL = self.videoExportUrl;
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"convert To MP4 Fialed: %@", [[exportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"convert To MP4 Canceled");
                    break;
                case AVAssetExportSessionStatusCompleted:
                    NSLog(@"convert To MP4 success");
                    if(self.combineCompleteHandler){
                        self.combineCompleteHandler();
                    }
                    [self deleteAllVideoPart];
                    [self deleteTempVideoFile];
                    break;
                default:
                    break;
            }
        }];
    }
}

-(NSString *)md5:(NSString *)str {
    
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
@end
