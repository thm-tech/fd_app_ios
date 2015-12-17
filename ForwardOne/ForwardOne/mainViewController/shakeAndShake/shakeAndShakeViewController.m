//
//  shakeAndShakeViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/26.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "shakeAndShakeViewController.h"
#import "LZAudioTool.h"
#import "UIView+LZ.h"
#import "danLiDataCenter.h"

#import "friendsDetailViewController.h"

#define SHAKEUSERURL @"http://%@/chat/match"

@interface shakeAndShakeViewController ()<YBFriendDetailChatDelegate>
{
    //YBWebSocketManager *sockerManager;
    NSString *boyString;
    NSString *girlString;
    
}

@property (nonatomic, strong) UIImageView *bg;
@property (nonatomic, strong) UIImageView *up;
@property (nonatomic, strong) UIImageView *down;

@end

@implementation shakeAndShakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    boyString = [NSString stringWithFormat:@"0"];
    girlString = [NSString stringWithFormat:@"0"];
    
    [self createUINav];
    
    [self createTextUI];
    
    //摇一摇接收摇一摇结果的通知
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(getShakeUserID:) name:@"sendShakeUserID" object:nil];
    
    
    // Do any additional setup after loading the view.
}
//摇一摇通知
-(void)getShakeUserID:(NSNotification *)notification
{
    NSString *shakeUserIDString = notification.userInfo[@"shakeUserID"];
    friendsDetailViewController *vc = [[friendsDetailViewController alloc]init];
    danLiDataCenter *dc = [danLiDataCenter sharedInstance];
    dc.frdIDString = shakeUserIDString;
    vc.frdIDString = shakeUserIDString;
    vc.gnameString = self.gnameString;
    vc.invitationLabelString = self.invitationLabelString;
    vc.YB_delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
    
}
//好友资料的详情的反向传值
-(void)YBYBFriendDetailChatWithGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    [self.YB_delegate YBShakeChangeChatWithGname:gname andGroupName:groupName];
}


-(void)createTextUI
{
//    UIImageView *shakeImageView = [ZCControl createImageViewWithFrame:CGRectMake(SCREENWIDTH*0.25, SCREENHEIGHT*0.2, SCREENWIDTH*0.5, SCREENWIDTH*0.5) ImageName:@"s"];
//    [self.view addSubview:shakeImageView];
    
    //背景图
    UIImageView *bg = [ZCControl createImageViewWithFrame:self.view.bounds ImageName:@""];
    [self.view addSubview:bg];
    self.bg = bg;
    
    
    //摇一摇分开的上部分图片
    UIImageView *up = [ZCControl createImageViewWithFrame:CGRectMake(0, 0, self.view.width, self.view.height * 0.5) ImageName:@"首页-聊天-摇一摇_02"];
    ///up.backgroundColor = [UIColor orangeColor];
    [bg addSubview:up];
    self.up = up;
    
    //摇一摇分开的下部分图片
    UIImageView *down = [ZCControl createImageViewWithFrame:CGRectMake(0, self.view.height * 0.5, self.view.width, self.view.height * 0.5) ImageName:@"首页-聊天-摇一摇_03"];
    //down.backgroundColor = [UIColor redColor];
    [bg addSubview:down];
    self.down = down;
    
    //下方添加匹配同城和性别的按钮
    
    //匹配男性
    UIButton *sameCityButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.2, self.view.height*0.5*0.45, SCREENWIDTH*0.2, self.view.height*0.5*0.1) ImageName:nil Target:self Action:@selector(sameCityButtonBtn:) Title:@"男"];
    [sameCityButton setTitleColor:[UIColor colorWithHexStr:@"#666666"] forState:UIControlStateNormal];
    [sameCityButton setImage:[UIImage imageNamed:@"shake"] forState:UIControlStateNormal];
    //sameCityButton.backgroundColor = [UIColor orangeColor];
    [self.down addSubview:sameCityButton];
    
    
    //女性
    UIButton *sexButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.6, self.view.height*0.5*0.45, SCREENWIDTH*0.2, self.view.height*0.5*0.1) ImageName:nil Target:self Action:@selector(sexButtonBtn:) Title:@"女"];
    [sexButton setTitleColor:[UIColor colorWithHexStr:@"#666666"] forState:UIControlStateNormal];
    [sexButton setImage:[UIImage imageNamed:@"shake"] forState:UIControlStateNormal];
    //sexButton.backgroundColor = [UIColor orangeColor];
    [self.down addSubview:sexButton];
    
    //fenka
    
}
-(void)sameCityButtonBtn:(UIButton *)button
{
   static BOOL b = YES;
    if(b)
    {
    [button setImage:[UIImage imageNamed:@"shakeSelected"] forState:UIControlStateNormal];
        boyString = @"1";
        b = NO;
    }
    else
    {
        [button setImage:[UIImage imageNamed:@"shake"] forState:UIControlStateNormal];
        b = YES;
        boyString = @"0";
    }
}

-(void)sexButtonBtn:(UIButton *)button
{
    static BOOL b = YES;
    if(b)
    {
        [button setImage:[UIImage imageNamed:@"shakeSelected"] forState:UIControlStateNormal];
        girlString = @"1";
        b = NO;
    }
    else
    {
        [button setImage:[UIImage imageNamed:@"shake"] forState:UIControlStateNormal];
        girlString = @"0";
        b = YES;
        
    }

}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}


//代理实现相应的手势动作触发的事件
#pragma mark - 实现相应的响应者方法
/** 开始摇一摇 */
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"motionBegan");
    
    CGFloat offset = self.bg.height/2;
    CGFloat duration = 0.4;
    
    [UIView animateWithDuration:duration animations:^{
        self.up.y -= offset;
        self.down.y += offset;
    }];
    [LZAudioTool playMusic:@"dance.mp3"];
    
}

/** 摇一摇结束（需要在这里处理结束后的代码） */
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    // 不是摇一摇运动事件
    if (motion != UIEventSubtypeMotionShake) return;
    
    NSLog(@"motionEnded");
    CGFloat offset = self.bg.height / 2;
    CGFloat duration = 0.4;
    [UIView animateWithDuration:duration animations:^{
        self.up.y += offset;
        self.down.y -= offset;
    }];
    
    //摇一摇结束之后 通过webSocket像后台通信
//    sockerManager = [YBWebSocketManager sharedInstance];
//    NSString *userString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
//    [sockerManager YBShakeWithUser:userString];
    
    //取出数据
    NSString *userIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
    //下载数据  然后创建对应的view
    [self downLoadShakeUserIDInformationWithUserID:userIDString];
//    //创建View
//    [self createUserInformationView];
}

//
-(void)downLoadShakeUserIDInformationWithUserID:(NSString *)userID
{
    //发送摇一摇的http请求
    NSString *urlString = [NSString stringWithFormat:SHAKEUSERURL,DomainName2];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    NSMutableDictionary *genderIdDict = [[NSMutableDictionary alloc]init];
    NSNumber *cityIDNumber = [[NSNumber alloc]initWithInt:0];
    //NSNumber *userID = [[NSNumber alloc]initWithInt:userIDString.intValue];
    if([boyString isEqualToString:@"1"]&&[girlString isEqualToString:@"1"])
    {
        [genderIdDict setObject:userID forKey:@"userId"];
        [genderIdDict setObject:cityIDNumber forKey:@"cityId"];
        NSNumber *sexNumber = [[NSNumber alloc]initWithInt:5];
        [genderIdDict setObject:sexNumber forKey:@"gender"];
    }
    else if ([boyString isEqualToString:@"0"]&&[girlString isEqualToString:@"0"])
    {
        [genderIdDict setObject:userID forKey:@"userId"];
        [genderIdDict setObject:cityIDNumber forKey:@"cityId"];
         NSNumber *sexNumber = [[NSNumber alloc]initWithInt:5];
        [genderIdDict setObject:sexNumber forKey:@"gender"];
    }
    else if ([boyString isEqualToString:@"1"]&&[girlString isEqualToString:@"0"])
    {
         [genderIdDict setObject:userID forKey:@"userId"];
        [genderIdDict setObject:cityIDNumber forKey:@"cityId"];
         NSNumber *sexNumber = [[NSNumber alloc]initWithInt:1];
        [genderIdDict setObject:sexNumber forKey:@"gender"];
    }
    else if ([boyString isEqualToString:@"0"]&&[girlString isEqualToString:@"1"])
    {
         [genderIdDict setObject:userID forKey:@"userId"];
        [genderIdDict setObject:cityIDNumber forKey:@"cityId"];
         NSNumber *sexNumber = [[NSNumber alloc]initWithInt:2];
        [genderIdDict setObject:sexNumber forKey:@"gender"];
    }
    
    NSLog(@"摇一摇的最终字典 = %@",genderIdDict);
    
    
    [manager POST:urlString parameters:genderIdDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"摇一摇回复的字典 = %@",responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"摇一摇的err = %@",error);
        
    }];
    
}

//SocketDeletegate
//-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
//{
//    NSString *messageString = message;
//    NSDictionary *dict = [messageString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
//    NSString *userIDString = dict[@"user"];
//    
//    //得到摇一摇匹配的userID 在根据userID获取相关的信息
//    [self createShakeLaterViewWithUserID:userIDString];
//}
////获得摇一摇陌生人的ID之后 (下载相关信息 进行界面显示)
//-(void)createShakeLaterViewWithUserID:(NSString *)userIDString
//{
//    UIView *strangerInformationView = [[UIView alloc]initWithFrame:self.view.bounds];
//    strangerInformationView.backgroundColor = [UIColor blueColor];
//    [self.view addSubview:strangerInformationView];
//    
//}


/** 摇一摇取消（被中断，比如突然来电） */
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"motionCancelled");
    CGFloat offset = self.bg.height / 2;
    CGFloat duration = 0.4;
    [UIView animateWithDuration:duration animations:^{
        self.up.y += offset;
        self.down.y -= offset;
    }];
}

-(void)createUINav
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"摇一摇"];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
