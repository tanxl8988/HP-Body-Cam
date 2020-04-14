//
//  APKRecordStateResponseObjectHandler.m
//  微米
//
//  Created by Mac on 17/8/1.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKRecordStateResponseObjectHandler.h"

@implementation APKRecordStateResponseObjectHandler

- (void)handle:(id)responseObject successCommandHandler:(APKSuccessCommandHandler)successCommandHandler failureCommandHandler:(APKFailureCommandHandler)failureCommandHandler{
    
    NSData *data = responseObject;
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",msg);
    NSArray *arr = [msg componentsSeparatedByString:@"\n"];
    if (arr.count > 0) {
        
        int rval = [arr.firstObject intValue];
        if (rval == 0) {
            
            for (NSString *element in arr) {
                
                if ([element containsString:@"Camera.Preview.MJPEG.status.record"]) {
                    
                    NSArray *infoArr = [element componentsSeparatedByString:@"="];
                    NSString *recordInfo = infoArr.lastObject;
                    BOOL isRecording = [recordInfo isEqualToString:@"Recording"] ? YES : NO;
                    successCommandHandler(@(isRecording));
                }
            }
            
        }else{
            
            failureCommandHandler(rval);
        }
        
    }else{
        
        failureCommandHandler(-1);
    }
}

@end
