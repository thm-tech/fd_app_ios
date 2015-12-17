//
//  miaomiaoViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/9.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "miaomiaoViewController.h"
#import "SlideDeleteCell.h"
#import "miaomiaoChatDetailViewController.h"

#import "myAppDataBase.h"
#import "fansShopDataBaseModel.h"

#import "systemMessageDetailViewController.h"
#import "fansShopPushMessageDetailViewController.h"

#import "staticUserInfo.h"


#define RECEIVEADDFRIENDURL @"http://%@/user/friend/accept?uid=%d&accept=%d"


static NSString *CellIdentifier = @"Cell";

@interface miaomiaoViewController ()<UITableViewDelegate,UITableViewDataSource,SlideDeleteCellDelegate,YBMiaoMiaoCellButtonDelegate,UIGestureRecognizerDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
}

@end

@implementation miaomiaoViewController
-(void)viewWillAppear:(BOOL)animated
{
    [self createData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    __weak typeof(self) weakSelf = self;
//    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
//    {
//        self.navigationController.interactivePopGestureRecognizer.delegate = weakSelf;
//    }
    
    [self createUINa];
    //[self createData];
    
     NSArray *array = [[myAppDataBase sharedInstance]getAllMiaoMiaoRecordTypeWithRecordType:RecoredTypeAttention];
    if(array.count != 0)
    {
    [self createTableView];
    }
    else
    {
        UILabel *label = [ZCControl createLabelWithFrame:CGRectMake(0, SCREENHEIGHT*0.2, SCREENWIDTH, SCREENHEIGHT*0.1) Font:SCREENWIDTH*0.048 Text:@"你还没有喵喵，请先发起会话吧"];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
    }
    
    //通知
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(createData) name:@"startLoadWebSocketData" object:nil];
    [nc addObserver:self selector:@selector(createData) name:@"startLoadCreateGroupData" object:nil];
    [nc addObserver:self selector:@selector(createData) name:@"startLoadWebSocketDataEnterGroup" object:nil];
   [nc addObserver:self selector:@selector(createData) name:@"existGroup" object:nil];
    
    // Do any additional setup after loading the view.
    
}
-(void)createTableView
{
    NSArray *array = [[myAppDataBase sharedInstance]getAllMiaoMiaoRecordTypeWithRecordType:RecoredTypeAttention];
    if(array.count != 0)
    {
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH,SCREENHEIGHT-64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[SlideDeleteCell class] forCellReuseIdentifier:CellIdentifier];
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
    return _dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SlideDeleteCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[SlideDeleteCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    //config cell
    cell.delegate = self;
    cell.receiveButton.hidden = YES;
    cell.refuseButton.hidden = YES;
    cell.pointImageView.hidden = YES;
//    cell.iconImageView.image = [UIImage imageNamed:@"s"];
//    cell.nameLabel.text = @"陈小小";
//    cell.messageLabel.text = @"信息信息信息信息信息信";
    NSDictionary *dict = _dataArray[indexPath.row];
   
    if([dict[@"unread"] isEqualToString:@"1"])
    {
        cell.pointImageView.hidden = NO;
    }
    //系统消息
    if([dict[@"miaomiaoTypeID"] isEqualToString:@"1"])
    {
        //本地系统图图片
        cell.iconImageView.image = [UIImage imageNamed:@""];
        cell.nameLabel.text = @"喵喵熊团队";
        cell.messageLabel.text = @"系统通知消息";
    }
    
    //商家推送消息
    if([dict[@"miaomiaoTypeID"] isEqualToString:@"2"])
    {
        //由商家的ID查粉丝店的表 得到粉丝店的信息
        NSString *shopIDString = [NSString stringWithFormat:@"%@",dict[@"senderID"]];
        NSNumber  *shopID = [[NSNumber alloc]initWithInt:shopIDString.intValue];;
        NSArray *shopInformationArray = [[myAppDataBase sharedInstance]getOneFansShopRecordWith:shopID];
        fansShopDataBaseModel *model = shopInformationArray[0];
        [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.pic]];
        cell.nameLabel.text = model.name;
        cell.messageLabel.text = @"通知消息";
        
    }
    
    
    //聊天消息
    if([dict[@"miaomiaoTypeID"] isEqualToString:@"3"])
    {
        
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
        
    }
    
     //添加好友cell
    if([dict[@"miaomiaoTypeID"] isEqualToString:@"4"])
    {
        cell.YB_cellDelegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if([dict[@"unread"] isEqualToString:@"1"])
        {
        cell.receiveButton.hidden = NO;
        cell.refuseButton.hidden = NO;
        }
        [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:dict[@"portrait"]]];
        cell.nameLabel.text = dict[@"name"];
        cell.messageLabel.text = [NSString stringWithFormat:@"%@请求加你为好友",dict[@"remark"]];
    }
    
    if([dict[@"miaomiaoTypeID"]isEqualToString:@"5"])
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:dict[@"portrait"]]];
        cell.nameLabel.text = dict[@"name"];
        if([dict[@"remark"]isEqualToString:@"1"])
        {
            cell.messageLabel.text = @"同意了你的好友请求";
//            //好友关系保存到本地数据库中 -（对于发起者而言）
//            NSString *senderIDString = dict[@"senderID"];
//            NSNumber *senderIDNumber = [[NSNumber alloc]initWithInt:senderIDString.intValue];
//            
//            NSMutableDictionary *addDict = [[NSMutableDictionary alloc]init];
//            NSString *mcodeString = [NSString stringWithFormat:@"m%@",dict[@"senderID"]];
//            [addDict setObject:dict[@"senderID"] forKey:@"frdID"];
//            [addDict setObject:@"" forKey:@"rmkName"];
//            [addDict setObject:dict[@"name"] forKey:@"nickName"];
//            [addDict setObject:mcodeString forKey:@"mcode"];
//            [addDict setObject:dict[@"portrait"] forKey:@"portrait"];
//            
//            
//            if(![[myAppDataBase sharedInstance]isExistMiaoMiaoRecordWithSenderID:senderIDNumber miaomiaoType:@"5"])
//            {
//                [[myAppDataBase sharedInstance]addUserInformationRecordWithDicitionary:addDict recordType:RecoredTypeAttention];
//            }
            
        }
        if([dict[@"remark"]isEqualToString:@"0"])
        {
            cell.messageLabel.text = @"拒绝了你的好友请求";
        }
    }
    
    //拉进讨论组消息 （包括被拉进讨论组或者自己主动创建的讨论组）
    if([dict[@"miaomiaoTypeID"]isEqualToString:@"6"])
    {
        
    }
    return cell;
    
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREENHEIGHT*0.15;
}
//滑动删除cell
-(void)slideToDeleteCell:(SlideDeleteCell *)slideDeleteCell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:slideDeleteCell];
    NSDictionary *dict = _dataArray[indexPath.row];
       //删除喵喵表中的数据 对应删除其他系统消息表 删除某个商店的推送消息表  删除聊天消息表
    
    NSString *miaomiaoIDString = [NSString stringWithFormat:@"%@",dict[@"senderID"]];
    NSNumber *miaomiaoNumber = [[NSNumber alloc]initWithInt:miaomiaoIDString.intValue];
    
    //对应的讨论组gname存在remark字段里面
    NSString *gname = dict[@"remark"];
   
    //[[myAppDataBase sharedInstance]deleteMiaoMiaoRecordWithSenderID:miaomiaoNumber recordType:RecoredTypeAttention];
    //[[myAppDataBase sharedInstance]deleteMiaoMiaoRecordWithSenderID:miaomiaoNumber miaomiaoType:@"4"];
    //如果是系统消息表
    if([dict[@"miaomiaoTypeID"] isEqualToString:@"1"])
    {
        [[myAppDataBase sharedInstance]deleteSystemRecordWithRecordType:RecoredTypeAttention];
        [[myAppDataBase sharedInstance]deleteMiaoMiaoRecordWithSenderID:miaomiaoNumber miaomiaoType:@"1"];
        
    }
    
    //如果是商家推送消息表
    if([dict[@"miaomiaoTypeID"] isEqualToString:@"2"])
    {
        [[myAppDataBase sharedInstance]deleteShopPushRecordWithShopID:miaomiaoNumber recordType:RecoredTypeAttention];
        [[myAppDataBase sharedInstance]deleteMiaoMiaoRecordWithSenderID:miaomiaoNumber miaomiaoType:@"2"];
    }
    
    //如果是聊天记录表
    if([dict[@"miaomiaoTypeID"] isEqualToString:@"3"])
    {
        [[myAppDataBase sharedInstance]deleteMessageWith:gname];
       
        [[myAppDataBase sharedInstance]deleteMiaoMiaoChatGroupRecordWithGname:gname];
    }
    
    //被添加好友消息
    if([dict[@"miaomiaoTypeID"] isEqualToString:@"4"])
    {
        [[myAppDataBase sharedInstance]deleteMiaoMiaoRecordWithSenderID:miaomiaoNumber miaomiaoType:@"4"];
    }
    //主动加好友回复的消息
    if([dict[@"miaomiaoTypeID"] isEqualToString:@"5"])
    {
        [[myAppDataBase sharedInstance]deleteMiaoMiaoRecordWithSenderID:miaomiaoNumber miaomiaoType:@"5"];
    }
    
    [_dataArray removeObjectAtIndex:indexPath.row];
    
    if(_dataArray.count == 0)
    {
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

    //删除回话 发出通知 通知主界面清空当前的聊天记录
    if([gname isEqualToString:self.mainTalkGname])
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
         [nc postNotificationName:@"deleteMiaoMiaoRecordCleanGname" object:nil userInfo:nil];
    }
}
//cell上面的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SlideDeleteCell *cell = (SlideDeleteCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    NSDictionary *dict = _dataArray[indexPath.row];
    if([dict[@"miaomiaoTypeID"] isEqualToString:@"1"])
    {
        systemMessageDetailViewController *vc = [[systemMessageDetailViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if([dict[@"miaomiaoTypeID"] isEqualToString:@"2"])
    {
        //点击当前cell之后 更新数据库中的未读消息  gengxin miaomiaoxiaoxi
        NSString *senderIDString = dict[@"senderID"];
        NSNumber *senderIDNumber = [[NSNumber alloc]initWithInt:senderIDString.intValue];
        [[myAppDataBase sharedInstance]upDateMiaoMiaoRecordUnreadWith:senderIDNumber andMiaoMiaoType:@"2" unread:@"0"];
        
        fansShopPushMessageDetailViewController *vc = [[fansShopPushMessageDetailViewController alloc]init];
        NSString *shopIDString = [NSString stringWithFormat:@"%@",dict[@"senderID"]];
        vc.shopIDString = shopIDString;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if([dict[@"miaomiaoTypeID"] isEqualToString:@"3"])
    {
        miaomiaoChatDetailViewController *mmcdvc = [[miaomiaoChatDetailViewController alloc]init];
        
        //更新数据库中的未读消息
        NSString *senderIDString = dict[@"senderID"];
        NSNumber *senderIDNumber = [[NSNumber alloc]initWithInt:senderIDString.intValue];
        [[myAppDataBase sharedInstance]upDateMiaoMiaoChatRecordUnreadWith:senderIDNumber miaomiaoType:@"3" gname:dict[@"remark"] unread:@"0"];
        
        //其他参数的值的传递 
        mmcdvc.gnameString = dict[@"remark"];
        mmcdvc.chatTitleName = cell.nameLabel.text;
        mmcdvc.usersIDString = dict[@"users"];
        mmcdvc.senderIDString = dict[@"senderID"];
        
        [self.navigationController pushViewController:mmcdvc animated:YES];
    }
    else if ([dict[@"miaomiaoTypeID"] isEqualToString:@"5"])
    {
        NSString *senderIDString = dict[@"senderID"];
        NSNumber *senderIDNumber = [[NSNumber alloc]initWithInt:senderIDString.intValue];
        
        [[myAppDataBase sharedInstance]upDateMiaoMiaoRecordUnreadWith:senderIDNumber andMiaoMiaoType:@"5" unread:@"0"];
        [self createData];
        
    }
    
}
 //cell上面添加好友按钮的点击
-(void)YBMiaoMiaoCellButtonDidClick:(UIButton *)button
{
    SlideDeleteCell *cell = (SlideDeleteCell *)[[button superview] superview];
    NSIndexPath *path = [_tableView indexPathForCell:cell];
    NSDictionary *dict = _dataArray[path.row];
    NSString *senderIDString = [NSString stringWithFormat:@"%@",dict[@"senderID"]];
    //与后台通讯 http请求
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    //拒绝
    if(button.tag == 501)
    {
        NSString *acceptString = [NSString stringWithFormat:@"0"];
            NSString *urlString = [NSString stringWithFormat:RECEIVEADDFRIENDURL,DomainName,senderIDString.intValue,acceptString.intValue];
        [manager POST:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSString *errString = dict[@"err"];
            if(errString.intValue == 0)
            {
                //拒绝好友成功  reload界面 界面重新显示
                cell.pointImageView.hidden = YES;
                cell.receiveButton.hidden = YES;
                cell.refuseButton.hidden = YES;
                
                //修改消息里面的未读消息
                NSNumber *senderIDNumber = [[NSNumber alloc]initWithInt:senderIDString.intValue];
                
                [[myAppDataBase sharedInstance]upDateMiaoMiaoRecordUnreadWith:senderIDNumber andMiaoMiaoType:@"4" unread:@"0"];
                //重新获取数据
                [self createData];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"拒绝加好友error = %@",error);
        }];
    }
    //同意
    else if(button.tag == 502)
    {
        NSString *acceptString = [NSString stringWithFormat:@"1"];
        NSString *urlString = [NSString stringWithFormat:RECEIVEADDFRIENDURL,DomainName,senderIDString.intValue,acceptString.intValue];
        [manager POST:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //保存好友关系以及好友资料在本地  对于接受者而言
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSString *errString = responseDict[@"err"];
            if(errString.intValue == 0)
            {
                
                //同意好友成功  reload界面 界面重新显示
                cell.pointImageView.hidden = YES;
                cell.receiveButton.hidden = YES;
                cell.refuseButton.hidden = YES;
                
                //修改消息里面的未读消息
                NSNumber *senderIDNumber = [[NSNumber alloc]initWithInt:senderIDString.intValue];
                
                [[myAppDataBase sharedInstance]upDateMiaoMiaoRecordUnreadWith:senderIDNumber andMiaoMiaoType:@"4" unread:@"0"];
                //重新获取数据
                [self createData];
                
                //
                if(![[myAppDataBase sharedInstance]isExistUserInformationRecordWithUserID:senderIDString recordType:RecoredTypeAttention])
                {
                NSMutableDictionary *addDict = [[NSMutableDictionary alloc]init];
                NSString *mcodeString = [NSString stringWithFormat:@"m%@",dict[@"senderID"]];
                [addDict setObject:dict[@"senderID"] forKey:@"frdID"];
                [addDict setObject:dict[@"remark"] forKey:@"rmkName"];
                [addDict setObject:dict[@"name"] forKey:@"nickName"];
                [addDict setObject:mcodeString forKey:@"mcode"];
                [addDict setObject:dict[@"portrait"] forKey:@"portrait"];
                [[myAppDataBase sharedInstance]addUserInformationRecordWithDicitionary:addDict recordType:RecoredTypeAttention];
                }
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"接收error = %@",error);
            
        }];
    }
    
}

-(void)createData
{
    _dataArray = [[NSMutableArray alloc]init];
    
    NSArray *array = [[myAppDataBase sharedInstance]getAllMiaoMiaoRecordTypeWithRecordType:RecoredTypeAttention];
    for(long i = array.count-1;i>=0;i--)
    {
        [_dataArray addObject:array[i]];
    }
    NSLog(@"喵喵消息中具体消息%@",_dataArray);
    
    [_tableView reloadData];
}
-(void)createUINa
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"喵喵"];
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
    [self.navigationController popToViewController:self.navigationController.viewControllers[0] animated:YES];
    //[self.navigationController popViewControllerAnimated:YES];
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
