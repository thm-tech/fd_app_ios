//
//  friendDetailLookedShopTableView.m
//  ForwardOne
//
//  Created by 杨波 on 15/7/7.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "friendDetailLookedShopTableView.h"
#import "firendDetailForthTableViewCell.h"

#import "friendLookedShopModel.h"

#import "danLiDataCenter.h"

//好友逛过
#define FRIENDLOOKEDSHOPURL @"http://%@/user/friend/visit?uid=%d&offset=%d&count=%d"


@interface friendDetailLookedShopTableView () <UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;

    NSMutableArray *_dataArray;
    int offect;
    int count;
    
}
@end

@implementation friendDetailLookedShopTableView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self createTableView];
        
        [self downLoadFriendLookedShopData];
    }
    return self;
}
#pragma mark-(好友逛过)
-(void)downLoadFriendLookedShopData
{
    danLiDataCenter *dc = [danLiDataCenter sharedInstance];
    _dataArray = [[NSMutableArray alloc]init];
    offect = 0;
    count = 100;
    NSString *urlString = [NSString stringWithFormat:FRIENDLOOKEDSHOPURL,DomainName,dc.frdIDString.intValue,offect,count];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"好友逛过的数组%@",dict);
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
            NSArray *array = dict[@"shopList"];
            for(NSDictionary *lookedDict in array)
            {
                friendLookedShopModel *model = [[friendLookedShopModel alloc]init];
                [model setValuesForKeysWithDictionary:lookedDict];
                [_dataArray addObject:model];
            }
            
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
    firendDetailForthTableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
    if(cell == nil)
    {
        cell = [[firendDetailForthTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    //config cell
    friendLookedShopModel *model = _dataArray[indexPath.row];
    [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.pic]];
    cell.shopNameLabel.text = model.name;
    cell.dateLabel.text = model.time;
    
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
//cell上面的点击
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    friendLookedShopModel *model = _dataArray[indexPath.row];
    
    [self.YB_cellDelegate YBFriendDetailLookedShopTableViewCellDidClick:model.id andShopName:model.name andShopPic:model.pic];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
