//
//  APKRetrieveDVRFileListing.m
//  Aigo
//
//  Created by Mac on 17/7/13.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKRetrieveDVRFileListing.h"
#import "APKDVRCommandFactory.h"
#import "APKDVRFileDownloadTask.h"
#import "APKMOCManager.h"
#import "LocalFileInfo.h"

@interface APKRetrieveDVRFileListing ()

@property (nonatomic) APKFileType fileType;
@property (nonatomic) APKCameraType cameraType;
@property (strong,nonatomic) NSMutableArray *fileArray;
@property (nonatomic) NSInteger numberOfRetrievedFiles;

@end

@implementation APKRetrieveDVRFileListing

- (void)dealloc
{
//    NSLog(@"%s",__func__);
}

#pragma mark - private 

- (void)retrieveFileListingSuccess:(void(^)(void))success failure:(void(^)(int rval))failure{
    
    __weak typeof(self)weakSelf = self;
    [[APKDVRCommandFactory getFileListCommandWithCameraType:self.cameraType fileType:self.fileType count:10 offset:self.fileArray.count] execute:^(id responseObject) {
        
        NSArray *files = responseObject;
        if (files.count > 0) {
            
            [weakSelf.fileArray addObjectsFromArray:files];
            [weakSelf retrieveFileListingSuccess:success failure:failure];
            
        }else{
            
            //排序
            NSComparator cmptr = ^(id obj1, id obj2){
                
                APKDVRFile *file1 = obj1;
                APKDVRFile *file2 = obj2;
                return [file2.fullStyleDate compare:file1.fullStyleDate];
            };
            [weakSelf.fileArray sortUsingComparator:cmptr];
            success();
        }
        
    } failure:^(int rval) {
       
        failure(rval);
    }];
}

- (void)loadDownloadStateForFileArray:(NSArray *)fileArray success:(APKRetrieveDVRFileListingSuccessHandler)success{
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [context setParentContext:[APKMOCManager sharedInstance].context];
    [context performBlock:^{
       
        for (APKDVRFile *file in fileArray) {
            
            LocalFileInfo *info = [LocalFileInfo retrieveLocalFileInfoWithName:file.name type:file.type context:context];
            file.isDownloaded = info ? YES : NO;
        }
        
        success(fileArray);
    }];
}

- (void)loadThumbnailForFileArray:(NSArray *)fileArray success:(APKRetrieveDVRFileListingSuccessHandler)success failure:(APKRetrieveDVRFileListingFailureHandler)failure{
    
    __block NSInteger count = fileArray.count;
    for (APKDVRFile *file in fileArray) {
        
        NSString *thumbnailName = [NSString stringWithFormat:@"thumb_%@",file.thumbnailDownloadPath.lastPathComponent];
        NSString *thumbnailPath = [NSTemporaryDirectory() stringByAppendingPathComponent:thumbnailName];
        __weak typeof(self)weakSelf = self;
        [APKDVRFileDownloadTask taskWithPriority:kDownloadPriorityLow sourcePath:file.thumbnailDownloadPath targetPath:thumbnailPath progress:^(float progress, NSString *info) {
            
        } success:^{
            
            file.thumbnailPath = thumbnailPath;
            count--;
            if (count == 0) {
                
                if ([APKMOCManager sharedInstance].context) {
                    
                    [weakSelf loadDownloadStateForFileArray:fileArray success:success];
                    
                }else{
                    
                    success(fileArray);
                }
            }
            
        } failure:^{
            
            count--;
            if (count == 0) {
                
                if ([APKMOCManager sharedInstance].context) {
                    
                    [weakSelf loadDownloadStateForFileArray:fileArray success:success];
                    
                }else{
                    
                    success(fileArray);
                }
            }
        }];
    }
}

- (NSArray *)retrieveFileArrayWithCount:(NSInteger)count{
    
    NSRange range;
    if (self.fileArray.count >= count) {
        
        range = NSMakeRange(0, count);
        
    }else{
        
        range = NSMakeRange(0, self.fileArray.count);
    }
    
    NSArray *fileArray = [self.fileArray subarrayWithRange:range];
    [self.fileArray removeObjectsInRange:range];
    return fileArray;
}

#pragma mark - public method

- (void)executeWithFileType:(APKFileType)fileType cameraType:(APKCameraType)cameraType offset:(NSInteger)offset count:(NSInteger)count success:(APKRetrieveDVRFileListingSuccessHandler)success failure:(APKRetrieveDVRFileListingFailureHandler)failure{
    
    self.fileType = fileType;
    self.cameraType = cameraType;
    if (offset == 0) {//offset == 0表示需要刷新列表，要重新获取数据
        
        [self.fileArray removeAllObjects];
        __weak typeof(self)weakSelf = self;
        [self retrieveFileListingSuccess:^{
            
            NSArray *fileArray = [weakSelf retrieveFileArrayWithCount:count];
            if (fileArray.count == 0) {
                
                success(fileArray);
                
            }else{
                
                [weakSelf loadThumbnailForFileArray:fileArray success:success failure:failure];
            }
            
        } failure:^(int rval) {
            
            failure();
        }];
        
    }else{
        
        NSArray *fileArray = [self retrieveFileArrayWithCount:count];
        if (fileArray.count == 0) {
            
            success(fileArray);
            
        }else{
            
            [self loadThumbnailForFileArray:fileArray success:success failure:failure];
        }
    }
}

#pragma mark - getter 

- (NSMutableArray *)fileArray{
    
    if (!_fileArray) {
        
        _fileArray = [[NSMutableArray alloc] init];
    }
    
    return _fileArray;
}

@end
