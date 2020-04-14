//
//  APKDVRCommandFactory.m
//  Aigo
//
//  Created by Mac on 17/6/30.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKDVRCommandFactory.h"
#import "APKAITCGI.h"
#import "APKDVRFile.h"
#import "APKDVRSettingInfoResponseObjectHandler.h"
#import "APKGetDVRFileListResponseObjectHandler.h"
#import "APKGetLiveInfoResponseObjectHandler.h"
#import "APKWifiInfoResponseObjectHandler.h"
#import "APKRecordStateResponseObjectHandler.h"
#import "APKDVR.h"

@implementation APKDVRCommandFactory

+ (APKDVRCommand *)getRecordStateCommand{
    
    NSString *url = @"http://192.72.1.1/cgi-bin/Config.cgi?action=get&property=Camera.Preview.MJPEG.status.record";
    APKDVRCommand *command = [APKDVRCommand commandWithUrl:url responseObjectHandler:[APKRecordStateResponseObjectHandler new]];
    return command;
}

+ (APKDVRCommand *)rebotWifiCommand{
    
    NSString *url = @"http://192.72.1.1/cgi-bin/Config.cgi?action=set&property=Net&value=reset";
    APKDVRCommand *command = [APKDVRCommand commandWithUrl:url responseObjectHandler:[APKDVRCommandResponseObjectHandler new]];
    return command;
}

+ (APKDVRCommand *)modifyWifiCommandWithAccount:(NSString *)account password:(NSString *)password{
    
    NSString *url = [NSString stringWithFormat:@"http://192.72.1.1/cgi-bin/Config.cgi?action=set&property=Net.WIFI_AP.SSID&value=%@&property=Net.WIFI_AP.CryptoKey&value=%@",account,password];
    APKDVRCommand *command = [APKDVRCommand commandWithUrl:url responseObjectHandler:[APKDVRCommandResponseObjectHandler new]];
    return command;
}

+ (APKDVRCommand *)getWifiInfoCommand{
    
    NSString *url = @"http://192.72.1.1/cgi-bin/Config.cgi?action=get&property=Net.WIFI_AP.SSID&property=Net.WIFI_AP.CryptoKey";
    APKDVRCommand *command = [APKDVRCommand commandWithUrl:url responseObjectHandler:[APKWifiInfoResponseObjectHandler new]];
    return command;

}

+ (APKDVRCommand *)setCommandWithProperty:(NSString *)property value:(NSString *)value{
    
    NSString *url = [APKAITCGI setCGIWithProperty:property value:value];
    APKDVRCommand *command = [APKDVRCommand commandWithUrl:url responseObjectHandler:[APKDVRCommandResponseObjectHandler new]];
    return command;
}

+ (APKDVRCommand *)getLiveInfoCommand{

    NSString *url = @"http://192.72.1.1/cgi-bin/Config.cgi?action=get&property=Camera.Preview.*";
    APKDVRCommand *command = [APKDVRCommand commandWithUrl:url responseObjectHandler:[APKGetLiveInfoResponseObjectHandler new]];
    return command;
}

+ (APKDVRCommand *)deleteCommandWithFileName:(NSString *)fileName{
    
    NSString *url = [APKAITCGI deleteCGIWithFileName:fileName];
    APKDVRCommand *command = [APKDVRCommand commandWithUrl:url responseObjectHandler:[APKDVRCommandResponseObjectHandler new]];
    return command;
}

+ (APKDVRCommand *)setHDRLiveCommand
{
    NSString *url = @"http://192.72.1.1/cgi-bin/Config.cgi?action=set&property=HDRTest&value=test";
    APKDVRCommand *command = [APKDVRCommand commandWithUrl:url responseObjectHandler:[APKDVRCommandResponseObjectHandler new]];
    return command;
}

+ (APKDVRCommand *)setHDRLiveViewControllerDismissCommand
{
    NSString *url = @"http://192.72.1.1/cgi-bin/Config.cgi?action=set&property=HDRTest&value=testOK";
    APKDVRCommand *command = [APKDVRCommand commandWithUrl:url responseObjectHandler:[APKDVRCommandResponseObjectHandler new]];
    return command;
}



+ (APKDVRCommand *)getFileListCommandWithCameraType:(APKCameraType)cameraType fileType:(APKFileType)fileType count:(NSInteger)count offset:(NSInteger)offset{
    
    NSString *action = nil;
    NSString *format = nil;
    NSString *property = nil;
    
    fileType = APKFileTypeEvent;
    
    if (cameraType == APKCameraTypeFront) {
        
        action = @"dir";
        
    }else if (cameraType == APKCameraTypeRear){
        
        action = @"reardir";
    }
    
    if (fileType == APKFileTypeCapture) {//photo
        
        format = @"jpeg";
        
        property = [APKDVR sharedInstance].modal == APKOldMachine ? @"Photo" : @"Picture";
        
    }else if (fileType == APKFileTypeVideo){//video
        
        format = @"mov";
        property = @"Normal";
        
    }else if (fileType == APKFileTypeEvent){//event
        
        format = @"all";
        property = @"DCIM";
    }
    
    APKGetDVRFileListResponseObjectHandler *handler = [[APKGetDVRFileListResponseObjectHandler alloc] init];
    handler.fileType = fileType;
    NSString *url = [APKAITCGI getDVRFileListCGIWithAction:action format:format property:property offset:offset count:count];
    APKDVRCommand *command = [APKDVRCommand commandWithUrl:url responseObjectHandler:handler];
    return command;
}

+ (APKDVRCommand *)getSettingInfoCommand{
    
    NSString *url = [APKAITCGI getSettingInfoCGI];
    APKDVRCommand *command = [APKDVRCommand commandWithUrl:url responseObjectHandler:[APKDVRSettingInfoResponseObjectHandler new]];
    return command;
}

+ (APKDVRCommand *)captureCommand{
    
    NSString *url = [APKAITCGI setCGIWithProperty:@"Video" value:@"capture"];
    APKDVRCommand *command = [APKDVRCommand commandWithUrl:url responseObjectHandler:[APKDVRCommandResponseObjectHandler new]];
    return command;
}

@end
