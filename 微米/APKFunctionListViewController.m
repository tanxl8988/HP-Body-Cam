//
//  APKFunctionListViewController.m
//  微米
//
//  Created by Mac on 17/4/10.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKFunctionListViewController.h"
#import "APKDVR.h"
#import "MBProgressHUD.h"
#import "APKCameraBrowserViewController.h"
#import "APKLocalAlbumViewController.h"
#import "APKAlertTool.h"
#import <Photos/Photos.h>

@interface APKFunctionListViewController ()

@property (weak, nonatomic) IBOutlet UILabel *cameraControlLabel;
@property (weak, nonatomic) IBOutlet UILabel *cameraPreviewLabel;
@property (weak, nonatomic) IBOutlet UILabel *cameraFileLabel;
@property (weak, nonatomic) IBOutlet UILabel *localFileLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionL;
@property (nonatomic) BOOL isVisible;
@property (nonatomic) CGFloat rowHeight;

@end

@implementation APKFunctionListViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        [[APKDVR sharedInstance] addObserver:self forKeyPath:@"isConnected" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = NSLocalizedString(@"HP Pixi Car", nil);
    self.cameraControlLabel.text = NSLocalizedString(@"摄像机与Wi-Fi设置", nil);
    self.cameraPreviewLabel.text = NSLocalizedString(@"摄像机预览", nil);
    self.cameraFileLabel.text = NSLocalizedString(@"摄像机文件", nil);
    self.localFileLabel.text = NSLocalizedString(@"本地文件", nil);
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    
    self.tableView.rowHeight = 114;
    
    self.versionL.text = [NSString stringWithFormat:@"%@1.5",NSLocalizedString(@"App版本:", nil)];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    self.isVisible = YES;
}

- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
    self.isVisible = NO;
}

- (void)dealloc
{
    [[APKDVR sharedInstance] removeObserver:self forKeyPath:@"isConnected"];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"isConnected"]) {
        
        BOOL isConnected = [change[@"new"] boolValue];
        if (!isConnected && !self.isVisible) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        }
    }
}

#pragma mark - private method

- (void)showGetPHAuthorizationAlert{
    
    [APKAlertTool showAlertInViewController:self title:nil message:NSLocalizedString(@"请允许\"HP Pixi Car\"访问iPhone的\"照片\"。", nil) cancelHandler:nil confirmHandler:^(UIAlertAction *action) {
        
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        UIApplication *app = [UIApplication sharedApplication];
        if ([app canOpenURL:url]) {
            
            NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
            NSInteger iosVersionNumber = [[[iosVersion componentsSeparatedByString:@"."] firstObject] integerValue];
            if (iosVersionNumber >= 10) {
                
                [app openURL:url options:@{} completionHandler:^(BOOL success) { /*do nothing*/ }];
                
            }else{
                
                [app openURL:url];
            }
        }
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    return self.rowHeight;
//}

#pragma mark - segue

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    
    if ([identifier isEqualToString:@"checkLocalFileListing"]) {
        
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status != PHAuthorizationStatusAuthorized) {
            
            if (status == PHAuthorizationStatusDenied) {
                
                [self showGetPHAuthorizationAlert];
                
            }else{
                
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    
                }];
            }
            return NO;
        }
    }
    else{
        
        if (![APKDVR sharedInstance].isConnected) {
            
            [APKAlertTool showAlertInViewController:self title:nil message:NSLocalizedString(@"未连接摄像机", nil) confirmHandler:^(UIAlertAction *action) {
            }];
            return NO;
        }
    }
    return YES;
}

#pragma mark - getter

- (CGFloat)rowHeight{
    
    if (_rowHeight == 0) {
        
        CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
        CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
        CGFloat navigationBarHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
        _rowHeight = (screenHeight - statusBarHeight - navigationBarHeight) / 4;
    }
    return _rowHeight;
}


@end
