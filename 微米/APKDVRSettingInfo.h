//
//  APKDVRSettingInfo.h
//  万能AIT
//
//  Created by Mac on 17/6/16.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APKDVRSettingInfo : NSObject

@property (assign,nonatomic) BOOL haveLoadSettingInfo;
@property (assign,nonatomic) NSInteger videoRes;
@property (assign,nonatomic) NSInteger recordSound;
@property (assign,nonatomic) NSInteger LCDPowerSave;
@property (assign,nonatomic) NSInteger VideoClipTime;
@property (assign,nonatomic) NSInteger EV;
@property (assign,nonatomic) NSInteger Flicker;
@property (assign,nonatomic) NSInteger ParkMode;
@property (assign,nonatomic) NSInteger GSensor;
@property (assign,nonatomic) NSInteger TimeStamp;
@property (assign,nonatomic) NSInteger SoundIndicator;
@property (assign,nonatomic) NSInteger Volume;
@property (assign,nonatomic) NSInteger Language;
@property (assign,nonatomic) NSInteger TimeZone;
@property (assign,nonatomic) NSInteger SatelliteSync;
@property (assign,nonatomic) NSInteger SpeedUnit;
@property (assign,nonatomic) NSInteger SpeedCamAlert;
@property (assign,nonatomic) NSInteger SpeedLimitAlert;
@property (assign,nonatomic) NSInteger SpeedPositionManagement;
@property (strong,nonatomic) NSString *FWversion;

@end
