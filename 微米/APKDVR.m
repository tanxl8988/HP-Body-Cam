//
//  APKDVR.m
//  AITBrain
//
//  Created by Mac on 17/3/20.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKDVR.h"
#import "APKWifiTool.h"
#import "AFNetworking.h"
#import "APKDVRCommandFactory.h"
@interface APKDVR ()

@end

@implementation APKDVR

#pragma mark - init

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationState:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationState:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        __weak typeof(self)weakSelf = self;
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            [weakSelf updateConnectState];
        }];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

static APKDVR *instance = nil;
+ (instancetype)sharedInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[APKDVR alloc] init];
    });
    
    return instance;
}

#pragma mark - getter

#pragma mark - public method

#pragma mark - private method

- (void)updateConnectState{
    
//    NSString *aitWifiAddress = @"192.72.1.1";
//    NSString *wifiAddress = [APKWifiTool getWifiAddress];
//    NSString *wifiName = [APKWifiTool getWifiName];
//    NSLog(@"wifiName : %@",wifiName);
//    self.isConnected = [wifiAddress isEqualToString:aitWifiAddress];
    
    NSString *aitWifiAddress = @"192.72.1.1";
    NSString *wifiAddress = [APKWifiTool getWifiAddress];
    //    NSString *aitWifiAddress = @"192.168.2.1";
    BOOL isConnectedDVRWifi = [wifiAddress isEqualToString:aitWifiAddress];
    if (isConnectedDVRWifi && !self.isConnected) {
        
        [[APKDVRCommandFactory getSettingInfoCommand] execute:^(id responseObject) {
            
            self.settingInfo = responseObject;
            NSString *version = self.settingInfo.FWversion;
            if ([version hasPrefix:@"f880x"]) {
                if ([version containsString:@"CN"])
                    self.modal = APKF880x_CNOrF860wMachine;
                else
                    self.modal = APK880xMachine;
            }
            else if([version hasPrefix:@"f860w"]){
                self.modal = APKF880x_CNOrF860wMachine;
            }else
                self.modal = APKOldMachine;
                
            self.isConnected = YES;
            
        } failure:^(int rval) {
            
        }];
    }
    else if (!isConnectedDVRWifi && self.isConnected){
        
        self.settingInfo = nil;
        self.isConnected = NO;
    }
}

- (void)handleApplicationState:(NSNotification *)notification{
    
    if ([notification.name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
    
        [self updateConnectState];
        
    }else if([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]){

    }
}

@end
