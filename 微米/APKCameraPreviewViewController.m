//
//  APKCameraPreviewViewController.m
//  微米
//
//  Created by Mac on 17/4/10.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKCameraPreviewViewController.h"
#import "APKDVR.h"
#import "APKDVRCommandFactory.h"
#import "APKLiveViewController.h"
#import "APKDVRListen.h"
#import "APKGetDVRRecordingState.h"

@interface APKCameraPreviewViewController ()<APKDVRListenDelegate>

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *snapshotButton;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;
@property (nonatomic) BOOL isRecording;
@property (strong,nonatomic) APKLiveViewController *live;
@property (strong,nonatomic) APKDVRListen *dvrListen;
@property (strong,nonatomic) APKGetDVRRecordingState *getRecordState;
@property (assign) BOOL isHDRPreview;
@property (nonatomic,assign) int numOfCloseRecordTime;
@end

@implementation APKCameraPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.\
    
    self.navigationItem.title = NSLocalizedString(@"HP Pixi Car", nil);
    
    self.recordButton.selected = YES;
    self.recordButton.enabled = NO;
    self.snapshotButton.enabled = NO;
    self.switchCameraButton.enabled = NO;
    
    [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    
    
    NSNumber *videoResNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"HDRSetDispaly"];
    int videoResValue = [videoResNum intValue];
    
    self.isHDRPreview = (videoResValue != 2 && videoResValue != 3) ? NO : YES;
    
    __weak typeof(self)weakSelf = self;
    [self.getRecordState execute:^(BOOL isRecording) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            weakSelf.isRecording = isRecording;
            weakSelf.recordButton.enabled = YES;
            weakSelf.recordButton.selected = weakSelf.isRecording;
            weakSelf.snapshotButton.enabled = YES;
            weakSelf.switchCameraButton.enabled = YES;
            
            [weakSelf.dvrListen startListen];
            
            if (weakSelf.isHDRPreview == NO) {
                [weakSelf.live startLive];
                return;
            }
            
            [weakSelf setHDRLiveTask];
            
        });
    }];
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
    [self.live stopLive:nil];
    [self.dvrListen stopListen];
    
    if (self.isHDRPreview == YES) {
        [[APKDVRCommandFactory setHDRLiveViewControllerDismissCommand] execute:^(id responseObject) {
        } failure:^(int rval) {
        }];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self searchRecordState];
}

-(void)searchRecordState
{
    __weak typeof(self) weakSelf = self;
    [self.getRecordState execute:^(BOOL isRecording) {
        
        if (isRecording == YES)
            [weakSelf closeRecordVideo];
    }];
}

-(void)closeRecordVideo
{
    self.numOfCloseRecordTime++;
    __weak typeof(self) weakSelf = self;
    [[APKDVRCommandFactory setCommandWithProperty:@"Video" value:@"record"] execute:^(id responseObject) {
        
        if (weakSelf.numOfCloseRecordTime < 2) {
            [weakSelf closeRecordVideo];
        }
    } failure:^(int rval) {
    }];
    
}

-(void)setHDRLiveTask
{
    
    __weak typeof(self) weakSelf = self;
    [[APKDVRCommandFactory setHDRLiveCommand] execute:^(id responseObject) {
        
        [weakSelf.live startLive];
    } failure:^(int rval) {
        [weakSelf setHDRLiveTask];
    }];
}

#pragma mark - APKDVRListenDelegate

- (void)APKDVRListenDidReceiveMessage:(NSString *)message{
    
    NSArray *arr = [message componentsSeparatedByString:@"\n"];
    for (NSInteger i = arr.count - 1; i >= 0; i--) {
        
        NSString *str = arr[i];
        NSArray *infos = [str componentsSeparatedByString:@"="];
        if ([infos.firstObject isEqualToString:@"Recording"]) {
            
            BOOL isRecording = [infos.lastObject isEqualToString:@"YES"] ? YES : NO;
            if (self.isRecording != isRecording) {
                
                self.isRecording = isRecording;
                self.recordButton.selected = self.isRecording;
            }
            break;
        }
    }
}

#pragma mark - actions

- (IBAction)clickSnapshotButton:(UIButton *)sender {
    
    sender.enabled = NO;
    [[APKDVRCommandFactory captureCommand] execute:^(id responseObject) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            sender.enabled = YES;
        });
        
    } failure:^(int rval) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            sender.enabled = YES;
        });
    }];
}

- (IBAction)clickRecordButton:(UIButton *)sender {
    
     __weak typeof(self)weakSelf = self;
    [[APKDVRCommandFactory setCommandWithProperty:@"Video" value:@"record"] execute:^(id responseObject) {
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//            sender.selected = !sender.selected;
//        });
        
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0/*延迟执行时间*/ * NSEC_PER_SEC));
        
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [weakSelf updateRecodeState];
        });
        
    } failure:^(int rval) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
//            sender.enabled = !sender.enabled;
        });
    }];
}

-(void)updateRecodeState
{
    __weak typeof(self) weakSelf = self;
    [self.getRecordState execute:^(BOOL isRecording) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            weakSelf.recordButton.selected = isRecording;
            [APKDVR sharedInstance].isRecord = isRecording;
            NSLog(@"state : %d",isRecording);
        });
    }];
}

- (IBAction)clickSwitchCameraButton:(UIButton *)sender {
    
    sender.enabled = NO;
    __weak typeof(self) weakSelf = self;
    [self.live stopLive:^{
       
        NSString *value = weakSelf.live.isRearCameraLive ? @"front" : @"rear";
        [[APKDVRCommandFactory setCommandWithProperty:@"Camera.Preview.Source.1.Camid" value:value] execute:^(id responseObject) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                sender.enabled = YES;
                [weakSelf.live startLive];
            });
            
        } failure:^(int rval) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                sender.enabled = YES;
                [weakSelf.live startLive];
            });
        }];
    }];
}

- (void)updateTime:(NSTimer *)timer{
    
    if (self.isViewLoaded && self.view.window) {
        
        //获取手机当前时间
        NSDate *date = [[NSDate alloc] init];
        //实例化一个NSDateFormatter对象
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //设定时间格式,这里可以设置成自己需要的格式
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *currentTime = [dateFormatter stringFromDate:date];
        self.timeLabel.text = currentTime;
        
    }else{
        
        [timer invalidate];
    }
}

#pragma mark - getter

- (APKLiveViewController *)live{
    
    if (!_live) {
        
        for (UIViewController *vc in self.childViewControllers) {
            
            if ([vc isKindOfClass:[APKLiveViewController class]]) {
                
                _live = (APKLiveViewController *)vc;
                break;
            }
        }
    }
    return _live;
}

- (APKGetDVRRecordingState *)getRecordState{
    
    if (!_getRecordState) {
        
        _getRecordState = [[APKGetDVRRecordingState alloc] init];
    }
    return _getRecordState;
}

- (APKDVRListen *)dvrListen{
    
    if (!_dvrListen) {
        
        _dvrListen = [[APKDVRListen alloc] initWithDelegate:self];
    }
    return _dvrListen;
}


@end
