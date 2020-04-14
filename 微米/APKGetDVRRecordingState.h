//
//  APKGetDVRRecordingState.h
//  微米
//
//  Created by Mac on 17/9/11.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^APKGetDVRRecordingStateCompletionHandler)(BOOL isRecording);

@interface APKGetDVRRecordingState : NSObject

- (void)execute:(APKGetDVRRecordingStateCompletionHandler)completionHandler;

@end
