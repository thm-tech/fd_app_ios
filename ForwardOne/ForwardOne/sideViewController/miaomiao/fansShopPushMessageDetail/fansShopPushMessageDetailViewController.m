//
//  fansShopPushMessageDetailViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/8/28.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "fansShopPushMessageDetailViewController.h"
#import "myAppDataBase.h"
#include "systemMessageDetailTableViewCell.h"
#import "fansShopDataBaseModel.h"


@interface fansShopPushMessageDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
}
@end

@implementation fansShopPushMessageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUINavi];
    
    [self createTableView];
    
    [self loadDataBaseData];
    // Do any additional setup after loading the view.
}
//从数据库中取出数据
-(void)loadDataBaseData
{
    _dataArray = [[NSMutableArray alloc]init];
    
    NSNumber  *shopID = [[NSNumber alloc]initWithInt:self.shopIDString.intValue];;
    
   NSArray *array = [[myAppDataBase sharedInstance]getShopPushAllRecordWithShopID:shopID];
    
    for(long i = array.count-1;i>=0;i--)
    {
        [_dataArray addObject:array[i]];
    }
    
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
    return _dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    systemMessageDetailTableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
    if(cell == nil)
    {
        cell = [[systemMessageDetailTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    //config cell
    NSDictionary *dict = _dataArray[indexPath.section];
    [cell.webView loadHTMLString:dict[@"text"] baseURL:nil];
    
    NSLog(@"商店推送的具体消息 = %@",dict[@"text"]);
    
    cell.webView.backgroundColor = [UIColor whiteColor];
    
    return cell;
    
}

//设置各种高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREENHEIGHT*0.7;
}


-(void)createUINavi
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSNumber  *shopID = [[NSNumber alloc]initWithInt:self.shopIDString.intValue];;
    NSArray *shopInformationArray = [[myAppDataBase sharedInstance]getOneFansShopRecordWith:shopID];
    fansShopDataBaseModel *model = shopInformationArray[0];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:model.name];
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
