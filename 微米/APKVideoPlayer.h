//
//  APKLocalVideoPlayerVC.h
//  第三版云智汇
//
//  Created by Mac on 16/8/10.
//  Copyright © 2016年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface APKVideoPlayer : UIViewController

- (void)configureWithURLArray:(NSArray<NSURL *> *)urlArray nameArray:(NSArray *)nameArray currentIndex:(NSInteger)currentIndex;
- (void)configureWithAssetArray:(NSArray<PHAsset *> *)assetArray nameArray:(NSArray *)nameArray currentIndex:(NSInteger)currentIndex isAudioFile:(BOOL)isAudioFile;

@end
