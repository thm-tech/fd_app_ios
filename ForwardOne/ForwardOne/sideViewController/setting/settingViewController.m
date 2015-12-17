//
//  settingViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/9.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "settingViewController.h"
#import "privacySettingViewController.h"
#import "messageSettingViewController.h"
#import "dataSettingViewController.h"

#import "aboutMiaomiaoXiongViewController.h"
#import "bufferSettingViewController.h"
#import "myAppDataBase.h"

#define LOGOUTURL @"http://%@/user/logout"


@interface settingViewController () <UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate>
{
    UITableView *_tableView;
    NSArray *_titleArray;
    NSArray *_imageArray;
    
    YBWebSocketManager *webSocketManager;
   
}
@end

@implementation settingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    __weak typeof(self) weakSelf = self;
//    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
//    {
//        self.navigationController.interactivePopGestureRecognizer.delegate = weakSelf;
//    }
    
    [self createUINA];
    [self createTableView];
    [self createDataArray];
    
    // Do any additional setup after loading the view.
}
-(void)createDataArray
{
    _titleArray = @[@[@"隐私设置",@"消息设置",@"流量设置",@"缓存设置"],@[@"邀请好友使用"],@[@"关于喵喵熊",@"退出登录"]];
    _imageArray = @[@[@"设置_031",@"设置_07",@"设置_11",@"设置_15"],@[@"设置_19"],@[@"设置_23",@"设置_26"]];
    [_tableView reloadData];
}

-(void)createTableView
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
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 4;
    }
    else if(section == 1)
    {
        return 1;
    }
    else
    {
        return 2;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    UITableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    //config cell
    cell.textLabel.text = _titleArray[indexPath.section][indexPath.row];
    cell.imageView.image = [UIImage imageNamed:_imageArray[indexPath.section][indexPath.row]];
    return cell;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  SCREENHEIGHT*0.08;
}

//cell上面的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *loginString = [[NSUserDefaults standardUserDefaults]objectForKey:IsLogin];
    if([loginString isEqualToString:@"login"])
    {
        
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            privacySettingViewController *psvc = [[privacySettingViewController alloc]init];
            [self.navigationController pushViewController:psvc animated:YES];
            
        }
        else if (indexPath.row == 1)
        {
            messageSettingViewController *msvc = [[messageSettingViewController alloc]init];
            [self.navigationController pushViewController:msvc animated:YES];
        }
        else if (indexPath.row == 2)
        {
            dataSettingViewController *dsvc = [[dataSettingViewController alloc]init];
            [self.navigationController pushViewController:dsvc animated:YES];
        }
        else
        {
            bufferSettingViewController *bsvc = [[bufferSettingViewController alloc]init];
            [self.navigationController pushViewController:bsvc animated:YES];
        }
    }
    else if (indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            UIActionSheet *sharedSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"微信",@"新浪微博",@"QQ好友",@"朋友圈",@"短信消息", nil];
            [sharedSheet showInView:self.view];
            
//            UIAlertController *al = [UIAlertController alertControllerWithTitle:@"haha" message:@"heihei" preferredStyle:UIAlertControllerStyleActionSheet];
//            [al addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
//            [self presentViewController:al animated:YES completion:nil];
            
        }
        
    }
    else
    {
        if(indexPath.row == 0)
        {
            aboutMiaomiaoXiongViewController *amxvc = [[aboutMiaomiaoXiongViewController alloc]init];
            [self.navigationController pushViewController:amxvc animated:YES];
        }
        else
        {
            UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"真的要退出吗？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            al.tag = 200;
            [al show];
        }
    }
    }
    else
    {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"您还没有登录，请先登录" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 200)
    {
    if(buttonIndex == 1)
    {
        //调用退出登录的协议 （同时清空NSUSerDefaults里面所有的值）
        //退出登录并不是app又第一次运行 （当清空NSUserDefaults里面所有值后 要重新存储当前版本号 用来避免退出登录后标志为app第一次运行）
        NSString *urlString = [NSString stringWithFormat:LOGOUTURL,DomainName];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        [manager POST:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSString *errString = dict[@"err"];
            if(errString.intValue == 0)
            {
                //关闭数据库
                [[myAppDataBase sharedInstance]closedDataBase];
                
                NSString *oldDataSetting = [[NSUserDefaults standardUserDefaults]objectForKey:DataSetting];
    
                //删除NSUserDefaults里面所有的数据
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSDictionary *userDict = [userDefaults dictionaryRepresentation];
                for(NSString *key in [userDict allKeys])
                {
                    [userDefaults removeObjectForKey:key];
                    [userDefaults synchronize];
                }
                
                //对于手机而言的数据流量的加载
                [[NSUserDefaults standardUserDefaults]setObject:oldDataSetting forKey:DataSetting];
                
                //判断是否app第一次启动
                NSString *key = (NSString *)kCFBundleVersionKey;
                //从Info.plist中取出版本号
                NSString *version = [NSBundle mainBundle].infoDictionary[key];
                
                [[NSUserDefaults standardUserDefaults]setObject:version forKey:key];
                
                //断开Socket连接
                webSocketManager = [YBWebSocketManager sharedInstance];
                [webSocketManager closedChatScoket];
                
                
                //删除所有数据之后 同时需要重新设置一些NSUserDefaults里面的值(例如判断程序是否第一次运行的值)
                
//                //提醒退出成功
//                UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"退出成功" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//                [al show];
                
                
                
                NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                [nc postNotificationName:@"changeLogout" object:nil userInfo:nil];
                
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
    }
    else
    {
        
    }
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 5)
    {
        return;
    }
}
-(void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for(UIView *subView in actionSheet.subviews)
    {
        if([subView isKindOfClass:[UIButton class]])
        {
            UIButton *button = (UIButton *)subView;
            [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        }
    }
}


-(void)createUINA
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"设置"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    //导航栏左按钮
    UIButton *imageLeftButton  =[ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(imageLeftItemBtn) Title:nil];
    [imageLeftButton setImage:[UIImage imageNamed:@"逛过_03"] forState:UIControlStateNormal];
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
