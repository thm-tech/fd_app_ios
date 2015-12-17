//
//  privacySettingViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/9.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "privacySettingViewController.h"

#define MYPRIVACYSETTINGURL @"http://%@/user/setting/private"


@interface privacySettingViewController () <UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    NSArray *_titleArray;
    NSDictionary *_settingDict;
    
    //post方法中各个设置的值
    NSString *_collectionPostString;
    NSString *_fansShopPostString;
    NSString *_lookedShopPostString;
}
@end

@implementation privacySettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUINa];
    
    [self createTableView];
    
    [self createDataArray];
    
    //下载个人隐私的数据
    NSString *string = [[NSUserDefaults standardUserDefaults]objectForKey:MyCollectionSetting];
    if(string.length == 0)
    {
    [self downloadMyPrivacySettingData];
    }
    // Do any additional setup after loading the view.
}
#pragma mark-(下载个人隐私的数据)
-(void)downloadMyPrivacySettingData
{
    NSString *urlString = [NSString stringWithFormat:MYPRIVACYSETTINGURL,DomainName];
    
    NSLog(@"个人信息的URL = %@",urlString);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"隐私结果的字典%@",dict);
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
            NSDictionary *settingDict = dict[@"setting"];
            _settingDict = [[NSDictionary alloc]init];
            _settingDict = settingDict;
            
            //刷新
            [_tableView reloadData];
            [_tableView reloadInputViews];
        }
       
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"err = %@",error);
    }];
}


-(void)createDataArray
{
    _titleArray = @[@"好友可以查看我的收藏",@"好友可以查看我的粉店",@"好友可以查看我的逛店记录"];
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
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
    static NSString *cellID = @"cell";
    UITableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        
        UISwitch *mySwitch1 = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0,0, 0)];
        mySwitch1.center = CGPointMake(SCREENWIDTH*0.85, SCREENHEIGHT*0.08*0.5);
        mySwitch1.tag = 100;
        
        NSString *nsuserdefaultSettingString = [[NSUserDefaults standardUserDefaults]objectForKey:MyCollectionSetting];
        NSString *settingString  =[[NSString alloc]init];
        if(nsuserdefaultSettingString.length != 0)
        {
           settingString = nsuserdefaultSettingString;
        }
        else
        {
           settingString = _settingDict[@"favoriteEnable"];

        }
        mySwitch1.on = settingString.intValue;
        [mySwitch1 addTarget:self action:@selector(dealSwitch:) forControlEvents:UIControlEventValueChanged];
        
        [cell.contentView addSubview:mySwitch1];
        
    }
    //config cell
    cell.textLabel.text = _titleArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    }
    else if (indexPath.row == 1)
    {
        static NSString *cellID = @"cell";
        UITableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
            
            UISwitch *mySwitch2 = [[UISwitch alloc]initWithFrame:CGRectMake(0,0,0, 0)];
            mySwitch2.center = CGPointMake(SCREENWIDTH*0.85, SCREENHEIGHT*0.08*0.5);
            mySwitch2.tag = 200;
            
            NSString *nsuserdefaultSettingString = [[NSUserDefaults standardUserDefaults]objectForKey:MyFansShopSetting];
            NSString *settingString  =[[NSString alloc]init];
            if(nsuserdefaultSettingString.length != 0)
            {
                settingString = nsuserdefaultSettingString;
            }
            else
            {
                settingString = _settingDict[@"fansEnable"];
                
            }

        
            mySwitch2.on = settingString.intValue;
            [mySwitch2 addTarget:self action:@selector(dealSwitch:) forControlEvents:UIControlEventValueChanged];
            
            [cell.contentView addSubview:mySwitch2];
            
        }
        //config cell
        cell.textLabel.text = _titleArray[indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;

    }
    else
    {
        static NSString *cellID = @"cell";
        UITableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
            
            UISwitch *mySwitch3 = [[UISwitch alloc]initWithFrame:CGRectMake(0,0,0, 0)];
            mySwitch3.center = CGPointMake(SCREENWIDTH*0.85, SCREENHEIGHT*0.08*0.5);
            mySwitch3.tag = 300;
            
            NSString *nsuserdefaultSettingString = [[NSUserDefaults standardUserDefaults]objectForKey:MyLookedShopSetting];
            NSString *settingString  =[[NSString alloc]init];
            if(nsuserdefaultSettingString.length != 0)
            {
                settingString = nsuserdefaultSettingString;
            }
            else
            {
                settingString = _settingDict[@"visitEnable"];
                
            }
            mySwitch3.on = settingString.intValue;
            [mySwitch3 addTarget:self action:@selector(dealSwitch:) forControlEvents:UIControlEventValueChanged];
            
            [cell.contentView addSubview:mySwitch3];
            
        }
        //config cell
        cell.textLabel.text = _titleArray[indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;

    }
}
//switch的开关控件的点击处理事件
-(void)dealSwitch:(UISwitch *)s
{
    _collectionPostString = [[NSString alloc]init];
    _fansShopPostString  =[[NSString alloc]init];
    _lookedShopPostString = [[NSString alloc]init];
    
    
    if(s.tag == 100)
    {
        _collectionPostString = [NSString stringWithFormat:@"%d",s.on];
        
        [[NSUserDefaults standardUserDefaults]setObject:_collectionPostString forKey:MyCollectionSetting];
         [[NSUserDefaults standardUserDefaults]synchronize];
    }
    else if (s.tag == 200)
    {
        _fansShopPostString = [NSString stringWithFormat:@"%d",s.on];
        
         [[NSUserDefaults standardUserDefaults]setObject:_fansShopPostString forKey:MyFansShopSetting];
         [[NSUserDefaults standardUserDefaults]synchronize];
    }
    else
    {
        _lookedShopPostString = [NSString stringWithFormat:@"%d",s.on];
    
        [[NSUserDefaults standardUserDefaults]setObject:_lookedShopPostString forKey:MyLookedShopSetting];
         [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    NSString *urlString = [NSString stringWithFormat:MYPRIVACYSETTINGURL,DomainName];
    
    NSString *collection = [[NSUserDefaults standardUserDefaults]objectForKey:MyCollectionSetting];
    NSString *fansShop = [[NSUserDefaults standardUserDefaults]objectForKey:MyFansShopSetting];
    NSString *looked = [[NSUserDefaults standardUserDefaults]objectForKey:MyLookedShopSetting];
    
    if(collection.length == 0)
    {
        collection = [NSString stringWithFormat:@"0"];
    }
    if(fansShop.length == 0)
    {
        fansShop = [NSString stringWithFormat:@"0"];
    }
    if(looked.length == 0)
    {
        looked = [NSString stringWithFormat:@"0"];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:urlString parameters:@{@"favoriteEnable":collection,@"fansEnable":fansShop,@"visitEnable":looked} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"隐私提交的字典%@",dict);
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];

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
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"隐私设置"];
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
    
    //返回前  post自己的隐私设置
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
