//
//  APKLiveViewController.m
//  万能AIT
//
//  Created by Mac on 17/3/21.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKLiveViewController.h"
#import "MobileVLCKit/VLCMediaPlayer.h"
#import "APKDVR.h"
#import "APKDVRCommandFactory.h"

@interface APKLiveViewController ()<VLCMediaPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (weak, nonatomic) IBOutlet UIButton *quitButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *flower;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIView *maskView;

@property (strong,nonatomic) VLCMediaPlayer *mediaPlayer;
@property (assign) NSInteger timeCount;
@property (copy,nonatomic) APKStopLiveCompletionHandler stopLiveHandler;

@end

@implementation APKLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (!self.isFullScreenMode) {
        
        self.quitButton.hidden = YES;
        self.captureButton.hidden = YES;
    }
}

#pragma mark - private method

- (void)loadLiveUI{
    
    self.maskView.hidden = NO;
    self.playButton.hidden = YES;
    [self.flower startAnimating];
}

- (void)showLiveUI{
    
    [self.flower stopAnimating];
    [UIView animateWithDuration:1.f animations:^{
        
        self.maskView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        self.maskView.hidden = YES;
        self.maskView.alpha = 1;
    }];
}

- (void)noLiveUI{
    
    self.maskView.hidden = NO;
    self.playButton.hidden = NO;
    [self.flower stopAnimating];
}

- (void)startLive{
    
    [self loadLiveUI];
    self.timeCount = 0;
    
    __weak typeof(self)weakSelf = self;
    [[APKDVRCommandFactory getLiveInfoCommand] execute:^(id responseObject) {
        
        NSDictionary *dict = responseObject;
        NSString *cameraTypeInfo = dict.allKeys.firstObject;
        weakSelf.isRearCameraLive = [cameraTypeInfo isEqualToString:@"rear"] ? YES : NO;
        NSURL *url = dict.allValues.firstObject;
        VLCMedia *media = [VLCMedia mediaWithURL:url];
        [weakSelf.mediaPlayer setMedia:media];
        [weakSelf.mediaPlayer play];
        
    } failure:^(int rval) {
        
        [weakSelf noLiveUI];
        if (weakSelf.isFullScreenMode) {
            [weakSelf quit:weakSelf.quitButton];
        }
    }];
}

- (void)stopLive:(APKStopLiveCompletionHandler)completionHandler{
    
    self.stopLiveHandler = completionHandler;
    [self.mediaPlayer stop];
}

#pragma mark - VLCMediaPlayerDelegate

- (void)mediaPlayerStateChanged:(NSNotification *)aNotification{
    
    switch (self.mediaPlayer.state) {
        case VLCMediaPlayerStateEnded:
        case VLCMediaPlayerStateStopped:
        case VLCMediaPlayerStateError:
            [self noLiveUI];
            if (self.mediaPlayer.state == VLCMediaPlayerStateStopped && self.stopLiveHandler) {
                
                self.stopLiveHandler();
                self.stopLiveHandler = nil;
            }
            break;
        case VLCMediaPlayerStatePlaying:
            
            break;
        default:
            break;
    }
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification{
    
    if (self.timeCount == 2) [self showLiveUI];
    if (self.timeCount < 3) {
        self.timeCount += 1;
    }
}

#pragma mark - event response

- (IBAction)play:(UIButton *)sender {
    
    [self startLive];
}

- (IBAction)quit:(UIButton *)sender {
 
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)capture:(UIButton *)sender {
    
    sender.enabled = NO;
    [[APKDVRCommandFactory captureCommand] execute:^(id responseObject) {
        
        sender.enabled = YES;
        
    } failure:^(int rval) {
        
        sender.enabled = YES;
    }];
}

#pragma mark - Rotate

- (BOOL)shouldAutorotate{
    
    return self.isFullScreenMode;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return self.isFullScreenMode ? UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight : UIInterfaceOrientationMaskPortrait;
}

#pragma mark - getter

- (VLCMediaPlayer *)mediaPlayer{
    
    if (!_mediaPlayer) {
        
        NSArray *options = @[@"--network-caching=400",@"--extraintf=",@"--gain=0"];
        UIViewController *content = [self.childViewControllers firstObject];
        _mediaPlayer = [[VLCMediaPlayer alloc] initWithOptions:options];
        _mediaPlayer.delegate = self;
        _mediaPlayer.drawable = content.view;
    }
    
    return _mediaPlayer;
}

@end
