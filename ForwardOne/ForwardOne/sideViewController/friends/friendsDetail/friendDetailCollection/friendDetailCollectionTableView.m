//
//  friendDetailCollectionTableView.m
//  ForwardOne
//
//  Created by 杨波 on 15/7/7.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "friendDetailCollectionTableView.h"

#import "firendDetailSecondTableViewCell.h"

#import "danLiDataCenter.h"

#import "friendCollectionModel.h"

//分页查询好友收藏
#define FRIENDCOLLECTIONURL @"http://%@/user/friend/favorite?uid=%d&offset=%d&count=%d"


@interface friendDetailCollectionTableView ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    int offset;
    int count;
    NSMutableArray *_dataArray;
}
@end

@implementation friendDetailCollectionTableView
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self createTableView];
        
        [self downLoadFriendCollectionData];
    }
    return self;
}
#pragma mark-(下载数据)
-(void)downLoadFriendCollectionData
{
    danLiDataCenter *dc = [danLiDataCenter sharedInstance];
    
    _dataArray = [[NSMutableArray alloc]init];
    offset = 0;
    count = 100;
    NSString *urlString = [NSString stringWithFormat:FRIENDCOLLECTIONURL,DomainName,dc.frdIDString.intValue,offset,count];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //解析
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"好友收藏字典%@",dict);
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
            NSArray *array = dict[@"goodsList"];
            for(NSDictionary *collectionDict in array)
            {
                friendCollectionModel *model  =[[friendCollectionModel alloc]init];
                [model setValuesForKeysWithDictionary:collectionDict];
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
    firendDetailSecondTableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
    if(cell == nil)
    {
        cell = [[firendDetailSecondTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    //config cell
    friendCollectionModel *model = _dataArray[indexPath.row];
    [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.pic]];
    cell.describtionLabel.text = model.desc;
    cell.discountImageView.image = [UIImage imageNamed:@"iconfont-arrowthindown"];
    
    //好友收藏的商品的价格为实时查询 不用再去查询 已经为最新的价格
//    cell.originalPriceLabel.text = model.price;
//    cell.discounLabel.text = model.promot;
    NSLog(@"_____%@",model.promot);
    NSLog(@"%@",model.price);
    NSString *proNullString = [NSString stringWithFormat:@"%@",model.promot];
    NSString *priNullString = [NSString stringWithFormat:@"%@",model.price];
    //判断有没有促销价格
    if([proNullString isEqualToString:@"(null)"])
    {
        cell.discountImageView.hidden = YES;
        cell.lineImageView.hidden = YES;
        if(![priNullString isEqualToString:@"(null)"])
        {
        cell.discounLabel.text = model.price;
        }
        NSLog(@"hahhahahah");
    }
    else
    {
        cell.originalPriceLabel.text = model.price;
        cell.discounLabel.text = model.promot;

    }
    cell.sharedButton.hidden = YES;
    cell.collectionButton.hidden = YES;
    
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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //带上商品ID的参数
    friendCollectionModel *model = _dataArray[indexPath.row];
    
    //[self.YB_cellDelegate YBFriendDetailColletionCellDidClick:model.id];
    [self.YB_cellDelegate YBFriendDetailColletionCellDidClick:model.id andShopID:model.shop_id];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
