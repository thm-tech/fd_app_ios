//
//  inShopFansViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/9/30.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "inShopFansViewController.h"

#import "OpenUDID.h"

#import "myAppDataBase.h"
#import "fansShopDataBaseModel.h"

//粉丝店信息URL
#define  FANSHOPINFORMATIONURL @"http://%@/user/fans/info?"

//本地存储的粉丝店与后台的差异
#define SHOPIDDFIFFERURL @"http://%@/user/fans/diff"

//退出商店的URL
#define EXISTSHOPURL @"http://%@/user/shop/exit?sid=%d"

@interface inShopFansViewController () <UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
    
    NSMutableArray *_activityArray;
    
    //处理完本地与后台差异之后的shopID数组
    NSMutableArray *_finalShopIDArray;
    
    myAppDataBase *dc;
}
@end

@implementation inShopFansViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUINav];
    
    //先判断有没有登录
    NSString *loginString = [[NSUserDefaults standardUserDefaults]objectForKey:IsLogin];
    if([loginString isEqualToString:@"login"])
    {
        
        dc = [myAppDataBase sharedInstance];
        
        //判断两次的设备是否一致 (与是否登录没有关系)
        NSString *lastUserDevice = [[NSUserDefaults standardUserDefaults]objectForKey:UserDevice];
        NSString *nowUserDevice = [OpenUDID value];
        if([lastUserDevice isEqualToString:nowUserDevice])
        {
            //两次设备相同 从本地数据库中取数据
            NSArray *array = [dc getFansShopRecordWithRecordType:RecoredTypeAttention];
            NSMutableArray *finalArray = [[NSMutableArray alloc]init];
            for(long i = array.count-1;i>=0;i--)
            {
                [finalArray addObject:array[i]];
            }
            
            _dataArray = [[NSMutableArray alloc]initWithArray:finalArray];
            if(_dataArray.count != 0)
            {
                [self createTableView];
                
                NSLog(@"粉丝店中数据库的数据%@",_dataArray);
                
                [_tableView reloadData];
            }
            else
            {
                UILabel *label = [ZCControl createLabelWithFrame:CGRectMake(0, SCREENHEIGHT*0.2, SCREENWIDTH, SCREENHEIGHT*0.1) Font:SCREENWIDTH*0.048 Text:@"你还没有任何粉丝店哟，请先关注商店吧"];
                label.textAlignment = NSTextAlignmentCenter;
                [self.view addSubview:label];
            }
        }
        else
        {
            NSString *isTogetherFansShopString = [[NSUserDefaults standardUserDefaults]objectForKey:IsTogetherFansShop];
            if([isTogetherFansShopString isEqualToString:@"1"])
            {
                NSArray *array = [dc getFansShopRecordWithRecordType:RecoredTypeAttention];
                NSMutableArray *finalArray = [[NSMutableArray alloc]init];
                for(long i = array.count-1;i>=0;i--)
                {
                    [finalArray addObject:array[i]];
                }
                
                _dataArray = [[NSMutableArray alloc]initWithArray:finalArray];
                if(_dataArray.count != 0)
                {
                    [self createTableView];
                    
                    NSLog(@"粉丝店中数据库的数据%@",_dataArray);
                    
                    [_tableView reloadData];
                }
                else
                {
                    UILabel *label = [ZCControl createLabelWithFrame:CGRectMake(0, SCREENHEIGHT*0.2, SCREENWIDTH, SCREENHEIGHT*0.1) Font:SCREENWIDTH*0.048 Text:@"你还没有任何粉丝店哟，请先关注商店吧"];
                    label.textAlignment = NSTextAlignmentCenter;
                    [self.view addSubview:label];
                }
                
            }
            else
            {
                //两次设备不同 从后台取数据
        
                
                [self downloadShopIDDataFromNet];
                
                [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:IsTogetherFansShop];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }
            //        //比较差异一次之后 更改存储的手机的UDID (只比较差异一次)
            //        [[NSUserDefaults standardUserDefaults]setObject:nowUserDevice forKey:UserDevice];
            //        [[NSUserDefaults standardUserDefaults]synchronize];
            
        }
        
        //下载是否有新活动以及新品的数据
        //[self downLoadNewData];
       
    }
    else
    {
        UILabel *label = [ZCControl createLabelWithFrame:CGRectMake(0, SCREENHEIGHT*0.2, SCREENWIDTH, SCREENHEIGHT*0.1) Font:SCREENWIDTH*0.048 Text:@"你还没登录，请先登录"];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
    }
    
    // Do any additional setup after loading the view.
}
//-(void)loadData
//{
//    dc = [myAppDataBase sharedInstance];
//    
//    //判断两次的设备是否一致 (与是否登录没有关系)
//    NSString *lastUserDevice = [[NSUserDefaults standardUserDefaults]objectForKey:UserDevice];
//    NSString *nowUserDevice = [OpenUDID value];
//    if([lastUserDevice isEqualToString:nowUserDevice])
//    {
//        //两次设备相同 从本地数据库中取数据
//        NSArray *array = [dc getFansShopRecordWithRecordType:RecoredTypeAttention];
//        NSMutableArray *finalArray = [[NSMutableArray alloc]init];
//        for(long i = array.count-1;i>=0;i--)
//        {
//            [finalArray addObject:array[i]];
//        }
//        
//        _dataArray = [[NSMutableArray alloc]initWithArray:finalArray];
//        //[_tableView reloadData];
//    }
//    else
//    {
//        //两次设备不同 从后台取数据
//        [self downloadShopIDDataFromNet];
//        
//    }
//
//}

#pragma mark-(两次设备不同 从后台取数据shopID)
-(void)downloadShopIDDataFromNet
{
    
    //先得到本地存储的shopID列表
    NSArray *array = [dc getFansShopRecordWithRecordType:RecoredTypeAttention];
    NSMutableArray *shopIDArray = [[NSMutableArray alloc]init];
    for(int i = 0;i<array.count;i++)
    {
        fansShopDataBaseModel *model = array[i];
        [shopIDArray addObject:model.id];
    }
    
    NSString *urlString = [NSString stringWithFormat:SHOPIDDFIFFERURL,DomainName];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:urlString parameters:@{@"shopIDs":shopIDArray} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
            //需要增加的ID数组
            NSArray *addShopArray = dict[@"addShopIDs"];
            _finalShopIDArray = [[NSMutableArray alloc]initWithArray:addShopArray];
            
            
            NSArray *deleteShopArray = dict[@"delShopIDs"];
            //进行数据库的操作删除应该删除的数据
            
            NSLog(@"增加的数组 = %d",addShopArray.count);
            NSLog(@"删除的数组 = %d",deleteShopArray.count);
            
            
            for(int i = 0;i<deleteShopArray.count;i++)
            {
                NSDictionary *delectDict = @{@"id":deleteShopArray[i]};
                [dc deleteFansShopRecordWithDicitionary:delectDict recordType:RecoredTypeAttention];
            }
            if(addShopArray.count == 0&&deleteShopArray.count == 0)
            {
                UILabel *label = [ZCControl createLabelWithFrame:CGRectMake(0, SCREENHEIGHT*0.2, SCREENWIDTH, SCREENHEIGHT*0.1) Font:SCREENWIDTH*0.048 Text:@"你还没有任何粉丝店哟，请先关注商店吧"];
                label.textAlignment = NSTextAlignmentCenter;
                [self.view addSubview:label];

            }
            else
            {
                //得到比较差异之后的shopID数组之后
                [self downloadShopInformationData];
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"err = %@",error);
        
    }];
    
}
#pragma mark-(下载粉丝店信息)
-(void)downloadShopInformationData
{
    NSString *shopIDString = [[NSString alloc]init];
    NSString *string = [NSString stringWithFormat:FANSHOPINFORMATIONURL,DomainName];
    
    for(int i = 0;i<_finalShopIDArray.count;i++)
    {
        if(i == _finalShopIDArray.count-1)
        {
            shopIDString = [NSString stringWithFormat:@"sid=%@",_finalShopIDArray[i]];
        }
        else
        {
            shopIDString = [NSString stringWithFormat:@"sid=%@&",_finalShopIDArray[i]];
        }
        string = [string stringByAppendingString:shopIDString];
    }
    
    //下载数据
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:string parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //解析数据
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
            NSArray *array = dict[@"shopList"];
            for(NSDictionary *shopDict in array)
            {
                //数据库中添加记录
                [dc addFansShopRecordWithDicitionary:shopDict recordType:RecoredTypeAttention];
                
            }
            
            //在数据库中添加记录之后 获取所有的记录
            NSArray *finalArray = [dc getFansShopRecordWithRecordType:RecoredTypeAttention];
            _dataArray = [[NSMutableArray alloc]init];
            for(long i = finalArray.count-1;i>=0;i--)
            {
                [_dataArray addObject:finalArray[i]];
            }
            
            if(_dataArray.count != 0)
            {
                NSLog(@"粉丝店中数据库的数据%@",_dataArray);
                [self createTableView];
                //[self downLoadNewData];
                
                [_tableView reloadData];
            }
            else
            {
                UILabel *label = [ZCControl createLabelWithFrame:CGRectMake(0, SCREENHEIGHT*0.2, SCREENWIDTH, SCREENHEIGHT*0.1) Font:SCREENWIDTH*0.048 Text:@"你还没有任何粉丝店哟，请先关注商店吧"];
                label.textAlignment = NSTextAlignmentCenter;
                [self.view addSubview:label];
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}


-(void)createTableView
{
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-64) style:UITableViewStylePlain];
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


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    UITableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    //config cell
    fansShopDataBaseModel *model = _dataArray[indexPath.row];
    cell.textLabel.text = model.name;
    cell.textLabel.textColor = [UIColor colorWithHexStr:@"#333333"];
    return cell;
}

#pragma mark-(设置各种高度)

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREENHEIGHT*0.1;
}

#pragma mark-(cell上面的点击事件)
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    fansShopDataBaseModel *model = _dataArray[indexPath.row];
    [self.YB_delegate YBInshopFansTableViewCellDidClickWithShopName:model.name andShopPic:model.pic andShopID:model.id];
    [self.navigationController popViewControllerAnimated:YES];
    
    //退出之前的商店
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


-(void)createUINav
{
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"关注的店"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    //导航栏左按钮
    UIButton *leftButton = [ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(leftButtonBtn:) Title:nil    ];
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
