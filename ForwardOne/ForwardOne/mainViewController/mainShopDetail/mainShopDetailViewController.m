
;//
//  mainShopDetailViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/14.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "mainShopDetailViewController.h"
#import "shopInformationViewController.h"
#import "inShopMyFansShopAndLookedViewController.h"
#import "collectionCommodityDetailViewController.h"
#import "fansShopDetailViewController.h"

#import "shakeAndShakeViewController.h"
#import "invivateFriendsShoppingViewController.h"
#import "changeChatGroupViewController.h"

#import "shopInformationViewController.h"
#import "collectionCommodityDetailViewController.h"
#import "mmxActivityDetailViewController.h"

#import "inShopActivityViewController.h"
#import "inShopFansViewController.h"
#import "inshopLookedViewController.h"

#import "ViewController.h"
#import "SidebarViewController.h"

#import "loginViewController.h"

//聊天相关  
#import "TouchDownGestureRecognizer.h"
#import "EmotionsModule.h"
#import "Mp3Recorder.h"
#import "UUProgressHUD.h"
#import "ASIFormDataRequest.h"
#import "UUAVAudioPlayer.h"

//数据类模型
#import "mainShopDetailCommodityModel.h"

//获取用户信息
#import "staticUserInfo.h"
#import "myAppDataBase.h"

//上拉加载更多的聊天内容
#import "UIView+MJExtension.h"
#import "MJRefresh.h"

#import "danLiDataCenter.h"

//店内商品URL
#define SHOPDETAILCOMMODITYURL @"http://%@/user/goods?sid=%d&offset=%d&count=%d"

//进店URl
#define VISITSHOPURL @"http://%@/user/shop/enter?sid=%d"

//退出商店的URL
#define EXISTSHOPURL @"http://%@/user/shop/exit?sid=%d"

#define INSHOPACTIVITYURL @"http://%@/user/shop/activity?sid=%d"

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



@interface mainShopDetailViewController () <UITextFieldDelegate,UIActionSheetDelegate,Mp3RecorderDelegate,ASIHTTPRequestDelegate,YBInShopMyFansShopAndLookedTableViewDelegate,YBInvivateFriendGnameDelegate,YBChangeGroupNameDelegate,UIGestureRecognizerDelegate,YBInshopLookedDelegate,YBInshopFansDelegate,YBFansShopDetailDelegate,YBShopInformationChangeGnameDelegate,YBSendActivityDelegate,YBShakeChangeChatDelegate,UIAlertViewDelegate>

{
    //聊天
    UITableView *_tableView;
    Mp3Recorder *MP3;
    NSInteger playTime;
    NSTimer *playTimer;
    
    //底部view
    UIView *bottomView;
    UIImageView *contractionImageView;
    UILabel *invitationLabel;
    UIButton *changeChatStyleButton;
    
    //店内商品
    YBHttpRequest *_httpRequest;
    NSMutableArray *_mainShopDetailCommodityArray;
    int mainShopDetailCommodityOffset;
    int mainShopDetailCommodityCount;
    
    //webSocket
    YBWebSocketManager *webSocketManager;
    //组内好友信息数组
    NSMutableArray *_groupUserInformationArray;
    //聊天的消息的数组
    NSMutableArray *_chatDataArray;
    
    
    //数据库
    myAppDataBase *dc;
    
    
    NSMutableArray *_inShopActivityArray;
    
    int pageCount;
    
}
@property (nonatomic, retain) SidebarViewController* sidebarVC;
@property (nonatomic,strong)NSMutableArray *items;

- (void)p_clickThRecordButton:(UIButton*)button;
- (void)p_record:(UIButton*)button;
- (void)p_willCancelRecord:(UIButton*)button;
- (void)p_cancelRecord:(UIButton*)button;
- (void)p_sendRecord:(UIButton*)button;
- (void)p_endCancelRecord:(UIButton*)button;

- (void)p_hideBottomComponent;
- (void)p_tapOnTableView:(UIGestureRecognizer*)sender;

@end

@implementation mainShopDetailViewController
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
    
    //聊天输入框输入为空 聊天框输入为空 刷新聊天输入框
    [self.chatInputView.textView setText:nil];
    
    //隐藏聊天输入框
    // [self p_hideBottomComponent];
    //当选择的是商店聊天室之后 重新选择自己的聊天组
   // [self loadBaseViewsAndData];
   // [self createBottomViewAndChatView];
    
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
    dc = [myAppDataBase sharedInstance];
    
    webSocketManager = [YBWebSocketManager sharedInstance];
    
    //聊天模块中数据源数组中加入数据
    self.chatModel = [[chatModel alloc]init];
    self.chatModel.isGroupChat = NO;
    _chatDataArray = [[NSMutableArray alloc]init];

    
    
    [self createUINa];
    
    //下载店内商品的数据
    [self downLoadMainShopDetailCommodityData];
    
    //创建商品书架陈列的效果
    [self createBookShelfPictureList];
    
    //聊天的模块 下载聊天的数据
    [self loadBaseViewsAndData];
    
    //创建底部view和聊天View
    [self createBottomViewAndChatView];
    
    
    //调用用户进店的协议
    [self visitShop];
    
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
//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    if(![self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
//    {
//    _carousel.currentItemIndex = 0;
//    }
//    return YES;
//}


#pragma mark-(实时更新插入一条聊天记录)
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


#pragma mark-(用户进店协议)
-(void)visitShop
{
    NSString *urlString = [NSString stringWithFormat:VISITSHOPURL,DomainName,self.shopIDString.intValue];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
            //获取当前时间
//            NSString *date = [[NSString alloc]init];
//            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//            [formatter setDateStyle:kCFDateFormatterFullStyle];
//            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//            date = [formatter stringFromDate:[NSDate date]];
            
            //NSLog(@"当前时间%@",date);
            
            NSDate *date1 = [NSDate date];
            NSString *date = [NSString stringWithFormat:@"%ld",(long)[date1 timeIntervalSince1970]];
            //进店成功之后  本地保存逛店记录 （当数据库中有记录的时候则更新记录 没有记录则插入记录）
           if([dc isExistVisitShopRecordWithShopID:self.shopIDString recordTyoe:RecoredTypeAttention])
           {
               //[dc upDateVisitShopTimeWithShopID:self.shopIDString time:date];
               //[dc deleteVisitShopRecordWithRecordType:<#(RecordType)#>]
               //先删除上次记录 然后插入本次记录
               NSNumber *shopIDNumber =[[NSNumber alloc]initWithInt:self.shopIDString.intValue];
               
               [dc deleteVisitShopREcordWithShopID:shopIDNumber recordType:RecoredTypeAttention];
               
               NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
               [dict setObject:date forKey:@"time"];
               [dict setObject:shopIDNumber forKey:@"shopID"];
               [dict setObject:self.shopNamestrting forKey:@"shopName"];
               [dict setObject:self.shopPic forKey:@"shopPic"];
               NSLog(@"逛店记录的字典%@",dict);
               
               [dc addVisitShopRecordWithDicitionary:dict recordType:RecoredTypeAttention];
               
               
           }
            else
            {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                NSNumber *shopIDNumber =[[NSNumber alloc]initWithInt:self.shopIDString.intValue];
                [dict setObject:date forKey:@"time"];
                [dict setObject:shopIDNumber forKey:@"shopID"];
                [dict setObject:self.shopNamestrting forKey:@"shopName"];
                [dict setObject:self.shopPic forKey:@"shopPic"];
                NSLog(@"逛店记录的字典%@",dict);
                
                [dc addVisitShopRecordWithDicitionary:dict recordType:RecoredTypeAttention];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    
}


#pragma mark-(下载店内商品的数据)
-(void)downLoadMainShopDetailCommodityData
{
    
    [_mainShopDetailCommodityArray removeAllObjects];
    
    _mainShopDetailCommodityArray = [[NSMutableArray alloc]init];
    mainShopDetailCommodityOffset = 0;
    mainShopDetailCommodityCount = 100;
    
    NSString *urlString = [NSString stringWithFormat:SHOPDETAILCOMMODITYURL,DomainName,self.shopIDString.intValue,mainShopDetailCommodityOffset,mainShopDetailCommodityCount];
    NSLog(@"*************%@",urlString);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSString *errString = dict[@"err"];
            if(errString.intValue == 0)
            {
                NSArray *array = dict[@"goodsList"];
                for(NSDictionary *goodListDict in array)
                {
                    mainShopDetailCommodityModel *model = [[mainShopDetailCommodityModel alloc]init];
                    [model setValuesForKeysWithDictionary:goodListDict];
                    [_mainShopDetailCommodityArray addObject:model];
                }
                
                //当下载完数据之后  reload Carousel
                [_carousel reloadData];
                
                //设置当前商品
                //_carousel.currentItemIndex = 7;
                
            }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"err = %@",error);
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _carousel.currentItemIndex = 0;
    [self p_hideBottomComponent];
    
  
    //解除通知
    //[[NSNotificationCenter defaultCenter]removeObserver:self];
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark-(创建底部的View和聊天的tableView)
-(void)createBottomViewAndChatView
{
    
    //设置bottomView的frame
    //    [UIView beginAnimations:nil context:nil];
    //    [UIView setAnimationDuration:0.250000];
    //    [UIView setAnimationCurve:7];
    //    bottomView.frame = CGRectMake(5, SCREENHEIGHT*0.5, SCREENWIDTH-10, 44);
    //    [UIView commitAnimations];
    //    [UIView animateWithDuration:0.25 animations:^{
    //bottomView.frame = CGRectMake(5, SCREENHEIGHT*0.3, SCREENWIDTH-10, 44);
    //contractionImageView.frame = CGRectMake(SCREENWIDTH*0.41, 36, SCREENWIDTH*0.18, 8);
    
    
    if(SCREENHEIGHT<500)
    {
        bottomView = [[UIView alloc]initWithFrame:CGRectMake(0,SCREENHEIGHT*0.1, SCREENWIDTH, 44)];
    }
    else
    {
    bottomView = [[UIView alloc]initWithFrame:CGRectMake(0,SCREENHEIGHT*0.3, SCREENWIDTH, 44)];
    }
    bottomView.backgroundColor = [UIColor colorWithHexStr:@"#48d58b"];
    //[self.view addSubview:bottomView];
    [self.view insertSubview:bottomView atIndex:1];
    
    
    //切换群聊天室和群组
//    changeChatStyleButton = [ZCControl createButtonWithFrame:CGRectMake(10, 10, SCREENWIDTH*0.15-20, 24) ImageName:@"btn_login_bg_2@2x" Target:self Action:@selector(changeStyleButtonBtn:) Title:nil];
//    [bottomView addSubview:changeChatStyleButton];
    
    //提示逛的label
    invitationLabel = [ZCControl createLabelWithFrame:CGRectMake(5, 5, SCREENWIDTH*0.4, 34) Font:SCREENWIDTH*0.04 Text:@""];
    invitationLabel.textColor = [UIColor whiteColor];
    invitationLabel.adjustsFontSizeToFitWidth = YES;
    
//    if([[NSUserDefaults standardUserDefaults]objectForKey:MyGname])
//    {
//        //这里需要判断  如果内存中存在聊天组名则去取出不进行Socket通信 如果内存中不存在则进行Socket通信 然后保存在内存中 再取出来
//        NSString *gname = [[NSUserDefaults standardUserDefaults]objectForKey:MyGname];
//        NSString *subGnameString = [gname substringFromIndex:2];
//        if([subGnameString isEqualToString:@"e2e"])
//        {
//            //聊天室
//            if([gname rangeOfString:@"shop"].location != NSNotFound)
//            {
//                invitationLabel.text = @"私信店主";
//            }
//            else
//            {
//                //用户之间单聊
//                NSString *groupNameString = [staticUserInfo getGroupNameWithGname:gname];
//                //缓存中没有数据
//                if(groupNameString.length == 0)
//                {
//                    [self useWebSocketGetGroupUserInformation];
//                    NSString *groupNameString2 = [staticUserInfo getGroupNameWithGname:gname];
//                    invitationLabel.text = groupNameString2;
//                }
//                
//                //缓存中有数据
//                else
//                {
//                    invitationLabel.text = groupNameString;
//                }
//
//                
//            }
//        }
//        else if ([subGnameString isEqualToString:@"sho"])
//        {
//            //私信店主
//            invitationLabel.text = @"聊天室";
//        }
//        else
//        {
//        NSString *groupNameString = [staticUserInfo getGroupNameWithGname:gname];
//        //缓存中没有数据
//        if(groupNameString.length == 0)
//        {
//            [self useWebSocketGetGroupUserInformation];
//            NSString *groupNameString2 = [staticUserInfo getGroupNameWithGname:gname];
//            invitationLabel.text = groupNameString2;
//        }
//        
//        //缓存中有数据
//        else
//        {
//            invitationLabel.text = groupNameString;
//        }
//        }
//
//    }
//    else
//    {
//        invitationLabel.text = @"可以邀请好友一起逛哦";
//    }
//
//    invitationLabel.adjustsFontSizeToFitWidth = YES;
    //invitationLabel.backgroundColor = [UIColor orangeColor];
    if(self.gnameString.length != 0)
    {
        invitationLabel.text = self.invitationLabelString;
    }
    else
    {
        invitationLabel.text = @"可以邀请好友一起逛哦";
    }
    [bottomView addSubview:invitationLabel];
    
    
    //显示和收缩的imageView
    contractionImageView = [ZCControl createImageViewWithFrame:CGRectMake(0, 0, SCREENWIDTH*0.12, 10) ImageName:nil];
    contractionImageView.center = CGPointMake(SCREENWIDTH/2, 10);
    contractionImageView.image = [UIImage imageNamed:@"店铺_10"];
    [bottomView addSubview:contractionImageView];
    
    //在allContractionImagrView上添加点击收缩和处理的事件
    UIControl *control = [[UIControl alloc]initWithFrame:CGRectMake(SCREENWIDTH*0.41, 0, SCREENWIDTH*0.18, 44)];
    [control addTarget:self action:@selector(dealWithContraction2:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:control];
    
    //拉好友群组的button
    UIButton *invitationButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.8, 0, SCREENWIDTH*0.2, 44) ImageName:@"" Target:self Action:@selector(invitationButtonBtn:) Title:nil];
    [invitationButton setImage:[UIImage imageNamed:@"首页_15"] forState:UIControlStateNormal];
    [bottomView addSubview:invitationButton];

    
    //创建聊天输入框
    //视图的原点y从64开始
    CGRect inputFrame = CGRectMake(0, SCREEN_HEIGHT -44,SCREEN_WIDTH,44.0f);
    self.chatInputView = [[JSMessageInputView alloc] initWithFrame:inputFrame delegate:self];
    //[self.chatInputView setBackgroundColor:[UIColor orangeColor]];
    [self.chatInputView setBackgroundColor:[UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0]];
    //[self.view addSubview:self.chatInputView];
    [self.view insertSubview:self.chatInputView atIndex:5];
    
    
    
    //表情
    [self.chatInputView.emotionbutton addTarget:self
                                         action:@selector(showEmotio:)
                               forControlEvents:UIControlEventTouchUpInside];
    //➕号
    [self.chatInputView.showUtilitysbutton addTarget:self
                                              action:@selector(showUtilit:)
                                    forControlEvents:UIControlEventTouchDown];
    //语音
    [self.chatInputView.voiceButton addTarget:self
                                       action:@selector(p_clickThRecordButton:)
                             forControlEvents:UIControlEventTouchUpInside];
    
    //录音上面一系列的手势效果
    _touchDownGestureRecognizer = [[TouchDownGestureRecognizer alloc] initWithTarget:self action:nil];
    __weak mainShopDetailViewController* weakSelf = self;
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
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT*0.3+44, SCREENWIDTH, SCREEN_HEIGHT -44-SCREENHEIGHT*0.3-44) style:UITableViewStylePlain];
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
}

////切换群聊天室和群则
//-(void)changeStyleButtonBtn:(UIButton *)button
//{
//    
//}

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


#pragma mark-(webSocket相关)
//获取聊天记录（先查询本地数据库 如果本地没有则用webSocket进行通信)
-(void)useWebSocketGetRecord
{
    
    //这是获取最新的聊天记录(当需要显示更多消息的时候 开始时间为上次取的最后一条记录的时间)
    [webSocketManager YBGetRecordWithGname:self.gnameString andStartTime:@"0" andRecordCount:@"30"];
}

//获取组内成员信息 (不用来显示聊天内容里面的user)
-(void)useWebSocketGetGroupUserInformation
{
    [webSocketManager YBGetGroupUsersWithGname:self.gnameString];
    
}

////接收消息的代理方法（所有接收消息都在这个借口中 需要对命令码做出判断 从而对应不同的处理）
//-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
//{
//    NSString *messageString = message;
//    NSDictionary *dict = [messageString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
//    NSString *codeString = dict[@"c"];
//    //通过命令码来判断
//    //_groupUserInformationArray  = [[NSMutableArray alloc]init];
//    if([codeString isEqualToString:@"GROUP_USERS"])
//    {
//        NSArray *groupUserArray = dict[@"users"];
//        
//        //对聊天组名的label进行赋值
//        NSString *groupNameString = [[NSString alloc]init];
//        for(int i = 0;i<groupUserArray.count;i++)
//        {
//            groupNameString = [groupNameString stringByAppendingString:groupUserArray[i]];
//        }
//        invitationLabel.text = [NSString stringWithFormat:@"%@（%ld人）",groupNameString,groupUserArray.count];
//
//    }
//    //接收消息
//    if([codeString isEqualToString:@"CHAT_M"])
//    {
//        //接收来的消息都存入缓存和数据库中
//        NSString *gname = dict[@"gname"];
//        NSDictionary *messageBodyDict = dict[@"body"];
//        
//        //当是聊天室内的消息的时候不需要保存到内存和数据库中
//        
//        //存入
//        [staticUserInfo addMessageToGname:gname withMessageBody:messageBodyDict];
//        
//        //存入之后 从缓存和数据库中读取新的数据
//        [self loadBaseViewsAndData];
//    }
//    //获取聊天记录
//    if([codeString isEqualToString:@"GET_RECORD"])
//    {
//        //获取到的聊天记录
//        NSString *gname = dict[@"gname"];
//        NSArray *messageArray = dict[@"ms"];
//        //这里需要判断当为群聊天室消息记录的时候不保存到内存和数据库中
//        
//        //存入数据库和缓存中
//        for(int i = 0;i<messageArray.count;i++)
//        {
//            [staticUserInfo addMessageToGname:gname withMessageBody:messageArray[i]];
//        }
//        //数据存入缓存和数据之后   从缓存或者数据库中取出数据来填充UI
//        [self loadBaseViewsAndData];
//    }
//    //获取商店聊天室的gname
//    if([codeString isEqualToString:@"SHOP_GNAME"])
//    {
//        NSString *shopGnameString = dict[@"gname"];
//        
//        [[NSUserDefaults standardUserDefaults]setObject:shopGnameString forKey:MyGname];
//        [[NSUserDefaults standardUserDefaults]synchronize];
//        [self loadShopChatRoomData];
//    }
//    
//}
#pragma mark-(聊天模块)-商店的聊天室
-(void)loadShopChatRoomData
{
    //
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
            
              NSLog(@"取出来的聊天的数据 = %@",_chatDataArray);
            
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
        rect.size.height = SCREENHEIGHT-64-SCREENHEIGHT*0.3-44-44;
        }
        _tableView.frame = rect;
        [self tableViewScrollToBottom];
    }];
    //    NSLog(@"%f",self.chatInputView.frame.origin.y);
    [self setValue:@(self.chatInputView.frame.origin.y) forKeyPath:@"_inputViewY"];
}


#pragma mark-(点击显示收缩的处理事件)
-(void)dealWithContraction2:(UIControl *)control
{
    fansShopDetailViewController *fsdvc = [[fansShopDetailViewController alloc]init];
    fsdvc.YB_delegate = self;
    fsdvc.dataArray = _mainShopDetailCommodityArray;
    fsdvc.shopNamestrting = self.shopNamestrting;
    fsdvc.shopIDString = self.shopIDString;
    fsdvc.groupNameString = invitationLabel.text;
    fsdvc.gnameString = self.gnameString;
    [self.navigationController pushViewController:fsdvc animated:NO];
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
        return 7;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
        return SCREENWIDTH/2;
    }
}
//cell上面的点击
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _tableView)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        [self.view endEditing:YES];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        mainShopDetailViewController *mdvc = [[mainShopDetailViewController alloc]init];
        [self.navigationController pushViewController:mdvc animated:YES];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}
#pragma mark-(自己制定的cell上面头像的点击代理)
-(void)headImageDidClick:(UUMessageCell *)cell userId:(NSString *)userId
{
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:cell.messageFrame.message.strName message:@"headImage clicked" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil];
//    
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
        
         [self existShop];
        
        //商店
//        shopInformationViewController *vc = [[shopInformationViewController alloc]init];
//        vc.YB_delegate = self;
//        vc.gnameString = self.gnameString;
//        vc.invitationLabelString = invitationLabel.text;
        NSString *detailDictString = messageDict[@"m"];
        NSDictionary *detailDict = [detailDictString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        self.shopIDString = [NSString stringWithFormat:@"%@",detailDict[@"id"]];
        self.shopNamestrting = detailDict[@"name"];
        self.shopPic = detailDict[@"img"];
        
        [self visitShop];
        [self downLoadMainShopDetailCommodityData];
        [self createUINa];
        // NSLog(@"***********%@",messageDict);
        //[self.navigationController pushViewController:vc animated:YES];
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
            
            NSArray *array = self.navigationController.viewControllers;
            
            
            NSString *pushString = [[NSString alloc]init];
            int pushNumber = 0;
            for(int i = 0;i<array.count-1;i++)
            {
                if([array[i] isKindOfClass:[inShopActivityViewController class]])
                {
                    pushString = @"1";
                    pushNumber = i;
                }
                
            }
            
            if([pushString isEqualToString:@"1"])
            {
                //vc = array[array.count-2];
                //[self.navigationController popToViewController:array[array.count-2] animated:YES];
                [self.YB_ShopDetailChangeDelegate YBShopDetailChangeGroupGname:self.gnameString andGroupName:invitationLabel.text];
                [self.navigationController popToViewController:array[pushNumber] animated:YES];
            }
            else
            {
                [self.navigationController pushViewController:vc animated:YES];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];

    }
}


-(void)showEmotio:(id)send
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
    rect.size.height = SCREENHEIGHT-216-44-64-44-SCREENHEIGHT*0.3;
    }
    _tableView.frame = rect;
    //adjust UUInputFunctionView's originPoint
    [UIView commitAnimations];
    [self tableViewScrollToBottom];
    
}
//-(IBAction)showUtilitys:(id)sender
-(void)showUtilit:(id)sende
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
        rect.size.height = SCREENHEIGHT-216-44-64-44-SCREENHEIGHT*0.3;
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
    rect.size.height = SCREENHEIGHT-keyboardHeight-64-44-SCREENHEIGHT*0.3-44;
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

//发送消息和表情（）
- (void)textViewEnterSend
{
    
    //发送消息
    NSString* text = [self.chatInputView.textView text];
    
//    NSDictionary *dic = @{@"strContent":text,@"type":@(UUMessageTypeText)};
//    self.chatInputView.textView.text = @"";
//    [self dealTheFunctionData:dic];
    
    NSString *myIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
   // NSString *gnameString = [[NSUserDefaults standardUserDefaults]objectForKey:MyGname];
    if(text.length != 0)
    {
    [webSocketManager YBSendMessageFromUser:myIDString toGname:self.gnameString message:text messageType:@"text"];
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
//发送图片
-(void)sendPicture:(UIImage *)image
{
//    NSDictionary *dic = @{@"picture": image,
//                          @"type": @(UUMessageTypePicture)};
//    [self dealTheFunctionData:dic];
    
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
        NSLog(@"%@",request.responseString);
        NSDictionary *picDict = [request.responseString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        [webSocketManager YBSendMessageFromUser:myIDString toGname:self.gnameString message:picDict[@"url"] messageType:picDict[@"content_type"]];
        
        
    }
    if(request.tag == 103)
    {
        NSLog(@"%@",request.responseString);
        NSDictionary *voiceDict = [request.responseString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        [webSocketManager YBSendMessageFromUser:myIDString toGname:self.gnameString message:voiceDict[@"url"] messageType:voiceDict[@"content_type"]];
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

#pragma mark-(拉好友点击和导航栏右按钮的点击)
-(void)invitationButtonBtn:(UIButton *)button
{
    UIActionSheet *ac = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"切换聊天",@"发起聊天",@"摇一摇",@"店铺聊天室",@"私信店主", nil];
    ac.tag = 101;
    [ac showInView:self.view];
}
//拉好友动作列表的代理
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //拉好友点击
    if(actionSheet.tag == 101)
    {
        NSString *loginString = [[NSUserDefaults standardUserDefaults]objectForKey:IsLogin];
        if([loginString isEqualToString:@"login"])
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
        invitationLabel.text = [NSString stringWithFormat:@"%@-聊天室",self.shopNamestrting];
        
        //店铺聊天室
        //先获取商店聊天室的Gname  然后根据gname去获取聊天记录
        [webSocketManager YBGetShopGnameWithShopID:self.shopIDString];
        
        
    }
    else if (buttonIndex == 4)
    {
        invitationLabel.text = [NSString stringWithFormat:@"%@-私信店主",self.shopNamestrting];;
        
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
        
        //拼接私信店主的gname
        NSString *messageGname = [[NSString alloc]init];
            if(userIDString.intValue > self.shopIDString.intValue)
            {
                messageGname = [NSString stringWithFormat:@"e2e_%@_%@",userIDString,self.shopIDString];
            }
            else
            {
                messageGname = [NSString stringWithFormat:@"e2e_%@_%@",self.shopIDString,userIDString];
            }
        self.gnameString = messageGname;
        
        [self loadBaseViewsAndData];
        
    }
    else
    {
        
    }
        }
        else
        {
            UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"亲，您还没有登录哟!" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [al show];
        }
    }
    //导航栏上面acsheet
    else if (actionSheet.tag == 102)
    {
        if(buttonIndex == 0)
        {
            inshopLookedViewController *vc = [[inshopLookedViewController alloc]init];
            vc.YB_delegate = self;
            vc.shopIDString = self.shopIDString;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if (buttonIndex == 1)
        {
            inShopFansViewController *vc = [[inShopFansViewController alloc]init];
            vc.YB_delegate = self;
            vc.shopIDString = self.shopIDString;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if (buttonIndex == 2)
        {
            shopInformationViewController *sfvc = [[shopInformationViewController alloc]init];
            sfvc.YB_delegate = self;
            sfvc.shopIDString = self.shopIDString;
            sfvc.shopNamestrting = self.shopNamestrting;
            sfvc.gnameString = self.gnameString;
            sfvc.invitationLabelString = invitationLabel.text;
            [self.navigationController pushViewController:sfvc animated:YES];
        }
        else if (buttonIndex == 3)
        {
           
            //先把商店的活动信息下来然后进行界面的跳转
            
            _inShopActivityArray = [[NSMutableArray alloc]init];
            NSString *urlString = [NSString stringWithFormat:INSHOPACTIVITYURL,DomainName,self.shopIDString.intValue];
            //NSLog(@"________________%@",urlString);
            AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                NSString *errString = dict[@"err"];
                if(errString.intValue == 0)
                {
                    NSArray *array = dict[@"actList"];
                    for (NSDictionary *actDict in array)
                    {
                        NSMutableDictionary *finalActDict = [NSMutableDictionary dictionaryWithDictionary:actDict];
                        [finalActDict setObject:self.shopPic forKey:@"img"];
                        [finalActDict setObject:self.shopIDString forKey:@"shopID"];
                        [_inShopActivityArray addObject:actDict];
                    }
                    
                    inShopActivityViewController *vc = [[inShopActivityViewController alloc]init];
                    vc.YB_delegate = self;
                    vc.gnameString = self.gnameString;
                    vc.invitationLabelString = invitationLabel.text;
                    if(_inShopActivityArray.count != 0)
                    {
                    vc.activityArray = _inShopActivityArray;
                    }
                    else
                    {
                        NSMutableDictionary *sendActivityShopDict = [[NSMutableDictionary alloc]init];
                        NSMutableArray *sendActivityShopArray = [[NSMutableArray alloc]init];
                        
                        [sendActivityShopDict setObject:self.shopIDString forKey:@"shopID"];
                        [sendActivityShopArray addObject:sendActivityShopDict];
                        vc.activityArray = sendActivityShopArray;
                        
                    }
                    [self.navigationController pushViewController:vc animated:YES];
                }
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"err = %@",error);
            }];

            
        }
        else
        {
            
        }
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

//#pragma mark-(更多活动界面的反向传值——聊天)
//-(void)YBSendMoreActivityDelegateWithGname:(NSString *)gname andGroupName:(NSString *)groupName
//{
//    self.gnameString = gname;
//    if(_gnameString.length != 0)
//    {
//        invitationLabel.text = groupName;
//        [self loadBaseViewsAndData];
//    }
//    
//}
#pragma mark-(发送活动界面的反向传值——聊天)
-(void)YBSendActivityDelgateWithGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    _gnameString = gname;
    if(_gnameString.length != 0)
    {
        invitationLabel.text = groupName;
        [self loadBaseViewsAndData];
    }
    
}
-(void)YBSendActivityDelgateWithGname:(NSString *)gname andGroupName:(NSString *)groupName andShopID:(NSString *)shopID andShopPic:(NSString *)shopPic andShopName:(NSString *)shopName
{
    //聊天的更新
    _gnameString = gname;
    if(_gnameString.length != 0)
    {
        invitationLabel.text = groupName;
        [self loadBaseViewsAndData];
    }
    
    //店内商品的更新
    [self existShop];
    self.shopIDString = shopID;
    self.shopNamestrting = shopName;
    self.shopPic = shopPic;
    
    [self visitShop];
    [self downLoadMainShopDetailCommodityData];
    [self createUINa];
    
}

//摇一摇的聊天的反向传值
-(void)YBShakeChangeChatWithGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    self.gnameString = gname;
    if(self.gnameString.length != 0)
    {
        invitationLabel.text = groupName;
        [self loadBaseViewsAndData];
    }
}


//商店内更多商品界面的反向传值 （聊天）
-(void)YBFansShopGnameDelegate:(NSString *)gname andGroupName:(NSString *)groupName
{
    self.gnameString = gname;
    if(self.gnameString.length != 0)
    {
        invitationLabel.text = groupName;
        [self loadBaseViewsAndData];
    }
    [self.YB_ShopDetailChangeDelegate YBShopDetailChangeGroupGname:gname andGroupName:groupName];
}

//商店详情界面的反向传值 （聊天）
-(void)YBShopInformationChangeGnameWithGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    self.gnameString = gname;
    if(self.gnameString.length != 0)
    {
        invitationLabel.text = groupName;
        [self loadBaseViewsAndData];
    }
}

//商店详情界面的反向传值(聊天)
-(void)YBShopInformationChangeGnameWithGname:(NSString *)gname andGroupName:(NSString *)groupName andShopPic:(NSString *)shopPic andShopIDString:(NSString *)shopID andShopNameString:(NSString *)shopName
{
    //修改聊天的数据
    self.gnameString = gname;
    if(self.gnameString.length != 0)
    {
        invitationLabel.text = groupName;
        [self loadBaseViewsAndData];
    }
    
    //修改商店内商品的数据
    
    [self existShop];
    
    self.shopIDString = shopID;
    self.shopNamestrting = shopName;
    self.shopPic = shopPic;
    
    [self visitShop];
    [self downLoadMainShopDetailCommodityData];
    [self createUINa];

    
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



#pragma mark-(创建书架效果view)
-(void)createBookShelfPictureList
{
    
//    self.items = [NSMutableArray array];
//    for(int i = 0;i<100;i++)
//    {
//        [_items addObject:@(i)];
//    }
    
    _carousel = [[iCarousel alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH , SCREENHEIGHT*0.3)];
    _carousel.delegate = self;
   // _carousel.backgroundColor = [UIColor orangeColor];
    _carousel.dataSource = self;
    _carousel.type = iCarouselTypeCoverFlow2;
    [self.view insertSubview:_carousel atIndex:0];
    
}
#pragma mark-(书架效果展示商品图片的代理)

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
   // return [_items count];
    return _mainShopDetailCommodityArray.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    UIView *boomView = nil;
    
    mainShopDetailCommodityModel *model = _mainShopDetailCommodityArray[index];
  
    //create new view if no view is available for recycling
    if (view == nil)
    {
        //don't do anything specific to the index within
        //this `if (view == nil) {...}` statement because the view will be
        //recycled and used with other index values later
        
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH*0.6, SCREENHEIGHT*0.3*0.8)];
        //view.backgroundColor = [UIColor orangeColor];
        view.contentMode = UIViewContentModeCenter;
        view.layer.masksToBounds = YES;
        
        
        boomView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT*0.3*0.8*0.8, SCREENWIDTH*0.6, SCREENHEIGHT*0.3*0.8*0.2)];
        boomView.backgroundColor = [UIColor blackColor];
        boomView.contentMode = UIViewContentModeCenter;
        boomView.layer.masksToBounds = YES;
        boomView.alpha = 0.3;
        [view addSubview:boomView];
        
        //label = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH*0.6*0.6, SCREENHEIGHT*0.3*0.8*0.75, SCREENWIDTH*0.6*0.4, SCREENHEIGHT*0.3*0.8*0.25)];
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT*0.3*0.8*0.8, SCREENWIDTH*0.6, SCREENHEIGHT*0.3*0.8*0.2)];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [label.font fontWithSize:SCREENWIDTH*0.0426];
        label.textColor = [UIColor whiteColor];
        label.tag = 201;
        [view addSubview:label];
        
        //在view上面添加手势发送商品
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dealPan:)];
        pan.delegate = self;
        [view addGestureRecognizer:pan];
        
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:201];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    //label.text = [_items[index] stringValue];
    NSNumber *widthNumber = [[NSNumber alloc]initWithLong:(long)(SCREENWIDTH*0.6)];
    NSNumber *heightNumber = [[NSNumber alloc]initWithLong:(long)(SCREENHEIGHT*0.3*0.8)];
    UIImageView *goodsImageView = (UIImageView *)view;
    NSString *haha = [NSString stringWithFormat:@"%@@%@w_%@h_1e_0l_1c",model.pic,widthNumber,heightNumber];
    [goodsImageView sd_setImageWithURL:[NSURL URLWithString:haha]];
    
//    //判断有没有促销价格
//    
//    NSString *promoteString = [NSString stringWithFormat:@"%@",model.promot];
//
//    if([promoteString isEqualToString:@"(null)"])
//    {
//        //没有促销价
//        NSString *priceNullString = [NSString stringWithFormat:@"%@",model.price];
//        if(![priceNullString isEqualToString:@"(null)"])
//        {
//        label.text = [NSString stringWithFormat:@"￥%@",model.price];
//        }
//    }
//    else
//    {
//        label.text = [NSString stringWithFormat:@"￥%@",model.promot];
//    }
    label.text = model.name;
    return view;
}

#pragma mark-(向下手势拖移处理 发送商品)
-(void)dealPan:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan translationInView:_carousel.contentView];
    if(point.y>100)
    {
       if(self.gnameString.length != 0)
        {
        NSString *myIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
        mainShopDetailCommodityModel *model = _mainShopDetailCommodityArray[_carousel.currentItemIndex];
            if(pan.state == UIGestureRecognizerStateEnded)
            {
        [webSocketManager YBsendMMXMessageFromUser:myIDString toGname:self.gnameString mmxID:model.id mmxImg:model.pic mmxName:model.name messageType:@"mmx/goods"];
            }
        }
    }
}

#pragma mark-(解决手势冲突的问题)
//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
////    CGPoint point = [touch locationInView:_carousel.contentView];
////    NSLog(@"位置位移位移位移%f",point.y);
////    if(point.y>20)
////    {
////        return YES;
////    }
////    else
////    {
////        return NO;
////    }
//    return NO;
//}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


//设置商品陈列的紧密度效果

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionSpacing)
    {
        return value * 1.6f;
    }
    return value;
}

-(void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    collectionCommodityDetailViewController *ccdvc = [[collectionCommodityDetailViewController alloc]init];
    //传入商品ID的参数
    mainShopDetailCommodityModel *model = _mainShopDetailCommodityArray[index];
    ccdvc.goodsIDString = model.id;
    ccdvc.shopIDString = self.shopIDString;
    [self.navigationController pushViewController:ccdvc animated:YES];
}


-(void)dealloc
{
    _carousel.delegate = nil;
    _carousel.dataSource = nil;
    
    //[MP3 stopRecord];
    [[UUAVAudioPlayer sharedInstance]stopSound];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[self removeObserver:self forKeyPath:@"_inputViewY"];
    
}
-(void)viewDidUnload
{
    [super viewDidUnload];
    self.carousel = nil;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


-(void)createUINa
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    //导航栏左按钮
    UIButton *leftButton = [ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(leftButtonBtn:) Title:nil    ];
    [leftButton setImage:[UIImage imageNamed:@"店铺-店铺详情_03"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
//    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"lady's-purse@2x"] style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonBtn:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    //导航栏右按钮
//    UIButton *rightButton = [ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(rightButtonBtn:) Title:nil];
//    [rightButton setImage:[UIImage imageNamed:@"店铺_05"] forState:UIControlStateNormal];
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
//    UIButton *rightButton2 = [ZCControl createButtonWithFrame:CGRectMake(0, 0, 20, 20) ImageName:@"" Target:self Action:@selector(titleButtonBtn:) Title:nil];
//    [rightButton2 setImage:[UIImage imageNamed:@"店铺_03"] forState:UIControlStateNormal];
//    UIBarButtonItem *rightItem2 = [[UIBarButtonItem alloc]initWithCustomView:rightButton2];
//    self.navigationItem.rightBarButtonItems = @[rightItem,rightItem2];
    
    //导航栏右按钮（改动之后）
    UIButton *rightButton = [ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(rightButtonDidClick:) Title:nil];
    [rightButton setImage:[UIImage imageNamed:@"首页_15"] forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    //导航栏的title
    //self.title = self.shopNamestrting;
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:self.shopNamestrting];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
}
-(void)rightButtonDidClick:(UIButton *)button
{
    UIActionSheet *ac = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"逛过的店",@"关注的店",@"店面信息",@"商店活动", nil];
    ac.tag = 102;
    [ac showInView:self.view];

}


-(void)titleButtonBtn:(UIButton *)button
{
    shopInformationViewController *sfvc = [[shopInformationViewController alloc]init];
    sfvc.shopIDString = self.shopIDString;
    sfvc.shopNamestrting = self.shopNamestrting;
    [self.navigationController pushViewController:sfvc animated:YES];
}

-(void)rightButtonBtn:(UIButton *)button
{
    //逛过和粉丝店
    inShopMyFansShopAndLookedViewController *isfvc = [[inShopMyFansShopAndLookedViewController alloc]init];
    isfvc.YB_Delagete = self;
    [self.navigationController pushViewController:isfvc animated:YES];
}
#pragma mark-（逛过和粉丝店的点击协议的传值处理）--已经不用（界面更改）
-(void)YBYBInShopMyFansShopAndLookedTableViewDidClickWithShopName:(NSString *)shopName andShopPic:(NSString *)shopPic andShopID:(NSString *)shopID
{
    self.shopPic = shopPic;
    self.shopNamestrting = shopName;
    self.shopIDString = shopID;
    [self downLoadMainShopDetailCommodityData];
    [self visitShop];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:self.shopNamestrting];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
}

#pragma mark-(逛过店点击协议传值处理)
-(void)YBInshopLookedTableViewCellDidClickWithShopName:(NSString *)shopName andShopPic:(NSString *)shopPic andShopID:(NSString *)shopID
{
    self.shopPic = shopPic;
    self.shopNamestrting = shopName;
    self.shopIDString = shopID;
    [self downLoadMainShopDetailCommodityData];
    [self visitShop];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:self.shopNamestrting];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    

}

#pragma mark-(粉丝店点击协议传值处理)
-(void)YBInshopFansTableViewCellDidClickWithShopName:(NSString *)shopName andShopPic:(NSString *)shopPic andShopID:(NSString *)shopID
{
    self.shopPic = shopPic;
    self.shopNamestrting = shopName;
    self.shopIDString = shopID;
    [self downLoadMainShopDetailCommodityData];
    [self visitShop];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:self.shopNamestrting];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;

}
#pragma mark-(全部商店商品的界面传值处理)
-(void)YBFansShopDetailClickWithShopName:(NSString *)shopName andShopPic:(NSString *)shopPic andShopID:(NSString *)shopID
{
    self.shopPic = shopPic;
    self.shopNamestrting = shopName;
    self.shopIDString = shopID;
    [self downLoadMainShopDetailCommodityData];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:self.shopNamestrting];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
}

-(void)leftButtonBtn:(UIButton *)button
{
    //调用退店协议
    [self existShop];
    
    
//    //退出商店界面之间 退出当前所在店
//    NSString *myLastGname = [[NSUserDefaults standardUserDefaults]objectForKey:MyLastGname];
//    if(MyLastGname.length != 0)
//    {
//        //这是关闭Socket协议的方法 退出讨论组
//       // [webSocketManager YBExitGroupWithUser:userIDString andGname:gname];
//        [[NSUserDefaults standardUserDefaults]setObject:myLastGname forKey:MyGname];
//        [[NSUserDefaults standardUserDefaults]synchronize];
//    }
    
    [self.YB_ShopDetailChangeDelegate YBShopDetailChangeGroupGname:self.gnameString andGroupName:invitationLabel.text];
    _carousel.currentItemIndex = 0;
    _carousel = nil;
    _carousel.delegate = nil;
    _carousel.dataSource = nil;
    
    NSArray *array = self.navigationController.viewControllers;
    NSString *sideBarHiddenString = [[NSUserDefaults standardUserDefaults]objectForKey:SideBarHidden];
    if([sideBarHiddenString isEqualToString:@"yes"])
    {
        [self.navigationController popToViewController:array[0] animated:YES];
    }
    else
    {
    
    if(array[1] == self)
    {
        [self.navigationController popToViewController:array[0] animated:YES];
    }
    else if (array[2] == self)
    {
        [self.navigationController popToViewController:array[1] animated:YES];
    }
    else if (array[3] == self)
    {
        [self.navigationController popToViewController:array[2] animated:YES];
    }
    else if (array[4] == self)
    {
        [self.navigationController popToViewController:array[3] animated:YES];
    }
    else if (array[5] == self)
    {
        [self.navigationController popToViewController:array[4] animated:YES];
    }
    }
}
-(void)existShop
{
    NSString *urlString = [NSString stringWithFormat:EXISTSHOPURL,DomainName,self.shopIDString.intValue];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
            //进店成功之后  本地保存逛店记录 （当数据库中有记录的时候则更新记录 没有记录则插入记录）
            NSLog(@"本汪今天大展风采");
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

#pragma mark-(键盘回收)
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    if ([gestureRecognizer.view isEqual:_tableView])
//    {
//        return YES;
//    }
//    return NO;
//}
#pragma mark -
- (void)playingStoped
{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
