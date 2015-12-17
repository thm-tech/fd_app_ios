//
//  ViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/4/7.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "ViewController.h"
#import "SidebarViewController.h"
#import "PopoverView.h"

#import "TMQuiltView.h"
#import "TMPhotoQuiltViewCell.h"
#import "introductionTableViewCell.h"

#import "personalInformationViewController.h"
#import "firendsViewController.h"
#import "miaomiaoViewController.h"
#import "myFansShopViewController.h"
#import "myCollectionCommodityViewController.h"
#import "myLookedShopViewController.h"
#import "ZCZBarViewController.h"
#import "myCityViewController.h"
#import "settingViewController.h"
#import "userFeedbackViewController.h"

#import "mainShopDetailViewController.h"

#import "loginViewController.h"

#import "shakeAndShakeViewController.h"
#import "invivateFriendsShoppingViewController.h"
#import "changeChatGroupViewController.h"
#import "loginViewController.h"
#import "searchViewController.h"
#import "activityDetailViewController.h"
#import "moreActivityViewController.h"

#import "shopInformationViewController.h"
#import "collectionCommodityDetailViewController.h"
#import "mmxActivityDetailViewController.h"
#import "inShopActivityViewController.h"
#import "friendsDetailViewController.h"

#import "DIImageView.h"
#import "mainShopTableViewCell.h"
#import "mainShopIntroduceTableViewCell.h"
#import "mainShopActivityTableViewCell.h"


//聊天相关
#import "TouchDownGestureRecognizer.h"
#import "EmotionsModule.h"
#import "Mp3Recorder.h"
#import "UUProgressHUD.h"
#import "ASIFormDataRequest.h"
#import "UUAVAudioPlayer.h"

//数据模型类相关
#import "introductionModel.h"
#import "activityModel.h"
#import "waterfullModel.h"

//获取用户信息
#import "staticUserInfo.h"
#import "myAppDataBase.h"

//地图相关定位
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "UIView+MJExtension.h"
#import "MJRefresh.h"

#import "danLiDataCenter.h"

#define MAININTRODUCTION_URL @"http://%@/user/shop/recommend?city=%d"
#define ACTIVITY_URL @"http://%@/user/activity?city=%d&offset=%d&count=%d"
#define WATERFULL_URL @"http://%@/user/shop?category=%d&city=%d&long=%f&lat=%f&offset=%d&count=%d"
#define MAINSHOPGOODSINFORMATIONYRL @"http://%@/userweb/shopgoods/%@?count=2"

//关注商店URL
#define SHOPATTENTIONURL @"http://%@/user/shop/concern?sid=%d"

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


#import "nextViewController.h"




@interface ViewController () <YBSideTableViewDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,YBMenuTableViewDelegate,YBCollectionViewDelegate,UIActionSheetDelegate,Mp3RecorderDelegate,UIScrollViewDelegate,YBInvivateFriendGnameDelegate,UIAlertViewDelegate,ASIHTTPRequestDelegate,YBChangeGroupNameDelegate,YBShopDetailChangeGroupNameDelegate,mainShopSendShopDelegate,YBMainShopIntroduceDelegate,YBSendActivityDelegate,YBSendMoreActivityDelegate,YBShopInformationChangeGnameDelegate,YBSearchViewControllerChatDelegate,CLLocationManagerDelegate,YBMyFanShopChatChangeGnameDelegate,YBMyLookedShopChatChangeGroupGnameDelegate,YBFriendChatDelegate,YBFriendDetailChatDelegate,YBShakeChangeChatDelegate,YBMyCollectionChatChangeGnameDelegate>

{
    UIPanGestureRecognizer* panGesture;
    UITextField *_searchTextField;
    
    //瀑布流
    TMQuiltView *qtmquitView;
    
    UITableView *_mainShopTableView;
    
    //活动专区横向的tableView
    UITableView *_introducetionTableView;
    
    //数据
      NSArray *_shopNameArray;
//    NSArray *_distanceArray;
//    NSArray *_attentionCountArray;
//    NSArray *_onlinePeopleArray;
    
    //品牌推荐的scrollview
    UIScrollView *_scrollView;
    UIPageControl *_scrollViewPageControl;
    //推荐广告栏数据相关
    YBHttpRequest *_httpRequest;
    NSMutableArray *_mainIntroductionArray;
    
    
    //活动专区相关数据
    NSMutableArray *_activityArray;
    int activityOffset;
    int activityCount;
    
    //瀑布流的数据相关
    NSMutableArray *_waterfullArray;
    int categoryID;
    float longitude;
    float latitude;
    int waterfullOffect;
    int waterfullCount;
    
    NSMutableArray *_mainShopGoodArray;
    
    //保存瀑布流图片高度的数组
    NSMutableArray *_imageHeightArray;
    NSMutableArray *_finalImageHeightArray;
    NSMutableArray *_waterFullImageHeightFinalArray;
    
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
    
    //地图定位相关
    CLLocationManager *_locationManager;
    
    //显示聊天记录的条数
    int pageCount;
    
}
@property (nonatomic, retain) SidebarViewController* sidebarVC;

//瀑布流相片数组
@property (nonatomic,strong) NSMutableArray *images;
@property (nonatomic,strong) UILabel *secondTitleLabel;

//当前的gname
@property (copy,nonatomic) NSString *gnameString;

- (void)p_clickThRecordButton:(UIButton*)button;
- (void)p_record:(UIButton*)button;
- (void)p_willCancelRecord:(UIButton*)button;
- (void)p_cancelRecord:(UIButton*)button;
- (void)p_sendRecord:(UIButton*)button;
- (void)p_endCancelRecord:(UIButton*)button;

- (void)p_hideBottomComponent;
- (void)p_tapOnTableView:(UIGestureRecognizer*)sender;

@end

@implementation ViewController
{
    TouchDownGestureRecognizer* _touchDownGestureRecognizer;
    DDBottomShowComponent _bottomShowComponent;
    UIButton *_recordButton;
    float _inputViewY;
    NSString* _currentInputContent;
}
//视图即将显示的时候
-(void)viewWillAppear:(BOOL)animated
{
    
    //显示状态栏
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
    
    //聊天输入框输入为空 聊天框输入为空 刷新聊天输入框
    [self.chatInputView.textView setText:nil];
    
    
    //隐藏聊天输入框
    // [self p_hideBottomComponent];
    
    //当视图即将显示的时候 重新加载聊天数据 
   // [self loadBaseViewsAndData];
    
   // [self createBottomView];
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
    
   
//    __weak typeof(self) weakSelf = self;
//    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
//    {
//        self.navigationController.interactivePopGestureRecognizer.delegate = weakSelf;
//    }
    
    //创建MP3播放器
    
    MP3 = [[Mp3Recorder alloc]initWithDelegate:self];
    webSocketManager = [YBWebSocketManager sharedInstance];
    
    
    //聊天模块中数据源数组中加入数据
    self.chatModel = [[chatModel alloc]init];
    self.chatModel.isGroupChat = NO;
    _chatDataArray = [[NSMutableArray alloc]init];
    
    
    self.cityIDString = [NSString stringWithFormat:@"1048577"];
    
    
    _waterfullArray = [[NSMutableArray alloc]init];
    
    
    //定位
    [self startLocation];
    
    
    [self createUINavi];
    
    //整个界面的tableView
    [self createTableView];
    
    //创建标题的label
    //[self createTitleLabel];
    
    //创建品牌推荐的数据
    [self createINtroducetionScrollViewAndData];
    
    //创建活动专区数据
    [self createIntroducetionTableViewChangeActivity];
    
    //创建瀑布流
    //[self createWaterView];
    
    //创建底部view
    [self createBottomView];
    
    //创建侧滑菜单
    [self createSideMenu];
    
    [self downLoadMainData];
    
    //通知
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(insertBaseViewsAndDataWithGname:) name:@"startLoadWebSocketData" object:nil];
    
    [nc addObserver:self selector:@selector(upDateMyGname:) name:@"startLoadGname" object:nil];
    
    //从网络上获取聊天记录
    [nc addObserver:self selector:@selector(loadBaseViewsAndDataWithGname) name:@"startLoadChatDataFromeNet" object:nil];
    
    //当退出当前账号的时候 清空当前组的gname 以及聊天记录
    [nc addObserver:self selector:@selector(logoutCleanGname) name:@"changeLogout" object:nil];

    //退出讨论组  如果是退出当前的聊天框的讨论组 则清空label和聊天记录
    [nc addObserver:self selector:@selector(existGroup:) name:@"existGroup" object:nil];
    
    //删除讨论组 清空聊天
    [nc addObserver:self selector:@selector(logoutCleanGname) name:@"deleteMiaoMiaoRecordCleanGname" object:nil];
    //获取聊天类的数据
    //[self loadBaseViewsAndData];
    
    // Do any additional setup after loading the view, typically from a nib.
}

    

#pragma mark-(及时聊天插入一条新的消息)
-(void)insertBaseViewsAndDataWithGname:(NSNotification *)notification
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

#pragma mark-(退出讨论组 如果是退出当前的讨论组 则清空gname以及聊天记录)
-(void)existGroup:(NSNotification *)notification
{
    NSString *existGnameString = notification.userInfo[@"existGname"];
    if([existGnameString isEqualToString:self.gnameString])
    {
        self.gnameString = nil;
        [_chatDataArray removeAllObjects];
        [self.chatModel populateRandomDataSource:_chatDataArray];
        invitationLabel.text = @"可以邀请好友一起逛哦";
        [_tableView reloadData];

    }
}

#pragma mark-(当退出当前账号的时候 清空当前组的gname 以及聊天记录)
-(void)logoutCleanGname
{
    self.gnameString = nil;
    [_chatDataArray removeAllObjects];
    [self.chatModel populateRandomDataSource:_chatDataArray];
    invitationLabel.text = @"可以邀请好友一起逛哦";
    [_tableView reloadData];
}

#pragma mark-(定位自己的地理位置)
-(void)startLocation
{
    if(![CLLocationManager locationServicesEnabled])
    {
        NSLog(@"不支持定位");
        return;
    }
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 10;
    //[_locationManager requestWhenInUseAuthorization];
    if([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
    {
        [_locationManager requestAlwaysAuthorization];
        [_locationManager requestWhenInUseAuthorization];
    }
    [_locationManager startUpdatingLocation];

}
//定位的代理
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //获取当前位置----是地球地址(国际地址)
    //manager.location
    CLLocation *location = manager.location;
    longitude = location.coordinate.longitude;
    latitude = location.coordinate.latitude;
}


//通知传值 更新当前gname
-(void)upDateMyGname:(NSNotification *)notifiction
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
    _gnameString = upDateGname;
    
    //同时修改标题label的值
    NSDictionary *oneGnameInfo = [[myAppDataBase sharedInstance]getOneMiaoMiaoRecordWithGname:upDateGname];
    invitationLabel.text = oneGnameInfo[@"name"];
    
    [self loadBaseViewsAndDataWithGname];

}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    if(self.sidebarVC.view.hidden == YES)
    {
        [[NSUserDefaults standardUserDefaults]setObject:@"yes" forKey:SideBarHidden];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults]setObject:@"no" forKey:SideBarHidden];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    [self p_hideBottomComponent];
    //解除通知
    //[[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark-(webSocket相关)
//获取聊天记录（先查询本地数据库 如果本地没有则用webSocket进行通信)
-(void)useWebSocketGetRecord
{
   
    //这是获取最新的聊天记录(当需要显示更多消息的时候 开始时间为上次取的最后一条记录的时间)
    [webSocketManager YBGetRecordWithGname:_gnameString andStartTime:@"0" andRecordCount:@"30"];
}

//获取组内成员信息 (不用来显示聊天内容里面的user)
-(void)useWebSocketGetGroupUserInformation
{
    [webSocketManager YBGetGroupUsersWithGname:_gnameString];
    
}


#pragma mark-(聊天的模块)
-(void)loadBaseViewsAndDataWithGname
{
    
    [_chatDataArray removeAllObjects];
    
    //判断gname是否存在 （当第一次运行的时候 gname不存在）
    if(_gnameString.length != 0)
    {
        pageCount = 7;
        
       //获取聊天记录 如果数据库中没有useWebSocket
    if([[myAppDataBase sharedInstance]isExistMessageWith:_gnameString])
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
    
       // [_tableView insertRowsAtIndexPaths:<#(NSArray *)#> withRowAnimation:<#(UITableViewRowAnimation)#>]
        
        //聊天记录tableView滚动到底部
        [self tableViewScrollToBottom];
        
    }
    else
    {
        //获取聊天记录
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
//聊天的tableView滚动到底部
-(void)tableViewScrollToBottom
{
    if(self.chatModel.dataSource.count == 0)
        return;
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
    invitationLabel.text = @"可以邀请好友一起逛哦";
    invitationLabel.adjustsFontSizeToFitWidth = YES;
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
    //invitationButton.backgroundColor = [UIColor orangeColor];
    [invitationButton setImage:[UIImage imageNamed:@"首页_14"] forState:UIControlStateNormal];
    [bottomView addSubview:invitationButton];
    
}
#pragma mark-(点击显示收缩的处理事件)
-(void)dealWithAllContraction:(UIControl *)control
{
    if(control.tag == 101)
    {
        moreActivityViewController *vc = [[moreActivityViewController alloc]init];
        vc.dataArray = _activityArray;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (control.tag == 102)
    {
        activityDetailViewController *vc = [[activityDetailViewController alloc]init];
        vc.model = _activityArray[0];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(control.tag == 103)
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
        //contractionImageView.frame = CGRectMake(SCREENWIDTH*0.41, 36, SCREENWIDTH*0.18, 8);
        invitationLabel.textColor = [UIColor whiteColor];
        contractionImageView.image = [UIImage imageNamed:@"店铺_10"];
        [invitationButton setImage:[UIImage imageNamed:@"首页_15"] forState:UIControlStateNormal];
        //创建聊天输入框
        //视图的原点y从64开始
        CGRect inputFrame = CGRectMake(0, SCREEN_HEIGHT -44,SCREEN_WIDTH,44.0f);
        self.chatInputView = [[JSMessageInputView alloc] initWithFrame:inputFrame delegate:self];
        //[self.chatInputView setBackgroundColor:[UIColor orangeColor]];
        [self.chatInputView setBackgroundColor:[UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0]];
        [self.view insertSubview:self.chatInputView atIndex:2];
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
    __weak ViewController* weakSelf = self;
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
    //[self addObserver:self forKeyPath:@"_inputViewY" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];

    
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
        
        //添加下拉刷新加载更多聊天记录的空进啊
//        NSArray *messageArray = [staticUserInfo getMessagesWithGname:self.gnameString];
//        if(messageArray.count > 7)
//        {
            __weak typeof(self) weakSelf2 = self;
            [_tableView addLegendHeaderWithRefreshingBlock:^{
                
                [weakSelf2 loadMoreChatData];
                
            }];
       // }
        
    //添加轻击和拖移的手势去回收键盘
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_tapOnTableView:)];
    [_tableView addGestureRecognizer:tap];
    
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(p_tapOnTableView:)];
    pan.delegate = self;
    [_tableView addGestureRecognizer:pan];
    [_tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];

    //tableView的内容滚动到下方
    [self tableViewScrollToBottom];
      
        [self.view insertSubview:_tableView atIndex:2];
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

#pragma mark-(创建整个主界面的tableView)
-(void)createTableView
{
    _mainShopTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-64-44) style:UITableViewStyleGrouped];
    _mainShopTableView.delegate = self;
    _mainShopTableView.dataSource = self;
   // _mainShopTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //设置表格视图左边短15像素问题
    if([_mainShopTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_mainShopTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if([_mainShopTableView  respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_mainShopTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    //下拉刷新
    __weak typeof(self) weakSelf1 = self;
    
    
    [_mainShopTableView addLegendHeaderWithRefreshingBlock:^{
        [weakSelf1 loadRefreshNewData];
    }];
    //马上进入刷新状态
    //[_mainShopTableView.legendHeader beginRefreshing];
    
    
    
    //上拉加载更多
    [_mainShopTableView addLegendFooterWithRefreshingBlock:^{
        [weakSelf1 loadREfreshMoreData];
    }];
    
    [self.view insertSubview:_mainShopTableView atIndex:0];
}
#pragma mark-(上拉刷新)
-(void)loadREfreshMoreData
{
    waterfullOffect += 10;
    [self downloadWaterfullData];
    //[_mainShopTableView reloadData];
    [_mainShopTableView.footer endRefreshing];
}

#pragma mark-(下拉刷新)
-(void)loadRefreshNewData
{
    [_mainIntroductionArray removeAllObjects];
    [_activityArray removeAllObjects];
    [_waterfullArray removeAllObjects];
    [_mainShopGoodArray removeAllObjects];
    
    [self createINtroducetionScrollViewAndData];
    [self createIntroducetionTableViewChangeActivity];
    waterfullOffect = 0;
    [self downloadWaterfullData];
    //[_mainShopTableView reloadData];
    [_mainShopTableView.header endRefreshing];
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
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == _tableView)
    {
        return 1;
    }
    else
    {
        return 3;
    }
}

//行数是根据消息数组中消息数目来动态地确定
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //消息的行数
    if(tableView == _tableView)
    {
        //return 10;
        return self.chatModel.dataSource.count ;
    }
    else
    {
        if(section == 0)
        {
            if(_mainIntroductionArray.count == 0)
            {
                return 0;
            }
            else
            {
                return 1;
            }
        }
        else if (section == 1)
        {
            if(_activityArray.count == 0)
            {
                return 0;
            }
            else
            {
                return 2;
            }
        }
        else
        {
            if(_waterfullArray.count != 0)
            {
            return _waterfullArray.count;
            }
            else
            {
                return 0;
            }
        }
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
        
    //自适应聊天的赋值
    [cell setMessageFrame:self.chatModel.dataSource[indexPath.row]];
    
    return cell;
    }
    else
    {
        if(indexPath.section == 0)
        {
            
            static NSString *cellID = @"cell";
            mainShopIntroduceTableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
            if(cell == nil)
            {
                cell = [[mainShopIntroduceTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
                cell.YB_delegate = self;
            }
            if(_mainIntroductionArray.count != 0)
            {
                introductionModel *model1 = _mainIntroductionArray[0];
            
                NSNumber *widthNumber = [[NSNumber alloc]initWithLong:(long)((SCREENWIDTH-40)/3)];
                NSNumber *heightNumber = [[NSNumber alloc]initWithLong:(long)(SCREENHEIGHT*0.2-20)];
                
                
                [cell.activityButton1 sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@@%@w_%@h_1e_0l_1c",model1.pic,widthNumber,heightNumber]] forState:UIControlStateNormal];
                
                introductionModel *model2 = _mainIntroductionArray[1];
                [cell.activityButton2 sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@@%@w_%@h_1e_0l_1c",model2.pic,widthNumber,heightNumber]] forState:UIControlStateNormal];
                
                introductionModel *model3 = _mainIntroductionArray[2];
                [cell.activityButton3 sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@@%@w_%@h_1e_0l_1c",model3.pic,widthNumber,heightNumber]] forState:UIControlStateNormal];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else if (indexPath.section == 1)
        {
            if(indexPath.row == 0)
            {
            static NSString *cellID = @"cell";
            UITableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
            if(cell == nil)
            {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
                
            }
            cell.textLabel.text = @"活动专区";
                cell.textLabel.textColor = [UIColor colorWithHexStr:@"#333333"];
            cell.detailTextLabel.text = @"更多";
                cell.detailTextLabel.textColor = [UIColor colorWithHexStr:@"#48d58b"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            }
            else
            {
                static NSString *cellID = @"cell";
                mainShopActivityTableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
                if(cell == nil)
                {
                    cell = [[mainShopActivityTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                    
                }
                if(_activityArray.count != 0)
                {
                    NSNumber *widthNumber = [[NSNumber alloc]initWithLong:(long)(SCREENWIDTH-20)];
                    NSNumber *heightNumber = [[NSNumber alloc]initWithLong:(long)(SCREENHEIGHT*0.3-10)];
                    
                activityModel *model = _activityArray[indexPath.row-1];
                    NSString *shopPic = [NSString stringWithFormat:@"%@@%@w_%@h_1e_0l_1c",model.shopPic,widthNumber,heightNumber];
                    
                [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:shopPic]];
                cell.activityNameLabel.text = model.title;
                cell.shopNameLabel.text = model.shopName;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                return cell;
            }
        }
        else
        {
            static NSString *cellID = @"cell";
            mainShopTableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
            if(cell == nil)
            {
                cell = [[mainShopTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
                cell.YB_delagete = self;
            }
            //config cell
            if(_waterfullArray.count != 0)
            {
        waterfullModel *model = _waterfullArray[indexPath.row];
        cell.shopNameLabel.text = model.name;
        cell.attentionCountLabel.text = [NSString stringWithFormat:@"%@",model.fans];
        cell.onLineCountLabel.text = [NSString stringWithFormat:@"%@",model.customers];
                cell.discountImageView1.hidden = YES;
                cell.discountImageView2.hidden = YES;
                cell.bttomImageView1.hidden = YES;
                cell.bttomImageView2.hidden = YES;
                NSDictionary *dict = [[NSDictionary alloc]init];
                if(_mainShopGoodArray.count != 0)
                {
                dict = _mainShopGoodArray[indexPath.row];
                }
        NSArray *goodArray = dict[@"goods"];
                
                NSNumber *widthNumber = [[NSNumber alloc]initWithLong:(long)((SCREENWIDTH-30)/2)];
                NSNumber *heightNumber = [[NSNumber alloc]initWithLong:(long)(SCREENHEIGHT*0.45*0.75)];
                
        if(goodArray.count != 0)
        {
//            cell.discountImageView1.hidden = NO;
//            cell.discountImageView2.hidden = NO;
//            cell.bttomImageView1.hidden = NO;
//            cell.bttomImageView2.hidden = NO;
            
        NSDictionary *detailDict1 = goodArray[0];
        [cell.goodsImageView1 sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@@%@w_%@h_1e_0l_1c",detailDict1[@"pic"],widthNumber,heightNumber]]];
            cell.goodsNameLabel1.text = detailDict1[@"name"];
//
//            NSString *orignalPriceLabel1NullString = [NSString stringWithFormat:@"%@",detailDict1[@"price"]];
//            if(![orignalPriceLabel1NullString isEqualToString:@"<null>"])
//            {
//            
//        cell.orignalPriceLabel1.text = [NSString stringWithFormat:@"￥%@",detailDict1[@"price"]];
//            }
//       // cell.discountPriceLabel1.text = [NSString stringWithFormat:@"%@",detailDict1[@"promot"]];
//            NSString *discountPriceLabel1NullString = [NSString stringWithFormat:@"%@",detailDict1[@"promot"]];
//            if(![discountPriceLabel1NullString isEqualToString:@"<null>"])
//            {
//                cell.discountPriceLabel1.text = [NSString stringWithFormat:@"￥%@",detailDict1[@"promot"]];
//            }
//            else
//            {
//                cell.discountImageView1.hidden = YES;
//                cell.orignalPriceLabel1.hidden = YES;
//                
//                if(![orignalPriceLabel1NullString isEqualToString:@"<null>"])
//                {
//                cell.discountPriceLabel1.text = [NSString stringWithFormat:@"￥%@",detailDict1[@"price"]];
//                }
//            }
            
            if(goodArray.count >1)
            {
        NSDictionary *detailDict2 = goodArray[1];
                
                [cell.goodsImageView2 sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@@%@w_%@h_1e_0l_1c",detailDict2[@"pic"],widthNumber,heightNumber]]];
                cell.goodsNamelable2.text = detailDict2[@"name"];
                
//                NSString *orignalPriceLabel2NullString = [NSString stringWithFormat:@"%@",detailDict2[@"price"]];
//                if(![orignalPriceLabel2NullString isEqualToString:@"<null>"])
//                {
//        cell.orignalPriceLabel2.text = [NSString stringWithFormat:@"￥%@",detailDict2[@"price"]];
//                }
//            
//            NSString *discountPriceLabel2NullString = [NSString stringWithFormat:@"%@",detailDict2[@"promot"]];
//            if(![discountPriceLabel2NullString isEqualToString:@"<null>"])
//            {
//        cell.discountPriceLabel2.text = [NSString stringWithFormat:@"￥%@",detailDict2[@"promot"]];
//            }
//            else
//            {
//                cell.discountImageView2.hidden = YES;
//                cell.orignalPriceLabel2.hidden = YES;
//                if(![orignalPriceLabel2NullString isEqualToString:@"<null>"])
//                {
//                cell.discountPriceLabel2.text = [NSString stringWithFormat:@"￥%@",detailDict2[@"price"]];
//                }
//            }
            }
            else
            {
                cell.discountImageView2.hidden = YES;
            }
        }
            //判断是否已经关注商店
            NSMutableDictionary *isExistFansShopDict = [[NSMutableDictionary alloc]init];
            NSNumber *shopIDNumber = [[NSNumber alloc]initWithInt:model.id.intValue];
            [isExistFansShopDict setObject:shopIDNumber forKey:@"id"];
            
                
            if([[myAppDataBase sharedInstance]isExistFansShopRecordWithDicitionary:isExistFansShopDict recordType:RecoredTypeAttention])
            {
                [cell.attentionButton setImage:[UIImage imageNamed:@"收藏实心"] forState:UIControlStateNormal];
            }
            else
            {
                [cell.attentionButton setImage:[UIImage imageNamed:@"收藏"] forState:UIControlStateNormal];
            }
            
            }
            return cell;
        }
    }
    
}
#pragma mark-(推荐品牌上面按钮点击的协议)
-(void)YBMainShopIntroduceButtonDidClick:(UIButton *)button
{
    //对点击的button进行判断
    long index = button.tag - 100 -1;
    //跳转界面之前通过index获取到数据数组中的值 进行传值之后在进行界面的跳转
    mainShopDetailViewController *mdvc = [[mainShopDetailViewController alloc]init];
    
    mdvc.YB_ShopDetailChangeDelegate = self;
    //传递参数 获取到shopID
    introductionModel *model = _mainIntroductionArray[index];
    mdvc.shopIDString = model.id;
    mdvc.shopNamestrting = model.name;
    mdvc.shopPic = model.pic;
    mdvc.gnameString = _gnameString;
    mdvc.invitationLabelString = invitationLabel.text;
    [self.navigationController pushViewController:mdvc animated:YES];
    
}

#pragma mark-(发送商店按钮的协议)
-(void)YBMainShopSendShopButtonDidClick:(UIButton *)button
{
    mainShopTableViewCell *cell = (mainShopTableViewCell *)[[button superview]superview];
    NSIndexPath *path = [_mainShopTableView indexPathForCell:cell];
    
    NSLog(@"主界面增加收藏%@",path);
    
    waterfullModel *model = _waterfullArray[path.row];
    
    if(button.tag == 102)
    {
    NSArray *picArray = model.picList;
    NSString *picUrlString = picArray[0];
    
    if(_gnameString.length != 0)
    {
        NSString *myIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
        [webSocketManager YBsendMMXMessageFromUser:myIDString toGname:_gnameString mmxID:model.id mmxImg:picUrlString mmxName:model.name messageType:@"mmx/shop"];
    }
    }
    else if (button.tag == 101)
    {
        
        //与后台通信
        NSString *urlString = [NSString stringWithFormat:SHOPATTENTIONURL,DomainName,model.id.intValue];
        //NSLog(@"后台通讯%@",urlString);
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        
        NSMutableDictionary *addToBaseDict = [[NSMutableDictionary alloc]init];
        
        NSNumber *shopIDNumber = [[NSNumber alloc]initWithInt:model.id.intValue];
        NSNumber *acceptMessageNumber = [[NSNumber alloc]initWithInt:1];
        
        //获取当前加粉丝店的时间
        NSString *date = [[NSString alloc]init];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateStyle:kCFDateFormatterFullStyle];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        date = [formatter stringFromDate:[NSDate date]];
        
        NSArray *picArray = model.picList;
        
        [addToBaseDict setObject:shopIDNumber forKey:@"id"];
        [addToBaseDict setObject:model.name forKey:@"name"];
        [addToBaseDict setObject:picArray[0] forKey:@"pic"];
        [addToBaseDict setObject:date forKey:@"time"];
        
        //默认接受粉丝店的推送消息cv
        [addToBaseDict setObject:acceptMessageNumber forKey:@"msgEnable"];
        
        // NSLog(@"增加粉丝店的字典%@",addToBaseDict);
        
        if([[myAppDataBase sharedInstance] isExistFansShopRecordWithDicitionary:addToBaseDict recordType:RecoredTypeAttention])
        {
            //删除收藏
            [manager DELETE:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                //当delete成功之后 改变button的状态
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                NSString *errString = dict[@"err"];
                if(errString.intValue == 0)
                {
                    
                    cell.attentionCountLabel.text = [NSString stringWithFormat:@"%d",cell.attentionCountLabel.text.intValue-1];
                    [button setImage:[UIImage imageNamed:@"收藏"] forState:UIControlStateNormal];
                    [[myAppDataBase sharedInstance] deleteFansShopRecordWithDicitionary:addToBaseDict recordType:RecoredTypeAttention];
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                NSLog(@"主界面删除收藏 error = %@",error);
            }];
        }
        else
        {
            //NSDictionary *dict = @{@"sid":self.shopIDString};
            //增加收藏
            
            [manager POST:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                //当post成功之后 改变button的image
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                NSString *errString = dict[@"err"];
                if(errString.intValue == 0)
                {
                    int a = cell.attentionCountLabel.text.intValue;
                    cell.attentionCountLabel.text = [NSString stringWithFormat:@"%d",a+1];
                    
                    [button setImage:[UIImage imageNamed:@"收藏实心"] forState:UIControlStateNormal];
                    [[myAppDataBase sharedInstance] addFansShopRecordWithDicitionary:addToBaseDict recordType:RecoredTypeAttention];
                    
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                 NSLog(@"主界面增加收藏 error = %@",error);
                
            }];
            
            
        }

    }
    
}

//根据消息内容cell动态地计算行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _tableView)
    {
    //return 50;
        return [self.chatModel.dataSource[indexPath.row] cellHeight];
    }
    else
    {
        if(indexPath.section == 0)
        {
            return SCREENHEIGHT*0.2;
        }
        else if (indexPath.section ==1)
        {
            if(indexPath.row == 0)
            {
                return SCREENHEIGHT*0.06;
            }
            else
            {
                return SCREENHEIGHT*0.3;
            }
        }
        else
        {
            return SCREENHEIGHT*0.45;
        }
    }
}
//cell上面的点击
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(tableView == _tableView)
    {
    
    
    [self.view endEditing:YES];
    }
    else
    {
        if(indexPath.section == 0)
        {
            
        }
        else if(indexPath.section == 1)
        {
            if(indexPath.row == 0)
            {
                moreActivityViewController *vc = [[moreActivityViewController alloc]init];
                vc.gnameString = self.gnameString;
                vc.invitationLabelString = invitationLabel.text;
                vc.YB_delegate = self;
                vc.dataArray = _activityArray;
                [self.navigationController pushViewController:vc animated:YES];

            }
            else if (indexPath.row == 1)
            {
//                activityDetailViewController *vc = [[activityDetailViewController alloc]init];
//                vc.model = _activityArray[0];
//                [self.navigationController pushViewController:vc animated:YES];
                
                inShopActivityViewController *vc = [[inShopActivityViewController alloc]init];
                vc.gnameString = self.gnameString;
                vc.invitationLabelString = invitationLabel.text;
                vc.YB_delegate = self;
                activityModel *model = _activityArray[0];
                NSMutableArray *activityArray = [[NSMutableArray alloc]init];
                NSMutableDictionary *activityDict = [[NSMutableDictionary alloc]init];
                [activityDict setObject:model.actID forKey:@"id"];
                [activityDict setObject:model.title forKey:@"title"];
                [activityDict setObject:model.content forKey:@"content"];
                [activityDict setObject:model.bt forKey:@"bt"];
                [activityDict setObject:model.et forKey:@"et"];
                [activityDict setObject:model.shopPic forKey:@"img"];
                [activityDict setObject:model.shopID forKey:@"shopID"];
                [activityArray addObject:activityDict];
            
                vc.activityArray = activityArray;
                [self.navigationController pushViewController:vc animated:YES];
                
                
            }
        }
        else
        {
        
    
        mainShopDetailViewController *msdvc = [[mainShopDetailViewController alloc]init];
        
        msdvc.YB_ShopDetailChangeDelegate = self;
        //传递参数
        waterfullModel *model = _waterfullArray[indexPath.row];
        
        int picWidth = (SCREENWIDTH-30)/2;
        
        NSArray *picArray = model.picList;
            NSString *picUrlString = [[NSString alloc]init];
            if(picArray.count != 0)
            {
              picUrlString = picArray[0];
            }
        NSString *picString = [NSString stringWithFormat:@"%@@%dw",picUrlString,picWidth];
        
        msdvc.shopNamestrting = model.name;
        msdvc.shopIDString = model.id;
        msdvc.shopPic = picString;
        
        msdvc.gnameString = _gnameString;
        msdvc.invitationLabelString = invitationLabel.text;
        
        [self.navigationController pushViewController:msdvc animated:YES];
        }
        
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView == _tableView)
    {
        return 0.1f;
    }
    else
    {
        return 0.1f;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(tableView == _tableView)
    {
        return 0.1f;
    }
    else
    {
    if(section == 2)
    {
        return 0.1f;
    }
    else
    {
        return SCREENHEIGHT*0.01;
    }
    }
}

#pragma mark-(自己制定的cell上面头像的点击代理)
-(void)headImageDidClick:(UUMessageCell *)cell userId:(NSString *)userId
{
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:cell.messageFrame.message.strName message:@"headImage clicked" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil];
//    [alert show];
}
//聊天视图上面cell上面的点击
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
        [self.navigationController pushViewController:vc animated:YES];
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
           inShopActivityViewController *vc = [[inShopActivityViewController alloc]init];
            vc.gnameString = self.gnameString;
            vc.invitationLabelString = invitationLabel.text;
            vc.YB_delegate = self;
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
            
            vc.activityArray = activityArray;
            [self.navigationController pushViewController:vc animated:YES];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
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
    NSData *imageData = UIImageJPEGRepresentation(image, 0.1);;
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

#pragma mark-(拉好友点击)
//拉好友点击
-(void)invitationButtonBtn:(UIButton *)button
{
    UIActionSheet *ac = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"切换聊天",@"发起聊天",@"摇一摇", nil];
    [ac showInView:self.view];
}
//拉好友动作列表的代理
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //判断是否已经登录建立长链接
    NSString *loginString = [[NSUserDefaults standardUserDefaults]objectForKey:IsLogin];
    
    if(buttonIndex == 0)
    {
        if(loginString)
        {
        changeChatGroupViewController *ccgvc = [[changeChatGroupViewController alloc]init];
            ccgvc.YB_ChangeGroupGnameDelegate = self;
        [self.navigationController pushViewController:ccgvc animated:YES];
        }
        else
        {
            UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"亲，您还没登录哟！" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [al show];
        }
        
    }
    else if (buttonIndex == 1)
    {
        if(loginString)
        {
        invivateFriendsShoppingViewController *isvc = [[invivateFriendsShoppingViewController alloc]init];
        isvc.YB_GnameDelegate = self;
        [self.navigationController pushViewController:isvc animated:YES];
        }
        else
        {
            UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"亲，您还没登录哟！" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [al show];
        }
    }
    else if(buttonIndex == 2)
    {
        if(loginString)
        {
        shakeAndShakeViewController *ssvc = [[shakeAndShakeViewController alloc]init];
            ssvc.gnameString = self.gnameString;
            ssvc.invitationLabelString = invitationLabel.text;
            ssvc.YB_delegate = self;
        [self.navigationController pushViewController:ssvc animated:YES];
        }
        else
        {
            UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"亲，您还没登录哟！" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登录", nil];
            [al show];
        }
    }
    else
    {
        
    }

}
#pragma mark-(拉好友提醒登录代理)
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        loginViewController *lvc = [[loginViewController alloc]init];
        [self.navigationController pushViewController:lvc animated:YES];
    }
}



#pragma mark-(更多活动界面的反向传值——聊天)
-(void)YBSendMoreActivityDelegateWithGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    _gnameString = gname;
    if(_gnameString.length != 0)
    {
        invitationLabel.text = groupName;
        [self loadBaseViewsAndDataWithGname];
    }

}

#pragma mark-(发送商店的界面的反向传值--聊天)
-(void)YBShopInformationChangeGnameWithGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    _gnameString = gname;
    if(_gnameString.length != 0)
    {
        invitationLabel.text = groupName;
        [self loadBaseViewsAndDataWithGname];
    }

}

#pragma mark-(发送活动界面的反向传值——聊天)
-(void)YBSendActivityDelgateWithGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    _gnameString = gname;
    if(_gnameString.length != 0)
    {
        invitationLabel.text = groupName;
        [self loadBaseViewsAndDataWithGname];
    }

}

//从摇一摇界面的反向传值
-(void)YBShakeChangeChatWithGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    _gnameString = gname;
    if(_gnameString.length != 0)
    {
        invitationLabel.text = groupName;
        [self loadBaseViewsAndDataWithGname];
    }
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
    _gnameString = messageGname;
    
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
    [self loadBaseViewsAndDataWithGname];
}

#pragma mark-(切换聊天组的代理)
-(void)YBChangeGroupGNameWith:(NSString *)gname andGroupName:(NSString *)groupName
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

    invitationLabel.text = groupName;
    _gnameString = gname;
    [self loadBaseViewsAndDataWithGname];
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
#pragma mark-(数据类相关)
-(void)downLoadMainData
{
    waterfullOffect = 0;
    [self downloadWaterfullData];
    
}
#pragma mark-(下载瀑布流商家的数据)
-(void)downloadWaterfullData
{
    
    categoryID = 0;
//    longitude = 12.000000;
//    latitude = 12.000000;
    
    waterfullCount = 10;
    
    
    NSString *urlString = [NSString stringWithFormat:WATERFULL_URL,DomainName,categoryID,self.cityIDString.intValue,longitude,latitude,waterfullOffect,waterfullCount];
    NSLog(@"**************瀑布流%@",urlString);
    
    _httpRequest = [[YBHttpRequest alloc]initWithURLString:urlString target:self action:@selector(downloadWaterfullDataFinish:)];
    
}
-(void)downloadWaterfullDataFinish:(YBHttpRequest *)httpRequest
{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:httpRequest.downloadData options:NSJSONReadingMutableContainers error:nil];
    //为0表示成功
    NSString *errString = dict[@"err"];
    if(errString.intValue == 0)
    {
       NSArray *array = dict[@"shopList"];
        if(array.count != 0)
        {
       for(NSDictionary *shopDic in array)
      {
        waterfullModel *model = [[waterfullModel alloc]init];
        [model setValuesForKeysWithDictionary:shopDic];
        [_waterfullArray addObject:model];
      }
        }
    }
    NSString *finalGoodsInformationString = [[NSString alloc]init];
    NSString *goodsInformationString = [[NSString alloc]init];
    if(_waterfullArray.count != 0)
    {
    for(int i = 0;i<_waterfullArray.count;i++)
    {
        waterfullModel *model = _waterfullArray[i];
        
        if(i == _waterfullArray.count-1)
        {
            goodsInformationString = [NSString stringWithFormat:@"%@",model.id];
        }
        else
        {
            goodsInformationString = [NSString stringWithFormat:@"%@,",model.id];
        }
        finalGoodsInformationString = [finalGoodsInformationString stringByAppendingString:goodsInformationString];
    }

    NSString *goodsUrl = [NSString stringWithFormat:MAINSHOPGOODSINFORMATIONYRL,DomainName,finalGoodsInformationString];
    NSLog(@"****主界面商家商品URL = %@",goodsUrl);
    _httpRequest = [[YBHttpRequest alloc]initWithURLString:goodsUrl target:self action:@selector(downMainShopGoods:)];
    }
}
//下载商家商品数据
-(void)downMainShopGoods:(YBHttpRequest *)httpRequest
{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:httpRequest.downloadData options:NSJSONReadingMutableContainers error:nil];
    NSArray *shopArray = dict[@"shops"];
    if(shopArray.count != 0)
    {
        _mainShopGoodArray = [NSMutableArray arrayWithArray:shopArray];
        [_mainShopTableView reloadData];
       
    }
}

#pragma mark-(创建品牌推荐的scrollView)
-(void)createINtroducetionScrollViewAndData
{
        
    _mainIntroductionArray = [[NSMutableArray alloc]init];
    
    NSString *urlString = [NSString stringWithFormat:MAININTRODUCTION_URL,DomainName,self.cityIDString.intValue];
    NSLog(@"*************品牌推荐%@",urlString);
    _httpRequest = [[YBHttpRequest alloc]initWithURLString:urlString target:self action:@selector(downLOadMainIntroductionDataFinish:)];
}
-(void)downLOadMainIntroductionDataFinish:(YBHttpRequest *)httpRequest
{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:httpRequest.downloadData options:NSJSONReadingMutableContainers error:nil];
    //对下载的数据进行分离
    NSString *str = dict[@"err"];
    if(str.intValue ==0)
    {
        NSArray *array = dict[@"shopList"];
        if(array.count != 0)
        {
        for(NSDictionary *shopDict in array)
        {
            introductionModel *model = [[introductionModel alloc]init];
            //对model进行赋值 字典key在类中一定要有相应的属性对应
            [model setValuesForKeysWithDictionary:shopDict];
            [_mainIntroductionArray addObject:model];
        }
        
        [_mainShopTableView reloadData];
        }
    }
}


#pragma mark-(商店详情界面的反向传值处理)
-(void)YBShopDetailChangeGroupGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    _gnameString = gname;
    if(_gnameString.length != 0)
    {
        invitationLabel.text = groupName;
        [self loadBaseViewsAndDataWithGname];
    }
    
}


#pragma mark-(创建活动专区)
-(void)createIntroducetionTableViewChangeActivity
{
    _activityArray  = [[NSMutableArray alloc]init];
    activityOffset = 0;
    activityCount = 30;
    
    NSString *urlString = [NSString stringWithFormat:ACTIVITY_URL,DomainName,self.cityIDString.intValue,activityOffset,activityCount];
    NSLog(@"*******************活动专区%@",urlString);
    
    _httpRequest = [[YBHttpRequest alloc]initWithURLString:urlString target:self action:@selector(downloadActivityData:)];
}
-(void)downloadActivityData:(YBHttpRequest *)httpRequest
{
    NSDictionary  *dict = [NSJSONSerialization JSONObjectWithData:httpRequest.downloadData options:NSJSONReadingMutableContainers error:nil];
       NSString *errString = dict[@"err"];
    //数据类型的转换 由string类型转化为int类型
    if(errString.intValue == 0)
    {
        NSArray *array = dict[@"actList"];
        if(array.count != 0)
        {
        for(NSDictionary *activityDic in array)
        {
            activityModel *model = [[activityModel alloc]init];
            [model setValuesForKeysWithDictionary:activityDic];
            [_activityArray addObject:model];
        }
        [_mainShopTableView reloadData];
        }
    }
    
}

#pragma mark-(创建侧滑菜单)
-(void)createSideMenu
{
    
    // 左侧边栏开始
     panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
   // panGesture.delegate = self;
   // panGesture.direction = UISwipeGestureRecognizerDirectionDown | UISwipeGestureRecognizerDirectionRight;
    //[panGesture delaysTouchesBegan];
    [self.view addGestureRecognizer:panGesture];
    
    
    //在self.view上面添加侧滑菜单栏
    self.sidebarVC = [[SidebarViewController alloc] init];
    //遵守侧滑菜单上面的cell的点击协议
    self.sidebarVC.YB_delegate = self;
    self.sidebarVC.view.frame  = self.view.bounds;
    [self.sidebarVC setBgRGB:0x000000];
    
    [self.view insertSubview:self.sidebarVC.view atIndex:8];
    //[self.view addSubview:self.sidebarVC.view];
    
    
   
    
}
#pragma mark-(侧滑菜单上面的点击事件)

-(void)YBSideTableViewLoginHeaderViewDidSelected
{
    loginViewController *lvc = [[loginViewController alloc]init];
    [self.navigationController pushViewController:lvc animated:YES];
}

//点击展示个人信息
-(void)YBSideTableViewHeaderViewDidSelected
{
    personalInformationViewController *pvc = [[personalInformationViewController alloc]init];
    [self.navigationController pushViewController:pvc animated:YES];
}

-(void)YBSideTableViewCellDidSelectedWithIndexPath:(NSIndexPath *)indexpath
{
//    nextViewController *nc = [[nextViewController alloc]init];
//    [self.navigationController pushViewController:nc animated:YES];
    
    if(indexpath.section == 0)
    {
    if(indexpath.row == 0)
    {
        
    }
    else if (indexpath.row == 1)
    {
        firendsViewController *fvc = [[firendsViewController alloc]init];
        fvc.gnameString = self.gnameString;
        fvc.invitationLabelString = invitationLabel.text;
        fvc.YB_deleagate = self;
        [self.navigationController pushViewController:fvc animated:YES];
    }
    else if (indexpath.row == 2)
    {
        miaomiaoViewController *mmvc = [[miaomiaoViewController alloc]init];
        mmvc.mainTalkGname = self.gnameString;
        [self.navigationController pushViewController:mmvc animated:YES];
    }
    else if (indexpath.row == 3)
    {
        myFansShopViewController *mfsvc = [myFansShopViewController alloc];
        mfsvc.YB_delegate = self;
        mfsvc.gnameString = self.gnameString;
        mfsvc.invitationLabelString = invitationLabel.text;
        [self.navigationController pushViewController:mfsvc animated:YES];
    }
    else if (indexpath.row == 4)
    {
        myCollectionCommodityViewController *mccvc = [[myCollectionCommodityViewController alloc]init];
        mccvc.gnameString = self.gnameString;
        mccvc.invitationLabelString = invitationLabel.text;
        mccvc.YB_delegate = self;
        
        [self.navigationController pushViewController:mccvc animated:YES];
    }
    else if (indexpath.row == 5)
    {
        myLookedShopViewController *mlsvc = [[myLookedShopViewController alloc]init];
        mlsvc.gnameString = self.gnameString;
        mlsvc.invitationLabelString = invitationLabel.text;
        mlsvc.YB_delegate = self;
        
        [self.navigationController pushViewController:mlsvc animated:YES];
    }
    else
    {
        ZCZBarViewController *vc = [[ZCZBarViewController alloc]initWithBlock:^(NSString *str, BOOL isFinish) {
            if(isFinish)
            {
                NSLog(@"扫描过后的结果%@",str);
                
                NSString *subString = [str substringFromIndex:28];
                
                //对扫描的结果进行处理
                //1.当扫描的是商家店铺时候 跳入商家店铺详情界面  2.当扫描用户二维码的时候 跳入添加好友界面
                if([str rangeOfString:@"user"].location != NSNotFound)
                {
                    //扫描用户的
                    danLiDataCenter *dc = [danLiDataCenter sharedInstance];
                    friendsDetailViewController *fvc =[[friendsDetailViewController alloc]init];
                    fvc.frdIDString = subString;
                    dc.frdIDString = subString;
                    fvc.gnameString = self.gnameString;
                    fvc.invitationLabelString = invitationLabel.text;
                    fvc.YB_delegate = self;
                    
                    
                    [self.navigationController pushViewController:fvc animated:YES];
                }
                if([str rangeOfString:@"shop"].location != NSNotFound)
                {
                    //扫描商家的
                    shopInformationViewController *sfvc = [[shopInformationViewController alloc]init];
                    sfvc.shopIDString = subString;
                    sfvc.gnameString = self.gnameString;
                    sfvc.invitationLabelString = invitationLabel.text;
                    sfvc.YB_delegate = self;
                    
                    
                    [self.navigationController pushViewController:sfvc animated:YES];
                }

                
            }
        }];
        
        [self presentViewController:vc animated:YES completion:nil];
    }
        
    }
    else
    {
        if(indexpath.row == 0)
        {
            myCityViewController *mcvc = [[myCityViewController alloc]init];
            mcvc.YB_CollectionViewDelegate = self;
            [self.navigationController pushViewController:mcvc animated:YES];
        }
        else if (indexpath.row == 1)
        {
            settingViewController *svc = [[settingViewController alloc]init];
            [self.navigationController pushViewController:svc animated:YES];
            
        }
        else
        {
            userFeedbackViewController *ufvc = [[userFeedbackViewController alloc]init];
            [self.navigationController pushViewController:ufvc animated:YES];
            
        }
    }
}
//城市选择collectionView代理
-(void)YBCollectionViewDidClickWithTitle:(NSString *)title
{
   self.sidebarVC.cityString = title;
}

//二维码扫描（扫描好友界面的聊天的反向传值）
-(void)YBYBFriendDetailChatWithGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    _gnameString = gname;
    if(_gnameString.length != 0)
    {
        invitationLabel.text = groupName;
        [self loadBaseViewsAndDataWithGname];
    }
}

#pragma mark-(我的收藏商品的聊天的反向传值)
-(void)YBMyCollectionChatChangeGnameWithGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    _gnameString = gname;
    if(_gnameString.length != 0)
    {
        invitationLabel.text = groupName;
        [self loadBaseViewsAndDataWithGname];
    }

}

#pragma mark-(好友粉丝店以及逛过店的聊天的反向传值)
-(void)YBFriendChatChangeGnamewithGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    _gnameString = gname;
    if(_gnameString.length != 0)
    {
        invitationLabel.text = groupName;
        [self loadBaseViewsAndDataWithGname];
    }
}

#pragma mark-(我的粉丝店进店之后聊天的反向传值）
-(void)YBMyFanShopChatChangeGnameWithGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    _gnameString = gname;
    if(_gnameString.length != 0)
    {
        invitationLabel.text = groupName;
        [self loadBaseViewsAndDataWithGname];
    }

}

#pragma mark-(我逛过的店的聊天的反向传值)
-(void)YBMyLookedShopChatChangeGroupNameWithGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    _gnameString = gname;
    if(_gnameString.length != 0)
    {
        invitationLabel.text = groupName;
        [self loadBaseViewsAndDataWithGname];
    }
}

#pragma mark-(侧滑滑出菜单)
- (void)panDetected:(UIPanGestureRecognizer*)recoginzer
{
    CGPoint point = [recoginzer translationInView:self.view];
    if(self.sidebarVC.view.hidden == YES)
    {
    if(point.x>=0)
    {
        
        [self.sidebarVC panDetected:recoginzer];
        
    }}
    else
    {
        [self.sidebarVC panDetected:recoginzer];
    }
    
}



#pragma amrk-(创建导航栏)
-(void)createUINavi
{
    
    //设置导航栏标题
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"首页"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    // 让iOS7 导航控制器不透明
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"导航栏BG"] forBarMetrics:UIBarMetricsDefault];
    
    //UIBarButtonItem *imageLeftItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"lady's-purse@2x"] style:UIBarButtonItemStylePlain target:self action:@selector(imageLeftItemBtn)];
    UIButton *imageLeftButton  =[ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(imageLeftItemBtn) Title:nil];
    [imageLeftButton setImage:[UIImage imageNamed:@"逛过_03"] forState:UIControlStateNormal];
    UIBarButtonItem *imageLeftItem = [[UIBarButtonItem alloc]initWithCustomView:imageLeftButton];
    self.navigationItem.leftBarButtonItem = imageLeftItem;
    
//    UIButton *rightButton1 = [ZCControl createButtonWithFrame:CGRectMake(0, 0, 30, 30) ImageName:@"lady's-purse@2x" Target:self Action:@selector(rightItemBtn) Title:nil];
//    UIBarButtonItem *rightItem1= [[UIBarButtonItem alloc]initWithCustomView:rightButton1];
    
    UIButton *rightButton2 = [ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 25) ImageName:@"" Target:self Action:@selector(searchButtonBtn) Title:nil];
    [rightButton2 setImage:[UIImage imageNamed:@"搜索"] forState:UIControlStateNormal];
    UIBarButtonItem *rightItem2 = [[UIBarButtonItem alloc]initWithCustomView:rightButton2];

    //隐藏搜索商家分类的按钮
    //self.navigationItem.rightBarButtonItems = @[rightItem2,rightItem1];
    
    self.navigationItem.rightBarButtonItem = rightItem2;


}
//搜索
-(void)searchButtonBtn
{
    searchViewController *vc = [[searchViewController alloc]init];
    vc.YB_delegate = self;
    vc.cityIDString = self.cityIDString;
    vc.gnameString = self.gnameString;
    vc.invitationLabelString = invitationLabel.text;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark-(搜索界面的反向传值——聊天)
-(void)YBSearchViewControllerChangeGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    _gnameString = gname;
    if(_gnameString.length != 0)
    {
        invitationLabel.text = groupName;
        [self loadBaseViewsAndDataWithGname];
    }

}

-(void)imageLeftItemBtn
{
    //回收键盘
    if (_bottomShowComponent)
    {
        [self p_hideBottomComponent];
    }
  
    
    [self.sidebarVC showHideSidebar];
}

-(void)rightItemBtn
{
    CGPoint point = CGPointMake(SCREENWIDTH*0.82, 54);
    //CGPoint point = CGPointMake(sender.frame.origin.x + sender.frame.size.width/2, sender.frame.origin.y + sender.frame.size.height);
    NSArray *titles = @[@"女装", @"男装", @"鞋帽箱包",@"工艺品",@"丽人",@"家居装饰",@"鲜花绿植",@"全部分类"];
    NSArray *images = @[@"28b.png", @"28b.png", @"28b.png",@"28b.png", @"28b.png", @"28b.png",@"28b.png",@"28b.png"];
    PopoverView *pop = [[PopoverView alloc] initWithPoint:point titles:titles images:images];
    pop.YBMenu_delegate = self;
    pop.selectRowAtIndex = ^(NSInteger index){
        //NSLog(@"select index:%ld", index);
        //瀑布流标题的赋值
       _secondTitleLabel.text = titles[index];
    };
    [pop show];
}
//菜单上面按钮点击的代理
-(void)YBMenUTableViewButtonBtn:(NSString *)title
{
    //瀑布流标题的赋值
    _secondTitleLabel.text = title;
    
}




#pragma mark-(键盘回收)
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField == _searchTextField)
    {
        _tableView.hidden = YES;
        self.chatInputView.hidden = YES;
        [self p_hideBottomComponent];
        bottomView.frame = CGRectMake(5,SCREENHEIGHT-44-64, SCREENWIDTH-10, 44);
        contractionImageView.frame = CGRectMake(SCREENWIDTH*0.41, 0, SCREENWIDTH*0.18, 8);
        invitationLabel.text = @"可以邀请好友一起逛哦";

    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[UUAVAudioPlayer sharedInstance]stopSound];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"_inputViewY"];
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


@end
