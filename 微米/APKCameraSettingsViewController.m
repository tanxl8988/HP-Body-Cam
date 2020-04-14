//
//  APKCameraSettingsViewController.m
//  微米
//
//  Created by Mac on 17/4/10.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKCameraSettingsViewController.h"
#import "APKDVR.h"
#import "MBProgressHUD.h"
#import "APKAlertTool.h"
#import "APKDVRCommandFactory.h"
#import "APKDVRSettingInfo.h"

@interface APKCameraSettingsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *videoResolutionLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *videoResolutionSegment;
@property (weak, nonatomic) IBOutlet UIButton *videoResolutionButton;
@property (weak, nonatomic) IBOutlet UILabel *firmwareVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *firmwareVersionValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *appVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *appVersionValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *motionDetectionSensitivityLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *motionDetectionSensitivitySegment;
@property (weak, nonatomic) IBOutlet UILabel *flickerFrequencyLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *flickerFrequencySegment;
@property (weak, nonatomic) IBOutlet UILabel *exposureLabel;
@property (weak, nonatomic) IBOutlet UISlider *exposureSlider;
@property (weak, nonatomic) IBOutlet UILabel *syncTimeLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *syncTimeCell;
@property (weak, nonatomic) IBOutlet UILabel *exposureValueLabel;
@property (strong,nonatomic) APKDVRSettingInfo *settingInfo;
@property (nonatomic,retain) NSArray *resulutionArray;
@end

@implementation APKCameraSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = NSLocalizedString(@"HP Pixi Car", nil);
    self.titleLabel.text = NSLocalizedString(@"摄像机设置", nil);
    
    self.videoResolutionLabel.text = NSLocalizedString(@"影像解析度", nil);
    self.motionDetectionSensitivityLabel.text = NSLocalizedString(@"碰撞侦测", nil);
    self.flickerFrequencyLabel.text = NSLocalizedString(@"电源频率", nil);
    NSString *exposure = [NSString stringWithFormat:@"%@:",NSLocalizedString(@"曝光", nil)];
    self.exposureLabel.text = exposure;
    self.syncTimeLabel.text = NSLocalizedString(@"时间设置", nil);
    self.firmwareVersionLabel.text = NSLocalizedString(@"固件版本", nil);
    
    self.appVersionLabel.text = NSLocalizedString(@"App版本", nil);
    self.appVersionValueLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    self.videoResolutionSegment.selectedSegmentIndex = UISegmentedControlNoSegment;
    

    
    [self.motionDetectionSensitivitySegment removeAllSegments];
    [self.motionDetectionSensitivitySegment insertSegmentWithTitle:NSLocalizedString(@"关", nil) atIndex:0 animated:NO];
    [self.motionDetectionSensitivitySegment insertSegmentWithTitle:NSLocalizedString(@"低灵敏度", nil) atIndex:1 animated:NO];
    [self.motionDetectionSensitivitySegment insertSegmentWithTitle:NSLocalizedString(@"中灵敏度", nil) atIndex:2 animated:NO];
    [self.motionDetectionSensitivitySegment insertSegmentWithTitle:NSLocalizedString(@"高灵敏度", nil) atIndex:3 animated:NO];
    self.motionDetectionSensitivitySegment.selectedSegmentIndex = UISegmentedControlNoSegment;
    
    self.flickerFrequencySegment.selectedSegmentIndex = UISegmentedControlNoSegment;
    
    self.exposureSlider.minimumValue = 0;
    self.exposureSlider.maximumValue = 12;
    self.exposureValueLabel.text = @"0";
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self getSettingInfoTask:hud];
}

-(void)getSettingInfoTask:(MBProgressHUD *)hud
{
    __weak typeof(self)weakSelf = self;
    [[APKDVRCommandFactory getSettingInfoCommand] execute:^(id responseObject) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            weakSelf.settingInfo = responseObject;
            weakSelf.videoResolutionSegment.selectedSegmentIndex = weakSelf.settingInfo.videoRes;
            
            [weakSelf.videoResolutionButton setTitle:weakSelf.resulutionArray[weakSelf.settingInfo.videoRes] forState:UIControlStateNormal];
            
            
            weakSelf.motionDetectionSensitivitySegment.selectedSegmentIndex = weakSelf.settingInfo.GSensor;
            weakSelf.flickerFrequencySegment.selectedSegmentIndex = weakSelf.settingInfo.Flicker;
            weakSelf.exposureSlider.value = weakSelf.settingInfo.EV;
            weakSelf.firmwareVersionValueLabel.text = weakSelf.settingInfo.FWversion;
            NSString *exposureValue = [weakSelf exposureValueWithIndex:weakSelf.settingInfo.EV];
            weakSelf.exposureValueLabel.text = exposureValue;
            
            [hud hideAnimated:YES];
        });
        
    } failure:^(int rval) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
//            [APKAlertTool showAlertInViewController:weakSelf title:nil message:NSLocalizedString(@"获取摄像机信息失败", nil) confirmHandler:^(UIAlertAction *action) {
//                [weakSelf.navigationController popViewControllerAnimated:YES];
            [weakSelf getSettingInfoTask:hud];
//            }];
        });
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == self.syncTimeCell) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];

        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy$MM$dd$HH$mm$ss"];
        NSString *currentTime = [dateFormatter stringFromDate:today];
        __weak typeof(self)weakSelf = self;
        [[APKDVRCommandFactory setCommandWithProperty:@"TimeSettings" value:currentTime] execute:^(id responseObject) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [hud hideAnimated:YES];
                [APKAlertTool showAlertInViewController:weakSelf title:nil message:NSLocalizedString(@"设置成功！", nil) confirmHandler:^(UIAlertAction *action) {
                }];
            });
            
        } failure:^(int rval) {
           
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [hud hideAnimated:YES];
                [APKAlertTool showAlertInViewController:weakSelf title:nil message:NSLocalizedString(@"设置失败！", nil) confirmHandler:^(UIAlertAction *action) {
                }];
            });
        }];
    }
}

#pragma mark - actions

- (IBAction)didUpdateSegment:(UISegmentedControl *)sender {
    
    NSString *property = nil;
    NSString *value = nil;
    NSInteger lastValue = 0;
    BOOL needStopRecord = NO;
    void (^successHandler) (void);
    
    __weak typeof(self)weakSelf = self;
    if (sender == self.videoResolutionSegment) {
        
        lastValue = self.settingInfo.videoRes;
        property = @"Videores";
        NSArray * map = [NSArray arrayWithObjects:@"1080P30",@"1080P27D5",@"720P30",@"720P55", nil];
        value = map[sender.selectedSegmentIndex];
        needStopRecord = YES;
        successHandler = ^{
            weakSelf.settingInfo.videoRes = sender.selectedSegmentIndex;
        };
        
    }else if (sender == self.motionDetectionSensitivitySegment){
        
        lastValue = self.settingInfo.GSensor;
        property = @"GSensor";
        NSArray * map = [NSArray arrayWithObjects:@"OFF",@"LEVEL4",@"LEVEL2",@"LEVEL0", nil];
        value = map[sender.selectedSegmentIndex];
        successHandler = ^{
            weakSelf.settingInfo.GSensor = sender.selectedSegmentIndex;
        };
        
    }else if (sender == self.flickerFrequencySegment){
        
        lastValue = self.settingInfo.Flicker;
        property = @"Flicker";
        NSArray *map = @[@"50Hz",@"60Hz"];
        value = map[sender.selectedSegmentIndex];
        successHandler = ^{
            weakSelf.settingInfo.Flicker = sender.selectedSegmentIndex;
        };
    }
    
    [[APKDVRCommandFactory setCommandWithProperty:property value:value] execute:^(id responseObject) {
        
        successHandler();
        
    } failure:^(int rval) {
       
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [APKAlertTool showAlertInViewController:weakSelf title:nil message:NSLocalizedString(@"设置失败", nil) confirmHandler:^(UIAlertAction *action) {
                sender.selectedSegmentIndex = lastValue;
            }];
        });
    }];
}

- (IBAction)didFinishUpdateExposureSlider:(UISlider *)sender {
    
    NSInteger index= [self indexWithExposureSliderValue:sender.value];
    NSArray *map = [NSArray arrayWithObjects:@"EVN200", @"EVN167", @"EVN133", @"EVN100", @"EVN067", @"EVN033", @"EV0", @"EVP033", @"EVP067", @"EVP100", @"EVP133", @"EVP167", @"EVP200", nil];
    NSString *property = @"EV";
    NSString *value = map[index];
    
    __weak typeof(self)weakSelf = self;
    [[APKDVRCommandFactory setCommandWithProperty:property value:value] execute:^(id responseObject) {
        
    } failure:^(int rval) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [APKAlertTool showAlertInViewController:weakSelf title:nil message:NSLocalizedString(@"设置失败", nil) confirmHandler:^(UIAlertAction *action) {
                sender.value = weakSelf.settingInfo.EV;
                weakSelf.exposureValueLabel.text = [weakSelf exposureValueWithIndex:weakSelf.settingInfo.EV];
            }];
        });
    }];
}

- (IBAction)updateExposureSlider:(UISlider *)sender {
    
    NSInteger index= [self indexWithExposureSliderValue:sender.value];
    NSString *value = [self exposureValueWithIndex:index];
    self.exposureValueLabel.text = value;
}
- (IBAction)clickResulutionButton:(UIButton *)sender {
    
    __weak typeof(self)weakSelf = self;
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    for (int i = 0; i < self.resulutionArray.count; i++) {
        UIAlertAction* action = [UIAlertAction actionWithTitle:self.resulutionArray[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
            NSString *value = [weakSelf handleValueStr:weakSelf.resulutionArray[i]];
            
//            if ([APKDVR sharedInstance].modal == APK880xMachine) {
//                if (i == 2)
//                    value = @"1080P30";
//                else if(i == 3)
//                    value = @"1080P27D5";
//            }
            
            [[APKDVRCommandFactory setCommandWithProperty:@"Videores" value:value] execute:^(id responseObject) {
                
                [weakSelf.videoResolutionButton setTitle:weakSelf.resulutionArray[i] forState:UIControlStateNormal];
                if ([APKDVR sharedInstance].modal == APK880xMachine && (i == 2 || i == 3)) {
                    
                    [[NSUserDefaults standardUserDefaults] setObject:@(i) forKey:@"HDRSetDispaly"];
                }else
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"HDRSetDispaly"];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            } failure:^(int rval) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [APKAlertTool showAlertInViewController:weakSelf title:nil message:NSLocalizedString(@"设置失败", nil) confirmHandler:^(UIAlertAction *action) {
                    }];
                });
            }];
        }];
        
        [alertController addAction:action];
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(NSString *)handleValueStr:(NSString *)value
{
    NSString *returnValue = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
    returnValue = [returnValue stringByReplacingOccurrencesOfString:@"." withString:@"D"];
    returnValue = [returnValue stringByReplacingOccurrencesOfString:@"fps" withString:@""];
    
    return returnValue;
}

#pragma mark - Utilities

- (NSInteger)indexWithExposureSliderValue:(CGFloat)value{
    
    NSInteger index = 0;
    if (value >= 0 && value < 0.5) {
        index = 0;
    }else if (value >= 0.5 && value < 1.5){
        index = 1;
    }else if (value >= 1.5 && value < 2.5){
        index = 2;
    }else if (value >= 2.5 && value < 3.5){
        index = 3;
    }else if (value >= 3.5 && value < 4.5){
        index = 4;
    }else if (value >= 4.5 && value < 5.5){
        index = 5;
    }else if (value >= 5.5 && value < 6.5){
        index = 6;
    }else if (value >= 6.5 && value < 7.5){
        index = 7;
    }else if (value >= 7.5 && value < 8.5){
        index = 8;
    }else if (value >= 8.5 && value < 9.5){
        index = 9;
    }else if (value >= 9.5 && value < 10.5){
        index = 10;
    }else if (value >= 10.5 && value < 11.5){
        index = 11;
    }else if (value >= 11.5 && value <= 12){
        index = 12;
    }
    
    return index;
}

- (NSString *)exposureValueWithIndex:(NSInteger)index{
    
    if (index == -1) {
        
        return @"0";
    }
    
    NSArray *arr = @[@"-2",@"-1.67",@"-1.33",@"-1",@"-0.67",@"-0.33",@"0",@"0.33",@"0.67",@"1",@"1.33",@"1.67",@"2"];
    NSString *value = arr[index];
    return value;
}

-(NSArray *)resulutionArray
{
    if (!_resulutionArray) {
        
        
        if ([APKDVR sharedInstance].modal == APK880xMachine)
            _resulutionArray = @[@"1080P 30fps",@"1080P 27.5fps",@"1080P 30fps HDR",@"1080P 27.5fps HDR",@"720P 30fps",@"720P 27.5fps"];
        else if([APKDVR sharedInstance].modal == APKOldMachine)
            _resulutionArray = @[@"1080P 30fps",@"1080P 27.5fps",@"720P 30fps",@"720P 55fps"];
        else
            _resulutionArray = @[@"1080P 30fps",@"1080P 30fps HDR",@"720P 30fps"];
    }
    return _resulutionArray;
}

@end































