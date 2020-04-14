//
//  APKBaseViewController.m
//  保时捷项目
//
//  Created by Mac on 16/4/21.
//
//

#import "APKBaseViewController.h"

@interface APKBaseViewController ()

@end

@implementation APKBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (BOOL)shouldAutorotate{
    
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    
    return UIStatusBarStyleDefault;
}

@end
