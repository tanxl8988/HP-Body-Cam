//
//  APKDVRFileCell.m
//  微米
//
//  Created by Mac on 17/4/21.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKDVRFileCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation APKDVRFileCell

- (void)configureCell:(APKDVRFile *)file{
    
    self.label.text = file.name;
    self.subLabel.text = file.size;
    
    if (file.thumbnailPath) {
        UIImage *image = [UIImage imageWithContentsOfFile:file.thumbnailPath];
//        NSString *str = [NSString stringWithFormat:@"%@/%@",@"http://192.72.1.1",file.fileDownloadPath];
//        [self.imagev setImageWithURL:[NSURL URLWithString:file.thumbnailDownloadPath] placeholderImage:nil];
        
        self.imagev.image = image;
        
        if ([file.name containsString:@"MP3"]) {
            
            self.imagev.image = [UIImage imageNamed:@"type_all"];
        }
    }else
         self.imagev.image = [UIImage imageNamed:@"type_all"];

}

@end
