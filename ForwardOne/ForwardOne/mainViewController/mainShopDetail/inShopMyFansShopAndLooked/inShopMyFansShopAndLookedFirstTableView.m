//
//  inShopMyFansShopAndLookedFirstTableView.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/14.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "inShopMyFansShopAndLookedFirstTableView.h"


#import "myAppDataBase.h"

@interface inShopMyFansShopAndLookedFirstTableView  ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
    
    myAppDataBase *dc;
}
@end

@implementation inShopMyFansShopAndLookedFirstTableView

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
    //从数据库中读取  我逛过的商店的数据只本地保存  读取数据也只从本地读取
    dc = [myAppDataBase sharedInstance];
    _dataArray = [[NSMutableArray alloc]init];
    NSArray *array = [dc getVisitShopRecordWithRecordTyepe:RecoredTypeAttention];
    for(long i = array.count-1;i>=0;i--)
    {
        [_dataArray addObject:array[i]];
    }
    [_tableView reloadData];
    
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
    myLookedShopModel *model = _dataArray[indexPath.row];
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
   
    myLookedShopModel *model = _dataArray[indexPath.row];
    
    [self.YB_cellDelegate YBInShopMyFansShopAndLookedFirstTableViewCellDidSelected:model];
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
