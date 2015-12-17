//
//  inShopActivityViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/9/30.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "inShopActivityViewController.h"
#import "shopInfoThirdTableViewCell.h"

#import "myAppDataBase.h"
#import "staticUserInfo.h"

#import "changeChatGroupViewController.h"
#import "invivateFriendsShoppingViewController.h"
#import "shakeAndShakeViewController.h"

//聊天相关
#import "TouchDownGestureRecognizer.h"
#import "EmotionsModule.h"
#import "Mp3Recorder.h"
#import "UUProgressHUD.h"
#import "ASIFormDataRequest.h"
#import "UUAVAudioPlayer.h"

#import "UIView+MJExtension.h"
#import "MJRefresh.h"

#import "collectionCommodityDetailViewController.h"
#import "mainShopDetailViewController.h"

#import "loginViewController.h"

//店内主信息URL
#define INSHOPMAINURL @"http://%@/user/shop/info?sid=%d"

//由活动ID下载活动的信息
#define ACTIVITYDETAILURL @"http://%@/userweb/activity/%d"


//一系列的枚举
typedef NS_ENUM(NSUInteger, DDBottomShowComponent)
{
    DDInputViewUp                       = 1,
    DDShowKeyboard                      = 1 << 1,
    DDShowEmotion                       = 1 << 2,
    DDShowUtility                       = 1 << 3
};

typedef NS_ENUM(NSUInteger, DDBottomHiddComponent)
{
    DDInputViewDown                     = 14,
    DDHideKeyboard                      = 13,
    DDHideEmotion                       = 11,
    DDHideUtility                       = 7
};
//

typedef NS_ENUM(NSUInteger, DDInputType)
{
    DDVoiceInput,
    DDTextInput
};

typedef NS_ENUM(NSUInteger, PanelStatus)
{
    VoiceStatus,
    TextInputStatus,
    EmotionStatus,
    ImageStatus
};
#define NAVBAR_HEIGHT 64.f
#define SCREEN_WIDTH          [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT         [[UIScreen mainScreen] bounds].size.height-64
#define DDCOMPONENT_BOTTOM          CGRectMake(0, (SCREEN_HEIGHT - NAVBAR_HEIGHT) + NAVBAR_HEIGHT, SCREEN_WIDTH, 216)
#define DDINPUT_BOTTOM_FRAME        CGRectMake(0, (SCREEN_HEIGHT - NAVBAR_HEIGHT) - self.chatInputView.frame.size.height + NAVBAR_HEIGHT,SCREEN_WIDTH,self.chatInputView.frame.size.height)
#define DDINPUT_HEIGHT              self.chatInputView.frame.size.height
#define DDINPUT_TOP_FRAME           CGRectMake(0, (SCREEN_HEIGHT - NAVBAR_HEIGHT) - self.chatInputView.frame.size.height + NAVBAR_HEIGHT - 216, SCREEN_WIDTH, self.chatInputView.frame.size.height)
#define DDUTILITY_FRAME             CGRectMake(0, (SCREEN_HEIGHT - NAVBAR_HEIGHT) + NAVBAR_HEIGHT -216, SCREEN_WIDTH, 216)
#define DDEMOTION_FRAME             CGRectMake(0, (SCREEN_HEIGHT - NAVBAR_HEIGHT) + NAVBAR_HEIGHT-216, SCREEN_WIDTH, 216)

@interface inShopActivityViewController ()<UITableViewDelegate,UITableViewDataSource,Mp3RecorderDelegate,UIActionSheetDelegate,YBChangeGroupNameDelegate,YBInvivateFriendGnameDelegate,YBShakeChangeChatDelegate,YBShopDetailChangeGroupNameDelegate,UIAlertViewDelegate>
{
    UITableView *_ActivityTableView;
    
    //数据库中的单例
    myAppDataBase *dc;
    
    //聊天
    UITableView *_tableView;
    Mp3Recorder *MP3;
    NSInteger playTime;
    NSTimer *playTimer;
    
    //底部view
    UIView *bottomView;
    UIImageView *contractionImageView;
    UILabel *invitationLabel;
    UIButton *invitationButton;
    
    //webSocket
    YBWebSocketManager *webSocketManager;
    //组内好友信息数组
    NSMutableArray *_groupUserInformationArray;
    //聊天的消息的数组
    NSMutableArray *_chatDataArray;
    
    int pageCount;

    NSString *_activityShopName;
    
    UILabel *noActivityLabel;
}

- (void)p_clickThRecordButton:(UIButton*)button;
- (void)p_record:(UIButton*)button;
- (void)p_willCancelRecord:(UIButton*)button;
- (void)p_cancelRecord:(UIButton*)button;
- (void)p_sendRecord:(UIButton*)button;
- (void)p_endCancelRecord:(UIButton*)button;

- (void)p_hideBottomComponent;
- (void)p_tapOnTableView:(UIGestureRecognizer*)sender;
@end

@implementation inShopActivityViewController
{
    TouchDownGestureRecognizer* _touchDownGestureRecognizer;
    DDBottomShowComponent _bottomShowComponent;
    UIButton *_recordButton;
    float _inputViewY;
    NSString* _currentInputContent;
    
    
}


//当视图已经显示的时候
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    
    //通知的监听的处理事件
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillShowKeyboard:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillHideKeyboard:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    //当键盘出现的时候 tableView的高度改变 然后 tableView滚动到底部
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tableViewScrollToBottom) name:UIKeyboardDidShowNotification object:nil];
    
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //粉丝店中数据库的单例
    dc = [myAppDataBase sharedInstance];
    
    //创建MP3播放器
    NSString *loginString = [[NSUserDefaults standardUserDefaults]objectForKey:IsLogin];
    if(loginString)
    {
        MP3 = [[Mp3Recorder alloc]initWithDelegate:self];
        webSocketManager = [YBWebSocketManager sharedInstance];
    }
    
    //聊天模块中数据源数组中加入数据
    self.chatModel = [[chatModel alloc]init];
    self.chatModel.isGroupChat = NO;
    _chatDataArray = [[NSMutableArray alloc]init];

    
    NSLog(@"传过来的聊天的数组 = %@",self.activityArray);
    
    //创建底部view
    [self createBottomView];
    
    [self createUINav];
    
    [self createTableView];
    
    //由shopID下载商店的信息
    [self downLoadShopInformaiton];
    
    //加载聊天相关的数据
    [self loadBaseViewsAndData];
    
    //通知 (及时聊天数据)
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(insertBaseViewsAndData:) name:@"startLoadWebSocketData" object:nil];
    
    //创建讨论组 更新gname
    [nc addObserver:self selector:@selector(upDateMyGname2:) name:@"startLoadGname" object:nil];
    
    //从后台获取聊天记录数据
    [nc addObserver:self selector:@selector(loadBaseViewsAndData) name:@"startLoadChatDataFromeNet" object:nil];
    
    //商店聊天室
    [nc addObserver:self selector:@selector(enterShopRoom:) name:@"startLoadShopGname" object:nil];

    
    // Do any additional setup after loading the view.
}
#pragma mark-(下载商店的信息)
-(void)downLoadShopInformaiton
{
    NSDictionary *dict = self.activityArray[0];
    NSString *shopIDString = dict[@"shopID"];
    NSString *urlString = [NSString stringWithFormat:INSHOPMAINURL,DomainName,shopIDString.intValue];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
            NSDictionary *infoDict = dict[@"info"];
            _activityShopName = [[NSString alloc]init];
            _activityShopName = infoDict[@"name"];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}



#pragma mark-(及时聊天插入一条新的消息)
-(void)insertBaseViewsAndData:(NSNotification *)notification
{
     NSString *currentGname = notification.userInfo[@"currentGname"];
    if([currentGname isEqualToString:self.gnameString])
    {
    
    NSArray *messageArray = [staticUserInfo getMessagesWithGname:self.gnameString];
    if(messageArray.count != 0)
    {
        NSDictionary *messageDict = messageArray[messageArray.count -1];
        
        [_chatDataArray addObject:messageDict];
        [self.chatModel insertOneMessageToTableViewWithDict:messageDict];
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.chatModel.dataSource.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        //[_tableView reloadData];
        [self tableViewScrollToBottom];
    }
    }
}

//通知传值 进入商店之后 得到商店的gname
-(void)enterShopRoom:(NSNotification *)notification
{
    NSString *shopGnameString = notification.userInfo[@"myShopGname"];
    self.gnameString = shopGnameString;
    
    NSString *userIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
    //用户进店的协议
    [webSocketManager YBEnterShopWithUserName:userIDString andGname:shopGnameString];
    
    [self loadBaseViewsAndData];
    
}

//通知传值 更新当前gname
-(void)upDateMyGname2:(NSNotification *)notifiction
{
    //如果之前gname是shop_的话 则退出商店聊天室
    if(self.gnameString.length != 0)
    {
        if([self.gnameString rangeOfString:@"shop"].location != NSNotFound)
        {
            NSString *myIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
            [webSocketManager YBExitGroupWithUser:myIDString andGname:self.gnameString];
        }
    }
    
    NSString *upDateGname = notifiction.userInfo[@"myGname"];
    self.gnameString = upDateGname;
    
    //同时修改标题label的值
    NSDictionary *oneGnameInfo = [[myAppDataBase sharedInstance]getOneMiaoMiaoRecordWithGname:upDateGname];
    invitationLabel.text = oneGnameInfo[@"name"];
    
    [self loadBaseViewsAndData];
    
}

#pragma mark-(聊天的模块)-非商店的聊天室
-(void)loadBaseViewsAndData
{
   [_chatDataArray removeAllObjects];
    
    //判断gname是否存在 （当第一次运行的时候 gname不存在）
    if(self.gnameString.length != 0)
    {
        pageCount = 7;
        
        //获取聊天记录 如果数据库中没有useWebSocket
        if([[myAppDataBase sharedInstance]isExistMessageWith:self.gnameString])
        {
            
            //数据中有则static中获取
            NSArray *messageArray = [staticUserInfo getMessagesWithGname:_gnameString];
            if(messageArray.count>pageCount)
            {
                
                for(int i = messageArray.count-pageCount;i<messageArray.count;i++)
                {
                    [_chatDataArray addObject:messageArray[i]];
                }
            }
            else
            {
                _chatDataArray = [NSMutableArray arrayWithArray:messageArray];
            }
            //加载数据源数组
            [self.chatModel populateRandomDataSource:_chatDataArray];
            
            [_tableView reloadData];
           
            
            //聊天记录tableView滚动到底部
            [self tableViewScrollToBottom];
        }
        else
        {
            [self useWebSocketGetRecord];
            
            //取出数据
            NSArray *messageArray = [staticUserInfo getMessagesWithGname:self.gnameString];
            _chatDataArray = [NSMutableArray arrayWithArray:messageArray];
            
            
            //加载数据源数组
            
            [self.chatModel populateRandomDataSource:_chatDataArray];
            
            
            [_tableView reloadData];
            
            //聊天记录tableView滚动到底部
            [self tableViewScrollToBottom];
            
        }
    }
}
//获取聊天记录（先查询本地数据库 如果本地没有则用webSocket进行通信)
-(void)useWebSocketGetRecord
{
    
    //这是获取最新的聊天记录(当需要显示更多消息的时候 开始时间为上次取的最后一条记录的时间)
    [webSocketManager YBGetRecordWithGname:self.gnameString andStartTime:@"0" andRecordCount:@"30"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self p_hideBottomComponent];
    //解除通知
    //[[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
//聊天的tableView滚动到底部
-(void)tableViewScrollToBottom
{
    if(self.chatModel.dataSource.count == 0)
    {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.chatModel.dataSource.count-1 inSection:0];
    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}

#pragma  mark - PrivateAPI
- (void)p_hideBottomComponent
{
    _bottomShowComponent = _bottomShowComponent * 0;
    [self.chatInputView.textView resignFirstResponder];
    [UIView animateWithDuration:0.25 animations:^{
        self.ddUtility.view.frame = DDCOMPONENT_BOTTOM;
        self.emotions.view.frame = DDCOMPONENT_BOTTOM;
        self.chatInputView.frame = DDINPUT_BOTTOM_FRAME;
        
        CGRect rect = _tableView.frame;
        if(SCREENHEIGHT<500)
        {
            rect.size.height = SCREENHEIGHT-64-SCREENHEIGHT*0.1-44-44;
        }
        else
        {

        rect.size.height = SCREENHEIGHT-64-SCREENHEIGHT*0.2-44-44;
        }
        _tableView.frame = rect;
        [self tableViewScrollToBottom];
    }];
    //    NSLog(@"%f",self.chatInputView.frame.origin.y);
    [self setValue:@(self.chatInputView.frame.origin.y) forKeyPath:@"_inputViewY"];
}

#pragma nark-(创建底部聊天view）
-(void)createBottomView
{
    bottomView = [[UIView alloc]initWithFrame:CGRectMake(0,SCREENHEIGHT-44-64, SCREENWIDTH, 44)];
    bottomView.backgroundColor = [UIColor colorWithHexStr:@"#eeeeee"];
    bottomView.alpha = 0.9;
    [self.view insertSubview:bottomView atIndex:1];
    // [self.view addSubview:bottomView];
    
    //提示逛的label
    invitationLabel = [ZCControl createLabelWithFrame:CGRectMake(5, 5, SCREENWIDTH*0.4, 34) Font:SCREENWIDTH*0.04 Text:@""];
    invitationLabel.textColor = [UIColor colorWithHexStr:@"#676767"];
    invitationLabel.adjustsFontSizeToFitWidth = YES;
    if(self.gnameString.length != 0)
    {
        invitationLabel.text = self.invitationLabelString;
    }
    else
    {
        invitationLabel.text = @"可以邀请好友一起逛哦";
    }
    
    //invitationLabel.backgroundColor = [UIColor orangeColor];
    [bottomView addSubview:invitationLabel];
    
    //显示和收缩的imageView
    contractionImageView = [ZCControl createImageViewWithFrame:CGRectMake(0, 0, SCREENWIDTH*0.12, 10) ImageName:nil];
    contractionImageView.center = CGPointMake(SCREENWIDTH/2, 10);
    contractionImageView.image = [UIImage imageNamed:@"首页_11"];
    //contractionImageView.backgroundColor = [UIColor redColor];
    [bottomView addSubview:contractionImageView];
    
    //在allContractionImagrView上添加点击收缩和处理的事件
    UIControl *control = [[UIControl alloc]initWithFrame:CGRectMake(SCREENWIDTH*0.41, 0, SCREENWIDTH*0.18, 44)];
    control.tag = 103;
    [control addTarget:self action:@selector(dealWithAllContraction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:control];
    
    //拉好友群组的button
    invitationButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.8, 0, SCREENWIDTH*0.2, 44) ImageName:@"" Target:self Action:@selector(invitationButtonBtn:) Title:nil];
    [invitationButton setImage:[UIImage imageNamed:@"首页_14"] forState:UIControlStateNormal];
    [bottomView addSubview:invitationButton];
    
}
#pragma mark-(拉好友点击事件处理)
-(void)invitationButtonBtn:(UIButton *)button
{
    UIActionSheet *ac = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"切换聊天",@"发起聊天",@"摇一摇",@"店铺聊天室",@"私信店主", nil];
    ac.tag = 101;
    [ac showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //拉好友点击
    NSString *loginString = [[NSUserDefaults standardUserDefaults]objectForKey:IsLogin];
    if([loginString isEqualToString:@"login"])
    {
    if(actionSheet.tag == 101)
    {
        if(buttonIndex == 0)
        {
            changeChatGroupViewController *ccgvc = [[changeChatGroupViewController alloc]init];
            ccgvc.YB_ChangeGroupGnameDelegate = self;
            [self.navigationController pushViewController:ccgvc animated:YES];
            
        }
        else if (buttonIndex == 1)
        {
            invivateFriendsShoppingViewController *isvc = [[invivateFriendsShoppingViewController alloc]init];
            isvc.YB_GnameDelegate = self;
            [self.navigationController pushViewController:isvc animated:YES];
        }
        else if(buttonIndex == 2)
        {
            shakeAndShakeViewController *ssvc = [[shakeAndShakeViewController alloc]init];
            ssvc.gnameString = self.gnameString;
            ssvc.invitationLabelString = invitationLabel.text;
            ssvc.YB_delegate = self;
            [self.navigationController pushViewController:ssvc animated:YES];
        }
        else if(buttonIndex == 3)
        {
            if(self.activityArray.count != 0)
            {
            invitationLabel.text = [NSString stringWithFormat:@"%@-聊天室",_activityShopName];
            //店铺聊天室
            //先获取商店聊天室的Gname  然后根据gname去获取聊天记录
            NSDictionary *dict = self.activityArray[0];
                NSString *shopIDString = dict[@"shopID"];
            [webSocketManager YBGetShopGnameWithShopID:shopIDString];
                
            }
            
            
        }
        else if (buttonIndex == 4)
        {
            if(self.activityArray.count != 0)
            {
            invitationLabel.text = [NSString stringWithFormat:@"%@-私信店主",_activityShopName];
            
            //数据加载之前  清空tableView
            [_chatDataArray removeAllObjects];
            [self.chatModel populateRandomDataSource:_chatDataArray];
            [_tableView reloadData];
            
            //如果之前gname是shop_的话 则退出商店聊天室
            if(self.gnameString.length != 0)
            {
                if([self.gnameString rangeOfString:@"shop"].location != NSNotFound)
                {
                    NSString *myIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
                    [webSocketManager YBExitGroupWithUser:myIDString andGname:self.gnameString];
                }
            }
            
            //私信店主 先获取商店的gname 然后根据商店的gname和自己的ID拼接成单聊的gname
            NSString *userIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
            
                NSDictionary *dict = self.activityArray[0];
                NSString *shopIDString = dict[@"shopID"];

            //拼接私信店主的gname
            NSString *messageGname = [[NSString alloc]init];
            if(userIDString.intValue > shopIDString.intValue)
            {
                messageGname = [NSString stringWithFormat:@"e2e_%@_%@",userIDString,shopIDString];
            }
            else
            {
                messageGname = [NSString stringWithFormat:@"e2e_%@_%@",shopIDString,userIDString];
            }
            self.gnameString = messageGname;
            
            [self loadBaseViewsAndData];
            }
            
        }
        else
        {
            
        }
        
    }
    }
    else
    {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"亲，您还没有登录哟!" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    if(buttonIndex == 0)
//    {
//        return;
//    }
//    else
//    {
//        loginViewController *vc = [[loginViewController alloc]init];
//        [self.navigationController pushViewController:vc animated:YES];
//    }
}


//摇一摇界面的反向代理
-(void)YBShakeChangeChatWithGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    self.gnameString = gname;
    if(self.gnameString.length != 0)
    {
        invitationLabel.text = groupName;
        [self loadBaseViewsAndData];
    }
}


#pragma mark-(切换聊天组的代理)
-(void)YBChangeGroupGNameWith:(NSString *)gname andGroupName:(NSString *)groupName
{
    //    //如果之前gname是shop_的话 则退出商店聊天室
    
    if(self.gnameString.length != 0)
    {
        if([self.gnameString rangeOfString:@"shop"].location != NSNotFound)
        {
            NSString *myIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
            [webSocketManager YBExitGroupWithUser:myIDString andGname:self.gnameString];
        }
    }
    
    invitationLabel.text = groupName;
    self.gnameString = gname;
    [self loadBaseViewsAndData];
}

#pragma mark-(从好友选择界面上面选择好友得到gname代理  --单聊 )
-(void)YBgetWebSocketGname:(NSString *)gname
{
    //如果之前gname是shop_的话 则退出商店聊天室
    if(self.gnameString.length != 0)
    {
        if([self.gnameString rangeOfString:@"shop"].location != NSNotFound)
        {
            NSString *myIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
            [webSocketManager YBExitGroupWithUser:myIDString andGname:self.gnameString];
        }
    }
    
    //根据发送方和接收方的ID的大小比较得到结果填写字段
    NSString *myIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
    NSString *messageGname = [[NSString alloc]init];
    if(myIDString.intValue > gname.intValue)
    {
        messageGname = [NSString stringWithFormat:@"e2e_%@_%@",myIDString,gname];
    }
    else
    {
        messageGname = [NSString stringWithFormat:@"e2e_%@_%@",gname,myIDString];
    }
    self.gnameString = messageGname;
    
    //同时根据单聊传过来的ID去获取ID的信息来修改标题label的值
    NSDictionary *userInfo = [[myAppDataBase sharedInstance]getUserInformationRecordWithUserID:gname];
    if(![userInfo[@"rmkName"] isEqualToString:@""])
    {
        //存在备注名字
        invitationLabel.text = userInfo[@"rmkName"];
    }
    else
    {
        invitationLabel.text = userInfo[@"nickName"];
    }
    [self loadBaseViewsAndData];
}

#pragma mark-（发起聊天 tableViewReloadData）
-(void)YBChangeGroupTableViewReloadData
{
    [_chatDataArray removeAllObjects];
    [self.chatModel populateRandomDataSource:_chatDataArray];
    [_tableView reloadData];
}
#pragma mark-(切换聊天 tableViewReloadData)
-(void)YBchangeGroupTableViewReloadData2
{
    [_chatDataArray removeAllObjects];
    [self.chatModel populateRandomDataSource:_chatDataArray];
    [_tableView reloadData];
    
}


#pragma mark-(点击显示收缩的处理事件)
-(void)dealWithAllContraction:(UIControl *)control
    {
        static BOOL isContraction = YES;
        if(isContraction == YES)
        {
            if(SCREENHEIGHT<500)
            {
                bottomView.frame = CGRectMake(0, SCREENHEIGHT*0.1, SCREENWIDTH, 44);
            }
            else
            {
            bottomView.frame = CGRectMake(0, SCREENHEIGHT*0.2, SCREENWIDTH, 44);
            }
            bottomView.backgroundColor = [UIColor colorWithHexStr:@"#48d58b"];
            bottomView.alpha = 1.0;
            invitationLabel.textColor = [UIColor whiteColor];
            //contractionImageView.frame = CGRectMake(SCREENWIDTH*0.41, 36, SCREENWIDTH*0.18, 8);
            contractionImageView.image = [UIImage imageNamed:@"店铺_10"];
            [invitationButton setImage:[UIImage imageNamed:@"首页_15"] forState:UIControlStateNormal];
            //创建聊天输入框
            //视图的原点y从64开始
            CGRect inputFrame = CGRectMake(0, SCREEN_HEIGHT -44,SCREEN_WIDTH,44.0f);
            self.chatInputView = [[JSMessageInputView alloc] initWithFrame:inputFrame delegate:self];
            //[self.chatInputView setBackgroundColor:[UIColor orangeColor]];
            [self.chatInputView setBackgroundColor:[UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0]];
            [self.view insertSubview:self.chatInputView atIndex:5];
            // [self.view addSubview:self.chatInputView];
            
            
            
            //表情
            [self.chatInputView.emotionbutton addTarget:self
                                                 action:@selector(showEmotion:)
                                       forControlEvents:UIControlEventTouchUpInside];
            //➕号
            [self.chatInputView.showUtilitysbutton addTarget:self
                                                      action:@selector(showUtility:)
                                            forControlEvents:UIControlEventTouchDown];
            //语音
            [self.chatInputView.voiceButton addTarget:self
                                               action:@selector(p_clickThRecordButton:)
                                     forControlEvents:UIControlEventTouchUpInside];
            
            //录音上面一系列的手势效果
            _touchDownGestureRecognizer = [[TouchDownGestureRecognizer alloc] initWithTarget:self action:nil];
            __weak inShopActivityViewController* weakSelf = self;
            _touchDownGestureRecognizer.touchDown = ^{
                [weakSelf p_record:nil];
            };
            
            _touchDownGestureRecognizer.moveInside = ^{
                [weakSelf p_endCancelRecord:nil];
            };
            
            _touchDownGestureRecognizer.moveOutside = ^{
                [weakSelf p_willCancelRecord:nil];
            };
            
            _touchDownGestureRecognizer.touchEnd = ^(BOOL inside){
                if (inside)
                {
                    [weakSelf p_sendRecord:nil];
                }
                else
                {
                    [weakSelf p_cancelRecord:nil];
                }
            };
            [self.chatInputView.recordButton addGestureRecognizer:_touchDownGestureRecognizer];
            //    _recordingView = [[RecordingView alloc] initWithState:DDShowVolumnState];
            //    [_recordingView setHidden:YES];
            //    [_recordingView setCenter:CGPointMake(SCREENWIDTH/2, SCREENHEIGHT*0.4)];
           // [self addObserver:self forKeyPath:@"_inputViewY" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
            
            
            //聊天界面
            if(SCREENHEIGHT<500)
            {
                 _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT*0.1+44, SCREENWIDTH, SCREEN_HEIGHT -44-SCREENHEIGHT*0.1-44) style:UITableViewStylePlain];
            }
            else
            {
                _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT*0.2+44, SCREENWIDTH, SCREEN_HEIGHT -44-SCREENHEIGHT*0.2-44) style:UITableViewStylePlain];
            }
            
            _tableView.delegate = self;
            _tableView.dataSource = self;
            
            //去除聊天界面的分割线
            _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            
            //设置表格视图左边短15像素问题
            if([_tableView respondsToSelector:@selector(setSeparatorInset:)])
            {
                [_tableView setSeparatorInset:UIEdgeInsetsZero];
            }
            if([_tableView  respondsToSelector:@selector(setLayoutMargins:)])
            {
                [_tableView setLayoutMargins:UIEdgeInsetsZero];
            }
            
            __weak typeof(self) weakSelf2 = self;
            [_tableView addLegendHeaderWithRefreshingBlock:^{
                
                [weakSelf2 loadMoreChatData];
                
            }];
            
            //添加轻击和拖移的手势去回收键盘
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_tapOnTableView:)];
            [_tableView addGestureRecognizer:tap];
            
            UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(p_tapOnTableView:)];
            pan.delegate = self;
            [_tableView addGestureRecognizer:pan];
            [_tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
            //tableView的内容滚动到下方
            [self tableViewScrollToBottom];
            
            [self.view insertSubview:_tableView atIndex:1];
            //[self.view addSubview:_tableView];
            
            isContraction = NO;
        }
        else
        {
            _tableView.hidden = YES;
            self.chatInputView.hidden = YES;
            [self p_hideBottomComponent];
            bottomView.frame = CGRectMake(0,SCREENHEIGHT-44-64, SCREENWIDTH, 44);
            // contractionImageView.frame = CGRectMake(SCREENWIDTH*0.41, 0, SCREENWIDTH*0.18, 8);
            //invitationLabel.text = @"可以邀请好友一起逛哦";
           
            bottomView.backgroundColor = [UIColor colorWithHexStr:@"#eeeeee"];
            bottomView.alpha = 0.9;
             invitationLabel.textColor = [UIColor colorWithHexStr:@"#676767"];
            contractionImageView.image = [UIImage imageNamed:@"首页_11"];
            [invitationButton setImage:[UIImage imageNamed:@"首页_14"] forState:UIControlStateNormal];
            isContraction = YES;
        }
        
    }

#pragma mark-(下拉加载更多的聊天记录)
-(void)loadMoreChatData
{
    pageCount = pageCount+7;
    NSMutableArray *addArray = [[NSMutableArray alloc]init];
    NSArray *messageArray = [staticUserInfo getMessagesWithGname:self.gnameString];
    //NSLog(@"加载消息记录的条数 = %d",pageCount);
    //NSLog(@"所有的消息记录的条数 = %d",messageArray.count);
    if(messageArray.count < pageCount)
    {
        if(pageCount-messageArray.count+1<=7)
        {
            for(int i = 0;i<messageArray.count-(pageCount-7);i++)
            {
                [addArray addObject:messageArray[i]];
                
            }
            for(int i = addArray.count-1;i>=0;i--)
            {
                [_chatDataArray insertObject:addArray[i] atIndex:0];
                
            }
            
        }
    }
    else
    {
        for(int i = messageArray.count-pageCount;i<messageArray.count-(pageCount-7);i++)
        {
            // NSLog(@"下拉加载具体的每一条数据 = %@",messageArray[i]);
            [addArray addObject:messageArray[i]];
            
        }
        
        for(int i = addArray.count-1;i>=0;i--)
        {
            [_chatDataArray insertObject:addArray[i] atIndex:0];
            
        }
        
        //NSLog(@"下拉加载更多的数据 = %@",addArray);
    }
    if(addArray.count != 0)
    {
        [self.chatModel addMoreChatData:addArray];
    }
    
    [_tableView reloadData];
    NSIndexPath *path = [NSIndexPath indexPathForRow:7 inSection:0];
    if(messageArray.count > 14)
    {
        
        [_tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    [_tableView.header endRefreshing];
}


#pragma mark-(聊天界面UI)
    -(void)showEmotion:(id)send
    {
        [_recordButton setImage:[UIImage imageNamed:@"dd_record_normal"] forState:UIControlStateNormal];
        _recordButton.tag = DDVoiceInput;
        [self.chatInputView willBeginInput];
        if ([_currentInputContent length] > 0)
        {
            [self.chatInputView.textView setText:_currentInputContent];
        }
        
        if (self.emotions == nil) {
            self.emotions = [EmotionsViewController new];
            [self.emotions.view setBackgroundColor:[UIColor darkGrayColor]];
            self.emotions.view.frame=DDCOMPONENT_BOTTOM;
            self.emotions.delegate = self;
            [self.view addSubview:self.emotions.view];
        }
        if (_bottomShowComponent & DDShowKeyboard)
        {
            //显示的是键盘,这是需要隐藏键盘，显示表情，不需要动画
            _bottomShowComponent = (_bottomShowComponent & 0) | DDShowEmotion;
            [self.chatInputView.textView resignFirstResponder];
            [self.emotions.view setFrame:DDEMOTION_FRAME];
            [self.ddUtility.view setFrame:DDCOMPONENT_BOTTOM];
        }
        else if (_bottomShowComponent & DDShowEmotion)
        {
            //表情面板本来就是显示的,这时需要隐藏所有底部界面
            [self.chatInputView.textView resignFirstResponder];
            _bottomShowComponent = _bottomShowComponent & DDHideEmotion;
        }
        else if (_bottomShowComponent & DDShowUtility)
        {
            //显示的是插件，这时需要隐藏插件，显示表情
            [self.ddUtility.view setFrame:DDCOMPONENT_BOTTOM];
            [self.emotions.view setFrame:DDEMOTION_FRAME];
            _bottomShowComponent = (_bottomShowComponent & DDHideUtility) | DDShowEmotion;
        }
        else
        {
            //这是什么都没有显示，需用动画显示表情
            _bottomShowComponent = _bottomShowComponent | DDShowEmotion;
            // [UIView animateWithDuration:0.25 animations:^{
            
            [self.emotions.view setFrame:DDEMOTION_FRAME];
            [self.chatInputView setFrame:DDINPUT_TOP_FRAME];
            //}];
            [self setValue:@(DDINPUT_TOP_FRAME.origin.y) forKeyPath:@"_inputViewY"];
        }
        
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.250000];
        [UIView setAnimationCurve:7];
        
        CGRect rect = _tableView.frame;
        if(SCREENHEIGHT<500)
        {
            rect.size.height = SCREENHEIGHT-216-44-64-44-SCREENHEIGHT*0.1;
        }
        else
        {
        rect.size.height = SCREENHEIGHT-216-44-64-44-SCREENHEIGHT*0.2;
        }
        _tableView.frame = rect;
        //adjust UUInputFunctionView's originPoint
        [UIView commitAnimations];
        [self tableViewScrollToBottom];
        
    }
    //-(IBAction)showUtilitys:(id)sender
    -(void)showUtility:(id)sende
    {
        [_recordButton setImage:[UIImage imageNamed:@"dd_record_normal"] forState:UIControlStateNormal];
        _recordButton.tag = DDVoiceInput;
        [self.chatInputView willBeginInput];
        if ([_currentInputContent length] > 0)
        {
            [self.chatInputView.textView setText:_currentInputContent];
            
        }
        
        if (self.ddUtility == nil)
        {
            self.ddUtility = [ChatUtilityViewController new];
            self.ddUtility.delegate = self;
            [self addChildViewController:self.ddUtility];
            self.ddUtility.view.frame=CGRectMake(0, self.view.frame.size.height,self.view.frame.size.width , 280);
            [self.view addSubview:self.ddUtility.view];
            
        }
        
        if (_bottomShowComponent & DDShowKeyboard)
        {
            //显示的是键盘,这是需要隐藏键盘，显示插件，不需要动画
            _bottomShowComponent = (_bottomShowComponent & 0) | DDShowUtility;
            [self.chatInputView.textView resignFirstResponder];
            [self.ddUtility.view setFrame:DDUTILITY_FRAME];
            [self.emotions.view setFrame:DDCOMPONENT_BOTTOM];
            
        }
        else if (_bottomShowComponent & DDShowUtility)
        {
            //插件面板本来就是显示的,这时需要隐藏所有底部界面
            //        [self p_hideBottomComponent];
            //        [self.chatInputView.textView becomeFirstResponder];
            //        _bottomShowComponent = _bottomShowComponent & DDHideUtility;
            
        }
        else if (_bottomShowComponent & DDShowEmotion)
        {
            //显示的是表情，这时需要隐藏表情，显示插件
            [self.emotions.view setFrame:DDCOMPONENT_BOTTOM];
            [self.ddUtility.view setFrame:DDUTILITY_FRAME];
            _bottomShowComponent = (_bottomShowComponent & DDHideEmotion) | DDShowUtility;
            
        }
        else
        {
            //这是什么都没有显示，需用动画显示插件
            _bottomShowComponent = _bottomShowComponent | DDShowUtility;
            //[UIView animateWithDuration:0.25 animations:^{
            [self.ddUtility.view setFrame:DDUTILITY_FRAME];
            [self.chatInputView setFrame:DDINPUT_TOP_FRAME];
            //}];
            [self setValue:@(DDINPUT_TOP_FRAME.origin.y) forKeyPath:@"_inputViewY"];
            
            
        }
        
        //调节tableView的高度 tableView滚动到底部
        if(_tableView.frame.size.height == SCREENHEIGHT-216-64-44)
        {
            return;
        }
        else
        {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.250000];
            [UIView setAnimationCurve:7];
            
            CGRect rect = _tableView.frame;
            if(SCREENHEIGHT<500)
            {
                rect.size.height = SCREENHEIGHT-216-44-64-44-SCREENHEIGHT*0.1;
            }
            else
            {
            rect.size.height = SCREENHEIGHT-216-44-64-44-SCREENHEIGHT*0.2;
            }
            _tableView.frame = rect;
            //adjust UUInputFunctionView's originPoint
            [UIView commitAnimations];
            [self tableViewScrollToBottom];
            
        }
    }
    - (void)p_clickThRecordButton:(UIButton*)button
    {
        switch (button.tag) {
            case DDVoiceInput:
                //开始录音 界面UI进行连动的改变
                [self p_hideBottomComponent];
                [button setImage:[UIImage imageNamed:@"dd_input_normal"] forState:UIControlStateNormal];
                button.tag = DDTextInput;
                [self.chatInputView willBeginRecord];
                [self.chatInputView.textView resignFirstResponder];
                _currentInputContent = self.chatInputView.textView.text;
                if ([_currentInputContent length] > 0)
                {
                    [self.chatInputView.textView setText:nil];
                }
                break;
            case DDTextInput:
                //开始输入文字
                [button setImage:[UIImage imageNamed:@"dd_record_normal"] forState:UIControlStateNormal];
                button.tag = DDVoiceInput;
                [self.chatInputView willBeginInput];
                if ([_currentInputContent length] > 0)
                {
                    [self.chatInputView.textView setText:_currentInputContent];
                }
                [self.chatInputView.textView becomeFirstResponder];
                break;
        }
    }
    
    //开始录音的部分
    - (void)p_record:(UIButton*)button
    {
        [MP3 startRecord];
        playTime = 0;
        playTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countVoiceTime) userInfo:nil repeats:YES];
        [UUProgressHUD show];
        
        //    [self.chatInputView.recordButton setHighlighted:YES];
        //    if (![[self.view subviews] containsObject:_recordingView])
        //    {
        //        [self.view addSubview:_recordingView];
        //    }
        //    [_recordingView setHidden:NO];
        //    [_recordingView setRecordingState:DDShowVolumnState];
        
        //    [[RecorderManager sharedManager] setDelegate:self];
        //    [[RecorderManager sharedManager] startRecording];
        //    NSLog(@"record");
    }
    - (void)countVoiceTime
    {
        playTime ++;
        if (playTime>=60) {
            [self p_sendRecord:nil];
        }
    }
    
    //结束取消发送
    - (void)p_endCancelRecord:(UIButton*)button
    {
        //    [_recordingView setHidden:NO];
        //    [_recordingView setRecordingState:DDShowVolumnState];
        [UUProgressHUD changeSubTitle:@"向上滑动，取消发送"];
        
    }
    //即将开始取消发送
    - (void)p_willCancelRecord:(UIButton*)button
    {
        //    [_recordingView setHidden:NO];
        //    [_recordingView setRecordingState:DDShowCancelSendState];
        //    NSLog(@"will cancel record");
        [UUProgressHUD changeSubTitle:@"松开 取消"];
        
    }
    //发送
    - (void)p_sendRecord:(UIButton*)button
    {
        // [self.chatInputView.recordButton setHighlighted:NO];
        //    [[RecorderManager sharedManager] stopRecording];
        //    NSLog(@"send record");
        
        if(playTimer)
        {
            [MP3 stopRecord];
            [playTimer invalidate];
            playTimer = nil;
        }
    }
    - (void)p_cancelRecord:(UIButton*)button
    {
        if(playTimer)
        {
            [MP3 cancelRecord];
            [playTimer invalidate];
            playTimer = nil;
        }
        
        [UUProgressHUD dismissWithError:@"取消"];
        
        //    [self.chatInputView.recordButton setHighlighted:NO];
        //        [_recordingView setHidden:YES];
        //    [[RecorderManager sharedManager] cancelRecording];
        //    NSLog(@"cancel record");
    }
#pragma mark - Mp3RecorderDelegate（这个回调得到的数据位MP3）
    -(void)endConvertWithData:(NSData *)voiceData
    {
        //声音为二进制数据
        //    NSDictionary *dic = @{@"voice": voiceData,
        //                          @"strVoiceTime": [NSString stringWithFormat:@"%d",(int)playTime],
        //                          @"type": @(UUMessageTypeVoice)};
        //    [self dealTheFunctionData:dic];
        
        //存储声音数据的长度的值(使用NSUserDefaults  单例)
        NSString *timeString = [NSString stringWithFormat:@"%d",(int)playTime];
        [[NSUserDefaults standardUserDefaults]setObject:timeString forKey:Voicetime];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths objectAtIndex:0];
        NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:@"audio.mp3"];
        [voiceData writeToFile:fullPathToFile atomically:YES];
        
        
        NSURL*url=[NSURL URLWithString:@"http://chat.immbear.com:8889/file/uploader"];
        /*上传按钮 使用路径的上传方式*/
        ASIFormDataRequest*logpicrequest=[ASIFormDataRequest requestWithURL:url];
        [logpicrequest addFile:fullPathToFile withFileName:@"impower" andContentType:@"audio/mp3" forKey:@"Content-Type"];
        logpicrequest.delegate=self;
        [voiceData writeToFile:fullPathToFile atomically:NO];
        [logpicrequest setFile:fullPathToFile forKey:@"uploadFile"];
        // [logpicrequest   setData:imageData forKey:@"cont"];
        logpicrequest.tag=103;
        [logpicrequest startAsynchronous];//异步开始
        
        
        [UUProgressHUD dismissWithSuccess:@"发送成功"];
        
        //缓冲消失时间 (最好有block回调消失完成)
        self.chatInputView.recordButton.userInteractionEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.chatInputView.recordButton.userInteractionEnabled = YES;
        });
    }
    -(void)failRecord
    {
        [UUProgressHUD dismissWithError:@"时间太短"];
        
        
        //缓冲消失时间 (最好有block回调消失完成)  缓冲消失时间
        self.chatInputView.recordButton.userInteractionEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.chatInputView.recordButton.userInteractionEnabled = YES;
        });
        
    }
    -(void)beginConvert
    {
        
    }
    
    
#pragma mark - KeyBoardNotification
    - (void)handleWillShowKeyboard:(NSNotification *)notification
    {
        //键盘改变设置聊天输入框的位置
        CGRect keyboardRect;
        keyboardRect = [(notification.userInfo)[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
        
        _bottomShowComponent = _bottomShowComponent | DDShowKeyboard;
        //什么都没有显示
        [UIView animateWithDuration:0.25 animations:^{
            [self.chatInputView setFrame:CGRectMake(0, keyboardRect.origin.y - DDINPUT_HEIGHT, self.view.frame.size.width, DDINPUT_HEIGHT)];
        }];
        [self setValue:@(keyboardRect.origin.y - DDINPUT_HEIGHT) forKeyPath:@"_inputViewY"];
        
        //键盘改变设置tableView的位置
        
        NSDictionary *userInfo = [notification userInfo];
        NSTimeInterval animationDuration;
        UIViewAnimationCurve animationCurve;
        
        [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
        [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
        //获取键盘的高度
        //[[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
        NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGFloat keyboardHeight = CGRectGetHeight([value CGRectValue]);
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:animationCurve];
        
        CGRect rect = _tableView.frame;
        if(SCREENHEIGHT<500)
        {
            rect.size.height = SCREENHEIGHT-keyboardHeight-64-44-SCREENHEIGHT*0.1-44;
        }
        else
        {
        rect.size.height = SCREENHEIGHT-keyboardHeight-64-44-SCREENHEIGHT*0.2-44;
        }
        _tableView.frame = rect;
        //adjust UUInputFunctionView's originPoint
        [UIView commitAnimations];
        
        
    }
    
    - (void)handleWillHideKeyboard:(NSNotification *)notification
    {
        CGRect keyboardRect;
        keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
        _bottomShowComponent = _bottomShowComponent & DDHideKeyboard;
        if (_bottomShowComponent & DDShowUtility)
        {
            //显示的是插件
            [UIView animateWithDuration:0.25 animations:^{
                [self.chatInputView setFrame:DDINPUT_TOP_FRAME];
            }];
            [self setValue:@(self.chatInputView.frame.origin.y) forKeyPath:@"_inputViewY"];
        }
        else if (_bottomShowComponent & DDShowEmotion)
        {
            //显示的是表情
            [UIView animateWithDuration:0.25 animations:^{
                [self.chatInputView setFrame:DDINPUT_TOP_FRAME];
            }];
            [self setValue:@(self.chatInputView.frame.origin.y) forKeyPath:@"_inputViewY"];
            
        }
        else
        {
            [self p_hideBottomComponent];
        }
        
        
        //键盘位置改变设置tableView的位置
        NSDictionary *userInfo = [notification userInfo];
        NSTimeInterval animationDuration;
        UIViewAnimationCurve animationCurve;
        CGRect keyboardEndFrame;
        
        [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
        [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
        [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:animationCurve];
        
        //adjust ChatTableView's height  调节聊天tableView的高度
        //    if (notification.name == UIKeyboardWillShowNotification) {
        //
        //        self.bottomConstraint.constant = keyboardEndFrame.size.height+40;
        //    }else{
        //        self.bottomConstraint.constant = 40;
        //    }
        
        
        CGRect rect = _tableView.frame;
        rect.size.height = SCREENHEIGHT-64-44;
        _tableView.frame = rect;
        
        
        [UIView commitAnimations];
        
        
    }
#pragma mark - Text view delegatef
    
    - (void)viewheightChanged:(float)height
    {
        [self setValue:@(self.chatInputView.frame.origin.y) forKeyPath:@"_inputViewY"];
    }
    
#pragma mark-(发送文字表情)
    - (void)textViewEnterSend
    {
        
        //发送消息
        NSString* text = [self.chatInputView.textView text];
        //
        //    NSDictionary *dic = @{@"strContent":text,@"type":@(UUMessageTypeText)};
        //    self.chatInputView.textView.text = @"";
        //    [self dealTheFunctionData:dic];
        
        NSString *myIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
        if(text.length != 0)
        {
            [webSocketManager YBSendMessageFromUser:myIDString toGname:_gnameString message:text messageType:@"text"];
        }
        self.chatInputView.textView.text = nil;
        
        //对表情进行处理的正则表达式，如果输入框中含有表情 则需要将表情进行正则表达式的转换
        
        //    NSString* parten = @"\\s";
        //    NSRegularExpression* reg = [NSRegularExpression regularExpressionWithPattern:parten options:NSRegularExpressionCaseInsensitive error:nil];
        //
        //    NSString* checkoutText = [reg stringByReplacingMatchesInString:text options:NSMatchingReportProgress range:NSMakeRange(0, [text length]) withTemplate:@""];
        //    if ([checkoutText length] == 0)
        //    {
        //        return;
        //    }
    }
#pragma mark-(发送图片)
    -(void)sendPicture:(UIImage *)image
    {
        
        //    NSDictionary *dic = @{@"picture": image,
        //                          @"type": @(UUMessageTypePicture)};
        //    [self dealTheFunctionData:dic];
        
        //发送图片之前 先要把图片进行上传得到图片的URL 然后message作为messageBody里面的内容消息进行发送
        NSData *imageData = UIImagePNGRepresentation(image);
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths objectAtIndex:0];
        NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:@"sendPic.png"];
        [imageData writeToFile:fullPathToFile atomically:YES];
        NSURL*url=[NSURL URLWithString:@"http://chat.immbear.com:8889/file/uploader"];
        ASIFormDataRequest*logpicrequest=[ASIFormDataRequest requestWithURL:url];
        logpicrequest.delegate=self;
        [imageData writeToFile:fullPathToFile atomically:NO];
        [logpicrequest setFile:fullPathToFile forKey:@"uploadFile"];
        // [logpicrequest   setData:imageData forKey:@"cont"];
        logpicrequest.tag=101;
        [logpicrequest startAsynchronous];//异步开始
        
        
    }
    
#pragma mark-(发送图片语音返回的ASI代理)
    -(void)requestFinished:(ASIHTTPRequest *)request
    {
        
        NSString *myIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
        //发送图片
        if(request.tag == 101)
        {
            
            NSDictionary *picDict = [request.responseString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
            [webSocketManager YBSendMessageFromUser:myIDString toGname:_gnameString message:picDict[@"url"] messageType:picDict[@"content_type"]];
            
            
        }
        if(request.tag == 103)
        {
            NSLog(@"%@",request.responseString);
            NSDictionary *voiceDict = [request.responseString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
            [webSocketManager YBSendMessageFromUser:myIDString toGname:_gnameString message:voiceDict[@"url"] messageType:voiceDict[@"content_type"]];
            
        }
        
    }
    
    
#pragma makr-(总的处理发送的文字消息 图片 表情 语音  交给chatModel处理)
    - (void)dealTheFunctionData:(NSDictionary *)dic
    {
        [self.chatModel addSpecifiedItem:dic];
        [_tableView reloadData];
        [self tableViewScrollToBottom];
    }
    
#pragma mark - KVO
    - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
    {
        if ([keyPath isEqualToString:@"_inputViewY"])
        {
            //            [self p_unableLoadFunction];
            [UIView animateWithDuration:0.25 animations:^{
                if (_bottomShowComponent & DDShowEmotion)
                {
                    CGRect frame = self.emotions.view.frame;
                    frame.origin.y = self.chatInputView.bottom;
                    self.emotions.view.frame = frame;
                }
                if (_bottomShowComponent & DDShowUtility)
                {
                    CGRect frame = self.ddUtility.view.frame;
                    frame.origin.y = self.chatInputView.bottom;
                    self.ddUtility.view.frame = frame;
                }
                
            } completion:^(BOOL finished) {
                //                [self p_enableLoadFunction];
            }];
        }
        
    }
    - (void)p_tapOnTableView:(UIGestureRecognizer*)sender
    {
        if (_bottomShowComponent)
        {
            [self p_hideBottomComponent];
        }
        
    }


//创建表格视图
-(void)createTableView
{
    NSDictionary *activityDict = self.activityArray[0];

    if([[activityDict allKeys]containsObject:@"title"])
    {
    _ActivityTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-64-44) style:UITableViewStylePlain];
    _ActivityTableView.delegate = self;
    _ActivityTableView.dataSource = self;
    if(self.activityArray.count == 1)
    {
        _ActivityTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    //设置表格视图左边短15像素问题
    if([_ActivityTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_ActivityTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if([_ActivityTableView  respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_ActivityTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self.view insertSubview:_ActivityTableView atIndex:0];
    }
    else
    {
       noActivityLabel = [ZCControl createLabelWithFrame:CGRectMake(0, SCREENHEIGHT*0.1, SCREENWIDTH, SCREENHEIGHT*0.1) Font:SCREENWIDTH*0.048 Text:@"暂无商店活动"];
        noActivityLabel.textAlignment = NSTextAlignmentCenter;
        //[self.view addSubview:noActivityLabel];
        [self.view insertSubview:noActivityLabel atIndex:0];
    }
}

#pragma mark-(设置解决表格视图左边短15像素问题)
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == _tableView)
    {
        return self.chatModel.dataSource.count ;
    }
    else
    {
    return self.activityArray.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _tableView)
    {
        static NSString *cellID = @"cell";
        UUMessageCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
        if(cell == nil)
        {
            cell = [[UUMessageCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
            cell.delegate = self;
        }
        //config cell
        
        
        [cell setMessageFrame:self.chatModel.dataSource[indexPath.row]];
        
        return cell;

    }
    else
    {
    static NSString *cellID = @"cell";
    shopInfoThirdTableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
    if(cell == nil)
    {
        cell = [[shopInfoThirdTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
    //config cell
    if(self.activityArray.count != 0)
    {
        NSDictionary *dict = self.activityArray[indexPath.row];
        
        cell.titleLabel.text = dict[@"title"];
    
                NSString *bt = [dict[@"bt"] substringToIndex:10];
                NSString *et = [dict[@"et"] substringToIndex:10];
                NSString *dateString = [NSString stringWithFormat:@"活动时间：%@至%@",bt,et];
                cell.dateLabel.text = dateString;
                cell.webView.backgroundColor = [UIColor whiteColor];
        
                //查询宽度（加上自动换行）
                NSString *finalString = [NSString stringWithFormat:@"<style>p{word-wrap: break-word;word-break: normal;}</style>%@",dict[@"content"]];
        
                NSMutableArray *_widthArray = [[NSMutableArray alloc]init];
        
                NSString *regex = @"width:[0-9]+";
                NSError *error;
                NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
                NSArray *matchs = [regular matchesInString:finalString options:0 range:NSMakeRange(0, finalString.length)];
        NSRange widthRange;
                for(NSTextCheckingResult *match in matchs)
                {
                    widthRange = [match range];
                    
                    NSString *mstr = [finalString substringWithRange:widthRange];
                     NSLog(@"正则表达式匹配的字符串 = %@",mstr);
                    NSString *widthValueString = [mstr substringFromIndex:6];
                     NSLog(@"宽度%@",widthValueString);
                    [_widthArray addObject:widthValueString];
        
                }
        
                //查询高度
                NSMutableArray *_heightArray = [[NSMutableArray alloc]init];
        
                NSString *heightRegex = @"height:[0-9]+";
                NSRegularExpression *heightRegular = [NSRegularExpression regularExpressionWithPattern:heightRegex options:NSRegularExpressionCaseInsensitive error:&error];
                NSArray *heightMatchs = [heightRegular matchesInString:finalString options:0 range:NSMakeRange(0, finalString.length)];
                NSString *heightValueString = [[NSString alloc]init];
        NSRange heightRange;
                for(NSTextCheckingResult *heightMatch in heightMatchs)
                {
                    heightRange = [heightMatch range];
                    NSString *heightString = [finalString substringWithRange:heightRange];
                    heightValueString = [heightString substringFromIndex:7];
                    [_heightArray addObject:heightValueString];
                }
        
                //判断是否要更改
                for(int i = 0;i<_widthArray.count;i++)
                {
                    NSString *deceidedWidthSting = _widthArray[i];
                    NSString *deceideHeightSting = _heightArray[i];
                    NSRange finalWidthRange = NSMakeRange(widthRange.location+6, deceidedWidthSting.length);
                    NSRange finalHeightRange = NSMakeRange(heightRange.location+7, deceideHeightSting.length);
                    if(deceidedWidthSting.intValue>SCREENWIDTH)
                    {
                        NSString *finaleDeceideWidthing = [NSString stringWithFormat:@"%f",SCREENWIDTH-15];
                        NSString *finaleDeceideHeighing = [NSString stringWithFormat:@"%f",deceideHeightSting.intValue*(SCREENWIDTH/deceidedWidthSting.intValue)];
                        //字符串的替换操作
//                        finalString = [finalString stringByReplacingOccurrencesOfString:deceidedWidthSting withString:finaleDeceideWidthing];
//                        finalString = [finalString stringByReplacingOccurrencesOfString:deceideHeightSting withString:finaleDeceideHeighing];
                        
                        finalString = [finalString stringByReplacingCharactersInRange:finalWidthRange withString:finaleDeceideWidthing];
                        finalString = [finalString stringByReplacingCharactersInRange:finalHeightRange withString:finaleDeceideHeighing];
                        
                    }
                    else
                    {
                        NSString *finaleDeceideWidthing = [NSString stringWithFormat:@"%f",SCREENWIDTH-15];
                        //finalString = [finalString stringByReplacingOccurrencesOfString:deceidedWidthSting withString:finaleDeceideWidthing];
                        finalString = [finalString stringByReplacingCharactersInRange:finalWidthRange withString:finaleDeceideWidthing];
                    }
                }
        
                NSLog(@"嘿嘿嘿嘿嘿%@",finalString);
                [cell.webView loadHTMLString:finalString baseURL:nil];
        
    }

    return cell;
    }
}

#pragma mark-(设置各种高度)

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _tableView)
    {
        return [self.chatModel.dataSource[indexPath.row] cellHeight];
    }
    else
    {
        return SCREENHEIGHT*0.7;
    }
}

//聊天视图上面cell的点击
-(void)cellContentDidClick:(UUMessageCell *)cell image:(UIImage *)contentImage
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    NSDictionary *messageDict = _chatDataArray[indexPath.row];
    if([messageDict[@"mtype"] isEqualToString:@"mmx/goods"])
    {
        //商品
        collectionCommodityDetailViewController *vc = [[collectionCommodityDetailViewController alloc]init];
        NSString *detailDictString = messageDict[@"m"];
        NSDictionary *detailDict = [detailDictString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        vc.goodsIDString = [NSString stringWithFormat:@"%@",detailDict[@"id"]];
        // NSLog(@"***********%@",messageDict);
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([messageDict[@"mtype"] isEqualToString:@"mmx/shop"])
    {
        //商店
        mainShopDetailViewController *vc = [[mainShopDetailViewController alloc]init];
        vc.YB_ShopDetailChangeDelegate = self;
        vc.gnameString = self.gnameString;
        vc.invitationLabelString = invitationLabel.text;
        
        NSString *detailDictString = messageDict[@"m"];
        NSDictionary *detailDict = [detailDictString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        vc.shopPic = detailDict[@"img"];
        vc.shopIDString = [NSString stringWithFormat:@"%@",detailDict[@"id"]];
        vc.shopNamestrting = detailDict[@"name"];
        // NSLog(@"***********%@",messageDict);
        
        
        NSArray *array = self.navigationController.viewControllers;
        NSLog(@"当前栈中导航控制器 = %@",array);
        
        //如果之前存在商店则pop到商店  如果不存在商店的话则push到商店
        NSString *pushString = [[NSString alloc]init];
        int pushNumber = 0;
        for(int i = 0;i<array.count-1;i++)
        {
            if([array[i] isKindOfClass:[mainShopDetailViewController class]])
            {
                pushString = @"1";
                pushNumber = i;
            }

        }
        
        if([pushString isEqualToString:@"1"])
        {
            //vc = array[array.count-2];
            //[self.navigationController popToViewController:array[array.count-2] animated:YES];
            //视图退出之前进行界面之间的传值
            //[self.YB_delegate YBSendActivityDelgateWithGname:self.gnameString andGroupName:invitationLabel.text];
            [self.YB_delegate YBSendActivityDelgateWithGname:self.gnameString andGroupName:invitationLabel.text andShopID:[NSString stringWithFormat:@"%@",detailDict[@"id"]] andShopPic:detailDict[@"img"] andShopName:detailDict[@"name"]];
            [self.navigationController popToViewController:array[pushNumber] animated:YES];
           
        }
        else
        {
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }
    else if ([messageDict[@"mtype"] isEqualToString:@"mmx/act"])
    {
        //活动
        
        NSString *detailDictString = messageDict[@"m"];
        NSDictionary *detailDict = [detailDictString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        //vc.activityIDString = [NSString stringWithFormat:@"%@",detailDict[@"id"]];
        NSString *activiIDString = detailDict[@"id"];
        //由活动的ID去下载活动的具体信息
        NSString *urlString = [NSString stringWithFormat:ACTIVITYDETAILURL,DomainName,activiIDString.intValue];
        // NSLog(@"聊天内活动的URl%@",urlString);
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//            inShopActivityViewController *vc = [[inShopActivityViewController alloc]init];
//            vc.gnameString = self.gnameString;
//            vc.invitationLabelString = invitationLabel.text;
//            vc.YB_delegate = self;
            NSMutableArray *activityArray = [[NSMutableArray alloc]init];
            NSMutableDictionary *activityDict = [[NSMutableDictionary alloc]init];
            [activityDict setObject:dict[@"actID"] forKey:@"id"];
            [activityDict setObject:dict[@"title"] forKey:@"title"];
            [activityDict setObject:dict[@"content"] forKey:@"content"];
            [activityDict setObject:dict[@"bt"] forKey:@"bt"];
            [activityDict setObject:dict[@"et"] forKey:@"et"];
            NSArray *picArray = dict[@"shopPic"];
            [activityDict setObject:picArray[0] forKey:@"img"];
            [activityDict setObject:dict[@"shopID"] forKey:@"shopID"];
            [activityArray addObject:activityDict];
            self.activityArray = activityArray;
            [noActivityLabel removeFromSuperview];
            [_ActivityTableView removeFromSuperview];
            [self createTableView];
            //[_ActivityTableView reloadData];
            
//            vc.activityArray = activityArray;
//            [self.navigationController pushViewController:vc animated:YES];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }

}

//活动到商店的反向传值
-(void)YBShopDetailChangeGroupGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    self.gnameString = gname;
    self.invitationLabelString = groupName;
    [self.YB_delegate YBSendActivityDelgateWithGname:gname andGroupName:groupName];
    
    if(_gnameString.length != 0)
    {
        invitationLabel.text = groupName;
        [self loadBaseViewsAndData];
    }
    
}


-(void)createUINav
{
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"商店活动"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    //导航栏左按钮
    UIButton *leftButton = [ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(leftButtonBtn:) Title:nil    ];
    [leftButton setImage:[UIImage imageNamed:@"店铺-店铺详情_03"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    //导航栏右按钮
    UIButton *rightButton = [ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(rightButtonDidClick:) Title:nil];
    [rightButton setImage:[UIImage imageNamed:@"发送1"] forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
}
//导航栏右按钮点击发送活动
-(void)rightButtonDidClick:(UIButton *)button
{
    if(self.gnameString.length != 0)
    {
        NSString *myIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
        for(NSDictionary *dict in self.activityArray)
        {
        
        [webSocketManager YBsendMMXMessageFromUser:myIDString toGname:self.gnameString mmxID:dict[@"id"] mmxImg:dict[@"img"] mmxName:dict[@"title"] messageType:@"mmx/act"];
        }
        
    }

}


-(void)leftButtonBtn:(UIButton *)button
{
    //视图退出之前进行界面之间的传值
    [self.YB_delegate YBSendActivityDelgateWithGname:self.gnameString andGroupName:invitationLabel.text];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

    - (void)dealloc
    {
        
        [[UUAVAudioPlayer sharedInstance]stopSound];
        
        //当有KVO观察者模式的时候 视图从栈中销毁  需要移除当前视图的观察者
        
        //    [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        //需要判断下 当前是否存在KVO的观察者模式
        // [self removeObserver:self forKeyPath:@"_inputViewY"];
    }

#pragma mark - EmotionsViewController Delegate
    //发送图片表情
    - (void)emotionViewClickSendButton
    {
        [self textViewEnterSend];
    }
    //输入框中插入聊天表情
    -(void)insertEmojiFace:(NSString *)string
    {
        NSMutableString* content = [NSMutableString stringWithString:self.chatInputView.textView.text];
        [content appendString:string];
        [self.chatInputView.textView setText:content];
    }
    //输入框中删除聊天表情
    -(void)deleteEmojiFace
    {
        EmotionsModule* emotionModule = [EmotionsModule shareInstance];
        NSString* toDeleteString = nil;
        if (self.chatInputView.textView.text.length == 0)
        {
            return;
        }
        if (self.chatInputView.textView.text.length == 1)
        {
            self.chatInputView.textView.text = @"";
        }
        else
        {
            toDeleteString = [self.chatInputView.textView.text substringFromIndex:self.chatInputView.textView.text.length - 1];
            int length = [emotionModule.emotionLength[toDeleteString] intValue];
            if (length == 0)
            {
                toDeleteString = [self.chatInputView.textView.text substringFromIndex:self.chatInputView.textView.text.length - 2];
                length = [emotionModule.emotionLength[toDeleteString] intValue];
            }
            length = length == 0 ? 1 : length;
            self.chatInputView.textView.text = [self.chatInputView.textView.text substringToIndex:self.chatInputView.textView.text.length - length];
        }
        
    }
#pragma mark - UIGestureRecognizerDelegate
    - (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
    {
        CGPoint location = [gestureRecognizer locationInView:self.view];
        if (CGRectContainsPoint(DDINPUT_BOTTOM_FRAME, location))
        {
            return NO;
        }
        return YES;
    }
    - (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
        if ([gestureRecognizer.view isEqual:_tableView])
        {
            return YES;
        }
        return NO;
    }
#pragma mark -
    - (void)playingStoped
    {
        
    }

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
