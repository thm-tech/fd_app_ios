//
//  dataSettingViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/9.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "dataSettingViewController.h"

@interface dataSettingViewController () <UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
}
@end

@implementation dataSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUINa];
    [self createTableView];
    // Do any additional setup after loading the view.
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
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1 ;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        static NSString *cellID = @"cell";
        UITableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
            
            UISwitch *mySwitch3 = [[UISwitch alloc]initWithFrame:CGRectMake(0,0,0, 0)];
            mySwitch3.center = CGPointMake(SCREENWIDTH*0.85, SCREENHEIGHT*0.08*0.5);
            
            NSString *switchString = [[NSUserDefaults standardUserDefaults]objectForKey:DataSetting];
            NSLog(@"没改变之前设置的数据流量的值 = %@",switchString);
            mySwitch3.on = switchString.intValue;
            
            
            [mySwitch3 addTarget:self action:@selector(dealSwitch:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:mySwitch3];
            
        }
        //config cell
        //
        cell.textLabel.text = @"只在WiFi网络下加载图片";
    
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    
}
//switch的开关控件的点击处理事件
-(void)dealSwitch:(UISwitch *)s
{
    NSString *switchString = [NSString stringWithFormat:@"%d",s.on];
    NSLog(@"改变之后的设置的数据流量的值 = %@",switchString);
    [[NSUserDefaults standardUserDefaults]setObject:switchString forKey:DataSetting];
    [[NSUserDefaults standardUserDefaults]synchronize];
     [_tableView reloadData];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"www.baidu.com"]];
    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        //设置网络状态改变后执行的block
        
        //4种状态(未知,不可达,GPRS,WiFi)
        /*
         AFNetworkReachabilityStatusUnknown
         AFNetworkReachabilityStatusNotReachable
         AFNetworkReachabilityStatusReachableViaWWAN
         AFNetworkReachabilityStatusReachableViaWiFi
         */
        NSLog(@"当前网络状态为 %@",@[@"不可达",@"使用GPRS",@"使用WiFi"][status]);
        if([switchString isEqualToString:@"1"])
        {
            if(status == AFNetworkReachabilityStatusReachableViaWiFi)
            {
                [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:DataSetting2];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
            }
            else
            {
                [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:DataSetting2];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }
        }
        else
        {
            [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:DataSetting2];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
       
    }];
    
    //开始启动网络状态的监听
    [manager.reachabilityManager startMonitoring];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  SCREENHEIGHT*0.08;
}


-(void)createUINa
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"流量设置"];
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
