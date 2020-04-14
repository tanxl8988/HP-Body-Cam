//
//  APKDVRCommand.m
//  Aigo
//
//  Created by Mac on 17/6/30.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKDVRCommand.h"
#import "AFNetworking.h"

static AFHTTPSessionManager *manager = nil;

@implementation APKDVRCommand

+ (APKDVRCommand *)commandWithUrl:(NSString *)url responseObjectHandler:(APKDVRCommandResponseObjectHandler *)responseObjectHandler{
    
    APKDVRCommand *command = [[APKDVRCommand alloc] init];
    command.url = url;
    command.responseObjectHandler = responseObjectHandler;
    return command;
}

- (void)dealloc
{
//    NSLog(@"%s",__func__);
}

#pragma mark - public method

- (void)execute:(APKCommandSuccessHandler)success failure:(APKCommandFailureHandler)failure{
    
    if (!manager) {
        
        manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/xml",nil];
        manager.requestSerializer.timeoutInterval = 10;//10s超时
    }
    
    NSLog(@"执行：%@",self.url);
    
    [manager GET:self.url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString * str  =[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        [self.responseObjectHandler handle:responseObject successCommandHandler:^(id result) {
        
            dispatch_async(dispatch_get_main_queue(), ^{
                
                success(result);
            });
            
        } failureCommandHandler:^(int rval) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                failure(rval);
            });
        }];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            failure(-1);
        });
    }];
}

@end
