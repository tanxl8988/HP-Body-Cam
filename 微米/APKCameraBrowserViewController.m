//
//  APKCameraBrowserViewController.m
//  微米
//
//  Created by Mac on 17/4/10.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKCameraBrowserViewController.h"
#import "APKDVRFileCell.h"
#import "MBProgressHUD.h"
#import "MWPhotoBrowser.h"
#import "APKVideoPlayer.h"
#import "APKDownloadInfoView.h"
#import "APKRetrieveDVRFileListing.h"
#import "APKBatchDownload.h"
#import "APKMOCManager.h"
#import "APKBatchDelete.h"
#import "APKAlertTool.h"
#import "APKDVRFileDownloadTask.h"
#import "APKDVRCommandFactory.h"
#import <AVKit/AVKit.h>
#import "APKGetDVRRecordingState.h"
#import "APKDVR.h"
#import "MobileVLCKit/VLCMediaPlayer.h"

typedef enum : NSUInteger {
    kAPKRequestDVRFileStateNone,
    kAPKRequestDVRFileStateRefreshPage,//刷新页面（下拉刷新）
    kAPKRequestDVRFileStateLoadMore,//上拉加载更多
} APKRequestDVRFileState;

@interface APKCameraBrowserViewController ()<UITableViewDataSource,UITableViewDelegate,MWPhotoBrowserDelegate>

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *openButton;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *fileTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *switchFileTypeButton1;
@property (weak, nonatomic) IBOutlet UIButton *switchFileTypeButton2;
@property (weak, nonatomic) IBOutlet UIButton *switchFileTypeButton3;
@property (weak, nonatomic) IBOutlet UIView *fileTypeView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *flower;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (strong,nonatomic) UIRefreshControl *refreshControl;
@property (strong,nonatomic) NSMutableArray *dataSource;
@property (assign) APKRequestDVRFileState requestState;
@property (nonatomic) BOOL isNoMoreFiles;
@property (strong,nonatomic) NSMutableArray *photos;
@property (strong,nonatomic) NSMutableArray *previewFiles;
@property (weak,nonatomic) MWPhotoBrowser *photoBrowser;
@property (strong,nonatomic) APKRetrieveDVRFileListing *retrieveFileListing;
@property (nonatomic) APKFileType fileType;
@property (nonatomic) APKCameraType cameraType;
@property (strong,nonatomic) APKBatchDownload *batchDownload;
@property (strong,nonatomic) APKBatchDelete *batchDelete;
@property (weak,nonatomic) APKDVRFileDownloadTask *downloadTask;
@property (strong,nonatomic) APKGetDVRRecordingState *getRecordState;
@property (nonatomic,assign) BOOL isJoinPlayBackVC;
@end

@implementation APKCameraBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = NSLocalizedString(@"HP Pixi Car", nil);
    self.titleLabel.text = NSLocalizedString(@"摄像机文件", nil);
    [self.cancelButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    self.tipsLabel.text = nil;
    
//    self.saveButton.layer.shadowOffset = CGSizeMake(0, 2);
//    self.saveButton.layer.shadowOpacity = 0.80;
//    
//    self.deleteButton.layer.shadowOffset = CGSizeMake(0, 2);
//    self.deleteButton.layer.shadowOpacity = 0.80;
//    
//    self.openButton.layer.shadowOffset = CGSizeMake(0, 2);
//    self.openButton.layer.shadowOpacity = 0.80;
//    
//    self.switchCameraButton.layer.shadowOffset = CGSizeMake(0, 2);
//    self.switchCameraButton.layer.shadowOpacity = 0.80;
//    
//    self.fileTypeButton.layer.shadowOffset = CGSizeMake(0, 2);
//    self.fileTypeButton.layer.shadowOpacity = 0.80;
    
    self.fileTypeView.layer.shadowOffset = CGSizeMake(0, 2);
    self.fileTypeView.layer.shadowOpacity = 0.80;
    self.fileTypeView.hidden = YES;

    [self.fileTypeButton setTitle:@"VIDEO" forState:UIControlStateNormal];
    [self.switchFileTypeButton1 setTitle:@"VIDEO" forState:UIControlStateNormal];
    [self.switchFileTypeButton2 setTitle:@"AUDIO" forState:UIControlStateNormal];
    [self.switchFileTypeButton3 setTitle:@"PHOTO" forState:UIControlStateNormal];

    self.tableView.rowHeight = 101;
    self.tableView.editing = YES;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshPage) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    [self.tableView sendSubviewToBack:self.refreshControl];
    
    self.fileType = APKFileTypeVideo;
    self.cameraType = APKCameraTypeFront;

}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshPage];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.isJoinPlayBackVC == NO || !self.isJoinPlayBackVC) {
        [[APKDVRCommandFactory setCommandWithProperty:@"Playback" value:@"exit"] execute:^(id responseObject) {
            
//            if ([APKDVR sharedInstance].isRecord == YES) {
//                [[APKDVRCommandFactory setCommandWithProperty:@"Video" value:@"record"] execute:^(id responseObject) {
//
//                } failure:^(int rval) {
//
//                }];
//            }
        } failure:^(int rval) {
        }];
    }
    self.isJoinPlayBackVC = NO;
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

- (BOOL)checkDownloadAuthority{
    
    if (self.tableView.indexPathsForSelectedRows.count == 0 || ![APKMOCManager sharedInstance].context) {
        
        return NO;
    }
    
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

    return YES;
}

- (void)updateSelectInfo{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSInteger count = self.tableView.indexPathsForSelectedRows.count;
        if (count == 0) {
            
            self.cancelButton.hidden = YES;
            self.openButton.enabled = NO;
            self.deleteButton.enabled = NO;
            self.saveButton.enabled = NO;
            
        }else{
            
            self.cancelButton.hidden = NO;
            self.openButton.enabled = count == 1;
            self.deleteButton.enabled = YES;
            self.saveButton.enabled = YES;
        }
    });
}

- (void)refreshPage{
    
    if (self.requestState == kAPKRequestDVRFileStateNone) {
        
        self.requestState = kAPKRequestDVRFileStateRefreshPage;
        self.isNoMoreFiles = NO;
        [self.dataSource removeAllObjects];
        [self.tableView reloadData];
        [self clickCancelButton:nil];
        [self updateSelectInfo];
        [self requestFileList];
        
    }else{
        
        [self.refreshControl endRefreshing];
    }
}

- (void)requestFileList{
    
    MBProgressHUD *hud = nil;
    if (self.requestState == kAPKRequestDVRFileStateRefreshPage && !self.refreshControl.isRefreshing) {
        
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    __weak typeof(self)weakSelf = self;
    APKRetrieveDVRFileListingSuccessHandler success = ^(NSArray<APKDVRFile *> *fileArray){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (fileArray.count > 0) {
                
                NSMutableArray *dataArray = [weakSelf seperateDataArrayWithFileType:fileArray];
                
                NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:dataArray.count];
                NSInteger startIndex = weakSelf.dataSource.count;
                for (int i = 0; i < dataArray.count; i++) {
                    
                    NSInteger row = startIndex + i;
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                    [indexPaths addObject:indexPath];
                }
                
                [weakSelf.dataSource addObjectsFromArray:dataArray];
                
                [weakSelf.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
//                [weakSelf.tableView reloadData];
            }
            
            if (weakSelf.refreshControl.isRefreshing) [weakSelf.refreshControl endRefreshing];
            if (weakSelf.flower.isAnimating) [weakSelf.flower stopAnimating];
            if (hud) [hud hideAnimated:YES];
            weakSelf.requestState = kAPKRequestDVRFileStateNone;
            weakSelf.isNoMoreFiles = fileArray.count == 0 ? YES : NO;
        });
    };
    APKRetrieveDVRFileListingFailureHandler failure = ^{
      
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (weakSelf.refreshControl.isRefreshing) [weakSelf.refreshControl endRefreshing];
            if (weakSelf.flower.isAnimating) [weakSelf.flower stopAnimating];
            if (hud) [hud hideAnimated:YES];
            weakSelf.requestState = kAPKRequestDVRFileStateNone;
        });
    };
    
    [[APKDVRCommandFactory setCommandWithProperty:@"Playback" value:@"enter"] execute:^(id responseObject) {
    
        [weakSelf.retrieveFileListing executeWithFileType:weakSelf.fileType cameraType:weakSelf.cameraType offset:0 count:10000 success:success failure:failure];
        
    } failure:^(int rval) {

        failure();
    }];
}

-(NSMutableArray*)seperateDataArrayWithFileType:(NSArray *)arr
{
    NSMutableArray *dataArray = [NSMutableArray array];
    NSString *containStr = @"";
    APKFileType type = APKFileTypeVideo;
    switch (self.fileType) {
        case APKFileTypeVideo:
            containStr = @"MOV";
            break;
        case APKFileTypeEvent:
            containStr = @"MP3";
            type = APKFileTypeEvent;
            break;
        default:
            containStr = @"JPG";
            type = APKFileTypeCapture;
            break;
    }
    
    for (APKDVRFile *file in arr) {
        
        if ([file.name containsString:containStr])
        {
            file.type = type;
            [dataArray addObject:file];
        }
    }
    return dataArray;
}

#pragma mark - event response

- (IBAction)clickCancelButton:(UIButton *)sender {
    
    [self.tableView reloadData];
    [self updateSelectInfo];
//    self.cancelButton.hidden = YES;
}

- (IBAction)clickSwitchFileTypeButton:(UIButton *)sender {
    
    if (sender == self.switchFileTypeButton1 && self.fileType != APKFileTypeVideo) {
        
        self.fileType = APKFileTypeVideo;
        [self.fileTypeButton setTitle:@"VIDEO" forState:UIControlStateNormal];
        [self refreshPage];
        
    }else if (sender == self.switchFileTypeButton2 && self.fileType != APKFileTypeEvent){
        
        self.fileType = APKFileTypeEvent;
        [self.fileTypeButton setTitle:@"AUDIO" forState:UIControlStateNormal];
        [self refreshPage];
        
    }else if (sender == self.switchFileTypeButton3 && self.fileType != APKFileTypeCapture){
        
        self.fileType = APKFileTypeCapture;
        [self.fileTypeButton setTitle:@"PHOTO" forState:UIControlStateNormal];
        [self refreshPage];
    }
    
    self.fileTypeView.hidden = YES;
}

- (IBAction)clickSwitchCameraButton:(UIButton *)sender {

    if (self.cameraType == APKCameraTypeFront) {
        
        self.cameraType = APKCameraTypeRear;
    }else if (self.cameraType == APKCameraTypeRear){
        
        self.cameraType = APKCameraTypeFront;
    }
    
//    sender.selected = !sender.selected;
    [self refreshPage];
}

- (IBAction)clickOpenButton:(UIButton *)sender {
    
    NSArray *indexPaths = self.tableView.indexPathsForSelectedRows;
    if (indexPaths.count == 0) {
        
        return;
    }
    
    if (self.fileType == APKFileTypeCapture) {
        
        [self.photos removeAllObjects];
        [self.previewFiles removeAllObjects];
        for (NSIndexPath *indexPath in indexPaths) {
            
            APKDVRFile *file = self.dataSource[indexPath.row];
            UIImage *image = nil;
            if (file.previewPath) {
                image = [UIImage imageWithContentsOfFile:file.previewPath];
            }else if (file.thumbnailPath) {
                image = [UIImage imageWithContentsOfFile:file.thumbnailPath];
            }else{
                image = [UIImage imageNamed:@"cameraPhoto_placeholder"];
            }
            MWPhoto *photo = [MWPhoto photoWithImage:image];
            [self.photos addObject:photo];
            [self.previewFiles addObject:file];
        }
        
        MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        photoBrowser.alwaysShowControls = YES;
        photoBrowser.displayActionButton = NO;
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:photoBrowser];
        [self presentViewController:navi animated:YES completion:nil];
        self.photoBrowser = photoBrowser;
        
    }else{
        
        //Use AVKit
//        NSIndexPath *indexPath = indexPaths.firstObject;
//        APKDVRFile *file = self.dataSource[indexPath.row];
//        NSURL *url = [NSURL URLWithString:file.fileDownloadPath];
//        AVPlayerViewController *vc = [[AVPlayerViewController alloc] init];
//        AVPlayer *player = [AVPlayer playerWithURL:url];
//        [player play];
//        vc.player = player;
//        [self presentViewController:vc animated:YES completion:nil];
        
        self.isJoinPlayBackVC = YES;
        
        NSMutableArray *urlArray = [[NSMutableArray alloc] init];
        NSMutableArray *nameArray = [[NSMutableArray alloc] init];
        for (NSIndexPath *indexPath in indexPaths) {
            
            APKDVRFile *file = self.dataSource[indexPath.row];
            [nameArray addObject:file.name];
            [urlArray addObject:[NSURL URLWithString:file.fileDownloadPath]];
        }
        
        APKVideoPlayer *videoPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"APKVideoPlayer"];
        [videoPlayer configureWithURLArray:urlArray nameArray:nameArray currentIndex:0];
        videoPlayer.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:videoPlayer animated:YES completion:nil];
    }
}

- (IBAction)clickDeleteButton:(UIButton *)sender {
    
    if (self.tableView.indexPathsForSelectedRows.count == 0) {
        return;
    }
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"删除%d个文件？", nil),(int)self.tableView.indexPathsForSelectedRows.count];
    [APKAlertTool showAlertInViewController:self title:nil message:message cancelHandler:nil confirmHandler:^(UIAlertAction *action) {
       
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        NSMutableArray *fileArray = [[NSMutableArray alloc] init];
        for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
            
            APKDVRFile *file = self.dataSource[indexPath.row];
            [fileArray addObject:file];
        }
        
        [self clickCancelButton:self.cancelButton];
        
        __weak typeof(self)weakSelf = self;
        [self.batchDelete executeWithFileArray:fileArray progress:^(APKDVRFile *file, BOOL success) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSInteger row = [weakSelf.dataSource indexOfObject:file];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                [weakSelf.dataSource removeObject:file];
                [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            });
            
        } completionHandler:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [hud hideAnimated:YES];
            });
        }];
    }];
}

- (IBAction)clickDownloadButton:(UIButton *)sender {
    
    if (![self checkDownloadAuthority]) {
        
        return;
    }
    
    NSMutableArray *fileArray = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
        
        APKDVRFile *file = self.dataSource[indexPath.row];
        if (!file.isDownloaded) {
            
            [fileArray addObject:file];
        }
    }
    
    [self clickCancelButton:self.cancelButton];
    
    if (fileArray.count == 0) {
        
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    APKDownloadInfoView *downloadInfoView = [[NSBundle mainBundle] loadNibNamed:@"APKDownloadInfoView" owner:self options:nil].firstObject;
    [downloadInfoView showInView:self.view cancelHandler:^{
        
        [weakSelf.batchDownload cancel];
    }];
    
    [self.batchDownload executeWithFileArray:fileArray globalProgress:^(NSString *globalProgress) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            downloadInfoView.downloadInfoLabel.text = globalProgress;
        });
        
    } currentTaskProgress:^(float progress, NSString *info) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            downloadInfoView.progressView.progress = progress;
            NSString *progressInfo = [NSString stringWithFormat:@"%.1f%%",progress * 100.f];
            downloadInfoView.progressLabel.text = progressInfo;
            downloadInfoView.progressLabel2.text = info;
        });
        
    } completionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [downloadInfoView dismiss];
        });
    }];
}

- (IBAction)clickFileTypeButton:(UIButton *)sender {
    
    self.fileTypeView.hidden = !self.fileTypeView.hidden;
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    
    return self.photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    
    MWPhoto *photo = self.photos[index];
    return photo;
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index{
    
    APKDVRFile *file = self.previewFiles[index];
    if (file.previewPath) {
        
        return;
    }
    
    if (self.downloadTask) {
        
        [self.downloadTask cancel];
    }
    
    __weak typeof(self)weakSelf = self;
    NSString *savePath = [NSTemporaryDirectory() stringByAppendingPathComponent:file.name];
    self.downloadTask = [APKDVRFileDownloadTask taskWithPriority:kDownloadPriorityNormal sourcePath:file.fileDownloadPath targetPath:savePath progress:^(float progress, NSString *info) {
        
    } success:^{
        
        file.previewPath = savePath;
        UIImage *image = [UIImage imageWithContentsOfFile:savePath];
        MWPhoto *photo = [MWPhoto photoWithImage:image];
        [weakSelf.photos replaceObjectAtIndex:index withObject:photo];
        if (index == weakSelf.photoBrowser.currentIndex) {
            
            [weakSelf.photoBrowser reloadData];
        }
        
    } failure:^{
        
        if (index == weakSelf.photoBrowser.currentIndex) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                MWPhoto *photo = [MWPhoto photoWithImage:nil];
                [weakSelf.photos replaceObjectAtIndex:index withObject:photo];
                [weakSelf.photoBrowser reloadData];
            });
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return tableView == self.tableView ? self.dataSource.count : 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.tableView) {
        
        static NSString *cellIdentifier = @"dvrFileCell";
        
        APKDVRFileCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        APKDVRFile *file = self.dataSource[indexPath.row];
        [cell configureCell:file];
        return cell;
        
    }else{
        
        static NSString *cellIdentifier = @"fileTypeCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        NSArray *typeArray = @[NSLocalizedString(@"照片", nil),NSLocalizedString(@"视频", nil),NSLocalizedString(@"事件", nil)];
        cell.textLabel.text = typeArray[indexPath.row];
        return cell;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self updateSelectInfo];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self updateSelectInfo];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (self.requestState == kAPKRequestDVRFileStateNone && self.dataSource.count != 0 && !self.isNoMoreFiles) {
        
        CGFloat x = 0;//x是触发操作的阀值
        if (scrollView.contentOffset.y >= fmaxf(.0f, scrollView.contentSize.height - scrollView.frame.size.height) + x)
        {
//            self.requestState = kAPKRequestDVRFileStateLoadMore;
//            [self.flower startAnimating];
//            [self requestFileList];
        }
    }
}

#pragma mark - setter

- (void)setIsNoMoreFiles:(BOOL)isNoMoreFiles{
    
    _isNoMoreFiles = isNoMoreFiles;
}

#pragma mark - getter

- (void)setFileType:(APKFileType)fileType{
    
    _fileType = fileType;
    
    self.switchFileTypeButton1.enabled = YES;
    self.switchFileTypeButton2.enabled = YES;
    self.switchFileTypeButton3.enabled = YES;
    
    if (fileType == APKFileTypeVideo) {
        
        self.switchFileTypeButton1.enabled = NO;
        
    }else if (fileType == APKFileTypeEvent){
        
        self.switchFileTypeButton2.enabled = NO;

    }else if (fileType == APKFileTypeCapture){
        
        self.switchFileTypeButton3.enabled = NO;
    }
}

- (APKBatchDelete *)batchDelete{
    
    if (!_batchDelete) {
        
        _batchDelete = [[APKBatchDelete alloc] init];
    }
    
    return _batchDelete;
}

- (APKBatchDownload *)batchDownload{
    
    if (!_batchDownload) {
        
        _batchDownload = [[APKBatchDownload alloc] init];
    }
    
    return _batchDownload;
}

- (APKRetrieveDVRFileListing *)retrieveFileListing{
    
    if (!_retrieveFileListing) {
        
        _retrieveFileListing = [[APKRetrieveDVRFileListing alloc] init];
    }
    
    return _retrieveFileListing;
}

- (NSMutableArray *)previewFiles{
    
    if (!_previewFiles) {
        _previewFiles = [[NSMutableArray alloc] init];
    }
    return _previewFiles;
}

- (NSMutableArray *)photos{
    
    if (!_photos) {
        _photos = [[NSMutableArray alloc] init];
    }
    return _photos;
}

- (NSMutableArray *)dataSource{
    
    if (!_dataSource) {
        
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (APKGetDVRRecordingState *)getRecordState{
    
    if (!_getRecordState) {
        
        _getRecordState = [[APKGetDVRRecordingState alloc] init];
    }
    return _getRecordState;
}

@end
