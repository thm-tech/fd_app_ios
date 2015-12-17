//
//  bufferSettingViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/16.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "bufferSettingViewController.h"
#import "myAppDataBase.h"
#import "myLookedShopModel.h"

@interface bufferSettingViewController () <UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
{
    UITableView *_tableView;
    
    NSArray *_titleArray;
}
@end

@implementation bufferSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUINaV];
    
    [self createTableView];
    
    [self createLocalData];
    
    // Do any additional setup after loading the view.
}
-(void)createLocalData
{
    _titleArray = @[@[@"清空聊天记录",@"清空商家推送消息",@"清空系统消息"],@[@"清空所有逛店记录",@"清空一个月前逛店记录",@"清空一年前逛店记录"]];
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
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    UITableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    //config cell
    if(indexPath.row == 0)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = _titleArray[indexPath.section][indexPath.row];
    return cell;
    
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return @"    消息记录";
    }
    else
    {
        return @"    逛店记录";
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
      return   35;
    }
    else
    {
    return 15;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  SCREENHEIGHT*0.08;
}

//cell点击
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            [self createAlertView:@"是否清空聊天记录" tag:100];
        }
        if(indexPath.row == 1)
        {
            [self createAlertView:@"是否清空商家推送消息" tag:200];
        }
        if(indexPath.row == 2)
        {
            [self createAlertView:@"是否清空系统消息" tag:300];
        }
    }
    else
    {
        if(indexPath.row == 0)
        {
            [self createAlertView:@"是否清空所有逛店记录" tag:400];
        }
        if(indexPath.row == 1)
        {
            [self createAlertView:@"是否清空一个月前逛店记录" tag:500];
        }
        if(indexPath.row == 2)
        {
            [self createAlertView:@"是否清空一年前逛店记录" tag:600];
        }
    }
}

//创建提醒视图是否清空
-(void)createAlertView:(NSString *)title tag:(int)tag
{
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:title message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    al.tag = tag;
    [al show];
}

//提醒视图代理
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        return;
    }
    else
    {
        if(alertView.tag == 100)
        {
            //聊天记录
            [[myAppDataBase sharedInstance]deleteAllMessageRecordWith:RecoredTypeAttention];
            
        }
        else if (alertView.tag == 200)
        {
            //商家推送记录
            [[myAppDataBase sharedInstance]deleteAllShopPushRecord];
            
        }
        else if (alertView.tag == 300)
        {
            //系统记录
            [[myAppDataBase sharedInstance]deleteSystemRecordWithRecordType:RecoredTypeAttention];
        }
        else if (alertView.tag == 400)
        {
            //清空所有逛店记录
            [[myAppDataBase sharedInstance]deleteVisitShopRecordWithRecordType:RecoredTypeAttention];
        }
        else if (alertView.tag == 500)
        {
            //清空一个月前逛店记录
            NSArray *array = [[myAppDataBase sharedInstance]getVisitShopRecordWithRecordTyepe:RecoredTypeAttention];
            
            //获取当前的时间
            NSDate *date1 = [NSDate date];
            NSString *date = [NSString stringWithFormat:@"%ld",(long)[date1 timeIntervalSince1970]];
            
            for(myLookedShopModel *model in array)
            {
                if((date.intValue - model.time.intValue >30*24*60*60))
                {
                    NSNumber *deleteShopNumber = [[NSNumber alloc]initWithInt:model.id.intValue];
                    [[myAppDataBase sharedInstance]deleteVisitShopREcordWithShopID:deleteShopNumber recordType:RecoredTypeAttention];
                }
            }
            
        }
        else if (alertView.tag == 600)
        {
            //清空一年前逛店记录
            
            NSArray *array = [[myAppDataBase sharedInstance]getVisitShopRecordWithRecordTyepe:RecoredTypeAttention];
            
            //获取当前的时间
            NSDate *date1 = [NSDate date];
            NSString *date = [NSString stringWithFormat:@"%ld",(long)[date1 timeIntervalSince1970]];
            
            for(myLookedShopModel *model in array)
            {
                if((date.intValue - model.time.intValue >12*30*24*60*60))
                {
                    NSNumber *deleteShopNumber = [[NSNumber alloc]initWithInt:model.id.intValue];
                    [[myAppDataBase sharedInstance]deleteVisitShopREcordWithShopID:deleteShopNumber recordType:RecoredTypeAttention];
                }
            }

        }
       
    }
}

-(void)createUINaV
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"缓存设置"];
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
