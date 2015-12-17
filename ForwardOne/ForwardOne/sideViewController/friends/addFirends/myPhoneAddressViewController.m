//
//  myPhoneAddressViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/10/14.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "myPhoneAddressViewController.h"
#import "ZCAddressBook.h"
#import "JSONKit.h"
#import "utils.h"


#define SELECTPHONESURL @"http://%@/userweb/selectphones"
#define SENDMESSAGEURL @"http://%@/userweb/sendinvite2"
#define ADDFRIENDSURL @"http://%@/user/friend/invite"


@interface myPhoneAddressViewController ()<UITableViewDelegate,UITableViewDataSource,MFMessageComposeViewControllerDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_allFriendArray;
    NSMutableArray *_notPlatArray;
    NSMutableArray *_platFriendArray;
    NSMutableArray *_platNotFriendArray;
    NSMutableArray *_allAddFriendArray;
}
@end

@implementation myPhoneAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUINav];
    
    
    _notPlatArray = [[NSMutableArray alloc]init];
    _platFriendArray = [[NSMutableArray alloc]init];
    _platNotFriendArray = [[NSMutableArray alloc]init];
    //    _allAddFriendArray = [[NSMutableArray alloc]init];
    
    //获取vCard
    _allFriendArray = [[NSMutableArray alloc]init];

    
    //先判断是否有权限访问手机通讯录
    
    ZCAddressBook *zc = [ZCAddressBook shareControl];
    
    if([zc existPhone:@"18156832958"] == ABHelperCanNotConncetToAddressBook)
    {
        UILabel *label = [ZCControl createLabelWithFrame:CGRectMake(0, SCREENHEIGHT*0.2, SCREENWIDTH, SCREENHEIGHT*0.1) Font:SCREENWIDTH*0.048 Text:@"请在iPhone的“设置-隐私-通讯录” 选项中，允许喵喵熊访问你的通讯录。"];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
    }
    else
    {
        //获取手机通讯录的数据
        [self loadPhoneAddressData];
        
        [self createUITableView];
    }
    
    
    // Do any additional setup after loading the view.
}
#pragma mark-(创建表格视图)
-(void)createUITableView
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-64) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    //设置表格视图左边短15像素问题
    if([_tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if([_tableView  respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    
    [self.view addSubview:_tableView];
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
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return _notPlatArray.count + _platNotFriendArray.count;
    }
    else
    {
        return _platFriendArray.count;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:nil reuseIdentifier:nil];
    
    //static NSString *cellID = @"cell";
//    UITableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"cellID"];
//    if(cell == nil)
//    {
//        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
//    }
    //config cell
    //非平台用户以及平台用户非好友
    if(indexPath.section == 0)
    {
       UIButton *addButton = [ZCControl createButtonWithFrame:CGRectMake(0, 0, 60, 30) ImageName:@"同意bg" Target:self Action:@selector(addbuttonBtn:) Title:@"添加"];
       cell.accessoryView = addButton;
        NSString *phoneNumberString = _allAddFriendArray[indexPath.row];
        for(NSDictionary *friendDict in _allFriendArray)
        {
            if([phoneNumberString isEqualToString:friendDict[@"telphone"]])
            {
                cell.textLabel.text = [NSString stringWithFormat:@"%@%@",friendDict[@"last"],friendDict[@"first"]];
            }
        }
        
    }
    
    //平台好友
    else
    {
        UILabel *label = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 60, 30) Font:SCREENWIDTH*0.048 Text:@"已添加"];
        cell.accessoryView = label;
        
        NSString *phoneNumberString = _platFriendArray[indexPath.row];
        for(NSDictionary *friendDict in _allFriendArray)
        {
            if([phoneNumberString isEqualToString:friendDict[@"telphone"]])
            {
                cell.textLabel.text = [NSString stringWithFormat:@"%@%@",friendDict[@"last"],friendDict[@"first"]];
            }
        }

    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
       return cell;
}

//添加按钮的点击事件
-(void)addbuttonBtn:(UIButton *)button
{
    UITableViewCell *cell = (UITableViewCell *)[button superview] ;
    NSIndexPath *path = [_tableView indexPathForCell:cell];
    NSString *phoneString = _allAddFriendArray[path.row];
    NSLog(@"具体加好友的号码 = %@",phoneString);
    //前面的是邀请好友下载 （需要调用发短信协议以及加好友协议）   后面的是添加平台非好友（只需要调用加好友协议）
    if(path.row < _notPlatArray.count)
    {
        
//        if([utils validateMobile:phoneString])
//        {
        //1.发送邀请短信
        NSString *sendMessageURl = [NSString stringWithFormat:SENDMESSAGEURL,DomainName];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        
        [manager POST:sendMessageURl parameters:@{@"phone":phoneString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"************%@",dict);
            if([[dict allKeys]containsObject:@"des"])
            {
                
                //判断当前设备是否可以发送信息
                if ([MFMessageComposeViewController canSendText]) {
                    
                    MFMessageComposeViewController *messageViewController = [[MFMessageComposeViewController alloc] init];
                    messageViewController = [[MFMessageComposeViewController alloc]init];
                    //messageViewController.delegate = self;;
                    
                    //委托到本类
                    messageViewController.messageComposeDelegate = self;
                    
                    //设置收件人, 需要一个数组, 可以群发短信
                    messageViewController.recipients = @[phoneString];
                    
                    //短信的内容
                    messageViewController.body =dict[@"des"];
                    
                    //打开短信视图控制器
                    [self presentViewController:messageViewController animated:NO completion:nil];
                    
                }
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           
            NSLog(@"err = %@",error);
        }];
        
        //2.发送添加好友的请求
        NSString *addFriendsString = [NSString stringWithFormat:ADDFRIENDSURL,DomainName];
        NSDictionary *parameterDict = [[NSDictionary alloc]init];
        NSNumber *modeNumber = [[NSNumber alloc]initWithInt:1];
        parameterDict = @{@"mode":modeNumber,@"phone":phoneString,@"remark":@""};
        [manager POST:addFriendsString parameters:parameterDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //解析
            NSDictionary *addFriendDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"添加好友结果字典%@",addFriendDict);
            NSString *errString = addFriendDict[@"is_success"];
            if(errString.intValue == 0)
            {
//                UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"请求发送成功，请等待回复" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//                [al show];
                //视图重新刷新
                [self loadPhoneAddressData];
                
                
            }
            else
            {
                //通过手机号码添加好友 当手机号码对应的用户不存在的时候 提示是否邀请安装
                //                    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"该用户未安装喵喵熊，是否邀请安装" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                //                    al.tag = 850;
                //                    [al show];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"非平台添加err = %@",error);
            
            }];
    }
//        else
//        {
//            UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"此手机号码不合法，不能发送短信" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//            [al show];
//
//        }
//    }
    
    else
    {
        //2.发送添加好友的请求
        NSString *addFriendsString = [NSString stringWithFormat:ADDFRIENDSURL,DomainName];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        NSDictionary *parameterDict = [[NSDictionary alloc]init];
        NSNumber *modeNumber = [[NSNumber alloc]initWithInt:1];
        parameterDict = @{@"mode":modeNumber,@"phone":phoneString,@"remark":@""};
        [manager POST:addFriendsString parameters:parameterDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //解析
            NSDictionary *addFriendDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"添加好友结果字典2%@",addFriendDict);
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
            
            NSLog(@"平台非好友添加err = %@",error);
            
            UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"添加好友失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [al show];
            
        }];
    }
    
   
}

#pragma mark MFMessageComposeViewController 代理方法
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    //[self.target dismissViewControllerAnimated:YES completion:nil];
    //0 取消  1是成功 2是失败
    NSLog(@"~~~%d",result);
    if(result == 0)
    {
        [controller dismissViewControllerAnimated:NO completion:nil];
    }
    else if (result == 1)
    {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"信息发送成功" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
        [controller dismissViewControllerAnimated:NO completion:nil];
    }
    else if (result == 2)
    {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"信息发送失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
        [controller dismissViewControllerAnimated:NO completion:nil];
    }
    
    // [controller dismissModalViewControllerAnimated:NO];
}

//设置各种高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREENHEIGHT*0.1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == 1)
    {
        return 0.1f;
    }
    else
    {
        return SCREENHEIGHT*0.01;
    }
}

#pragma mark-(获取手机通讯录的数据)
-(void)loadPhoneAddressData
{
    
//    _notPlatArray = [[NSMutableArray alloc]init];
//    _platFriendArray = [[NSMutableArray alloc]init];
//    _platNotFriendArray = [[NSMutableArray alloc]init];
//    //    _allAddFriendArray = [[NSMutableArray alloc]init];
//    
//    //获取vCard
//    _allFriendArray = [[NSMutableArray alloc]init];

    
    [_notPlatArray removeAllObjects];
    [_platFriendArray removeAllObjects];
    [_platNotFriendArray removeAllObjects];
    [_allFriendArray removeAllObjects];
    
    
    //得到通讯录里面所有电话号码的数组
    NSMutableArray *phoneArray = [[NSMutableArray alloc]init];
    
    NSMutableDictionary *dict = [[ZCAddressBook shareControl]getPersonInfo];
    
    NSLog(@"获取的所有的通讯录字典 = %@",dict);
    
    //获取索引
    NSArray *array = [[ZCAddressBook shareControl]sortMethod];
    
    for(NSString *key in array)
    {
        NSArray *friendArray = dict[key];
        for(NSDictionary *friendDict in friendArray)
        {
            [_allFriendArray addObject:friendDict];
            if(![friendDict[@"telphone"] isEqualToString:@" "])
            {
                NSString *phoneAddString = [NSString stringWithFormat:@"%@",friendDict[@"telphone"]];
                [phoneArray addObject:phoneAddString];
            }
        }
    }
    
   // NSLog(@"所有的电话号码数组 = %@",phoneArray);
    NSLog(@"所有的电话号码数组数量 = %d",phoneArray.count);

    //查询平台用户（与后台post请求）
    NSString *selectPhonesString = [NSString stringWithFormat:SELECTPHONESURL,DomainName];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    NSString *myPhone = [[NSUserDefaults standardUserDefaults]objectForKey:UserPhone];
    
    NSDictionary *partnerDict = @{@"phone":myPhone,@"phone_list":phoneArray};
    NSLog(@"参数dict = %@",partnerDict);
    [manager POST:selectPhonesString parameters:partnerDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *selectPhoneResponseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"查询平台的回应 = %@",selectPhoneResponseDict);
        
        _notPlatArray = selectPhoneResponseDict[@"notplatform"];
        _platFriendArray = selectPhoneResponseDict[@"platform_friend"];
        _platNotFriendArray = selectPhoneResponseDict[@"platform_notfriend"];
        //_platNotFriendArray = @[@"099999",@"999999",@"8888888"];
        
        _allAddFriendArray = [[NSMutableArray alloc]initWithArray:_notPlatArray];
        for(NSString *finalAddString in _platNotFriendArray)
        {
            [_allAddFriendArray addObject:finalAddString];
        }
        NSLog(@"数组相加之后的数组 = %@",_allAddFriendArray);
        NSLog(@"数组相加之后的数组数量 = %d",_allAddFriendArray.count);
        //表格视图 刷新数据
        [_tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"错误的err = %@",error);
    }];
    
}

#pragma mark-(创建导航栏)
-(void)createUINav
{
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"手机通讯录"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    //导航栏左按钮
    UIButton *leftButton = [ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(leftButtonBtn:) Title:nil];
    [leftButton setImage:[UIImage imageNamed:@"店铺-店铺详情_03"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.view.backgroundColor = [UIColor whiteColor];
}
-(void)leftButtonBtn:(UIButton *)button
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
