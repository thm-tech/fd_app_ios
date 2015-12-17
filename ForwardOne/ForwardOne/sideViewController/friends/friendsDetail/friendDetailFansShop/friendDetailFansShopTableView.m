//
//  friendDetailFansShopTableView.m
//  ForwardOne
//
//  Created by 杨波 on 15/7/7.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "friendDetailFansShopTableView.h"

#import "firendDetailThirdTableViewCell.h"

#import "danLiDataCenter.h"

#import "friendFansShopModel.h"

//好友粉丝店
#define FRIENDFANSSHOPURL @"http://%@/user/friend/fans?uid=%d&offset=%d&count=%d"

@interface friendDetailFansShopTableView () <UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    int offset;
    int count;
    NSMutableArray *_dataArray;
}
@end

@implementation friendDetailFansShopTableView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self createTableView];
        
        [self downLoadFriendFansShopData];
    }
    return self;
}
#pragma mark-(好友粉丝店数据)
-(void)downLoadFriendFansShopData
{
    danLiDataCenter *dc = [danLiDataCenter sharedInstance];
    _dataArray = [[NSMutableArray alloc]init];
    offset = 0;
    count = 100;
    NSString *urlString = [NSString stringWithFormat:FRIENDFANSSHOPURL,DomainName,dc.frdIDString.intValue,offset,count];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"好友粉丝店字典%@",dict);
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
            NSArray *array = dict[@"shopList"];
            for(NSDictionary *shopDict in array)
            {
                friendFansShopModel *model = [[friendFansShopModel alloc]init];
                [model setValuesForKeysWithDictionary:shopDict];
                [_dataArray addObject:model];
            }
            //刷新tableView
            [_tableView reloadData];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"err = %@",error);
    }];
}

-(void)createTableView
{
    _tableView = [[UITableView alloc]initWithFrame:self.bounds style:UITableViewStyleGrouped];
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

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
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
    friendFansShopModel *model = _dataArray[indexPath.row];
    [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.pic]];
    cell.shopNameLabel.text = model.name;
    
    NSString *hasActString = [NSString stringWithFormat:@"%@",model.hasAct];
    NSString *hasNewString = [NSString stringWithFormat:@"%@",model.hasNew];
    //判断是否有活动以及新品上市
    if([hasActString isEqualToString:@"1"])
    {
        if([hasNewString isEqualToString:@"1"])
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
        if([hasNewString isEqualToString:@"1"])
        {
            cell.activityImageView.image = [UIImage imageNamed:@"逛过_07-03"];
            cell.activityNewLabel.text = @"新品上架";
        }
        else
        {
            
        }
    }
    cell.attenButton.hidden = YES;
    
    return cell;
    
    
}

#pragma mark-(设置各种高度）
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREENHEIGHT*0.15;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}
//cell上面的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    friendFansShopModel *model = _dataArray[indexPath.row];
    
    [self.YB_cellDelegate YBFriendDetailFansShopTableViewCellDidClick:model.id ansShopName:model.name andShopPic:model.pic];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
