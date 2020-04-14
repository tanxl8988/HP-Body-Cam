//
//  APKDVRSettingInfoResponseObjectHandler.m
//  Aigo
//
//  Created by Mac on 17/7/5.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKDVRSettingInfoResponseObjectHandler.h"
#import "APKDVRSettingInfo.h"
#import "APKDVR.h"

@implementation APKDVRSettingInfoResponseObjectHandler

- (void)handle:(id)responseObject successCommandHandler:(APKSuccessCommandHandler)successCommandHandler failureCommandHandler:(APKFailureCommandHandler)failureCommandHandler{
    
    NSData *data = responseObject;
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",msg);
    NSArray *lines = [msg componentsSeparatedByString:@"\n"];
    if (lines.count > 0) {
        int rval = [lines.firstObject intValue];
        if (rval != 0) {
            failureCommandHandler(rval);
            return;
        }
    }else{
        failureCommandHandler(-1);
        return;
    }
    
    APKDVRSettingInfo *info = [[APKDVRSettingInfo alloc] init];
    NSCharacterSet *sep = [NSCharacterSet characterSetWithCharactersInString:@"."];
    for (NSString *line in lines) {
        NSArray *properties = [line componentsSeparatedByString:@"="];
        if ([properties count] != 2)
            continue;
        NSRange rng = [[properties objectAtIndex:0] rangeOfCharacterFromSet:sep options:NSBackwardsSearch];
        if (rng.location == 0 || rng.length >= [[properties objectAtIndex:0] length])
            continue;
        rng.location++;
        rng.length = [[properties objectAtIndex:0] length] - rng.location;
        NSString *key = [[properties objectAtIndex:0] substringWithRange:rng];
        if ([properties count] != 2)
            continue;
        NSString* sz = [NSString alloc];
        sz = [properties objectAtIndex:1];
        
        if ([key caseInsensitiveCompare:@"VideoRes"] == NSOrderedSame){//录制时长
            
//            NSArray *map = @[@"1080P27D5",@"720P27D5",@"720P55"];
            
            NSArray *map = @[];
            if ([APKDVR sharedInstance].modal == APKOldMachine)
                map = @[@"1080P30",@"1080P27D5",@"720P30",@"720P55"];
            else if([APKDVR sharedInstance].modal == APK880xMachine)
                map = @[@"1080P30",@"1080P27D5",@"1080P30HDR",@"1080P27D5HDR",@"720P30",@"720P27D5"];
            else
                map = @[@"1080P30",@"1080P30HDR",@"720P30"];
            
            NSInteger index = [map indexOfObject:sz];
            info.videoRes = index;
            NSLog(@"info.videoRes : %ld",index);
            
            
        }else if ([key caseInsensitiveCompare:@"MuteStatus"] == NSOrderedSame){
            
            NSArray *map = @[@"OFF",@"ON"];
            info.recordSound = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"LCDPowerSave"] == NSOrderedSame){
            
            NSArray *map = @[@"ON",@"7SEC",@"1MIN",@"3MIN"];
            info.LCDPowerSave = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"VideoClipTime"] == NSOrderedSame){
            
            NSArray *map = @[@"30SEC",@"1MIN",@"3MIN"];
            info.VideoClipTime = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"EV"] == NSOrderedSame){
            
            NSArray *map = [NSArray arrayWithObjects:@"EVN200", @"EVN167", @"EVN133", @"EVN100", @"EVN067", @"EVN033", @"EV0", @"EVP033", @"EVP067", @"EVP100", @"EVP133", @"EVP167", @"EVP200", nil];
            info.EV = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"Flicker"] == NSOrderedSame){
            
            NSArray *map = @[@"50Hz",@"60Hz"];
            info.Flicker = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"ParkMode"] == NSOrderedSame){
            
            NSArray *map = @[@"OFF",@"GSR",@"MDT"];
            info.ParkMode = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"GSensor"] == NSOrderedSame){
            
            NSArray *map = @[@"OFF",@"LEVEL4",@"LEVEL2",@"LEVEL0"];
            info.GSensor = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"TimeStamp"] == NSOrderedSame){
            
            NSArray *map = @[@"OFF",@"DATE"];
            info.TimeStamp = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"SoundIndicator"] == NSOrderedSame){
            
            
            NSArray *map = @[@"OFF",@"ON"];
            info.SoundIndicator = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"Volume"] == NSOrderedSame){
            
            NSArray *map = @[@"LV0",@"LV1",@"LV2",@"LV3",@"LV4",@"LV5",@"LV6",@"LV7",@"LV8",@"LV9",@"LV10"];
            info.Volume = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"Language"] == NSOrderedSame){
            
            
            NSArray *map = @[@"ENGLISH",@"TCHINESE",@"JAPANESE"];
            info.Language = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"TimeZone"] == NSOrderedSame){
            
            NSArray *map = @[@"M12",@"M11",@"M10",@"M9",@"M8",@"M7",@"M6",@"M5",@"M4",@"M3",@"M2",@"M1",@"GMT",@"P1",@"P2",@"P3",@"P330",@"P4",@"P430",@"P5",@"P530",@"P545",@"P6",@"P630",@"P7",@"P8",@"P9",@"P930",@"P10",@"P11",@"P12",@"P13"];
            info.TimeZone = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"SatelliteSync"] == NSOrderedSame){
            
            NSArray *map = @[@"OFF",@"ON"];
            info.SatelliteSync = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"SpeedUnit"] == NSOrderedSame){
            
            NSArray *map = @[@"KMH",@"MPH"];
            info.SpeedUnit = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"SpeedCamAlert"] == NSOrderedSame){
            
            NSArray *map = @[@"OFF",@"ON"];
            info.SpeedCamAlert = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"SpeedLimitAlert"] == NSOrderedSame){
            
            NSArray *map = @[@"OFF",@"50KMH",@"60KMH",@"70KMH",@"80KMH",@"90KMH",@"100KMH",@"110KMH",@"120KMH",@"130KMH",@"140KMH",@"150KMH",@"160KMH",@"170KMH",@"180KMH",@"190KMH",@"200KMH"];
            info.SpeedLimitAlert = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"SpeedPositionManagement"] == NSOrderedSame){
            
            NSArray *map = @[@"ADD",@"DEL_ONE",@"DEL_ALL"];
            info.SpeedPositionManagement = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"FWversion"] == NSOrderedSame){
            
            info.FWversion = sz;
        }
    }
    
    successCommandHandler(info);
}

#pragma mark - utilities

- (NSInteger)getMenuId:(NSString *)val MenuMap:(NSArray*)map{
    
    NSInteger     i;
    for (i = 0; i < [map count]; i++) {
        if ([val compare:map[i]] == NSOrderedSame)
            return i;
    }
    return -1;
}

@end
