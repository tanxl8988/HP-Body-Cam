//
//  APKDVRCommandFactory.h
//  Aigo
//
//  Created by Mac on 17/6/30.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APKDVRCommand.h"
#import "APKDVRFile.h"

@interface APKDVRCommandFactory : NSObject

+ (APKDVRCommand *)getRecordStateCommand;
+ (APKDVRCommand *)rebotWifiCommand;
+ (APKDVRCommand *)modifyWifiCommandWithAccount:(NSString *)account password:(NSString *)password;
+ (APKDVRCommand *)getWifiInfoCommand;
+ (APKDVRCommand *)setCommandWithProperty:(NSString *)property value:(NSString *)value;
+ (APKDVRCommand *)getLiveInfoCommand;
+ (APKDVRCommand *)deleteCommandWithFileName:(NSString *)fileName;
+ (APKDVRCommand *)getFileListCommandWithCameraType:(APKCameraType)cameraType fileType:(APKFileType)fileType count:(NSInteger)count offset:(NSInteger)offset;
+ (APKDVRCommand *)getSettingInfoCommand;
+ (APKDVRCommand *)captureCommand;
+ (APKDVRCommand *)setHDRLiveCommand;
+ (APKDVRCommand *)setHDRLiveViewControllerDismissCommand;
@end
