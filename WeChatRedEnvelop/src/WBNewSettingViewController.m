//
//  WBNewSettingViewController.m
//  WCDylib
//
//  Created by in8 on 2019/1/22.
//  Copyright © 2019 junjie.zhou. All rights reserved.
//

#import "WBNewSettingViewController.h"
#import "WeChatRedEnvelop.h"
#import "WBRedEnvelopConfig.h"
#import <objc/objc-runtime.h>
#import "WBMultiSelectGroupsViewController.h"

@interface WBNewSettingViewController () <MultiSelectGroupsViewControllerDelegate>

@property (nonatomic, strong) WCTableViewManager *tableViewInfo;

@end

@implementation WBNewSettingViewController

- (instancetype)init {
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect rect = [UIScreen mainScreen].bounds;
    rect.size.height = rect.size.height - [objc_getClass("UiUtil") statusBarHeight] - [objc_getClass("UiUtil") navigationBarHeight];
    _tableViewInfo = [[objc_getClass("WCTableViewManager") alloc] initWithFrame:rect style:UITableViewStyleGrouped];

    [self initTitle];
    [self reloadTableData];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    MMTableView *tableView = [self.tableViewInfo getTableView];
    [self.view addSubview:tableView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self stopLoading];
}

- (void)initTitle {
    double height = [objc_getClass("UiUtil") statusBarHeight] + [objc_getClass("UiUtil") navigationBarHeight];
    
}

- (void)reloadTableData {
    [self.tableViewInfo clearAllSection];
    
    [self addBasicSettingSection];
//    [self addSupportSection];
    [self addAdvanceSettingSection];
    
    [self addAboutSection];
    
    MMTableView *tableView = [self.tableViewInfo getTableView];
    [tableView reloadData];
}

#pragma mark - BasicSetting

- (void)addBasicSettingSection {
    WCTableViewSectionManager *sectionInfo = [objc_getClass("WCTableViewSectionManager") defaultSection];
    
    [sectionInfo addCell:[self createAutoReceiveRedEnvelopCell]];
    [sectionInfo addCell:[self createDelaySettingCell]];
    
    [self.tableViewInfo addSection:sectionInfo];
}

- (id)createAutoReceiveRedEnvelopCell {
    return [objc_getClass("WCTableViewCellManager") switchCellForSel:@selector(switchRedEnvelop:) target:self title:@"自动抢红包" on:[WBRedEnvelopConfig sharedConfig].autoReceiveEnable];
}

- (id)createDelaySettingCell {
    NSInteger delaySeconds = [WBRedEnvelopConfig sharedConfig].delaySeconds;
    NSString *delayString = delaySeconds == 0 ? @"不延迟" : [NSString stringWithFormat:@"%ld 秒", (long)delaySeconds];
    
    id cellInfo;
    if ([WBRedEnvelopConfig sharedConfig].autoReceiveEnable) {
        cellInfo = [objc_getClass("WCTableViewNormalCellManager") normalCellForSel:@selector(settingDelay) target:self title:@"延迟抢红包" rightValue: delayString accessoryType:1];
    } else {
        cellInfo = [objc_getClass("WCTableViewNormalCellManager") normalCellForTitle:@"延迟抢红包" rightValue: @"抢红包已关闭"];
    }
    return cellInfo;
}

- (void)switchRedEnvelop:(UISwitch *)envelopSwitch {
    [WBRedEnvelopConfig sharedConfig].autoReceiveEnable = envelopSwitch.on;
    
    [self reloadTableData];
}

- (void)settingDelay {
    UIAlertView *alert = [UIAlertView new];
    alert.title = @"延迟抢红包(秒)";
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.delegate = self;
    [alert addButtonWithTitle:@"取消"];
    [alert addButtonWithTitle:@"确定"];
    
    [alert textFieldAtIndex:0].placeholder = @"延迟时长";
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *delaySecondsString = [alertView textFieldAtIndex:0].text;
        NSInteger delaySeconds = [delaySecondsString integerValue];
        
        [WBRedEnvelopConfig sharedConfig].delaySeconds = delaySeconds;
        
        [self reloadTableData];
    }
}

#pragma mark - ProSetting
- (void)addAdvanceSettingSection {
    WCTableViewSectionManager *sectionInfo = [objc_getClass("WCTableViewSectionManager") sectionInfoHeader:@"高级功能"];
    
    [sectionInfo addCell:[self createReceiveSelfRedEnvelopCell]];
    [sectionInfo addCell:[self createQueueCell]];
    [sectionInfo addCell:[self createAbortRemokeMessageCell]];
    
    [self.tableViewInfo addSection:sectionInfo];
}

- (id)createReceiveSelfRedEnvelopCell {
    return [objc_getClass("WCTableViewCellManager") switchCellForSel:@selector(settingReceiveSelfRedEnvelop:) target:self title:@"抢自己发的红包" on:[WBRedEnvelopConfig sharedConfig].receiveSelfRedEnvelop];
}

- (id)createQueueCell {
    return [objc_getClass("WCTableViewCellManager") switchCellForSel:@selector(settingReceiveByQueue:) target:self title:@"防止同时抢多个红包" on:[WBRedEnvelopConfig sharedConfig].serialReceive];
}

- (WCTableViewSectionManager *)createAbortRemokeMessageCell {
    return [objc_getClass("WCTableViewCellManager") switchCellForSel:@selector(settingMessageRevoke:) target:self title:@"消息防撤回" on:[WBRedEnvelopConfig sharedConfig].revokeEnable];
}

- (void)settingReceiveSelfRedEnvelop:(UISwitch *)receiveSwitch {
    [WBRedEnvelopConfig sharedConfig].receiveSelfRedEnvelop = receiveSwitch.on;
}

- (void)settingReceiveByQueue:(UISwitch *)queueSwitch {
    [WBRedEnvelopConfig sharedConfig].serialReceive = queueSwitch.on;
}

- (void)settingMessageRevoke:(UISwitch *)revokeSwitch {
    [WBRedEnvelopConfig sharedConfig].revokeEnable = revokeSwitch.on;
}

#pragma mark - About
- (void)addAboutSection {
    WCTableViewSectionManager *sectionInfo = [objc_getClass("WCTableViewSectionManager") defaultSection];
    
    [sectionInfo addCell:[self createGithubCell]];
    
    [self.tableViewInfo addSection:sectionInfo];
}

- (id)createGithubCell {
    return [objc_getClass("WCTableViewNormalCellManager") normalCellForSel:@selector(showGithub) target:self title:@"我的 Github" rightValue: @"★ star" accessoryType:1];
}

- (void)showGithub {
    NSURL *gitHubUrl = [NSURL URLWithString:@"https://github.com/zjjno/WeChatRedEnvelop"];
    MMWebViewController *webViewController = [[objc_getClass("MMWebViewController") alloc] initWithURL:gitHubUrl presentModal:NO extraInfo:nil];
    [self.navigationController PushViewController:webViewController animated:YES];
}

#pragma mark - Support
- (void)addSupportSection {
    WCTableViewSectionManager *sectionInfo = [objc_getClass("WCTableViewSectionManager") defaultSection];
    
    [sectionInfo addCell:[self createWeChatPayingCell]];
    
    [self.tableViewInfo addSection:sectionInfo];
}

- (id)createWeChatPayingCell {
    return [objc_getClass("WCTableViewNormalCellManager") normalCellForSel:@selector(payingToAuthor) target:self title:@"微信打赏" rightValue:@"支持作者开发" accessoryType:1];
}

- (void)payingToAuthor {
    [self startLoadingNonBlock];
    ScanQRCodeLogicController *scanQRCodeLogic = [[objc_getClass("ScanQRCodeLogicController") alloc] initWithViewController:self CodeType:31];
    scanQRCodeLogic.fromScene = 1;
    
    NewQRCodeScanner *qrCodeScanner = [[objc_getClass("NewQRCodeScanner") alloc] initWithDelegate:scanQRCodeLogic CodeType:31];
    
    NSString *rewardStr = @"m0#tYKR_$YKjkz~7IjWLFL";
    NSData *rewardData = [rewardStr dataUsingEncoding:4];
    [qrCodeScanner notifyResult:rewardStr type:@"WX_CODE" version:0 rawData:rewardData];
}

#pragma mark - MultiSelectGroupsViewControllerDelegate
- (void)onMultiSelectGroupCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)onMultiSelectGroupReturn:(NSArray *)arg1 {
    [WBRedEnvelopConfig sharedConfig].blackList = arg1;
    
    [self reloadTableData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
