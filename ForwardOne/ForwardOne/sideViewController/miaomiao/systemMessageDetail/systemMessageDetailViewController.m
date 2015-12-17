//
//  systemMessageDetailViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/8/28.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "systemMessageDetailViewController.h"
#import "myAppDataBase.h"
#import "systemMessageDetailTableViewCell.h"

@interface systemMessageDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
}
@end

@implementation systemMessageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUINav];
    
    [self createTableView];
    
    //从数据库中取出数据
    [self loadData];
    
    // Do any additional setup after loading the view.
}
-(void)loadData
{
    _dataArray = [[NSMutableArray alloc]init];
    
    NSArray *array = [[myAppDataBase sharedInstance]getAllSystemRecordWithRecordType:RecoredTypeAttention];
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
    
    NSDictionary *dict = _dataArray [indexPath.section];
    [cell.webView loadHTMLString:dict[@"text"] baseURL:nil];
    
    return cell;
    
}

//设置各种高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREENHEIGHT*0.3;
}


-(void)createUINav
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"喵喵熊团队"];
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
