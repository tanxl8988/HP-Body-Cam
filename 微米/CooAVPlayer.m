//
//  APKAVPlayer.m
//  Aigo
//
//  Created by Mac on 17/7/19.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "CooAVPlayer.h"
#import <Photos/Photos.h>

@implementation CooAVPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

@end

@implementation CooAVPlayerKit

+ (NSString *)convertSecondsToString:(NSTimeInterval)seconds{
    
    int wholeMinutes = (int)trunc(seconds / 60);
    int wholdSeconds = (int)trunc(seconds) - wholeMinutes * 60;
    NSString *formatTime = [NSString stringWithFormat:@"%02d:%02d", wholeMinutes, wholdSeconds];
    return formatTime;
}

@end

@interface CooAVPlayer ()

@property (strong,nonatomic) id asset;
@property (strong,nonatomic) id<NSObject> timeObserverToken;

@end

@implementation CooAVPlayer

#pragma mark - life circle

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.cachingTime = 1;
        
        [self.player addObserver:self forKeyPath:@"currentItem.duration" options:NSKeyValueObservingOptionNew context:nil];
        [self.player addObserver:self forKeyPath:@"currentItem.loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        [self.player addObserver:self forKeyPath:@"currentItem.status" options:NSKeyValueObservingOptionNew context:nil];
        [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    
    [self.player removeObserver:self forKeyPath:@"currentItem.duration" context:nil];
    [self.player removeObserver:self forKeyPath:@"currentItem.loadedTimeRanges" context:nil];
    [self.player removeObserver:self forKeyPath:@"currentItem.status" context:nil];
    [self.player removeObserver:self forKeyPath:@"rate" context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    if (self.player.currentItem) {
        
        [self.player pause];
        [self.player replaceCurrentItemWithPlayerItem:nil];
    }
    
    if (self.timeObserverToken) {
        
        [self.player removeTimeObserver:self.timeObserverToken];
        self.timeObserverToken = nil;
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"currentItem.duration"]) {
        
        NSValue *newDurationAsValue = change[NSKeyValueChangeNewKey];
        CMTime newDuration = [newDurationAsValue isKindOfClass:[NSValue class]] ? newDurationAsValue.CMTimeValue : kCMTimeZero;
        BOOL hasValidDuration = CMTIME_IS_NUMERIC(newDuration) && newDuration.value != 0;
        self.duration = hasValidDuration ? CMTimeGetSeconds(newDuration) : 0.0;
    }
    else if ([keyPath isEqualToString:@"rate"]) {
        
        double newRate = [change[NSKeyValueChangeNewKey] doubleValue];
        if (newRate == 1) {
            
            self.state = CooAVPlayerStatePlaying;
            
        }else{
            
            if (self.state == CooAVPlayerStatePlaying && self.time != self.duration) {
                
                self.state = CooAVPlayerStateBuffering;
            }
        }
    }
    else if ([keyPath isEqualToString:@"currentItem.status"]) {
        
        NSNumber *newStatusAsNumber = change[NSKeyValueChangeNewKey];
        AVPlayerItemStatus newStatus = [newStatusAsNumber isKindOfClass:[NSNumber class]] ? newStatusAsNumber.integerValue : AVPlayerItemStatusUnknown;
        
        if (newStatus == AVPlayerItemStatusFailed) {
            
            self.state = CooAVPlayerStateError;
            
        }else if (newStatus == AVPlayerItemStatusReadyToPlay){
            
            [self.player play];
            
            __weak typeof(self)weakSelf = self;
            self.timeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                
                weakSelf.time = CMTimeGetSeconds(time);
                NSLog(@"......%d",time);
            }];
        }
    }
    else if ([keyPath isEqualToString:@"currentItem.loadedTimeRanges"]) {
        
        NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        self.loadedTime = startSeconds + durationSeconds;// 计算缓冲总进度
        
        if (self.state == CooAVPlayerStateBuffering && self.loadedTime - self.time >= self.cachingTime) {
            
            [self.player play];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - private method

- (void)handlePlayToEndTimeNotification:(NSNotification *)notification{
    
    [self seekToTime:0];
    
    self.state = CooAVPlayerStateEnded;
}

- (void)loadPHAsset:(PHAsset *)asset{
    
    self.asset = asset;
    self.state = CooAVPlayerStateOpening;
    
    __weak typeof(self)weakSelf = self;
    [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        
        if (asset != weakSelf.asset) return ;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (playerItem) {
                
                [weakSelf.player replaceCurrentItemWithPlayerItem:playerItem];

            }else{
                
                weakSelf.state = CooAVPlayerStateError;
            }
        });
    }];
}

- (void)loadAVURLAsset:(AVURLAsset *)asset{
    
    self.asset = asset;
    self.state = CooAVPlayerStateOpening;
    
    __weak typeof(self)weakSelf = self;
    NSArray *loadKeys = @[@"playable",@"hasProtectedContent"];
    [asset loadValuesAsynchronouslyForKeys:loadKeys completionHandler:^{
        
        if (asset != weakSelf.asset) return;
        
        //判断是否加载keys成功
        for (NSString *key in loadKeys) {
            NSError *error = nil;
            if ([asset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed) {
                
                weakSelf.state = CooAVPlayerStateError;
                return;
            }
        }
        
        //判断是否可以播放该asset
        if (!asset.playable || asset.hasProtectedContent) {
            
            weakSelf.state = CooAVPlayerStateError;
            return;
        }
        
        //可以播放该asset
        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
        [weakSelf.player replaceCurrentItemWithPlayerItem:item];
        
    }];
}

- (void)resetAllProperties{
    
    if (self.timeObserverToken) {
        [self.player removeTimeObserver:self.timeObserverToken];
        self.timeObserverToken = nil;
    }
    
    if (self.player.currentItem) {
        [self.player replaceCurrentItemWithPlayerItem:nil];
    }
    
    self.duration = 0;
    self.time = 0;
    self.loadedTime = 0;
}

#pragma mark - public method

- (void)updateAsset:(id)asset{
    
    [self resetAllProperties];

    if ([asset isKindOfClass:[AVURLAsset class]]) {
        
        [self loadAVURLAsset:asset];
        
    }else if ([asset isKindOfClass:[PHAsset class]]){
        
        [self loadPHAsset:asset];
        
    }else{
        
        self.state = CooAVPlayerStateError;
    }
}

- (void)setDisplayView:(CooAVPlayerView *)aView{
    
    aView.player = self.player;
}

- (void)play{
    
    if (self.state == CooAVPlayerStatePaused || self.state == CooAVPlayerStateEnded) {
        
        [self.player play];
    }
    else{
        
        [self updateAsset:self.asset];
    }
}

- (void)pause{
    
    if (self.state == CooAVPlayerStatePlaying || self.state == CooAVPlayerStateBuffering) {
        
        self.state = CooAVPlayerStatePaused;
        [self.player pause];
    }
}

- (void)seekToTime:(NSTimeInterval)time{
    
    CMTimeScale scale = self.player.currentTime.timescale;
    CMTime t = CMTimeMake(scale * time, scale);
    [self.player seekToTime:t];
}

#pragma mark - getter

- (CMTimeScale)timeScale{
    
    return self.player.currentTime.timescale;
}

- (AVPlayer *)player{
    
    if (!_player) {
        
        _player = [[AVPlayer alloc] init];
    }
    
    return _player;
}

@end
