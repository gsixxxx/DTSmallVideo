//
//  RecordView.m
//  DTSmallVideo
//
//  Created by quan cui on 2016/12/15.
//  Copyright © 2016年 quan cui. All rights reserved.
//

#import "DTRecordView.h"
#import <MediaPlayer/MediaPlayer.h>

@interface DTRecordView()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>
@property (nonatomic, strong) MPMoviePlayerController *videoPlayer;

@end
@implementation DTRecordView{
    //captureInput
    AVCaptureSession *_cameraSession;
    AVCaptureVideoPreviewLayer *_videoPreViewLayer;
    AVCaptureDevice *_cameraDevice;
    AVCaptureVideoDataOutput *_videoDataOutPut;
    AVCaptureAudioDataOutput *_audioDataOutPut;
    //writerOutPut
    AVAssetWriter *_assetWriter;
    AVAssetWriterInputPixelBufferAdaptor *_assetWriterPixelBufferInput;
    AVAssetWriterInput *_assetWriterVideoInput;
    AVAssetWriterInput *_assetWriterAudioInput;
    
    CMTime _currentSampleTime;
    CMTime _startRecordTime;
    CMTime _previousFrameTime;
    
    dispatch_queue_t _videoRecordQueue;
    BOOL _isRecording;
    NSError *_assetWriterError;
    RecordProgressView *_progressView;
    
    NSArray *_devicesVideo;
    AVCaptureDeviceInput *_videoInput;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if(self  == [super initWithFrame:frame]){
        //setUp Video Configuration
        _videoModel = [[DTVideoModel alloc]init];
        CGFloat ratio = self.frame.size.width/self.frame.size.height;
        _videoModel.videoSize = CGSizeMake(640, 640/ratio);
        _videoModel.minRecordTime = 2;
        _videoModel.maxRecordTime = 10;
        
        _torchType = DTTorchClose;
        [self setupCameraSession];
        [self setUpProgressView];
        self.recordState = DTRecordStateInit;
    }
    return self;
}
- (void)setupCameraSession{
    NSString *unUseInfo = nil;
    if (TARGET_IPHONE_SIMULATOR) {
        unUseInfo = @"simulator prehibited";
    }
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(videoAuthStatus == ALAuthorizationStatusRestricted || videoAuthStatus == ALAuthorizationStatusDenied){
        unUseInfo = @"pricacy denied";
    }
    AVAuthorizationStatus audioAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if(audioAuthStatus == ALAuthorizationStatusRestricted || audioAuthStatus == ALAuthorizationStatusDenied){
        unUseInfo = @"pricacy denied";
    }

    _videoRecordQueue = dispatch_queue_create("com.DreamTreeTech", DISPATCH_QUEUE_SERIAL);
    
    _devicesVideo = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    NSArray *devicesAudio = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    _videoInput = [AVCaptureDeviceInput deviceInputWithDevice:_devicesVideo[0] error:nil];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:devicesAudio[0] error:nil];
    
    _cameraDevice = _devicesVideo[0];
    
    _videoDataOutPut = [[AVCaptureVideoDataOutput alloc] init];
    _videoDataOutPut.videoSettings = @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)};
    _videoDataOutPut.alwaysDiscardsLateVideoFrames = YES;
    [_videoDataOutPut setSampleBufferDelegate:self queue:_videoRecordQueue];
    
    _audioDataOutPut = [[AVCaptureAudioDataOutput alloc] init];
    [_audioDataOutPut setSampleBufferDelegate:self queue:_videoRecordQueue];
    
    _cameraSession = [[AVCaptureSession alloc] init];
    if ([_cameraSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        _cameraSession.sessionPreset = AVCaptureSessionPreset640x480;
    }
    if ([_cameraSession canAddInput:_videoInput]) {
        [_cameraSession addInput:_videoInput];
    }
    if ([_cameraSession canAddInput:audioInput]) {
        [_cameraSession addInput:audioInput];
    }
    if ([_cameraSession canAddOutput:_videoDataOutPut]) {
        [_cameraSession addOutput:_videoDataOutPut];
    }
    if ([_cameraSession canAddOutput:_audioDataOutPut]) {
        [_cameraSession addOutput:_audioDataOutPut];
    }
    _videoPreViewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_cameraSession];
    _videoPreViewLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);

    _videoPreViewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:_videoPreViewLayer];
    [_cameraSession startRunning];
}
- (void)setUpProgressView{
    _progressView = [[RecordProgressView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 3) minTime:_videoModel.minRecordTime maxTime:_videoModel.maxRecordTime];
    [self addSubview:_progressView];
}
#pragma mark - Action Part -
- (void)switchTorch{
    if(_torchType == DTTorchClose){
        if ([_cameraDevice hasTorch]) {
            [_cameraDevice lockForConfiguration:nil];
            [_cameraDevice setTorchMode:AVCaptureTorchModeOn];  // use AVCaptureTorchModeOff to turn off
            [_cameraDevice unlockForConfiguration];
            _torchType = DTTorchOpen;
        }
    }else if(_torchType == DTTorchOpen){
        if ([_cameraDevice hasTorch]) {
            [_cameraDevice lockForConfiguration:nil];
            [_cameraDevice setTorchMode:AVCaptureTorchModeAuto];  // use AVCaptureTorchModeOff to turn off
            [_cameraDevice unlockForConfiguration];
            _torchType = DTTorchAuto;
        }
    }else if(_torchType == DTTorchAuto){
        if ([_cameraDevice hasTorch]) {
            [_cameraDevice lockForConfiguration:nil];
            [_cameraDevice setTorchMode:AVCaptureTorchModeOff];  // use AVCaptureTorchModeOff to turn off
            [_cameraDevice unlockForConfiguration];
            _torchType = DTTorchClose;
        }
    };
}
- (void)switchCamera{
    [_cameraSession stopRunning];
    if(_cameraDevice.position == AVCaptureDevicePositionBack){
        [_cameraSession removeInput:_videoInput];
        _cameraDevice = _devicesVideo[1];
        _videoInput = [AVCaptureDeviceInput deviceInputWithDevice:_cameraDevice error:nil];
        [_cameraSession addInput:_videoInput];
    }else if(_cameraDevice.position == AVCaptureDevicePositionFront){
        [_cameraSession removeInput:_videoInput];
        _cameraDevice = _devicesVideo[0];
        _videoInput = [AVCaptureDeviceInput deviceInputWithDevice:_cameraDevice error:nil];
        [_cameraSession addInput:_videoInput];
    }
    [_cameraSession startRunning];
}
- (void)startRecord{
    self.recordState = DTRecordStateRecording;
    if(!_assetWriter){
        [_progressView resetProgress];
    }else{
        [_videoModel appendNewPartVideoModel];
    }
    [self setUpAssetWriter];
    _isRecording = YES;
}

- (void)pauseRecord{
    _isRecording = NO;
    self.recordState = DTRecordStatePause;
    if(_assetWriter && _assetWriter.status == AVAssetWriterStatusWriting){
        dispatch_async(_videoRecordQueue, ^{
            [_assetWriter finishWritingWithCompletionHandler:^{
                CGFloat newSecs = CMTimeGetSeconds(CMTimeSubtract(_currentSampleTime, _startRecordTime));
                CMTime newDuration = CMTimeMakeWithSeconds(newSecs, _currentSampleTime.timescale);
                [_videoModel.videoParts lastObject].partDuration = newDuration;
            }];
        });
    }
}
- (void)resetRecord{
    self.recordState = DTRecordStateInit;
    if(self.videoPlayer){
        [self.videoPlayer stop];
        [self.videoPlayer.view removeFromSuperview];
    }
    [_videoModel resetVideoParts];
    [_progressView deleteAllProgressViews];
    [_cameraSession startRunning];
}
- (void)finishVideoRecord{
    _isRecording = NO;
    self.recordState = DTRecordStateCombining;
    [_videoModel combineVideosToSandBoxWithCompleteHandler:^{
        [_cameraSession stopRunning];
        [_progressView deleteAllProgressViews];
        [self replayVideo];
    }];
}
- (void)finishVideoWithTimeOut{
    _isRecording = NO;
    self.recordState = DTRecordStateCombining;
    if(_assetWriter && _assetWriter.status == AVAssetWriterStatusWriting){
        dispatch_async(_videoRecordQueue, ^{
            [_assetWriter finishWritingWithCompletionHandler:^{
                [_videoModel combineVideosToSandBoxWithCompleteHandler:^{
                    [_cameraSession stopRunning];
                    [_progressView deleteAllProgressViews];
                    [self replayVideo];
                }];
            }];
        });
    }
}
- (void)replayVideo{
    //replay VIdeo
    self.recordState = DTRecordStateRePlay;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:self.videoModel.videoExportUrl];
        [self.videoPlayer.view setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:self.videoPlayer.view];
        [self bringSubviewToFront:self.videoPlayer.view];
        [self.videoPlayer prepareToPlay];
        self.videoPlayer.controlStyle = MPMovieControlStyleNone;
        self.videoPlayer.shouldAutoplay = YES;
        self.videoPlayer.repeatMode = MPMovieRepeatModeOne;
        [self.videoPlayer play];
    });
}

- (void)selectLastDeletePart{
    [_progressView willDeleteLastProgressView];
}
- (void)didDeleteLastPart{
    [_videoModel deleteLastVideoPart];
    [_progressView deleteLastProgressView];
}



- (void)setUpAssetWriter{
    _assetWriter = [AVAssetWriter assetWriterWithURL:_videoModel.currentVideoPartTempFileUrl fileType:AVFileTypeQuickTimeMovie error:nil];

    int videoWidth = _videoModel.videoSize.width;
    int videoHeight = _videoModel.videoSize.height;

    NSDictionary *outputSettings = @{
                                     AVVideoCodecKey : AVVideoCodecH264,
                                     AVVideoWidthKey : @(videoHeight),
                                     AVVideoHeightKey : @(videoWidth),
                                     AVVideoScalingModeKey:AVVideoScalingModeResizeAspectFill,
                                     };
    _assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
    _assetWriterVideoInput.expectsMediaDataInRealTime = YES;
    _assetWriterVideoInput.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
    
    
    NSDictionary *audioOutputSettings = @{
                                          AVFormatIDKey:@(kAudioFormatMPEG4AAC),
                                          AVEncoderBitRateKey:@(64000),
                                          AVSampleRateKey:@(44100),
                                          AVNumberOfChannelsKey:@(1),
                                          };
    
    _assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioOutputSettings];
    _assetWriterAudioInput.expectsMediaDataInRealTime = YES;
    
    
    NSDictionary *SPBADictionary = @{
                                     (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
                                     (__bridge NSString *)kCVPixelBufferWidthKey : @(videoWidth),
                                     (__bridge NSString *)kCVPixelBufferHeightKey  : @(videoHeight),
                                     (__bridge NSString *)kCVPixelFormatOpenGLESCompatibility : ((__bridge NSNumber *)kCFBooleanTrue)
                                     };
    _assetWriterPixelBufferInput = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_assetWriterVideoInput sourcePixelBufferAttributes:SPBADictionary];
    if ([_assetWriter canAddInput:_assetWriterVideoInput]) {
        [_assetWriter addInput:_assetWriterVideoInput];
    }else {
        NSLog(@"AssetWriter videoInput append Failed");
    }
    if ([_assetWriter canAddInput:_assetWriterAudioInput]) {
        [_assetWriter addInput:_assetWriterAudioInput];
    }else {
        NSLog(@"AssetWriter audioInput Append Failed");
    }
}
#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    
    @autoreleasepool {

        if (!_isRecording){
            [_progressView pauseProgress];
            return;
        }
        _currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer);
        
        if (_assetWriter.status != AVAssetWriterStatusWriting) {
            _startRecordTime = _currentSampleTime;
            _previousFrameTime = _currentSampleTime;
            [_assetWriter startWriting];
            [_assetWriter startSessionAtSourceTime:_startRecordTime];
        }

        if (captureOutput == _videoDataOutPut) {
            if (_assetWriterPixelBufferInput.assetWriterInput.isReadyForMoreMediaData) {
                
                //pending buffer
                CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
                BOOL pendingResult = [_assetWriterPixelBufferInput appendPixelBuffer:pixelBuffer withPresentationTime:_currentSampleTime];
              
                if (pendingResult) {
                    //update progressBar
                    CGFloat prgoress = CMTimeGetSeconds(CMTimeSubtract(_currentSampleTime, _startRecordTime))/_videoModel.maxRecordTime;
                    [_progressView updateProgressWithValue:prgoress];
                    
                    //update record duration
                    CGFloat newSecs = CMTimeGetSeconds(CMTimeSubtract(_currentSampleTime, _previousFrameTime));
                    CGFloat originSecs = CMTimeGetSeconds(_videoModel.duration);
                    CMTime newDuration = CMTimeMakeWithSeconds(newSecs+originSecs, _currentSampleTime.timescale);
                    _videoModel.duration = newDuration;
                    
//                    NSLog(@"videoModel.duration %f",CMTimeGetSeconds(_videoModel.duration));
                    //finish record with TimeOut
                    if(CMTimeGetSeconds(_videoModel.duration) >= _videoModel.maxRecordTime){
                        [self finishVideoWithTimeOut];
                    }
                    _previousFrameTime = _currentSampleTime;
                }else{
                    NSLog(@"Pixel Buffer Appending Failed");
                }
            }
        }
        if (captureOutput == _audioDataOutPut) {
            if(_assetWriterAudioInput.isReadyForMoreMediaData){
                [_assetWriterAudioInput appendSampleBuffer:sampleBuffer];
            }
        }
    }
}

@end
