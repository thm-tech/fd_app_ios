//
//  myFansShopViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/9.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "myFansShopViewController.h"
#import "firendDetailThirdTableViewCell.h"
//#import "fansShopDetailViewController.h"
#import "mainShopDetailViewController.h"
#import "OpenUDID.h"

#import "myAppDataBase.h"
#import "fansShopDataBaseModel.h"

#import "myFansShopNeNewActivityModel.h"


//是否有新活动以及新品的URL
#define FANSSHOPNEWACTIVITYANDNEWGOODSURL @"http://%@/user/fans/news?"

//粉丝店信息URL
#define  FANSHOPINFORMATIONURL @"http://%@/user/fans/info?"

//本地存储的粉丝店与后台的差异
#define SHOPIDDFIFFERURL @"http://%@/user/fans/diff"

//关注商店URL
#define SHOPATTENTIONURL @"http://%@/user/shop/concern?sid=%d"

@interface myFansShopViewController () <UITableViewDelegate,UITableViewDataSource,YBMyFanShopFansButtonDelegate,YBShopDetailChangeGroupNameDelegate,UIGestureRecognizerDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
    
    NSMutableArray *_activityArray;
    
    //处理完本地与后台差异之后的shopID数组
    NSMutableArray *_finalShopIDArray;
    
    myAppDataBase *dc;
    
}
@end

@implementation myFansShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    __weak typeof(self) weakSelf = self;
//    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
//    {
//        self.navigationController.interactivePopGestureRecognizer.delegate = weakSelf;
//    }
    
    [self createUINa];

    //先判断有没有登录
    NSString *loginString = [[NSUserDefaults standardUserDefaults]objectForKey:IsLogin];
    if([loginString isEqualToString:@"login"])
    {
         [self createTableView];
        
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
    [self downLoadNewData];
    }
    else
    {
        UILabel *label = [ZCControl createLabelWithFrame:CGRectMake(0, SCREENHEIGHT*0.2, SCREENWIDTH, SCREENHEIGHT*0.1) Font:SCREENWIDTH*0.048 Text:@"你还没登录，请先登录"];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
    }
    // Do any additional setup after loading the view.
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
                
                [self downLoadNewData];
                
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



#pragma mark-(下载店内新品上架以及新活动数据)
-(void)downLoadNewData
{
    _activityArray = [[NSMutableArray alloc]init];
    
    NSString *shopIDString = [[NSString alloc]init];
     NSString *string = [NSString stringWithFormat:FANSSHOPNEWACTIVITYANDNEWGOODSURL,DomainName];
    for(int i = 0;i<_dataArray.count;i++)
    {
        fansShopDataBaseModel *model = _dataArray[i];
        
        if(i == _dataArray.count-1)
        {
            shopIDString = [NSString stringWithFormat:@"sid=%d",model.id.intValue];
        }
        else
        {
       shopIDString = [NSString stringWithFormat:@"sid=%d&",model.id.intValue];
        }
        
            string = [string stringByAppendingString:shopIDString];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:string parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
            NSArray *array = dict[@"shopList"];
            NSLog(@"店活动数组%@",array);
            
            for(NSDictionary *newDict in array)
            {
                myFansShopNeNewActivityModel *model  =[[myFansShopNeNewActivityModel alloc]init];
                [model setValuesForKeysWithDictionary:newDict];
                [_activityArray addObject:model];
            }
            //刷新
            [_tableView reloadData];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    
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
    return _dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    firendDetailThirdTableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
    if(cell == nil)
    {
        cell = [[firendDetailThirdTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    //config cell
    cell.YBCell_delegate = self;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    fansShopDataBaseModel *model = _dataArray[indexPath.section];
    
    NSNumber *widthNumber = [[NSNumber alloc]initWithLong:(long)(SCREENWIDTH*0.3)];
    NSNumber *heightNumber = [[NSNumber alloc]initWithLong:(long)(SCREENHEIGHT*0.15*0.9)];
    
    [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@@%@w_%@h_1e_0l_1c",model.pic,widthNumber,heightNumber]]];
    cell.shopNameLabel.text = model.name;
    
    //店内新品以及活动的数据
    if(_activityArray.count != 0)
    {
    myFansShopNeNewActivityModel *activityAndNewGoodsModel = _activityArray[indexPath.section];
    if(activityAndNewGoodsModel.hasAct.intValue ==1)
    {
        if(activityAndNewGoodsModel.hasNew.intValue == 1)
        {
            cell.activityNewLabel.text = @"有新活动";
            cell.shopNewLabel.text = @"新品上架";
            cell.activityImageView.image = [UIImage imageNamed:@"逛过_07-04"];
            cell.shopNewImageView.image = [UIImage imageNamed:@"逛过_07-03"];
        }
        else
        {
            cell.activityNewLabel.text = @"有新活动";
            cell.activityImageView.image = [UIImage imageNamed:@"逛过_07-04"];
        }
    }
    else
    {
        if(activityAndNewGoodsModel.hasNew.intValue == 1)
        {
            cell.activityImageView.image = [UIImage imageNamed:@"逛过_07-03"];
            cell.activityNewLabel.text = @"新品上架";
        }
        else
        {
            
        }
        
    }
        
//    if(activityAndNewGoodsModel.hasNew.intValue == 1)
//    {
//        cell.shopNewLabel.text = @"新品上架";
//    }
    }
    return cell;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  SCREENHEIGHT*0.15;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return SCREENHEIGHT*0.01;
}

//cell上面的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    mainShopDetailViewController *mvc = [[mainShopDetailViewController alloc]init];
    //进行传递参数
    fansShopDataBaseModel *model = _dataArray[indexPath.section];
    mvc.shopNamestrting = model.name;
    mvc.shopIDString = model.id;
    mvc.shopPic = model.pic;
    mvc.gnameString = self.gnameString;
    mvc.invitationLabelString = self.invitationLabelString;
    mvc.YB_ShopDetailChangeDelegate = self;
    
    [self.navigationController pushViewController:mvc animated:YES];
    
}

//商店详情商品界面的聊天的反向传值
-(void)YBShopDetailChangeGroupGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    [self.YB_delegate YBMyFanShopChatChangeGnameWithGname:gname andGroupName:groupName];
}

//cell上面按钮的点击的协议
-(void)YBMyFanShopFansButtonDidClick:(UIButton *)button
{
    firendDetailThirdTableViewCell *cell = (firendDetailThirdTableViewCell *)[[button superview] superview];
    NSIndexPath *path = [_tableView indexPathForCell:cell];
    
    fansShopDataBaseModel *model = _dataArray[path.section];
    NSString *urlString = [NSString stringWithFormat:SHOPATTENTIONURL,DomainName,model.id.intValue];
    //NSLog(@"后台通讯%@",urlString);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    
    NSMutableDictionary *addToBasedict = [[NSMutableDictionary alloc]init];
    [addToBasedict setObject:model.id forKey:@"id"];
    [addToBasedict setObject:model.name forKey:@"name"];
    [addToBasedict setObject:model.pic forKey:@"pic"];
    [addToBasedict setObject:model.msgEnable forKey:@"msgEnable"];
    [addToBasedict setObject:model.time forKey:@"time"];
    //不存在则增加收藏
    if([dc isExistFansShopRecordWithDicitionary:addToBasedict recordType:RecoredTypeAttention] == NO)
    {
        //与后台通信
        [manager POST:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //当post成功之后 改变button的image
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSString *errString = dict[@"err"];
            if(errString.intValue == 0)
            {
                [button setImage:[UIImage imageNamed:@"逛过_07"] forState:UIControlStateNormal];
                [dc addFansShopRecordWithDicitionary:addToBasedict recordType:RecoredTypeAttention];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"err1 = %@",error);
            
        }];
        
    }
    //删除收藏
    else
    {
        //删除收藏
        [manager DELETE:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //当delete成功之后 改变button的状态
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSString *errString = dict[@"err"];
            if(errString.intValue == 0)
            {
                [button setImage:[UIImage imageNamed:@"逛过_071"] forState:UIControlStateNormal];
                [dc deleteFansShopRecordWithDicitionary:addToBasedict recordType:RecoredTypeAttention];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];

    }
    
}

-(void)createUINa
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"粉店"];
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
