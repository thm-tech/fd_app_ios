//
//  changeChatGroupViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/26.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "changeChatGroupViewController.h"
#import "changeChatGroupTableViewCell.h"
#import "mainShopDetailViewController.h"
#import "staticUserInfo.h"
#import "myAppDataBase.h"

#define GROUPINFORMATIONURL @"http://%@/chat/room/%@/info"

@interface changeChatGroupViewController () <UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    YBWebSocketManager *_webSocketManager;
    
    //所有用户所在讨论组信息数组
    NSMutableArray *_allGroupArray;
    NSMutableArray *_messageRecordArray;
    
}
@end

@implementation changeChatGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUINav];
   // [self createTableView];
    
    //从喵喵数据库中获取所有聊天信息（包括群聊和单聊）
    [self getChatData];
    
    // Do any additional setup after loading the view.
}
-(void)getChatData
{
    
    _allGroupArray = [[NSMutableArray alloc]init];
    //聊天的类型为3
    NSArray *array = [[myAppDataBase sharedInstance]getAllMiaoMiaoChatRecordWithMiaoMiaoTypeID:@"3"];
    for(long i = array.count-1;i>=0;i--)
    {
        [_allGroupArray addObject:array[i]];
    }
    NSLog(@"测试消息的数组%@",_allGroupArray);
    
    if(_allGroupArray.count != 0)
    {
        [self createTableView];
        [_tableView reloadData];
    }
    else
    {
        UILabel *label = [ZCControl createLabelWithFrame:CGRectMake(0, SCREENHEIGHT*0.2, SCREENWIDTH, SCREENHEIGHT*0.1) Font:SCREENWIDTH*0.048 Text:@"你还没有喵喵，请先发起会话吧"];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
    }
    
}


//-(void)useWebSocketSendMessage
//{
//    _webSocketManager = [YBWebSocketManager sharedInstance];
//    _messageRecordArray = [[NSMutableArray alloc]init];
//    _allGroupArray = [[NSMutableArray alloc]init];
//    //发送消息获取用户所在组的信息
//    NSString *userString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
//    
//    [_webSocketManager YBGetGroupInformationWithUser:userString];
//    
//    //获取所在组的信息
//    NSMutableArray *groupArray = [[NSUserDefaults standardUserDefaults]objectForKey:UserInGroups];
//    for(NSString *gnameString in groupArray)
//    {
//        if([gnameString rangeOfString:@"shop"].location != NSNotFound)
//        {
//            [groupArray removeObject:gnameString];
//        }
//    }
//    
//    //下载聊天组的信息
//    for(int i = 0;i<groupArray.count;i++)
//    {
//        [self downLoadgroupInformationWithGname:groupArray[i]];
//    }
//    
//    //下载聊天记录的数据
//    for(int i = 0;i<_allGroupArray.count;i++)
//    {
//        NSDictionary *dict = _allGroupArray[i];
//        NSString *string = dict[@"gname"];
//        if([[myAppDataBase sharedInstance]isExistMessageWith:string])
//        {
//            NSArray *mesageArray = [staticUserInfo getMessagesWithGname:string];
//            [_messageRecordArray addObject:mesageArray];
//        }
//        else
//        {
//            //这是获取最新的聊天记录(当需要显示更多消息的时候 开始时间为上次取的最后一条记录的时间)
//            [_webSocketManager YBGetRecordWithGname:string andStartTime:@"0" andRecordCount:@"30"];
//            NSArray *messageArray = [staticUserInfo getMessagesWithGname:string];
//            [_messageRecordArray addObject:messageArray];
//            
//        }
//        
//    }
//    
//    
//    
//    //刷新tableView
//    [_tableView reloadData];
//    
//}
//
//
////下载用户组的信息
//-(void)downLoadgroupInformationWithGname:(NSString *)gname
//{
//    NSString *urlString = [NSString stringWithFormat:GROUPINFORMATIONURL,DomainName,gname];
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//        [_allGroupArray addObject:dict];
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//    }];
//}

//#pragma mark-(webSocket Delegate)
//-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
//{
//    NSString *messageString = message;
//    NSDictionary *dict = [messageString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
//    //得到用户所在组列表
//    NSArray *array = dict[@"groups"];
//    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:array];
//    [self downLoadGroupDataWith:mutableArray];
//}
////用户列表中下载每一组的信息
//-(void)downLoadGroupDataWith:(NSMutableArray *)mutableArray
//{
//    //删除用户所在组列表中的商店的gname
//    for(NSString *gnameString in mutableArray)
//    {
//        if([gnameString rangeOfString:@"shop"].location != NSNotFound)
//        {
//            [mutableArray removeObject:gnameString];
//        }
//    }
//    
//    //得到删除过后的数组 然后去下载每一组的用户信息
//    
//}
-(void)createTableView
{
     NSArray *array = [[myAppDataBase sharedInstance]getAllMiaoMiaoChatRecordWithMiaoMiaoTypeID:@"3"];
    if(array.count != 0)
    {
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH,SCREENHEIGHT-64) style:UITableViewStylePlain];
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
    return _allGroupArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    changeChatGroupTableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
    if(cell == nil)
    {
        cell = [[changeChatGroupTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    //config cell
    NSDictionary *dict = _allGroupArray[indexPath.row];
    
    //这里需要判断是单聊还是群
    NSString *gnameString = [NSString stringWithFormat:@"%@",dict[@"remark"]];
    
    //单聊
    if([gnameString rangeOfString:@"e2e"].location != NSNotFound)
    
    {
        NSArray *messArray = [staticUserInfo getMessagesWithGname:gnameString];
        if(messArray.count != 0)
        {
        NSDictionary *messDict = messArray[messArray.count-1];
            if([messDict[@"mtype" ] isEqualToString:@"text"])
            {
                cell.messageLabel.text = messDict[@"m"];
            }
            else if ([messDict[@"mtype" ] isEqualToString:@"audio/mp3"])
            {
                cell.messageLabel.text = @"语音";
            }
            else
            {
                cell.messageLabel.text = @"图片";
            }

        }
        NSDictionary *userInformation = [staticUserInfo getUserInformationWithUserID:dict[@"senderID"]];
        //NSLog(@"*********************信息字典 = %@",userInformation);
        //在由userID得到game的名称，头像，以及最后一条聊天记录
        [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:userInformation[@"portrait"]]];
        if(![userInformation[@"rmkName"] isEqualToString:@""])
        {
            cell.nameLabel.text = userInformation[@"rmkName"];
        }
        else
        {
            cell.nameLabel.text = userInformation[@"nickName"];
        }
    }
    //群聊
    else if ([gnameString rangeOfString:@"users"].location != NSNotFound)
    {
        NSArray *messArray = [staticUserInfo getMessagesWithGname:gnameString];
        if(messArray.count != 0)
        {
            NSDictionary *messDict = messArray[messArray.count-1];
            if([messDict[@"mtype" ] isEqualToString:@"text"])
            {
                cell.messageLabel.text = messDict[@"m"];
            }
            else if ([messDict[@"mtype" ] isEqualToString:@"audio/mp3"])
            {
                cell.messageLabel.text = @"语音";
            }
            else
            {
                cell.messageLabel.text = @"图片";
            }

        }
        //群聊中 头像名字直接存在portrait 和 name的字段下面
        [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:dict[@"portrait"]]];
        
        //显示聊天群组的名字 (由组内ID名称拼接而成)
        cell.nameLabel.text = dict[@"name"];
        
    }
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREENHEIGHT*0.15;
}
//cell上面的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dict = _allGroupArray[indexPath.row];
    
    changeChatGroupTableViewCell *cell = (changeChatGroupTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
    
    //将选择的gname进行反向传值 (单聊和群聊的“gname”都在remark字段里面)
    
    [self.YB_ChangeGroupGnameDelegate YBchangeGroupTableViewReloadData2];
    [self.YB_ChangeGroupGnameDelegate YBChangeGroupGNameWith:dict[@"remark"] andGroupName:cell.nameLabel.text];
    
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)createUINav
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"切换聊天组"];
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
