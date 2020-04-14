//
//  APKAVPlayer.h
//  Aigo
//
//  Created by Mac on 17/7/19.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface CooAVPlayerView : UIView

@property (strong,nonatomic) AVPlayer *player;

@end

@interface CooAVPlayerKit : NSObject

+ (NSString *)convertSecondsToString:(NSTimeInterval)seconds;

@end

typedef enum : int {
    CooAVPlayerStateOpening,
    CooAVPlayerStateBuffering,
    CooAVPlayerStatePlaying,
    CooAVPlayerStateEnded,
    CooAVPlayerStatePaused,
    CooAVPlayerStateError,
} CooAVPlayerState;

@interface CooAVPlayer : NSObject

@property (nonatomic) CooAVPlayerState state;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSTimeInterval time;
@property (nonatomic) NSTimeInterval loadedTime;
@property (nonatomic) NSTimeInterval cachingTime;
@property (strong,nonatomic) AVPlayer *player;

- (void)setDisplayView:(CooAVPlayerView *)aView;
- (void)updateAsset:(id)asset;//PHAsset/AVURLAsset
- (void)pause;
- (void)play;
- (void)seekToTime:(NSTimeInterval)time;

@end
