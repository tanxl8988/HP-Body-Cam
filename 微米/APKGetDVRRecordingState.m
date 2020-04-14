//
//  APKGetDVRRecordingState.m
//  微米
//
//  Created by Mac on 17/9/11.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKGetDVRRecordingState.h"
#import "APKDVRCommandFactory.h"

@interface APKGetDVRRecordingState ()

@property (nonatomic) NSInteger count;
@property (copy,nonatomic) APKGetDVRRecordingStateCompletionHandler completionHandler;

@end

@implementation APKGetDVRRecordingState

#pragma mark - life circle

- (void)dealloc{
    
    NSLog(@"%s",__func__);
}

#pragma mark - public

- (void)execute:(APKGetDVRRecordingStateCompletionHandler)completionHandler{
    
    self.completionHandler = completionHandler;
    [self getRecordState];
}

#pragma mark - private

- (void)getRecordState{
    
//    if (self.count > 2) {
//
//        self.completionHandler(YES);
//        return;
//    }
    
//    self.count++;
    __weak typeof(self)weakSelf = self;
    [[APKDVRCommandFactory getRecordStateCommand] execute:^(id responseObject) {
        
        BOOL isRecording = [responseObject boolValue];
        weakSelf.completionHandler(isRecording);
        
    } failure:^(int rval) {
        
        [weakSelf getRecordState];
    }];
}

@end
