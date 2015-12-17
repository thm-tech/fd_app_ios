//
//  myLookedShopViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/9.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "myLookedShopViewController.h"
#import "firendDetailForthTableViewCell.h"
//#import "fansShopDetailViewController.h"
#import "mainShopDetailViewController.h"

#import "myLookedShopModel.h"
#import "myAppDataBase.h"


@interface myLookedShopViewController () <UITableViewDelegate,UITableViewDataSource,YBShopDetailChangeGroupNameDelegate,UIGestureRecognizerDelegate>

{
    UITableView *_tableView;
    
    NSMutableArray *_dataArray;
    
    myAppDataBase *dc;
    
}

@end

@implementation myLookedShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    __weak typeof(self) weakSelf = self;
//    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
//    {
//        self.navigationController.interactivePopGestureRecognizer.delegate = weakSelf;
//    }
    
    [self createUINav];
    
    //从数据库中读取  我逛过的商店的数据只本地保存  读取数据也只从本地读取
    dc = [myAppDataBase sharedInstance];
    NSArray *array = [dc getVisitShopRecordWithRecordTyepe:RecoredTypeAttention];
    if(array.count != 0)
    {
        [self createTableView];
        
        [self downLoadMyLookedShopData];
    }
    else
    {
        UILabel *label = [ZCControl createLabelWithFrame:CGRectMake(0, SCREENHEIGHT*0.2, SCREENWIDTH, SCREENHEIGHT*0.1) Font:SCREENWIDTH*0.048 Text:@"你还没有逛过任何商店，请和朋友一起先去逛逛吧"];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
    }
    
    
    // Do any additional setup after loading the view.
}
//-(void)viewWillAppear:(BOOL)animated
//{
//    [self downLoadMyLookedShopData];
//}

-(void)downLoadMyLookedShopData
{
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
    firendDetailForthTableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
    if(cell == nil)
    {
        cell = [[firendDetailForthTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    //config cell
    myLookedShopModel *model = _dataArray[indexPath.section];
    [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.shopPic]];
    cell.shopNameLabel.text = model.name;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:model.time.intValue+8*60*60];
    NSString *dateString = [NSString stringWithFormat:@"%@",date];
    
    cell.dateLabel.text =[dateString substringToIndex:20];
    
    return cell;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}
//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 20.0f;
//}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  SCREENHEIGHT*0.15;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return SCREENHEIGHT*0.01;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    mainShopDetailViewController *mvc = [[mainShopDetailViewController alloc]init];
    myLookedShopModel *model = _dataArray[indexPath.section];
    //传递参数
    mvc.shopIDString = model.id;
    mvc.shopNamestrting = model.name;
    mvc.shopPic = model.shopPic;
    mvc.gnameString = self.gnameString;
    mvc.invitationLabelString = self.invitationLabelString;
    mvc.YB_ShopDetailChangeDelegate = self;
    
    [self.navigationController pushViewController:mvc animated:YES];
}
//商店商品详情界面的反向传值聊天
-(void)YBShopDetailChangeGroupGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    [self.YB_delegate YBMyLookedShopChatChangeGroupNameWithGname:gname andGroupName:groupName];
}


-(void)createUINav
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"逛过"];
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
