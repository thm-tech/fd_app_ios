//
//  friendsDetailViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/7.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "friendsDetailViewController.h"

#import "XHMenu.h"
#import "XHScrollMenu.h"
#import "friendDetailCollectionTableView.h"
#import "friendDetailFansShopTableView.h"
#import "friendDetailLookedShopTableView.h"

#import "collectionCommodityDetailViewController.h"
#import "mainShopDetailViewController.h"

#import "miaomiaoChatDetailViewController.h"

//单例
#import "danLiDataCenter.h"

#import "myAppDataBase.h"

//修改备注的协议
#define MODIFICATIONURL @"http://%@/user/friend/name"

//查询好友信息
#define FRIENDINFORMATIONURL @"http://%@/user/friend?uid=%d"
//查询陌生人信息
#define PASSAGERINFORMATIONURL @"http://%@/user/info?uid=%d"

//查询用户粉丝店，收藏，逛过店的数量
#define FRIENDCOUNSURL @"http://%@/user/ffv/count?uid=%d"

#define FRIENDPRIVATESETTINGURL @"http://%@/user/friend/private?uid=%d"

#define ADDFRIENDSURL @"http://%@/user/friend/invite"

@interface friendsDetailViewController () <XHScrollMenuDelegate,UIScrollViewDelegate,YBFriendDetailCollectionDelegate,YBFriendDetailFansShopDelegate,YBFriendDetailLookedShopDelegate,UIAlertViewDelegate,YBShopDetailChangeGroupNameDelegate>
{
    UIImageView *_headerImageView;
    UILabel *_nameLabel;
    UILabel *_miaomiaoLabel;
    UILabel *_nickNameLabel;
    UIButton *_modificationButton;
    
    UIButton *_addFriendButton;
    UIButton *_chatWithFriendButton;

    
    YBHttpRequest *_httpRequest;
    NSDictionary *_countDict;
    NSDictionary *_settingDict;
}

//滚动视图
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
//菜单栏视图
@property (nonatomic, strong) XHScrollMenu *scrollMenu;
//菜单栏视图上面的按钮数组
@property (nonatomic, strong) NSMutableArray *menus;
//KVO的观察
@property (nonatomic, assign) BOOL shouldObserving;

@end

@implementation friendsDetailViewController

#pragma -mark(创建菜单栏上面的按钮的数组)
-(NSMutableArray *)menus
{
    if(!_menus)
    {
        _menus = [[NSMutableArray alloc]initWithCapacity:1];
    }
    return _menus;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _countDict = [[NSDictionary alloc]init];
    _settingDict = [[NSDictionary alloc]init];
    
    [self createUINa];
    
    //创建好友资料的topView
    [self downLoadDataAndCreatefriendInformationTopView];
    
    //创建SinaFrame的菜单
    //先判断传过来的ID是否为好友ID  如果是好友ID 则创建SinaFrame
    if([[myAppDataBase sharedInstance]isExistUserInformationRecordWithUserID:self.frdIDString recordType:RecoredTypeAttention])
    {
    [self createMyMenusAndDownLoadData];
    }
    
    // Do any additional setup after loading the view.
}
#pragma mark-(创建sinaFrame)
-(void)createMyMenusAndDownLoadData
{
    //下载粉丝店，收藏，逛过店的数量
    NSString *friendCountString = [NSString stringWithFormat:FRIENDCOUNSURL,DomainName,self.frdIDString.intValue];
    _httpRequest = [[YBHttpRequest alloc]initWithURLString:friendCountString target:self action:@selector(downLoadFriendCountInformation:)];
}
-(void)downLoadFriendCountInformation:(YBHttpRequest *)httpRequest
{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:httpRequest.downloadData options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"好友逛过数量的字典%@",dict);
    
    NSString *errString = dict[@"err"];
    if(errString.intValue == 0)
    {
        NSDictionary *countDict = dict[@"ffvCount"];
        //_countDict = [[NSDictionary alloc]init];
        _countDict = countDict;
    }
    [self downloadFrienSettingData];
}
-(void)downloadFrienSettingData
{
    NSString *friendPrivateSettingString = [NSString stringWithFormat:FRIENDPRIVATESETTINGURL,DomainName,self.frdIDString.intValue];
    _httpRequest = [[YBHttpRequest alloc]initWithURLString:friendPrivateSettingString target:self action:@selector(downLoadFinishSettingData:)];
}
-(void)downLoadFinishSettingData:(YBHttpRequest *)httpRequest
{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:httpRequest.downloadData options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"好友设置的字典%@",dict);
    NSString *errString = dict[@"err"];
    if(errString.intValue == 0)
    {
        NSDictionary *settingDict = dict[@"setting"];
        //_settingDict = [[NSDictionary alloc]init];
        _settingDict  = settingDict;
       
    }
    [self createMyMenusAndDownLoadDataaaa];

}


#pragma mark-(创建sinaFrame)
-(void)createMyMenusAndDownLoadDataaaa
{
//    //下载粉丝店，收藏，逛过店的数量
//    NSString *friendCountString = [NSString stringWithFormat:FRIENDCOUNSURL,DomainName,self.frdIDString.intValue];
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    
//   
//    [manager GET:friendCountString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//        //NSLog(@"好友逛过数量的字典%@",dict);
//        
//        NSString *errString = dict[@"err"];
//        if(errString.intValue == 0)
//        {
//            NSDictionary *countDict = dict[@"ffvCount"];
//            _countDict = [[NSDictionary alloc]init];
//           
//            
//        }
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"err = %@",error);
//    }];
//    
//    
//    //下载好友隐私设置的数据
//    NSString *friendPrivateSettingString = [NSString stringWithFormat:FRIENDPRIVATESETTINGURL,DomainName,self.frdIDString.intValue];
//    
//    static NSDictionary *_settingDict;
//    [manager GET:friendPrivateSettingString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//        //NSLog(@"好友设置的字典%@",dict);
//        NSString *errString = dict[@"err"];
//        if(errString.intValue == 0)
//        {
//            NSDictionary *settingDict = dict[@"setting"];
//            //_settingDict = [[NSDictionary alloc]init];
//            _settingDict  = settingDict;
//            //block里面的值的传递
//            
//        }
//
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"err = %@",error);
//    }];
//    
    
    
    self.shouldObserving = YES;
    //框架里面自身的选择控制器
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:nil, nil, nil]];
    // _segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    //   [_segmentedControl addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    CGRect segmentedControlFrame = _segmentedControl.frame;
    segmentedControlFrame.origin = CGPointMake(CGRectGetWidth(self.view.bounds) - CGRectGetWidth(segmentedControlFrame), 44);
    _segmentedControl.frame = segmentedControlFrame;
    [self.view addSubview:self.segmentedControl];
    
    //添加菜单栏，设置菜单栏的高度，背景颜色
    _scrollMenu = [[XHScrollMenu alloc] initWithFrame:CGRectMake(0,SCREENHEIGHT*0.2, CGRectGetWidth(self.view.bounds), SCREENHEIGHT*0.08)];
    //_scrollMenu.backgroundColor = [UIColor redColor];
    _scrollMenu.delegate = self;
    //    _scrollMenu.selectedIndex = 3;
    [self.view addSubview:self.scrollMenu];
    
    //菜单栏下面的滚动视图
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_scrollMenu.frame), CGRectGetWidth(self.view.bounds), SCREENHEIGHT - CGRectGetMaxY(_scrollMenu.frame)-64-44)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    [self.view addSubview:self.scrollView];
    
    //为菜单栏上面添加按钮标题
    for (int i = 0; i < 3; i ++) {
        
        XHMenu *menu = [[XHMenu alloc] init];
        NSString *title = nil;
        switch (i) {
            case 0:
                title = [NSString stringWithFormat:@"收藏(%@)",_countDict[@"favorite"]];
                break;
            case 1:
                title = [NSString stringWithFormat:@"粉丝店(%@)",_countDict[@"fans"]];
                break;
            case 2:
                title = [NSString stringWithFormat:@"逛过(%@)",_countDict[@"visited"]];
                break;
        }
        //菜单上标题被选中的颜色设置，字体的大小  (菜单上面下划线的颜色设置需要在sina里面设置)
        menu.title = title;
        menu.titleNormalColor = [UIColor colorWithHexStr:@"#666666"];
        menu.titleSelectedColor = [UIColor colorWithHexStr:@"#48d58b"];
        menu.titleHighlightedColor = [UIColor colorWithHexStr:@"#48d58b"];
        menu.titleFont = [UIFont boldSystemFontOfSize:WIDTH*0.046875];
        // menu.titleFont = [UIFont boldSystemFontOfSize:WIDTH*0.043];
        [self.menus addObject:menu];
    }
    
    //添加框架上三个表格视图
    friendDetailCollectionTableView *myGetPriceOrderFirst = [[friendDetailCollectionTableView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, SCREENHEIGHT - CGRectGetMaxY(_scrollMenu.frame)-64-44)];
    myGetPriceOrderFirst.YB_cellDelegate = self;
    //权限的判断
    NSString *favoriteEnableString = [NSString stringWithFormat:@"%@",_settingDict[@"favoriteEnable"]];
    if([favoriteEnableString isEqualToString:@"1"])
    {
    [_scrollView addSubview:myGetPriceOrderFirst];
    }
    
    friendDetailFansShopTableView *myGetPriceOrderSecond = [[friendDetailFansShopTableView alloc]initWithFrame:CGRectMake(WIDTH, 0, WIDTH, SCREENHEIGHT - CGRectGetMaxY(_scrollMenu.frame)-64-44)];
    myGetPriceOrderSecond.YB_cellDelegate = self;
    //权限的判断
    NSString *fanEnableString = [NSString stringWithFormat:@"%@",_settingDict[@"fansEnable"]];
    if([fanEnableString isEqualToString:@"1"])
    {
    [_scrollView addSubview:myGetPriceOrderSecond];
    }
    
    friendDetailLookedShopTableView *myGetPriceOrderThird = [[friendDetailLookedShopTableView alloc]initWithFrame:CGRectMake(WIDTH*2, 0, WIDTH, SCREENHEIGHT - CGRectGetMaxY(_scrollMenu.frame)-64-44)];
    myGetPriceOrderThird.YB_cellDelegate = self;
    //权限的判断
    NSString *visitEnable = [NSString stringWithFormat:@"%@",_settingDict[@"visitEnable"]];
    if([visitEnable isEqualToString:@"1"])
    {
    [_scrollView addSubview:myGetPriceOrderThird];
    }
    
    //滚动视图的内容大小
    [_scrollView setContentSize:CGSizeMake(3 * CGRectGetWidth(_scrollView.bounds), CGRectGetHeight(_scrollView.bounds))];
    
    [self startObservingContentOffsetForScrollView:_scrollView];
    _scrollMenu.menus = self.menus;
    [_scrollMenu reloadData];

}

#pragma mark-(自定义的cell上面点击的协议)
//收藏
-(void)YBFriendDetailColletionCellDidClick:(NSString *)commodityID andShopID:(NSString *)shopID
{
    //跳转之前传入参数
    collectionCommodityDetailViewController *ccdvc = [[collectionCommodityDetailViewController alloc]init];
    ccdvc.goodsIDString = commodityID;
    
    //无法获得shopID  传值传为空
    ccdvc.shopIDString = shopID;
    [self.navigationController pushViewController:ccdvc animated:YES];
}

//粉丝店
-(void)YBFriendDetailFansShopTableViewCellDidClick:(NSString *)shopIDString ansShopName:(NSString *)shopName andShopPic:(NSString *)shopPic
{
   
    mainShopDetailViewController *msdvc = [[mainShopDetailViewController alloc]init];
    //跳转之前传入shopID的参数]
    msdvc.shopIDString = shopIDString;
    msdvc.shopNamestrting = shopName;
    msdvc.shopPic = shopPic;
    msdvc.gnameString = self.gnameString;
    msdvc.invitationLabelString = self.invitationLabelString;
    msdvc.YB_ShopDetailChangeDelegate = self;

    
    [self.navigationController pushViewController:msdvc animated:YES];
}

//逛过
-(void)YBFriendDetailLookedShopTableViewCellDidClick:(NSString *)shopIDString andShopName:(NSString *)shopName andShopPic:(NSString *)shopPic
{
    mainShopDetailViewController *msdvc = [[mainShopDetailViewController alloc]init];
    //跳转之前传入shopID的参数
    msdvc.shopIDString = shopIDString;
    msdvc.shopNamestrting  = shopName;
    msdvc.shopPic = shopPic;
    msdvc.gnameString = self.gnameString;
    msdvc.invitationLabelString = self.invitationLabelString;
    msdvc.YB_ShopDetailChangeDelegate = self;
    
    [self.navigationController pushViewController:msdvc animated:YES];
}

//商店商品详情界面的聊天的反向传值
-(void)YBShopDetailChangeGroupGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    self.gnameString = gname;
    self.invitationLabelString = groupName;
    [self.YB_delegate YBYBFriendDetailChatWithGname:gname andGroupName:groupName];
}


#pragma mark-(按钮，横线label的联动，观察者模式)
- (void)startObservingContentOffsetForScrollView:(UIScrollView *)scrollView
{
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
}

- (void)stopObservingContentOffset
{
    if (self.scrollView) {
        [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
        self.scrollView = nil;
    }
}

#pragma mark-(创建好友资料的topView)
-(void)downLoadDataAndCreatefriendInformationTopView
{
    //先判断传过来的ID是否为好友ID  查询数据库
    if([[myAppDataBase sharedInstance]isExistUserInformationRecordWithUserID:self.frdIDString recordType:RecoredTypeAttention])
    {
    //每次点击好友详情信息的时候 都从网络上获取好友信息 然后更新本地数据库 保证用户修改信息之后能及时同步到app上面
    NSString *urlSting = [NSString stringWithFormat:FRIENDINFORMATIONURL,DomainName,self.frdIDString.intValue];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlSting parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"下载更新的好友信息字典%@",dict);
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
            NSArray *friendArray = dict[@"frdList"];
            if(friendArray.count != 0)
            {
            NSDictionary *detailDict = friendArray[0];
            NSNumber *frdIDNumber = [[NSNumber alloc]initWithInt:self.frdIDString.intValue];
            [[myAppDataBase sharedInstance]deleteUserInformationRecordWithDicitionary:frdIDNumber recordType:RecoredTypeAttention];
            [[myAppDataBase sharedInstance]addUserInformationRecordWithDicitionary:detailDict recordType:RecoredTypeAttention];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    //从数据库中取出数据
    NSDictionary *_friendInformationDict = [[myAppDataBase sharedInstance]getUserInformationRecordWithUserID:self.frdIDString];
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT*0.2)];
   // topView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:topView];
    
    _headerImageView = [ZCControl createImageViewWithFrame:CGRectMake(10, SCREENHEIGHT*0.2*0.15, SCREENWIDTH*0.25, SCREENWIDTH*0.25) ImageName:@""];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:_friendInformationDict[@"portrait"]]];
    _headerImageView.layer.cornerRadius = SCREENWIDTH*0.25/2;
    _headerImageView.layer.masksToBounds = YES;
    [topView addSubview:_headerImageView];
    
//    _nameLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.3, SCREENHEIGHT*0.2*0.2, SCREENWIDTH*0.2, SCREENHEIGHT*0.2*0.15) Font:SCREENWIDTH*0.048 Text:@""];
//    _nameLabel.adjustsFontSizeToFitWidth = YES;
//    _nameLabel.text = _friendInformationDict[@"rmkName"];
//    //_nameLabel.backgroundColor = [UIColor orangeColor];
//    [topView addSubview:_nameLabel];
    
    _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREENWIDTH*0.3, SCREENHEIGHT*0.2*0.2, SCREENWIDTH*0.2, SCREENHEIGHT*0.2*0.15)];
    _nameLabel.font = [UIFont systemFontOfSize:SCREENWIDTH*0.048];
    _nameLabel.adjustsFontSizeToFitWidth = YES;
    _nameLabel.text = _friendInformationDict[@"rmkName"];
    [topView addSubview:_nameLabel];
    
    _miaomiaoLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.3, SCREENHEIGHT*0.2*0.42, SCREENWIDTH*0.7, SCREENHEIGHT*0.2*0.15) Font:SCREENWIDTH*0.0426 Text:@""];
    _miaomiaoLabel.text = [NSString stringWithFormat:@"喵喵号： %@",_friendInformationDict[@"mcode"]];
    [topView addSubview:_miaomiaoLabel];
    
    _nickNameLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.3, SCREENHEIGHT*0.2*0.64, SCREENWIDTH*0.7, SCREENHEIGHT*0.2*0.15) Font:SCREENWIDTH*0.0426  Text:@""];
    _nickNameLabel.text = [NSString stringWithFormat:@"昵称： %@",_friendInformationDict[@"nickName"]];
    [topView addSubview:_nickNameLabel];
    
    
    _modificationButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.5, SCREENHEIGHT*0.2*0.05, SCREENWIDTH*0.15, SCREENWIDTH*0.15) ImageName:nil Target:self Action:@selector(modificationButtonBtn:) Title:nil];
    [_modificationButton setImage:[UIImage imageNamed:@"好友-好友信息_03"] forState:UIControlStateNormal];
   // [_modificationButton setBackgroundColor:[UIColor orangeColor]];
    [topView addSubview:_modificationButton];
        
        //底部添加好友的按钮
        _chatWithFriendButton = [ZCControl createButtonWithFrame:CGRectMake(0, SCREENHEIGHT-64-44, SCREENWIDTH, 44) ImageName:@"" Target:self Action:@selector(chatWithFriendButtonBtn:) Title:@"聊天"];
        [_chatWithFriendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_chatWithFriendButton setBackgroundColor:[UIColor colorWithHexStr:@"#48d58b"]];
        //[addFriendButton setImage:[UIImage imageNamed:@"同意bg"] forState:UIControlStateNormal];
        [self.view addSubview:_chatWithFriendButton];

        
    }
    else
    {
        NSString *urlSting = [NSString stringWithFormat:PASSAGERINFORMATIONURL,DomainName,self.frdIDString.intValue];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:urlSting parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            //NSLog(@"下载更新的好友信息字典%@",dict);
            NSString *errString = dict[@"err"];
            if(errString.intValue == 0)
            {
                NSArray *passagerArray = dict[@"userList"];
                if(passagerArray.count != 0)
                {
                    NSDictionary *passagerDict = passagerArray[0];
                
                   UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT*0.2)];
                // topView.backgroundColor = [UIColor orangeColor];
                  [self.view addSubview:topView];
                
                  _headerImageView = [ZCControl createImageViewWithFrame:CGRectMake(10, SCREENHEIGHT*0.2*0.15, SCREENWIDTH*0.25, SCREENWIDTH*0.25) ImageName:@""];
                  [_headerImageView sd_setImageWithURL:[NSURL URLWithString:passagerDict[@"portrait"]]];
                  _headerImageView.layer.cornerRadius = SCREENWIDTH*0.25/2;
                  _headerImageView.layer.masksToBounds = YES;
                   [topView addSubview:_headerImageView];
                    
                    
                    _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREENWIDTH*0.3, SCREENHEIGHT*0.2*0.2, SCREENWIDTH*0.4, SCREENHEIGHT*0.2*0.15)];
                    _nameLabel.font = [UIFont systemFontOfSize:SCREENWIDTH*0.048];
                    _nameLabel.adjustsFontSizeToFitWidth = YES;
                    _nameLabel.text = passagerDict[@"nickName"];
                    [topView addSubview:_nameLabel];
                    
                    _miaomiaoLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.3, SCREENHEIGHT*0.2*0.5, SCREENWIDTH*0.7, SCREENHEIGHT*0.2*0.15) Font:SCREENWIDTH*0.0426 Text:@""];
                    _miaomiaoLabel.text = [NSString stringWithFormat:@"喵喵号： m%@",passagerDict[@"userID"]];
                    [topView addSubview:_miaomiaoLabel];

                    //底部添加好友的按钮
                    _addFriendButton = [ZCControl createButtonWithFrame:CGRectMake(0, SCREENHEIGHT-64-44, SCREENWIDTH, 44) ImageName:@"" Target:self Action:@selector(addFriendButtonBtn:) Title:@"加好友"];
                    [_addFriendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [_addFriendButton setBackgroundColor:[UIColor colorWithHexStr:@"#48d58b"]];
                    //[addFriendButton setImage:[UIImage imageNamed:@"同意bg"] forState:UIControlStateNormal];
                    [self.view addSubview:_addFriendButton];
                    
                }

            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];

    }
    
//    UIImageView *lineImageView = [ZCControl createImageViewWithFrame:CGRectMake(0, SCREENHEIGHT*0.2, SCREENWIDTH, 1) ImageName:nil];
//    lineImageView.backgroundColor = [UIColor grayColor];
//    [self.view addSubview:lineImageView];
}
//点击好友聊天的事件
-(void)chatWithFriendButtonBtn:(UIButton *)button
{
    miaomiaoChatDetailViewController *vc = [[miaomiaoChatDetailViewController alloc]init];
    //在视图跳转之前 先添加喵喵记录
    NSString *userString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
    //加入喵喵表中
    NSString *otherUserString = [NSString stringWithFormat:@"%@",self.frdIDString];
    NSString *messageGname = [[NSString alloc]init];
    if(userString.intValue > otherUserString.intValue)
    {
        messageGname = [NSString stringWithFormat:@"e2e_%@_%@",userString,otherUserString];
    }
    else
    {
        messageGname = [NSString stringWithFormat:@"e2e_%@_%@",otherUserString,userString];
    }
    NSMutableDictionary *adddict = [[NSMutableDictionary alloc]init];
    
    NSNumber *idNumber = [[NSNumber alloc]initWithInt:otherUserString.intValue];
    [adddict setObject:idNumber forKey:@"senderID"];
    
    [adddict setObject:@"3" forKey:@"miaomiaoTypeID"];
    [adddict setObject:@"" forKey:@"portrait"];
    [adddict setObject:@"" forKey:@"name"];
    [adddict setObject:messageGname forKey:@"remark"];
    
    //表示新增加的未读消息
    [adddict setObject:@"1" forKey:@"unread"];
    [adddict setObject:@"" forKey:@"users"];
    
    if([[myAppDataBase sharedInstance]isExistMiaomiaoChatRecordWithSenderID:idNumber miaomiaoType:@"3" gname:messageGname])
    {
        [[myAppDataBase sharedInstance]deleteMiaoMiaoChatRecordWithSenderID:idNumber miaomiaoType:@"3" gname:messageGname];
    }
    [[myAppDataBase sharedInstance]addMiaoMiaoReordWithDicitionary:adddict recordType:RecoredTypeAttention];
    
    //传值
     NSDictionary *friendDict = [[myAppDataBase sharedInstance]getUserInformationRecordWithUserID:self.frdIDString];
    
    vc.usersIDString = @"";
    vc.gnameString = messageGname;
    vc.senderIDString = self.frdIDString;
    
    NSString *friendRmkName = friendDict[@"rmkName"];
    if(![friendRmkName isEqualToString:@""])
    {
        vc.chatTitleName =friendRmkName;
    }
    else
    {
        vc.chatTitleName = friendDict[@"nickName"];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

//添加陌生人好友的按钮的点击事件
-(void)addFriendButtonBtn:(UIButton *)button
{
    //添加好友 自己的备注信息
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"请输入备注信息" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    al.alertViewStyle = UIAlertViewStylePlainTextInput;
    al.tag = 750;
    [al show];

}



//修改备注的按钮的点击事件
-(void)modificationButtonBtn:(UIButton *)button
{
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"请输入备注名" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    al.tag = 200;
    al.alertViewStyle = UIAlertViewStylePlainTextInput;
    [al show];
}

//al代理
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 200)
    {
        if(buttonIndex == 1)
        {
             UITextField *modificationTextField = [alertView textFieldAtIndex:0];
            if(modificationTextField.text.length != 0)
            {
                NSString *modificationString = [NSString stringWithFormat:MODIFICATIONURL,DomainName];
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                manager.requestSerializer = [AFJSONRequestSerializer serializer];
                manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
                
                [manager POST:modificationString parameters:@{@"frdID":self.frdIDString,@"rmkName":modificationTextField.text} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    //解析
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                    NSString *errString = dict[@"err"];
                    if(errString.intValue == 0)
                    {
                        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"修改成功" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                        [al show];
                        
                        _nameLabel.text = modificationTextField.text;
                        //修改备注成功的同时 更新本地数据库
                        NSNumber *frdIDNumber = [[NSNumber alloc]initWithInteger:self.frdIDString.intValue];
                        
                        [[myAppDataBase sharedInstance]upDateStaticUserInfoRemarkNameWithFrD:frdIDNumber remarkName:modificationTextField.text];
                        
                        //同时更新喵喵数据库中值
                        
                    }
                    else
                    {
                        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"修改失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                        [al show];
                    }
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"修改失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    [al show];
                }];
            }
            else
            {
                UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"备注不能为空" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [al show];
            }
        }
    }
    
    if(alertView.tag == 750)
    {
        if(buttonIndex == 1)
        {
            //向后台post
            NSString *addFriendsString = [NSString stringWithFormat:ADDFRIENDSURL,DomainName];
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
            UITextField *noteTextField = [alertView textFieldAtIndex:0];
            NSString *noteString = noteTextField.text;
            //需要对添加好友的方式进行判断
            NSDictionary *parameterDict = [[NSDictionary alloc]init];
            //用手机号码添加好友
            //            if([utils validateMobile:_textField.text])
            //            {
            NSNumber *modeNumber = [[NSNumber alloc]initWithInt:2];
            
            parameterDict = @{@"mode":modeNumber,@"mcode":[NSString stringWithFormat:@"m%@",self.frdIDString],@"remark":noteString};
            //}
            //用喵喵号添加好友
            //            else
            //            {
            //                parameterDict = @{@"mode":@"2",@"mcode":_textField.text,@"remark":noteString};
            //            }
            [manager POST:addFriendsString parameters:parameterDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                //解析
                NSDictionary *addFriendDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                NSLog(@"添加好友结果字典%@",addFriendDict);
                NSString *errString = addFriendDict[@"is_success"];
                if(errString.intValue == 0)
                {
                    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"请求发送成功，请等待回复" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    [al show];
                }
                else
                {
                    //通过手机号码添加好友 当手机号码对应的用户不存在的时候 提示是否邀请安装
                    //                    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"该用户未安装喵喵熊，是否邀请安装" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    //                    al.tag = 850;
                    //                    [al show];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"添加好友失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [al show];
            }];
            
        }
    }

    
}

-(void)createUINa
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"好友资料"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    //导航栏左按钮
    UIButton *imageLeftButton  =[ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(imageLeftItemBtn) Title:nil];
    [imageLeftButton setImage:[UIImage imageNamed:@"店铺-店铺详情_03"] forState:UIControlStateNormal];
    UIBarButtonItem *imageLeftItem = [[UIBarButtonItem alloc]initWithCustomView:imageLeftButton];
    self.navigationItem.leftBarButtonItem = imageLeftItem;
}
-(void)imageLeftItemBtn
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self stopObservingContentOffset];
}

#pragma mark-(菜单栏上面按钮点击)
- (void)scrollMenuDidSelected:(XHScrollMenu *)scrollMenu menuIndex:(NSUInteger)selectIndex {
    self.shouldObserving = NO;
    [self menuSelectedIndex:selectIndex];
}

- (void)scrollMenuDidManagerSelected:(XHScrollMenu *)scrollMenu {
    
}
- (void)menuSelectedIndex:(NSUInteger)index {
    //下面横线label的坐标
    CGRect visibleRect = CGRectMake(index * CGRectGetWidth(self.scrollView.bounds), 0, CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds));
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.scrollView scrollRectToVisible:visibleRect animated:NO];
    } completion:^(BOOL finished) {
        self.shouldObserving = YES;
    }];
}

#pragma mark - ScrollView delegate（滚动视图的代理事件）
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //每页宽度
    CGFloat pageWidth = scrollView.frame.size.width;
    //根据当前的坐标与页宽计算当前页码
    int currentPage = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
    [self.scrollMenu setSelectedIndex:currentPage animated:YES calledDelegate:NO];
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //每页宽度
    CGFloat pageWidth = scrollView.frame.size.width;
    //根据当前的坐标与页宽计算当前页码
    int currentPage = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
    [self.scrollMenu setUnSelectedIndex:currentPage];
}

#pragma mark - KVO （横线label的坐标的改变和大小）

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"] && self.shouldObserving) {
        //每页宽度
        CGFloat pageWidth = self.scrollView.frame.size.width;
        //根据当前的坐标与页宽计算当前页码
        NSUInteger currentPage = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        if (currentPage > self.menus.count - 1)
            currentPage = self.menus.count - 1;
        
        CGFloat oldX = currentPage * CGRectGetWidth(self.scrollView.frame);
        if (oldX != self.scrollView.contentOffset.x) {
            BOOL scrollingTowards = (self.scrollView.contentOffset.x > oldX);
            NSInteger targetIndex = (scrollingTowards) ? currentPage + 1 : currentPage - 1;
            if (targetIndex >= 0 && targetIndex < self.menus.count) {
                CGFloat ratio = (self.scrollView.contentOffset.x - oldX) / CGRectGetWidth(self.scrollView.frame);
                CGRect previousMenuButtonRect = [self.scrollMenu rectForSelectedItemAtIndex:currentPage];
                CGRect nextMenuButtonRect = [self.scrollMenu rectForSelectedItemAtIndex:targetIndex];
                CGFloat previousItemPageIndicatorX = previousMenuButtonRect.origin.x;
                CGFloat nextItemPageIndicatorX = nextMenuButtonRect.origin.x;
                
                /* this bug for Memory
                 UIButton *previosSelectedItem = [self.scrollMenu menuButtonAtIndex:currentPage];
                 UIButton *nextSelectedItem = [self.scrollMenu menuButtonAtIndex:targetIndex];
                 [previosSelectedItem setTitleColor:[UIColor colorWithWhite:0.6 + 0.4 * (1 - fabsf(ratio))
                 alpha:1.] forState:UIControlStateNormal];
                 [nextSelectedItem setTitleColor:[UIColor colorWithWhite:0.6 + 0.4 * fabsf(ratio)
                 alpha:1.] forState:UIControlStateNormal];
                 */
                
                CGRect indicatorViewFrame = self.scrollMenu.indicatorView.frame;
                
                if (scrollingTowards) {
                    indicatorViewFrame.size.width = CGRectGetWidth(previousMenuButtonRect) + (CGRectGetWidth(nextMenuButtonRect) - CGRectGetWidth(previousMenuButtonRect)) * ratio;
                    indicatorViewFrame.origin.x = previousItemPageIndicatorX + (nextItemPageIndicatorX - previousItemPageIndicatorX) * ratio;
                } else {
                    indicatorViewFrame.size.width = CGRectGetWidth(previousMenuButtonRect) - (CGRectGetWidth(nextMenuButtonRect) - CGRectGetWidth(previousMenuButtonRect)) * ratio;
                    indicatorViewFrame.origin.x = previousItemPageIndicatorX - (nextItemPageIndicatorX - previousItemPageIndicatorX) * ratio;
                }
                
                self.scrollMenu.indicatorView.frame = indicatorViewFrame;
            }
        }
    }
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
