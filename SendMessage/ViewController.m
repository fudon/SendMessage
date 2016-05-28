//
//  ViewController.m
//  SendMessage
//
//  Created by fudon on 16/4/14.
//  Copyright © 2016年 fusu. All rights reserved.
//

#import "ViewController.h"
#import <MessageUI/MessageUI.h>
#import "SPSetViewController.h"
#import "FuSoft.h"
#import "FSMSGCell.h"

#define  UDKEY_SUCCESS      @"success"
#define  UDKEY_FAIL         @"fail"
#define  UDKEY_CANCEL       @"cancel"

#define  MICRO_BACKCOUNT    60


@interface ViewController ()<MFMessageComposeViewControllerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,assign) NSInteger      backCount;
@property (nonatomic,assign) NSInteger      silenceBackCount;

@property (nonatomic,assign) NSInteger      success;
@property (nonatomic,assign) NSInteger      cancel;
@property (nonatomic,assign) NSInteger      fail;

@property (nonatomic,strong) NSArray        *dtArray;
@property (nonatomic,strong) NSDictionary   *handlingDic;
@property (nonatomic,strong) UIView         *headView;
@property (nonatomic,strong) UITableView    *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *size = [FuData kMGTUnit:[FuData diskOfAllSizeBytes]];
    NSLog(@"%@",size);
    return;
    _backCount = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"ChangeBackCount" object:nil];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    self.success = [[ud objectForKey:UDKEY_SUCCESS] integerValue];
    self.fail = [[ud objectForKey:UDKEY_FAIL] integerValue];
    self.cancel = [[ud objectForKey:UDKEY_CANCEL] integerValue];
    
    [self findMsgCodes];
}

- (void)findMsgCodes
{
    [self showWaitView:YES];
    WEAKSELF(this);
    [FuWeb requestWithUrl:FSWebUrl_FindMsgCode params:nil successBlock:^(id bDic) {
        [this showWaitView:NO];
        this.dtArray = [bDic objectForKey:@"data"];
        if (this.tableView) {
            [this.tableView reloadData];
        }else{
            [this designViews];
        }
    } failBlock:^(NSString *msg) {
        [this showWaitView:NO];
        [this showTitle:msg];
    }];
}

- (void)designViews
{
    UIBarButtonItem *rightBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction)];
    self.navigationItem.rightBarButtonItem = rightBBI;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIDTHFC, HEIGHTFC - 64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_tableView];
}

- (void)refreshAction
{
    [self findMsgCodes];
}

#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dtArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"msgCell";
    FSMSGCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell= (FSMSGCell *)[[[NSBundle  mainBundle] loadNibNamed:@"FSMSGCell" owner:self options:nil]  lastObject];
    }
    cell.dictionary = [self.dtArray objectAtIndex:indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_headView) {
        return _headView;
    }
    _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTHFC, 60)];
    _headView.backgroundColor = FSAPPCOLOR;
    for (int x = 0; x < 3; x ++) {
        UILabel *label = [FSViewManager labelWithFrame:CGRectMake(x * WIDTHFC / 3, 0, WIDTHFC / 3, 60) text:@(x).stringValue textColor:[UIColor whiteColor] backColor:nil textAlignment:NSTextAlignmentCenter];
        label.tag = TAGLABEL + x;
        [_headView addSubview:label];
    }
    return _headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self handleDatas:self.dtArray[indexPath.row]];
}

- (void)handleNotification:(NSNotification *)notification
{
    NSString *text = notification.object;
    _silenceBackCount = [text integerValue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)handleDatas:(NSDictionary *)dic
{
    WEAKSELF(this);
    [self showWaitView:YES];
    [FuWeb requestWithUrl:FSWebUrl_UpdateMsg params:@{@"account":[dic objectForKey:@"account"]} successBlock:^(id bDic) {
        [this showWaitView:NO];
        [this sendMessage:dic];
    } failBlock:^(NSString *msg) {
        [this showWaitView:NO];
        [this showTitle:msg];
    }];
}

- (void)sendMessage:(NSDictionary *)dic
{
    self.handlingDic = dic;
    if ([MFMessageComposeViewController canSendText]) {
        _backCount --;
        if (_backCount <= 0) {
            [self keepDataInPohone];
            return;
        }
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.recipients = @[[dic objectForKey:@"account"]];
        controller.body = [[NSString alloc] initWithFormat:@"【支付宝】%@,用于短信校验，请勿告诉别人，否则账号将有风险。",[dic objectForKey:@"code"]];
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:^{
        }];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            _cancel ++;
            break;
        case MessageComposeResultSent:
        {
            _success ++;
            [self handleDatas:self.handlingDic];
        }
            break;
        case MessageComposeResultFailed:
            _fail ++;
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)saveData:(UIButton *)sender
{
    if (sender.tag == 1) {
        SPSetViewController *set = [[SPSetViewController alloc] init];
        [self presentViewController:set animated:YES completion:nil];
    }else if (sender.tag == 2){
        if (_silenceBackCount) {
            _backCount = _silenceBackCount;
        }else{
            _backCount = 60;
        }
    }
}

- (void)keepDataInPohone
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:@(_success).stringValue forKey:UDKEY_SUCCESS];
    [ud setObject:@(_fail).stringValue forKey:UDKEY_FAIL];
    [ud setObject:@(_cancel).stringValue forKey:UDKEY_CANCEL];
    [ud synchronize];
}

@end
