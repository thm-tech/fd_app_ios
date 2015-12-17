//
//  inShopMyFansShopAndLookedSecondTableView.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/14.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "inShopMyFansShopAndLookedSecondTableView.h"

#import "OpenUDID.h"

#import "myAppDataBase.h"
#import "fansShopDataBaseModel.h"

//粉丝店信息URL
#define  FANSHOPINFORMATIONURL @"http://%@/user/fans/info?"

//本地存储的粉丝店与后台的差异
#define SHOPIDDFIFFERURL @"http://%@/user/fans/diff"

@interface inShopMyFansShopAndLookedSecondTableView ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
    
    NSMutableArray *_activityArray;
    
    //处理完本地与后台差异之后的shopID数组
    NSMutableArray *_finalShopIDArray;
    
    myAppDataBase *dc;
}
@end

@implementation inShopMyFansShopAndLookedSecondTableView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self createTableView];
        [self loadData];
        
    }
    return self;
}
-(void)loadData
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
        //[_tableView reloadData];
    }
    else
    {
        //两次设备不同 从后台取数据
        [self downloadShopIDDataFromNet];
        
    }
}

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
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
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
            for(int i = 0;i<deleteShopArray.count;i++)
            {
                NSDictionary *delectDict = @{@"id":deleteShopArray[i]};
                [dc deleteFansShopRecordWithDicitionary:delectDict recordType:RecoredTypeAttention];
                
            }
            
            //得到比较差异之后的shopID数组之后
            [self downloadShopInformationData];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
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
            _dataArray = [[NSMutableArray alloc]initWithArray:finalArray];
            [_tableView reloadData];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}


-(void)createTableView
{
    
    _tableView = [[UITableView alloc]initWithFrame:self.bounds style:UITableViewStylePlain];
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
    
    
    [self addSubview:_tableView];
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
    [self.YB_cellDelegate YBInShopMyFansShopAndLookedSecondTableViewDidSelected:model];
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
