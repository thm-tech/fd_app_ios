//
//  messageSettingViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/9.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "messageSettingViewController.h"
#import "myAppDataBase.h"
#import "fansShopDataBaseModel.h"

#define MESSAGESETTINGURL @"http://%@/user/setting/message"

@interface messageSettingViewController () <UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    NSMutableArray *_titleArray;
    
    myAppDataBase *dc;
}
@end

@implementation messageSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUINA];
    [self createTableView];
    [self createDataArray];
    
    // Do any additional setup after loading the view.
}
-(void)createDataArray
{
    [_titleArray removeAllObjects];
     
    //读取数据库中粉丝店的店名
    dc = [myAppDataBase sharedInstance];
    
    NSArray *array = [dc getFansShopRecordWithRecordType:RecoredTypeAttention];
    NSMutableArray *finalArray = [[NSMutableArray alloc]init];
    for(long i = array.count-1;i>=0;i--)
    {
        [finalArray addObject:array[i]];
    }
    
    _titleArray = [[NSMutableArray alloc]initWithArray:finalArray];
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
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titleArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    fansShopDataBaseModel *model = _titleArray[indexPath.row];
            static NSString *cellID = @"cell";
            UITableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
            if(cell == nil)
            {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
                
                UISwitch *mySwitch3 = [[UISwitch alloc]initWithFrame:CGRectMake(0,0,0, 0)];
                mySwitch3.center = CGPointMake(SCREENWIDTH*0.85, SCREENHEIGHT*0.08*0.5);
                //mySwitch3.tag = 200;
                mySwitch3.on = model.msgEnable.intValue;
                [mySwitch3 addTarget:self action:@selector(dealSwitch:) forControlEvents:UIControlEventValueChanged];
                [cell.contentView addSubview:mySwitch3];
            }
            //config cell
    
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = model.name;
            return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{

    if(_titleArray.count != 0)
    {
        NSString *titleSectionString = @"    接受所有粉丝店推送";
        return titleSectionString;
    }
    else
    {
        return nil;
    }
}

-(void)dealSwitch:(UISwitch *)s
{
    //获取
    UITableViewCell *cell = (UITableViewCell *)[[s superview] superview];
    NSIndexPath *path = [_tableView indexPathForCell:cell];
    fansShopDataBaseModel *model = _titleArray[path.row];
    
    NSString *urlString = [NSString stringWithFormat:MESSAGESETTINGURL,DomainName];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];

        //在这里先本地存储switch的值 然后post到后台服务器 默认支持接收所有粉丝店的消息
        NSString *switchString = [NSString stringWithFormat:@"%d",s.on];
        [[NSUserDefaults standardUserDefaults]setObject:switchString forKey:AllMessageSetting];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
            [manager POST:urlString parameters:@{@"shopID":model.id,@"msgEnable":[NSString stringWithFormat:@"%d",s.on]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                NSString *errString = dict[@"err"];
                if(errString.intValue == 0)
                {
                    //更新本地粉丝店数据库
                    NSNumber *shopIDNumber = [[NSNumber alloc]initWithInt:model.id.intValue];
                    NSNumber *msgEnableNumber = [[NSNumber alloc]initWithInt:switchString.intValue];
                    [[myAppDataBase sharedInstance]upDateFansShopReceiveFansShopPushMessageWithShopID:shopIDNumber withMsgEnable:msgEnableNumber];
                    [self createDataArray];
                }
                NSLog(@"所有消息设置返回的字典%@",dict);
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{

       return SCREENHEIGHT*0.05;
   
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  SCREENHEIGHT*0.08;
}

-(void)createUINA
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"消息设置"];
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
