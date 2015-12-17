//
//  SidebarViewController.m
//  LLBlurSidebar
//
//  Created by Lugede on 14/11/20.
//  Copyright (c) 2014年 lugede.cn. All rights reserved.
//

#import "SidebarViewController.h"

#import "loginViewController.h"

#import "myAppDataBase.h"

//个人信息的URL
#define PERSONALINFORMATION @"http://%@/user/personal"

@interface SidebarViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    //头像 昵称
    UIImageView *headerImageView;
    UILabel *nickLabel;
    
}
@property (nonatomic, retain) UITableView* menuTableView;
@property (nonatomic,retain) NSArray *titleArray;
@property (nonatomic,retain) NSArray *imageView;
@property (nonatomic,copy) NSMutableDictionary *myInformationDict;

@end

@implementation SidebarViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createTableView];
    
    [self createData];
    
    NSString *loginString = [[NSUserDefaults standardUserDefaults]objectForKey:IsLogin];
    if([loginString isEqualToString:@"login"])
    {
    [self loadNetData];
    }
    //通过通知传值来获取当前支持城市中我选择的城市
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(changeCity:) name:@"changeMyCity" object:nil];
    [nc addObserver:self selector:@selector(loadNetData) name:@"changeMyNickName" object:nil];
    [nc addObserver:self selector:@selector(loadNetData) name:@"changeMyHeaderImage" object:nil];
    [nc addObserver:self selector:@selector(loadNetData1) name:@"changeLogout" object:nil];
    [nc addObserver:self selector:@selector(loadNetData) name:@"changeLogin" object:nil];
}

//退出登录刷新菜单栏
-(void)loadNetData1
{
    [self.menuTableView reloadData];
}
-(void)loadNetData
{
     NSString *myIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
//    if([[myAppDataBase sharedInstance]isExistUserInformationRecordWithUserID:myIDString recordType:RecoredTypeAttention])
//    {
//         NSDictionary *dict = [[myAppDataBase sharedInstance]getUserInformationRecordWithUserID:myIDString];
//        NSMutableDictionary *myDict = [[NSMutableDictionary alloc]init];
//        [myDict setObject:dict[@"nickName"] forKey:@"name"];
//        [myDict setObject:dict[@"portrait"] forKey:@"portrait"];
//        _myInformationDict = myDict;
//        NSLog(@"存储的我自己的字典 = %@",_myInformationDict);
//        [self.menuTableView reloadData];
//    }
//    else
//    {
    NSString *getPersonalInformationString = [NSString stringWithFormat:PERSONALINFORMATION,DomainName];
    //NSLog(@"个人信息%@",getPersonalInformationString);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:getPersonalInformationString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *informationDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSString *informationErrString = informationDict[@"err"];
        if(informationErrString.intValue == 0)
        {
            NSMutableDictionary *informationDetailDict = informationDict[@"info"];
            _myInformationDict = informationDetailDict;
            
//            //存储自己的个人头像URL
//            [[NSUserDefaults standardUserDefaults]setObject:_myInformationDict[@"portrait"] forKey:MyPhotoImageURL];
//            [[NSUserDefaults standardUserDefaults]synchronize];
            
            [self.menuTableView reloadData];
            
            //设计的缺陷（在好友表中存入自己的相关信息）
            NSLog(@"我自己的相关信息 = %@",_myInformationDict);
            
            NSMutableDictionary *addDict = [[NSMutableDictionary alloc]init];
           
            if(![[myAppDataBase sharedInstance]isExistUserInformationRecordWithUserID:myIDString recordType:RecoredTypeAttention])
            {
            NSString *mcodeString = [NSString stringWithFormat:@"m%@",_myInformationDict[@"mcode"]];
            [addDict setObject:myIDString forKey:@"frdID"];
            [addDict setObject:@"" forKey:@"rmkName"];
            [addDict setObject:_myInformationDict[@"name"] forKey:@"nickName"];
            [addDict setObject:mcodeString forKey:@"mcode"];
            [addDict setObject:_myInformationDict[@"portrait"] forKey:@"portrait"];
            [[myAppDataBase sharedInstance]addUserInformationRecordWithDicitionary:addDict recordType:RecoredTypeAttention];
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
//    }
}

#pragma mark-(初始化数据)
-(void)createData
{
    NSString *cityString = [[NSUserDefaults standardUserDefaults]objectForKey:MyChooseCity];
    if(cityString == nil)
    {
        self.titleArray = @[@[@"首页",@"好友",@"喵喵",@"粉店",@"收藏",@"逛过",@"扫扫"],@[@"合肥",@"设置",@"反馈"]];
    }
    else
    {
       self.titleArray = @[@[@"首页",@"好友",@"喵喵",@"粉店",@"收藏",@"逛过",@"扫扫"],@[cityString,@"设置",@"反馈"]];
    }
    [self.menuTableView reloadData];
}
    


#pragma mark-(通知传值 选择支持的城市)
-(void)changeCity:(NSNotification *)notification
{
    NSString *cityString = notification.userInfo[@"myCity"];
    _cityString = cityString;
    
    if(_cityString == nil)
    {
         self.titleArray = @[@[@"首页",@"好友",@"喵喵",@"粉店",@"收藏",@"逛过",@"扫扫"],@[@"合肥",@"设置",@"反馈"]];
    }
    else
    {
         self.titleArray = @[@[@"首页",@"好友",@"喵喵",@"粉店",@"收藏",@"逛过",@"扫扫"],@[_cityString,@"设置",@"反馈"]];
    }
    [self.menuTableView reloadData];
}

#pragma mark-(创建表格视图）
-(void)createTableView
{
    
    self.menuTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0 , self.contentView.bounds.size.width, SCREENHEIGHT-20) style:UITableViewStyleGrouped];
    self.menuTableView.delegate = self;
    self.menuTableView.dataSource = self;
    //设置表格视图左边短15像素问题
    if([self.menuTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [self.menuTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if([self.menuTableView  respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self.menuTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    
    [self.view addSubview:self.menuTableView];

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 7;
    }
    else
    {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *sidebarMenuCellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sidebarMenuCellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sidebarMenuCellIdentifier] ;
        
    }
    cell.textLabel.text = self.titleArray[indexPath.section][indexPath.row];
    
    NSArray *imgaeArray = @[@[@"首页-菜单_03",@"首页-菜单_03-02",@"首页-菜单_03-03",@"首页-菜单_03-04",@"首页-菜单_03-05",@"首页-菜单_03-06",@"首页-菜单_03-07"],@[@"首页-菜单_03-08",@"首页-菜单_03-09",@"首页-菜单_03-10"]];
    cell.imageView.image = [UIImage imageNamed:imgaeArray[indexPath.section] [indexPath.row]];
    
    return cell;

}

#pragma mark-(设置各种高度)
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return HEIGHT*0.15;
    }
    else
    {
    return 0.1f;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HEIGHT*0.08;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        //在这需要进行判断是否已经登录成功
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSString *login = [user objectForKey:IsLogin];
        NSLog(@"是否登录的字符串%@",login);
        if(login)
        {
        UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.bounds.size.width, HEIGHT*0.15)];
        headerView.backgroundColor = [UIColor whiteColor];
            
        //登录之后如果没设置自己的头像名称的话  为系统默认的头像  如果有设置自己的头像昵称的话 则为自己设置的头像昵称
            
        headerImageView = [ZCControl createImageViewWithFrame:CGRectMake(10,HEIGHT*0.15*0.2, SCREENWIDTH*0.15, SCREENWIDTH*0.15) ImageName:@""];
            //登录过后图片为自己的图像
           // headerImageView.image =
        //headerImageView.backgroundColor = [UIColor orangeColor];
         [headerImageView sd_setImageWithURL:[NSURL URLWithString:_myInformationDict[@"portrait"]]];
        headerImageView.layer.cornerRadius=SCREENWIDTH*0.15/2;
        headerImageView.layer.masksToBounds=YES;
        [headerView addSubview:headerImageView];
        
            NSString *nickNameString = _myInformationDict[@"name"];
//            //本地保存我自己的名称
//            [[NSUserDefaults standardUserDefaults]setObject:nickNameString forKey:MyNickName];
//            [[NSUserDefaults standardUserDefaults]synchronize];
            
        nickLabel=[ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.22, HEIGHT*0.15*0.2,SCREENWIDTH*0.4, HEIGHT*0.15*0.6) Font:SCREENWIDTH*0.048 Text:nickNameString];
             nickLabel.textColor = [UIColor colorWithHexStr:@"#333333"];
        //nickLabel.backgroundColor = [UIColor orangeColor];
        [headerView addSubview:nickLabel];
        
        //在headerView上面添加UIControl的点击事件
        UIControl *headerControl = [[UIControl alloc]initWithFrame:headerView.frame];
        [headerControl addTarget:self action:@selector(controlClick:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:headerControl];
    
            return headerView;
        }
        else
        {
            UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.bounds.size.width, HEIGHT*0.15)];
            headerView.backgroundColor = [UIColor whiteColor];
            headerImageView = [ZCControl createImageViewWithFrame:CGRectMake(10,HEIGHT*0.15*0.2, SCREENWIDTH*0.15, SCREENWIDTH*0.15) ImageName:@""];
            headerImageView.image = [UIImage imageNamed:@"头像"];
            //headerImageView.backgroundColor = [UIColor orangeColor];
            headerImageView.layer.cornerRadius=SCREENWIDTH*0.15/2;
            headerImageView.layer.masksToBounds=YES;
            [headerView addSubview:headerImageView];
            
            nickLabel=[ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.22, HEIGHT*0.15*0.2,SCREENWIDTH*0.4, HEIGHT*0.15*0.6) Font:SCREENWIDTH*0.048 Text:@"登录喵喵熊"];
            //nickLabel.backgroundColor = [UIColor orangeColor];
            nickLabel.textColor = [UIColor colorWithHexStr:@"#333333"];
            [headerView addSubview:nickLabel];
            
            //在headerView上面添加UIControl的点击事件
            UIControl *headerControl = [[UIControl alloc]initWithFrame:headerView.frame];
            [headerControl addTarget:self action:@selector(logincontrolClick:) forControlEvents:UIControlEventTouchUpInside];
            [headerView addSubview:headerControl];
            
            return headerView;
        }
    
    }
    else
    {
        return nil;
    }
}
//点击登录
-(void)logincontrolClick:(UIControl *)control
{
    [self.YB_delegate YBSideTableViewLoginHeaderViewDidSelected];
}


//个人信息的点击事件
-(void)controlClick:(UIControl *)control
{
    //如果界面返回的时候 需要显示菜单栏 则不需要进行隐藏
    
  //  [self showHideSidebar];
    
    [self.YB_delegate YBSideTableViewHeaderViewDidSelected];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //隐藏侧滑菜单
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
        [self showHideSidebar];
        }
    }
    
    //自己制定cell的点击协议
    [self.YB_delegate YBSideTableViewCellDidSelectedWithIndexPath:indexPath];
    
    
}

@end
