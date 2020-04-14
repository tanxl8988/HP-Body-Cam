//
//  APKRetrieveLocalFileListing.m
//  万能AIT
//
//  Created by Mac on 17/7/28.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKRetrieveLocalFileListing.h"
#import "APKMOCManager.h"
#import "LocalFileInfo.h"

@interface APKRetrieveLocalFileListing ()

@property (nonatomic) BOOL shouldRemoveObserver;
@property (copy,nonatomic) APKRetrieveLocalFileListingCompletionHandler completionHandler;
@property (nonatomic) NSInteger offset;
@property (nonatomic) NSInteger count;

@end

@implementation APKRetrieveLocalFileListing

#pragma mark - life circle

- (void)dealloc
{
    if (self.shouldRemoveObserver) {
        
        [[APKMOCManager sharedInstance] removeObserver:self forKeyPath:@"context"];
    }
}

#pragma mark - private method

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"context"]) {
        
        if ([APKMOCManager sharedInstance].context) {
            
            [self executeRetrieveOperation];
        }
    }
}
- (void)executeRetrieveOperation{
    
    NSManagedObjectContext *context = [APKMOCManager sharedInstance].context;
    __weak typeof(self)weakSelf = self;
    [context performBlock:^{
        
        [LocalFileInfo retrieveLocalfileInfosWithOffset:weakSelf.offset count:weakSelf.count context:context completionHandler:^(NSAsynchronousFetchResult * _Nonnull result) {
            
            NSMutableArray *fileArray = [[NSMutableArray alloc] init];
            NSMutableArray *assets = [[NSMutableArray alloc] init];
            for (LocalFileInfo *info in result.finalResult) {
                
                if (info.type == APKFileTypeEvent) {
                    
                    APKLocalFile *file = [[APKLocalFile alloc] init];
                    file.info = info;
                    [fileArray addObject:file];
                    continue;
                }
                PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[info.localIdentifier] options:nil].firstObject;
                if (asset) {
                    
                    APKLocalFile *file = [[APKLocalFile alloc] init];
                    file.info = info;
                    file.asset = asset;
                    [fileArray addObject:file];
                    [assets addObject:asset];
                    
                }else{
                    
                    [context deleteObject:info];
                }
            }
            
            NSError *error = nil;
            if (![context save:&error]) {
                
                abort();
            }
            
            weakSelf.completionHandler(fileArray,assets);
        }];
    }];
}

#pragma mark - public method

- (void)executeWithOffset:(NSInteger)offset count:(NSInteger)count completionHandler:(APKRetrieveLocalFileListingCompletionHandler)completionHandler{
    
    self.completionHandler = completionHandler;
    self.offset = offset;
    self.count = count;
    if ([APKMOCManager sharedInstance].context) {
        
        [self executeRetrieveOperation];
        
    }else{
            
        self.shouldRemoveObserver = YES;
        [[APKMOCManager sharedInstance] addObserver:self forKeyPath:@"context" options:NSKeyValueObservingOptionNew context:nil];
    }
}

@end
