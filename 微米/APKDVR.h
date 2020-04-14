//
//  APKDVR.h
//  AITBrain
//
//  Created by Mac on 17/3/20.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APKDVRSettingInfo.h"

typedef enum : NSInteger {
    APKOldMachine,
    APK880xMachine,
    APKF880x_CNOrF860wMachine,
} APKDVRModal;
@interface APKDVR : NSObject

@property (assign) BOOL isConnected;
@property (assign,nonatomic) APKDVRModal modal;
@property (strong,nonatomic) APKDVRSettingInfo *settingInfo;
@property (nonatomic,assign) BOOL isRecord;
+ (instancetype)sharedInstance;

@end
