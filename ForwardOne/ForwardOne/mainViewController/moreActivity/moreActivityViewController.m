//
//  moreActivityViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/8/11.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "moreActivityViewController.h"
#import "moreActivityTableViewCell.h"
#import "activityModel.h"
#import "activityDetailViewController.h"
#import "inShopActivityViewController.h"
@interface moreActivityViewController () <UITableViewDelegate,UITableViewDataSource,YBSendActivityDelegate>
{
    UITableView *_tableView;
}
@end

@implementation moreActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //创建导航栏
    [self createUINavi];
    
    [self createTableView];
    
    // Do any additional setup after loading the view.
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
    return self.dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    moreActivityTableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
    if(cell == nil)
    {
        cell = [[moreActivityTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    //config cell
    activityModel *model = self.dataArray[indexPath.section];
    [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.shopPic]];
    cell.activityNameLabel.text = model.title;
    cell.shopNameLabel.text = model.shopName;
    
    NSString *bt = [model.bt substringToIndex:10];
    NSString *et = [model.et substringToIndex:10];
    NSString *dateString = [NSString stringWithFormat:@"%@至%@",bt,et];
    cell.dateLabel.text = dateString;
    return cell;
}

//设置各种高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREENHEIGHT*0.2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == self.dataArray.count-1)
    {
        return 0.1f;
    }
    else
    {
        return SCREENHEIGHT*0.01;
    }
}

//cell上面的点击
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    activityDetailViewController *acvc = [[activityDetailViewController alloc]init];
//    acvc.model = self.dataArray[indexPath.section];
    inShopActivityViewController *vc = [[inShopActivityViewController alloc]init];
    vc.gnameString = self.gnameString;
    vc.invitationLabelString = self.invitationLabelString;
    vc.YB_delegate = self;
    activityModel *model = self.dataArray[indexPath.section];
    NSMutableArray *activityArray = [[NSMutableArray alloc]init];
    NSMutableDictionary *activityDict = [[NSMutableDictionary alloc]init];
    [activityDict setObject:model.actID forKey:@"id"];
    [activityDict setObject:model.title forKey:@"title"];
    [activityDict setObject:model.content forKey:@"content"];
    [activityDict setObject:model.bt forKey:@"bt"];
    [activityDict setObject:model.et forKey:@"et"];
    [activityDict setObject:model.shopPic forKey:@"img"];
    [activityDict setObject:model.shopID forKey:@"shopID"];
    [activityArray addObject:activityDict];
    
    vc.activityArray = activityArray;
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(void)YBSendActivityDelgateWithGname:(NSString *)gname andGroupName:(NSString *)groupName
{
    [self.YB_delegate YBSendMoreActivityDelegateWithGname:gname andGroupName:groupName];
}


-(void)createUINavi
{
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"活动专区"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    //导航栏左按钮
    UIButton *leftButton = [ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(leftButtonBtn:) Title:nil];
    [leftButton setImage:[UIImage imageNamed:@"店铺-店铺详情_03"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.view.backgroundColor = [UIColor whiteColor];
}
-(void)leftButtonBtn:(UIButton *)button
{
    [self.navigationController popToRootViewControllerAnimated:YES];
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
