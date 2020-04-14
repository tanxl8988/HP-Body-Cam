//
//  APKModifyWifiViewController.m
//  微米
//
//  Created by Mac on 17/4/20.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKModifyWifiViewController.h"
#import "APKDVR.h"
#import "MBProgressHUD.h"
#import "APKAlertTool.h"
#import "APKDVRCommandFactory.h"

typedef enum : NSUInteger {
    APKWifiInfoStateFine,
    APKWifiInfoStateTooLong,
    APKWifiInfoStateTooShort,
} APKWifiInfoState;

@interface APKModifyWifiViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *contentCell;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *wifiNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *wifiNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *wifiPasswordLabel;
@property (weak, nonatomic) IBOutlet UITextField *wifiPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (strong,nonatomic) NSString *account;
@property (strong,nonatomic) NSString *password;
@property (nonatomic) APKWifiInfoState wifiNameState;
@property (nonatomic) APKWifiInfoState wifiPasswordState;

@end

@implementation APKModifyWifiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = NSLocalizedString(@"HP Pixi Car", nil);
    self.titleLabel.text = NSLocalizedString(@"Wi-Fi设置", nil);
    self.wifiNameLabel.text = NSLocalizedString(@"Wi-Fi名称", nil);
    self.wifiPasswordLabel.text = NSLocalizedString(@"Wi-Fi密码", nil);
    [self.updateButton setTitle:NSLocalizedString(@"更新", nil) forState:UIControlStateNormal];
    self.updateButton.enabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUIWithNotification:) name:UITextFieldTextDidChangeNotification object:nil];

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self)weakSelf = self;
    [[APKDVRCommandFactory getWifiInfoCommand] execute:^(id responseObject) {
       
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSDictionary *info = responseObject;
            weakSelf.account = info.allKeys.firstObject;
            weakSelf.password = info.allValues.firstObject;
            weakSelf.wifiNameTextField.text = weakSelf.account;
            weakSelf.wifiPasswordTextField.text = weakSelf.password;
            [hud hideAnimated:YES];
        });
        
    } failure:^(int rval) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [APKAlertTool showAlertInViewController:weakSelf title:nil message:NSLocalizedString(@"获取摄像机信息失败", nil) confirmHandler:^(UIAlertAction *action) {
                
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
            [hud hideAnimated:YES];
        });
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    NSLog(@"%s",__func__);
}

#pragma mark - UI

- (void)showTextHUDWithMessage:(NSString *)message{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.contentCell animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.numberOfLines = 0;
    hud.label.text = message;
    [hud hideAnimated:YES afterDelay:1.5];
}

- (void)updateUIWithNotification:(NSNotification *)notification{
    
    if ([notification.name isEqualToString:UITextFieldTextDidChangeNotification]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([self.wifiNameTextField.text isEqualToString:self.account] && [self.wifiPasswordTextField.text isEqualToString:self.password]) {
                
                self.updateButton.enabled = NO;
                
            }else{
                
                if (self.wifiNameTextField.text.length == 0) {
                    self.wifiNameState = APKWifiInfoStateTooShort;
                }
                else if (self.wifiNameTextField.text.length > 27){
                    self.wifiNameState = APKWifiInfoStateTooLong;
                }
                else{
                    self.wifiNameState = APKWifiInfoStateFine;
                }
                
                if (self.wifiPasswordTextField.text.length < 8) {
                    self.wifiPasswordState = APKWifiInfoStateTooShort;
                }
                else if (self.wifiPasswordTextField.text.length > 32){
                    self.wifiPasswordState = APKWifiInfoStateTooLong;
                }
                else{
                    self.wifiPasswordState = APKWifiInfoStateFine;
                }
                
                if (self.wifiNameState == APKWifiInfoStateFine && self.wifiPasswordState == APKWifiInfoStateFine) {
                    self.updateButton.enabled = YES;
                }
                else{
                    self.updateButton.enabled = NO;
                }
            }
        });
    }
}

#pragma mark - actions

- (IBAction)clickUpdateButton:(UIButton *)sender {
    
    [self.view endEditing:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    [[APKDVRCommandFactory modifyWifiCommandWithAccount:self.wifiNameTextField.text password:self.wifiPasswordTextField.text] execute:^(id responseObject) {
        
        [[APKDVRCommandFactory rebotWifiCommand] execute:^(id responseObject) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [APKAlertTool showAlertInViewController:weakSelf title:NSLocalizedString(@"设置成功！", nil) message:NSLocalizedString(@"摄像机将会重启Wi-Fi", nil) confirmHandler:^(UIAlertAction *action) {
                    [APKDVR sharedInstance].isConnected = NO;
                }];
                [hud hideAnimated:YES];
            });
            
        } failure:^(int rval) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [APKAlertTool showAlertInViewController:weakSelf title:NSLocalizedString(@"设置成功！", nil) message:NSLocalizedString(@"摄像机将会重启Wi-Fi", nil) confirmHandler:^(UIAlertAction *action) {
                    [APKDVR sharedInstance].isConnected = NO;
                }];
                [hud hideAnimated:YES];
            });
        }];
        
    } failure:^(int rval) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [APKAlertTool showAlertInViewController:weakSelf title:nil message:NSLocalizedString(@"设置失败！", nil) confirmHandler:^(UIAlertAction *action) {
            }];
            [hud hideAnimated:YES];
        });
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    BOOL isShouldChangeCharacters = YES;
    
    if (![string isEqualToString:@""]) {
        
        char ch = [string characterAtIndex:0];
        if (!(ch >= '0' && ch <= '9') && !(ch >= 'a' && ch <= 'z') && !(ch >= 'A' && ch <= 'Z')) {
            
            isShouldChangeCharacters = NO;
        }
    }
    
    return isShouldChangeCharacters;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    if (textField == self.wifiNameTextField) {
        
        [self.wifiPasswordTextField becomeFirstResponder];
    }
    
    return YES;
}

#pragma mark - setter

- (void)setWifiNameState:(APKWifiInfoState)wifiNameState{
    
    if (wifiNameState == _wifiNameState)
        return;
    _wifiNameState = wifiNameState;
    
    if (wifiNameState == APKWifiInfoStateTooLong) {
        
        [self showTextHUDWithMessage:NSLocalizedString(@"Wi-Fi名称超过长度限制", nil)];
    }
}

- (void)setWifiPasswordState:(APKWifiInfoState)wifiPasswordState{
    
    if (wifiPasswordState == _wifiPasswordState)
        return;
    _wifiPasswordState = wifiPasswordState;
    
    if (wifiPasswordState == APKWifiInfoStateTooLong) {
        
        [self showTextHUDWithMessage:NSLocalizedString(@"密码过长", nil)];
    }
    else if (wifiPasswordState == APKWifiInfoStateTooShort){
        
        [self showTextHUDWithMessage:NSLocalizedString(@"请输入至少8个字符", nil)];
    }
}



@end
