//
//  APKDVRFileCell.h
//  微米
//
//  Created by Mac on 17/4/21.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APKDVRFile.h"

@interface APKDVRFileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imagev;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;

- (void)configureCell:(APKDVRFile *)file;

@end
