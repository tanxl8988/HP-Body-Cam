//
//  APKLiveViewController.h
//  万能AIT
//
//  Created by Mac on 17/3/21.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^APKStopLiveCompletionHandler)(void);

@interface APKLiveViewController : UIViewController

@property (assign) BOOL isFullScreenMode;
@property (nonatomic) BOOL isRearCameraLive;
- (void)startLive;
- (void)stopLive:(APKStopLiveCompletionHandler)completionHandler;

@end
