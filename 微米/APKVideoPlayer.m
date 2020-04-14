//
//  APKLocalVideoPlayerVC.m
//  第三版云智汇
//
//  Created by Mac on 16/8/10.
//  Copyright © 2016年 APK. All rights reserved.
//

#import "APKVideoPlayer.h"
#import "CooAVPlayer.h"
#import "MobileVLCKit/VLCMediaPlayer.h"

typedef enum : NSUInteger {
    APKVideoPlayerResourceTypeNone,
    APKVideoPlayerResourceTypeURL,
    APKVideoPlayerResourceTypePHAsset,
} APKVideoPlayerResourceType;

@interface APKVideoPlayer ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet CooAVPlayerView *displayView;
@property (weak, nonatomic) IBOutlet UIView *playAndPauseView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *flower;
@property (nonatomic) APKVideoPlayerResourceType resourceType;
@property (strong,nonatomic) CooAVPlayer *cooPlayer;
@property (strong,nonatomic) NSMutableArray *assetArray;
@property (strong,nonatomic) NSMutableArray *urlArray;
@property (strong,nonatomic) NSMutableArray *nameArray;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic,retain) VLCMediaPlayer *vlcPlayer;
@property (nonatomic,assign) BOOL playFinished;


@end

@implementation APKVideoPlayer

#pragma mark - life circle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"videoPlayer_sliderBar"] forState:UIControlStateNormal];
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"videoPlayer_sliderBar"] forState:UIControlStateSelected];
    
    [self.cooPlayer setDisplayView:self.displayView];
    [self.cooPlayer addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
    [self.cooPlayer addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:nil];
    [self.cooPlayer addObserver:self forKeyPath:@"time" options:NSKeyValueObservingOptionNew context:nil];


    if (self.resourceType != APKVideoPlayerResourceTypeNone) {

        [self updateSwitchVideoButtons];

        [self updateCurrentVideo];
    }
}

- (void)dealloc {
   
    [self.cooPlayer removeObserver:self forKeyPath:@"state"];
    [self.cooPlayer removeObserver:self forKeyPath:@"duration"];
    [self.cooPlayer removeObserver:self forKeyPath:@"time"];
    [self.vlcPlayer stop];
    NSLog(@"%s",__func__);
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"state"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            CooAVPlayerState state = [change[@"new"] intValue];
            if (state == CooAVPlayerStateBuffering || state == CooAVPlayerStateOpening) {
                if (!self.flower.isAnimating)
                    [self.flower startAnimating];
            }
            else{
                if (self.flower.isAnimating)
                    [self.flower stopAnimating];
            }
            
            if (state == CooAVPlayerStateOpening) {
                self.playButton.enabled = NO;
                self.pauseButton.enabled = NO;
            }
            else{
                self.playButton.enabled = YES;
                self.pauseButton.enabled = YES;
                if (state != CooAVPlayerStateBuffering) {
                    if (state == CooAVPlayerStatePlaying) {
                        self.playButton.hidden = YES;
                        self.pauseButton.hidden = NO;
                    }
                    else{
                        self.playButton.hidden = NO;
                        self.pauseButton.hidden = YES;
                    }
                }
            }
        });
    }
    else if ([keyPath isEqualToString:@"duration"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSTimeInterval duration = [change[@"new"] doubleValue];
            self.progressSlider.maximumValue = duration;
            
            self.durationLabel.text = [CooAVPlayerKit convertSecondsToString:duration];
        });
    }
    else if ([keyPath isEqualToString:@"time"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSTimeInterval time = [change[@"new"] doubleValue];
            self.progressSlider.value = time;
            
            self.progressLabel.text = [CooAVPlayerKit convertSecondsToString:time];
            NSLog(@"time : %@",self.progressLabel.text);
            _playFinished = [self.progressLabel.text isEqualToString:@"00:00"] ? YES : NO;
        });
    }
}

#pragma mark - private method

- (void)updateCurrentVideo{
    
    id asset = nil;
    if (self.resourceType == APKVideoPlayerResourceTypeURL) {
        
        NSURL *url = [self.urlArray objectAtIndex:self.currentIndex];
        asset = [AVURLAsset assetWithURL:url];
        
//        [self vlcPlayRemoteVideo];
    }
    else if (self.resourceType == APKVideoPlayerResourceTypePHAsset){
        
        asset = [self.assetArray objectAtIndex:self.currentIndex];
        [self vlcPlayLocalVideo:asset];
    }
    
    [self.cooPlayer updateAsset:asset];
}

-(void)vlcPlayRemoteVideo
{
    self.vlcPlayer.media = [VLCMedia mediaWithURL:self.urlArray.firstObject];
    [self.vlcPlayer play];
}

-(void)vlcPlayLocalVideo:(PHAsset*)asset
{
    [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        NSString *filePath = [info valueForKey:@"PHImageFileSandboxExtensionTokenKey"];
        if (filePath && filePath.length > 0) {
            NSArray *lyricArr = [filePath componentsSeparatedByString:@";"];
            NSString *privatePath = [lyricArr lastObject];
            if (privatePath.length > 8) {
                NSString *videoPath = [privatePath substringFromIndex:8];
                self.vlcPlayer.media = [VLCMedia mediaWithPath:videoPath];
                [self.vlcPlayer play];
            }
        }
    }];
}

- (void)updateSwitchVideoButtons{
    
    NSString *videoName = [self.nameArray objectAtIndex:self.currentIndex];
    self.titleLabel.text = videoName;
    self.title = videoName;
    
    self.previousButton.enabled = self.currentIndex == 0 ? NO : YES;
    NSInteger maxIndex = self.resourceType == APKVideoPlayerResourceTypeURL ? self.urlArray.count - 1 : self.assetArray.count - 1;
    self.nextButton.enabled = self.currentIndex == maxIndex ? NO : YES;
}

#pragma mark - public method

- (void)configureWithURLArray:(NSArray<NSURL *> *)urlArray nameArray:(NSArray *)nameArray currentIndex:(NSInteger)currentIndex{
    
    [self.urlArray setArray:urlArray];
    [self.nameArray setArray:nameArray];
    self.currentIndex = currentIndex;
    self.resourceType = APKVideoPlayerResourceTypeURL;
    
    if (self.isViewLoaded) {
    
        [self updateSwitchVideoButtons];
        
        [self updateCurrentVideo];
    }
}

- (void)configureWithAssetArray:(NSArray<PHAsset *> *)assetArray nameArray:(NSArray *)nameArray currentIndex:(NSInteger)currentIndex isAudioFile:(BOOL)isAudioFile{
    
    [self.assetArray setArray:assetArray];
    [self.nameArray setArray:nameArray];
    self.currentIndex = currentIndex;
    self.resourceType =  isAudioFile == YES ? APKVideoPlayerResourceTypeURL : APKVideoPlayerResourceTypePHAsset;
    
    if (isAudioFile == YES) {
        [self.urlArray addObjectsFromArray:assetArray];
    }
    
    if (self.isViewLoaded) {
        
        [self updateSwitchVideoButtons];
        
        [self updateCurrentVideo];
    }
}

#pragma mark - event response

- (IBAction)tapDisplayView:(UITapGestureRecognizer *)sender {
    
    BOOL isShouldHidden = !self.titleLabel.hidden;
    self.titleLabel.hidden = isShouldHidden;
    self.progressLabel.hidden = isShouldHidden;
    self.durationLabel.hidden = isShouldHidden;
    self.progressSlider.hidden = isShouldHidden;
    self.previousButton.hidden = isShouldHidden;
    self.nextButton.hidden = isShouldHidden;
    self.playAndPauseView.hidden = isShouldHidden;
    self.backButton.hidden = isShouldHidden;
}

- (IBAction)progressSliderTouchFinished:(UISlider *)sender {
    
    [self.cooPlayer play];
}

- (IBAction)progressSliderValueChanged:(UISlider *)sender {
    
    NSTimeInterval time = floor(sender.value);
    self.progressLabel.text = [CooAVPlayerKit convertSecondsToString:time];
    
    [self.cooPlayer seekToTime:time];
}

- (IBAction)progressSliderTouchDown:(UISlider *)sender {
    
    [self.cooPlayer pause];
}

- (IBAction)play:(UIButton *)sender {
    
    if (_playFinished) {
        [self updateCurrentVideo];
        return;
    }
    
    [self.cooPlayer play];
}

- (IBAction)pause:(UIButton *)sender {
    
    [self.cooPlayer pause];
}

- (IBAction)chengePlayItemWithSender:(UIButton *)sender {
    
    if (sender == self.previousButton) {
        self.currentIndex -= 1;
    }
    else if(sender == self.nextButton){
        self.currentIndex += 1;
    }
    
    [self updateSwitchVideoButtons];
    
    [self updateCurrentVideo];
}

- (IBAction)quit {
    
    [self.cooPlayer pause];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - getter

- (CooAVPlayer *)cooPlayer{
    
    if (!_cooPlayer) {
        
        _cooPlayer = [[CooAVPlayer alloc] init];
    }
    return _cooPlayer;
}

- (NSMutableArray *)nameArray{
    
    if (!_nameArray) {
        
        _nameArray = [[NSMutableArray alloc] init];
    }
    return _nameArray;
}

- (NSMutableArray *)assetArray{
    
    if (!_assetArray) {
        
        _assetArray = [[NSMutableArray alloc] init];
    }
    return _assetArray;
}

- (NSMutableArray *)urlArray{
    
    if (!_urlArray) {
        
        _urlArray = [[NSMutableArray alloc] init];
    }
    return _urlArray;
}

-(VLCMediaPlayer *)vlcPlayer
{
    if (!_vlcPlayer) {
        
        UIView *videoView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:videoView];
        
        //2.创建播放器
        _vlcPlayer = [[VLCMediaPlayer alloc] initWithOptions:nil];
        //3.设置播放图层
        _vlcPlayer.drawable = videoView;
//        _vlcPlayer.media = [VLCMedia mediaWithURL:self.urlArray[0]];
    }
    return _vlcPlayer;
}

@end

































