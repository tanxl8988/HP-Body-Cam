//
//  APKCameraFile.h
//  AITDemo
//
//  Created by Mac on 16/9/5.
//  Copyright © 2016年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : int16_t {
    APKFileTypeAll = 0,
    APKFileTypeEvent,
    APKFileTypeVideo,
    APKFileTypeCapture,
} APKFileType;

typedef enum : NSUInteger {
    APKCameraTypeFront,
    APKCameraTypeRear,
} APKCameraType;

typedef enum : NSUInteger {
    kDownloadNone = 0,
    kDownloadFailure,
    kDownloadSuccess,
    kDownloading,
} APKCameraFileDownloadState;

@interface APKDVRFile : NSObject

@property (nonatomic) APKFileType type;
@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSString *originalName;
@property (strong,nonatomic) NSString *format;
@property (strong,nonatomic) NSString *size;
@property (strong,nonatomic) NSString *attr;
@property (strong,nonatomic) NSString *thumbnailDownloadPath;
@property (strong,nonatomic) NSString *fileDownloadPath;
@property (strong,nonatomic) NSString *thumbnailPath;
@property (strong,nonatomic) NSString *previewPath;
@property (strong,nonatomic) NSDate *fullStyleDate;
@property (strong,nonatomic) NSDate *shortStyleDate;
@property (strong,nonatomic) NSString *date;
@property (strong,nonatomic) NSString *time;
@property (strong,nonatomic) NSString *duration;
@property (nonatomic) BOOL isOnceDownloaded;
@property (nonatomic) BOOL isDownloaded;
@property (nonatomic) BOOL isCollected;
@property (nonatomic) float downloadProgress;
@property (nonatomic) APKCameraFileDownloadState downloadState;

@end
