//
//  APKCameraControlViewController.m
//  微米
//
//  Created by Mac on 17/4/10.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKCameraControlViewController.h"

@interface APKCameraControlViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *networkConfigureButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraSettingsButton;



@end

@implementation APKCameraControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    
    self.navigationItem.title = NSLocalizedString(@"HP Pixi Car", nil);
    self.titleLabel.text = NSLocalizedString(@"摄像机与Wi-Fi设置", nil);
    
    [self.networkConfigureButton setTitle:NSLocalizedString(@"Wi-Fi设置", nil) forState:UIControlStateNormal];
    [self.cameraSettingsButton setTitle:NSLocalizedString(@"摄像机设置", nil) forState:UIControlStateNormal];
}

@end
