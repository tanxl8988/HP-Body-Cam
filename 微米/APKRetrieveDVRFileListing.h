//
//  APKRetrieveDVRFileListing.h
//  Aigo
//
//  Created by Mac on 17/7/13.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APKDVRFile.h"

typedef void(^APKRetrieveDVRFileListingSuccessHandler)(NSArray<APKDVRFile *> *fileArray);
typedef void(^APKRetrieveDVRFileListingFailureHandler)(void);

@interface APKRetrieveDVRFileListing : NSObject

- (void)executeWithFileType:(APKFileType)fileType cameraType:(APKCameraType)cameraType offset:(NSInteger)offset count:(NSInteger)count success:(APKRetrieveDVRFileListingSuccessHandler)success failure:(APKRetrieveDVRFileListingFailureHandler)failure;

@end
