//
//  YBWebSocketManager.m
//  webSocketDemo
//
//  Created by 杨波 on 15/7/15.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "YBWebSocketManager.h"
#import "JSONKit.h"
#import "staticUserInfo.h"
#import "myAppDataBase.h"
#import "NSString+Hashing.h"
#import "fansShopDataBaseModel.h"


#define GROUPINFORMATIONURL @"http://%@/chat/room/%@/info"

@implementation YBWebSocketManager

//创建单例
+(id)sharedInstance
{
    static YBWebSocketManager *dc = nil;
    if(dc == nil)
    {
        dc = [[[self class] alloc]init];
        
    }
    return dc;
}

//重写init
-(id)init
{
    if(self = [super init])
    {
        [self createWebSocketToServers];
    }
    return self;
}

//打开
-(void)openChatSocket
{
    [self createWebSocketToServers];
}

//关闭
-(void)closedChatScoket
{
    //[self.webSocket close];
    [self.webSocket closeWithCode:1314 reason:@"myClosedSocket"];
}

-(void)createWebSocketToServers
{
//    NSString *loginString = [[NSUserDefaults standardUserDefaults]objectForKey:IsLogin];
//    if([loginString isEqualToString:@"login"])
//    {
    NSString *u = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
    NSString *p = [[NSUserDefaults standardUserDefaults]objectForKey:UserPassword];
    NSString *password = [p MD5Hash];
    self.webSocket = [[SRWebSocket alloc]initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"ws://chat.immbear.com:8889/chat/?u=%@&p=%@",u,password]]]];
    NSLog(@"建立聊天的用户%@",u);
    
    self.webSocket.delegate = self;
    //建立长链接
    [self.webSocket open];
    //}
}

//协议代理方法
-(void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"webSocket已经打开");
}

//接收消息的代理方法（所有接收消息都在这个借口中 需要对命令码做出判断 从而对应不同的处理）
-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    //加通知  当接收消息的方法被调用的时候
    
    NSString *messageString = message;
    NSDictionary *dict = [messageString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
    NSLog(@"****************%@",dict);
    
    NSString *codeString = dict[@"c"];
    //通过命令码来判断
    //_groupUserInformationArray  = [[NSMutableArray alloc]init];
    if([codeString isEqualToString:@"GROUP_USERS"])
    {
        NSString *gnameString = dict[@"gname"];
        NSArray *groupUserArray = dict[@"users"];
        NSString *groupNameString = [[NSString alloc]init];
        NSString *userNameString = [[NSString alloc]init];
        NSMutableArray *userNameArray = [[NSMutableArray alloc]init];
        
        for(int i = 0;i<groupUserArray.count;i++)
        {
            NSDictionary *userDict = [staticUserInfo getUserInformationWithUserID:groupUserArray[i]];
            //如果有备注名  则显示备注名字
            if([[userDict allKeys]containsObject:@"rmkName"])
            {
                userNameString = userDict[@"rmkName"];
            }
            else
            {
                userNameString = userDict[@"nickName"];
            }
            [userNameArray addObject:userNameString];
        }
        if(userNameArray.count<3)
        {
            groupNameString = [NSString stringWithFormat:@"%@、%@",userNameArray[0],userNameArray[1]];
            [staticUserInfo addGruopNameToGname:gnameString withGruopName:groupNameString];
        }
        else
        {
            groupNameString = [NSString stringWithFormat:@"%@、%@...(%ld人)",userNameArray[0],userNameArray[1],userNameArray.count];
        }
       
        //存入缓存中
        [staticUserInfo addGruopNameToGname:gnameString withGruopName:groupNameString];
       
    }
    //接收消息
    if([codeString isEqualToString:@"CHAT_M"])
    {
        NSLog(@"11111111111111111111");
        
        //接收来的消息都存入缓存和数据库中
        NSString *gname = dict[@"gname"];
        //当为店铺聊天室发来消息的时候不做处理
        
        
        NSDictionary *messageBodyDict = dict[@"body"];
        if([messageBodyDict[@"mtype"] isEqualToString:@"mmx/goods"]||[messageBodyDict[@"mtype"] isEqualToString:@"mmx/act"]||[messageBodyDict[@"mtype"] isEqualToString:@"mmx/shop"])
        {
            NSDictionary *mmxDetailDict = messageBodyDict[@"m"];
            NSString *mmxDetailString = [mmxDetailDict JSONString];
            NSMutableDictionary  *finalMessageBodyDict = [[NSMutableDictionary alloc]init];
            [finalMessageBodyDict setObject:mmxDetailString forKey:@"m"];
            [finalMessageBodyDict setObject:messageBodyDict[@"mtype"] forKey:@"mtype"];
            [finalMessageBodyDict setObject:messageBodyDict[@"time"] forKey:@"time"];
            [finalMessageBodyDict setObject:messageBodyDict[@"user"] forKey:@"user"];
            
            [staticUserInfo addMessageToGname:gname withMessageBody:finalMessageBodyDict];
        }
        else
        {
             [staticUserInfo addMessageToGname:gname withMessageBody:messageBodyDict];
        }
        
        NSLog(@"222222222222222222222222222");
        
        //存入
    
       
        
       // [[myAppDataBase sharedInstance]addMessagesWith:gname andMessageBody:messageBodyDict];
        
        
        //1.添加到喵喵消息表
        NSMutableDictionary *adddict = [[NSMutableDictionary alloc]init];
        NSString *idNumberString = messageBodyDict[@"user"];
        NSNumber *idNumber = [[NSNumber alloc]initWithInt:idNumberString.intValue];
        [adddict setObject:idNumber forKey:@"senderID"];
        
        [adddict setObject:@"3" forKey:@"miaomiaoTypeID"];
        [adddict setObject:@"" forKey:@"portrait"];
        [adddict setObject:@"" forKey:@"name"];
        [adddict setObject:dict[@"gname"] forKey:@"remark"];
        
        //表示新增加的未读消息
        [adddict setObject:@"1" forKey:@"unread"];
        [adddict setObject:@"" forKey:@"users"];
        
        //需要考虑的情况 （不能这样判断  一个senderID可能对应加好友消息 不同讨论组内的聊天信息 ）
        //如果是自己发送消息就不显示新消息
        NSString *myIDNumberString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
        if([gname rangeOfString:@"shop"].location != NSNotFound)
        {
            
        }
        else
        {
        if([myIDNumberString isEqualToString:idNumberString])
        {
            
        }
        else
        {
            //这里需要判断聊天的消息是单聊还是群聊 (单聊为e2e  群聊为users)
            if([gname rangeOfString:@"users"].location != NSNotFound)
            {
               //群聊
                //先判断是否存在某个gname的讨论组 如果存在则删除 然后在添加 （保持UI显示上面为最新的）
                if([[myAppDataBase sharedInstance]isExistMiaoMiaoGroupRecordWithGname:gname])
                {
                    NSDictionary *groupDict = [[myAppDataBase sharedInstance]getOneMiaoMiaoRecordWithGname:gname];
                    [[myAppDataBase sharedInstance]deleteMiaoMiaoChatGroupRecordWithGname:gname];
                    [[myAppDataBase sharedInstance]addMiaoMiaoReordWithDicitionary:groupDict recordType:RecoredTypeAttention];
                }
                //更新未读消息
                [[myAppDataBase sharedInstance]upDateMiaoMiaoGroupChatUnReadWithGname:gname unread:@"1"];
                
            }
            else
            {
                
                //单聊（包括用户与用户之间 用户和商家之间的单聊）
        if([[myAppDataBase sharedInstance]isExistMiaomiaoChatRecordWithSenderID:idNumber miaomiaoType:@"3" gname:gname])
        {
            [[myAppDataBase sharedInstance]deleteMiaoMiaoChatRecordWithSenderID:idNumber miaomiaoType:@"3" gname:gname];
        }
        
        [[myAppDataBase sharedInstance]addMiaoMiaoReordWithDicitionary:adddict recordType:RecoredTypeAttention];
        
        }
        }
        }
        NSLog(@"33333333333333333333333");
        
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:@"startLoadWebSocketData" object:nil userInfo:@{@"currentGname":gname}];
        
        NSLog(@"444444444444444444444");
        //存入之后 从缓存和数据库中读取新的数据
       // [self loadBaseViewsAndData];
    }
    //邀请消息 被拉的时候会收到
    if([codeString isEqualToString:@"INVITE"])
    {
        NSString *gname = dict[@"gname"];
        
        [[NSUserDefaults standardUserDefaults]setObject:gname forKey:MyGname];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        NSArray *usersArray = dict[@"users"];
        NSString *userNamesString = [[NSString alloc]init];
        NSString *myIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
    
        for(int i = 0;i<usersArray.count;i++)
        {
            //判断ID是否为自己的ID
            if(i == usersArray.count - 1)
            {
                NSString *oneUserIDString = [NSString stringWithFormat:@"%@",usersArray[i]];
                if([oneUserIDString isEqualToString:myIDString])
                {
                    NSString *mNickNameString = [[NSUserDefaults standardUserDefaults]objectForKey:MyNickName];
                    userNamesString = [userNamesString stringByAppendingString:[NSString stringWithFormat:@"%@",mNickNameString]];
                }
                else
                {
                    NSDictionary *oneUserInformationDict = [staticUserInfo getUserInformationWithUserID:oneUserIDString];
                    //NSLog(@"组内成员信息%@",oneUserInformationDict);
                    if([[oneUserInformationDict allKeys]containsObject:@"rmkName"])
                    {
                        
                        //cell.nameLabel.text = userInformation[@"rmkName"];
                        if(![oneUserInformationDict[@"rmkName"] isEqualToString:@""])
                        {
                        userNamesString  = [userNamesString stringByAppendingString:[NSString stringWithFormat:@"%@",oneUserInformationDict[@"rmkName"]]];
                        }
                        else
                        {
                            userNamesString = [userNamesString stringByAppendingString:[NSString stringWithFormat:@"%@",oneUserInformationDict[@"nickName"]]];
                        }
                    }
                    else
                    {
                        //cell.nameLabel.text = userInformation[@"nickName"];
                        userNamesString = [userNamesString stringByAppendingString:[NSString stringWithFormat:@"%@",oneUserInformationDict[@"nickName"]]];
                    }
                }

            }
            else
            {
            NSString *oneUserIDString = [NSString stringWithFormat:@"%@",usersArray[i]];
            if([oneUserIDString isEqualToString:myIDString])
            {
                NSString *mNickNameString = [[NSUserDefaults standardUserDefaults]objectForKey:MyNickName];
                userNamesString = [userNamesString stringByAppendingString:[NSString stringWithFormat:@"%@,",mNickNameString]];
            }
            else
            {
            NSDictionary *oneUserInformationDict = [staticUserInfo getUserInformationWithUserID:oneUserIDString];
           // NSLog(@"组内成员信息%@",oneUserInformationDict);
            if([[oneUserInformationDict allKeys]containsObject:@"rmkName"])
            {
                
                //cell.nameLabel.text = userInformation[@"rmkName"];
                if(![oneUserInformationDict[@"rmkName"] isEqualToString:@""])
                {
                userNamesString  = [userNamesString stringByAppendingString:[NSString stringWithFormat:@"%@,",oneUserInformationDict[@"rmkName"]]];
                }
                else
                {
                    userNamesString = [userNamesString stringByAppendingString:[NSString stringWithFormat:@"%@,",oneUserInformationDict[@"nickName"]]];
                }
            }
            else
            {
                //cell.nameLabel.text = userInformation[@"nickName"];
                userNamesString = [userNamesString stringByAppendingString:[NSString stringWithFormat:@"%@,",oneUserInformationDict[@"nickName"]]];
            }
            }
            }

        }
        
        NSString *createIDString = usersArray[0];
        NSNumber *createIDNumber = [[NSNumber alloc]initWithInt:createIDString.intValue];
        NSMutableDictionary *addDict = [[NSMutableDictionary alloc]init];
        
        [addDict setObject:createIDNumber forKey:@"senderID"];
        
        [addDict setObject:@"3" forKey:@"miaomiaoTypeID"];
        
        if([myIDString isEqualToString:createIDString])
        {
            NSString *myPhotoImageString = [[NSUserDefaults standardUserDefaults]objectForKey:MyPhotoImageURL];
            [addDict setObject:myPhotoImageString forKey:@"portrait"];
        }
        else
        {
        NSDictionary *userInformation = [staticUserInfo getUserInformationWithUserID:createIDString];
        [addDict setObject:userInformation[@"portrait"] forKey:@"portrait"];
        }
        
        
        //设计的缺陷 name字段存储讨论组成员ID
        [addDict setObject:userNamesString forKey:@"name"];
        [addDict setObject:gname forKey:@"remark"];
        
        //表示新增加的未读消息
        [addDict setObject:@"1" forKey:@"unread"];
        
        NSString *lastUserIDString = [[NSString alloc]init];
        for(int i = 0;i<usersArray.count;i++)
        {
            if(i == usersArray.count - 1)
            {
                lastUserIDString = [lastUserIDString stringByAppendingString:[NSString stringWithFormat:@"%@",usersArray[i]]];
            }
            else
            {
                lastUserIDString = [lastUserIDString stringByAppendingString:[NSString stringWithFormat:@"%@,",usersArray[i]]];
            }
        }
        
        [addDict setObject:lastUserIDString forKey:@"users"];
        
        [[myAppDataBase sharedInstance]addMiaoMiaoReordWithDicitionary:addDict recordType:RecoredTypeAttention];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:@"startLoadCreateGroupData" object:nil userInfo:nil];
        [nc postNotificationName:@"startLoadGname" object:nil userInfo:@{@"myGname":gname}];
        
        
        //上传我自己创建讨论组的头像和名称
        NSString *urlString = [NSString stringWithFormat:GROUPINFORMATIONURL,DomainName2,gname];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        [manager POST:urlString parameters:@{@"roomName":addDict[@"name"],@"roomImg":addDict[@"portrait"]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"哈哈哈%@",dict);
            NSString *errString = dict[@"error"];
            if(errString.intValue == 0)
            {
                
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"err = %@",error);
            
        }];
    

    }
    
    //已经存在聊天组然后拉人进组 （提示被拉者进组消息）
    if([codeString isEqualToString:@"ENTR_GROUP"])
    {
        NSString *gnameString = dict[@"gname"];
        //更新群聊中成员ID
        NSDictionary *oneMiaoMiaoDict = [[myAppDataBase sharedInstance]getOneMiaoMiaoRecordWithGname:gnameString];
        NSString *usersIDString = oneMiaoMiaoDict[@"users"];
        NSString *finalUsersIDString = [usersIDString stringByAppendingString:[NSString stringWithFormat:@",%@",dict[@"user"]]];
        NSArray *usersArray = [usersIDString componentsSeparatedByString:@","];
        if([usersArray containsObject:dict[@"user"]])
        {
            
        }
        else
        {
        //更新数据库
        [[myAppDataBase sharedInstance]upDateMiaoMiaoREcordUsers:finalUsersIDString withGname:gnameString];
        }
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:@"startLoadWebSocketDataEnterGroup" object:nil userInfo:nil];
    }
    
    //退出讨论组 (已经存在的讨论组  提示谁退出讨论组 然后更新组成员 如果为自己退出讨论组则删除对面的喵喵表以及聊天记录表)
    if([codeString isEqualToString:@"EXIT_G"])
    {
        NSString *gnameString = dict[@"gname"];
        NSString *userID = dict[@"user"];
        NSString *myIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
        if([userID isEqualToString:myIDString])
        {
            //如果是自己退出讨论组
            //删除喵喵记录
            [[myAppDataBase sharedInstance]deleteMiaoMiaoChatGroupRecordWithGname:gnameString];
            //删除消息记录
            [[myAppDataBase sharedInstance]deleteMessageWith:gnameString];
        }
        else
        {
            //如果是其他人退出讨论组  更新组内ID
            //更新群聊中成员ID
            NSDictionary *oneMiaoMiaoDict = [[myAppDataBase sharedInstance]getOneMiaoMiaoRecordWithGname:gnameString];
            NSString *usersIDString = oneMiaoMiaoDict[@"users"];
             NSArray *usersArray = [usersIDString componentsSeparatedByString:@","];
            NSMutableArray *deleteUsersArray = [NSMutableArray arrayWithArray:usersArray];
            [deleteUsersArray removeObject:userID];
            NSString *finalUsersString = [[NSString alloc]init];
            for(int i = 0; i<deleteUsersArray.count;i++)
            {
                if(i == deleteUsersArray.count - 1)
                {
                    finalUsersString = [finalUsersString stringByAppendingString:deleteUsersArray[i]];
                }
                else
                {
                    finalUsersString = [finalUsersString stringByAppendingString:[NSString stringWithFormat:@"%@,",deleteUsersArray[i]]];
                }
            }
         
            [[myAppDataBase sharedInstance]upDateMiaoMiaoREcordUsers:finalUsersString withGname:gnameString];
        }
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:@"existGroup" object:nil userInfo:@{@"existGname":gnameString}];
    }
    
    //获取聊天记录
    if([codeString isEqualToString:@"GET_RECORD"])
    {
        //获取到的聊天记录
        NSString *gname = dict[@"gname"];
        NSArray *messageArray = dict[@"ms"];
        //存入数据库和缓存中
      
        for(long i = messageArray.count-1;i>=0;i--)
        {
            //
            
            NSDictionary *messageBodyDict = messageArray[i];
            if([messageBodyDict[@"mtype"] isEqualToString:@"mmx/goods"]||[messageBodyDict[@"mtype"] isEqualToString:@"mmx/act"]||[messageBodyDict[@"mtype"] isEqualToString:@"mmx/shop"])
            {
                NSDictionary *mmxDetailDict = messageBodyDict[@"m"];
                NSString *mmxDetailString = [mmxDetailDict JSONString];
                NSMutableDictionary  *finalMessageBodyDict = [[NSMutableDictionary alloc]init];
                [finalMessageBodyDict setObject:mmxDetailString forKey:@"m"];
                [finalMessageBodyDict setObject:messageBodyDict[@"mtype"] forKey:@"mtype"];
                [finalMessageBodyDict setObject:messageBodyDict[@"time"] forKey:@"time"];
                [finalMessageBodyDict setObject:messageBodyDict[@"user"] forKey:@"user"];
                
                [staticUserInfo addMessageToGname:gname withMessageBody:finalMessageBodyDict];
            }
            
            else
            {
            [staticUserInfo addMessageToGname:gname withMessageBody:messageArray[i]];
            }
        }
        if(messageArray.count != 0)
        {
           
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:@"startLoadChatDataFromeNet" object:nil userInfo:nil];
    
        }
        //数据存入缓存和数据之后   从缓存或者数据库中取出数据来填充UI
       // [self loadBaseViewsAndData];
    }
    //摇一摇
    if([codeString isEqualToString:@"SHAKE_KEYS"])
    {
        //获取摇一摇摇到的用户ID
        NSString *shakeUserID = [NSString stringWithFormat:@"%@",dict[@"user"]];
        //发送通知 通知摇一摇的界面
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:@"sendShakeUserID" object:nil userInfo:@{@"shakeUserID":shakeUserID}];
        
    }
    //创建用户组
    if([codeString isEqualToString:@"PULL_US"])
    {
//        //得到创建用户组的gname
//        NSString *gnameString = dict[@"gname"];
//        [[NSUserDefaults standardUserDefaults]setObject:gnameString forKey:MyGname];
//        [[NSUserDefaults standardUserDefaults]synchronize];
//        
//        //1.添加到喵喵消息表
//        NSMutableDictionary *adddict = [[NSMutableDictionary alloc]init];
//        NSString *idNumberString = dict[@"gname"];
//        NSNumber *idNumber = [[NSNumber alloc]initWithInt:idNumberString.intValue];
//        [adddict setObject:idNumber forKey:@"senderID"];
//        
//        [adddict setObject:@"3" forKey:@"miaomiaoTypeID"];
//        [adddict setObject:@"" forKey:@"portrait"];
//        [adddict setObject:@"" forKey:@"name"];
//        [adddict setObject:@"" forKey:@"remark"];
//        
//        //表示新增加的未读消息
//        [adddict setObject:@"1" forKey:@"unread"];
//        
//        [[myAppDataBase sharedInstance]addMiaoMiaoReordWithDicitionary:adddict recordType:RecoredTypeAttention];

        
    }
    //拉用户进组(组已经存在拉别人进组)
    if([codeString isEqualToString:@"PULL_IN_G"])
    {
//        //1.添加到喵喵消息表
//        NSMutableDictionary *adddict = [[NSMutableDictionary alloc]init];
//        NSString *idNumberString = dict[@"gname"];
//        NSNumber *idNumber = [[NSNumber alloc]initWithInt:idNumberString.intValue];
//        [adddict setObject:idNumber forKey:@"senderID"];
//        
//        [adddict setObject:@"3" forKey:@"miaomiaoTypeID"];
//        [adddict setObject:@"" forKey:@"portrait"];
//        [adddict setObject:@"" forKey:@"name"];
//        [adddict setObject:@"" forKey:@"remark"];
//        
//        //表示新增加的未读消息
//        [adddict setObject:@"1" forKey:@"unread"];
//        
//        [[myAppDataBase sharedInstance]addMiaoMiaoReordWithDicitionary:adddict recordType:RecoredTypeAttention];
    }
    
    
    //获取用户所在聊天组 （需要删除用户所在商家聊天室的所在组）
    if([codeString isEqualToString:@"USER_GROUPS"])
    {
        
    }
    //获取商店聊天室的gname
    if([codeString isEqualToString:@"SHOP_GNAME"])
    {
        NSString *shopGnameString = dict[@"gname"];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:@"startLoadShopGname" object:nil userInfo:@{@"myShopGname":shopGnameString}];
        
    }
    //接受邀请消息
    if([codeString isEqualToString:@"ACCEPT"])
    {
//        //1.添加到喵喵消息表
//        NSMutableDictionary *adddict = [[NSMutableDictionary alloc]init];
//        NSString *idNumberString = dict[@"gname"];
//        NSNumber *idNumber = [[NSNumber alloc]initWithInt:idNumberString.intValue];
//        [adddict setObject:idNumber forKey:@"senderID"];
//        
//        [adddict setObject:@"3" forKey:@"miaomiaoTypeID"];
//        [adddict setObject:@"" forKey:@"portrait"];
//        [adddict setObject:@"" forKey:@"name"];
//        [adddict setObject:@"" forKey:@"remark"];
//        
//        //表示新增加的未读消息
//        [adddict setObject:@"1" forKey:@"unread"];
//        
//       // [[myAppDataBase sharedInstance]addMiaoMiaoReordWithDicitionary:adddict recordType:RecoredTypeAttention];

    }
    
    //添加好友时  收到的添加好友发起者的信息  ——————对于收到者的界面显示
    if([codeString isEqualToString:@"ADD_FRIEND"])
    {
        NSMutableDictionary *adddict = [[NSMutableDictionary alloc]init];
        
        NSDictionary *informationDict = dict[@"arguments"];
        
       // NSLog(@">>>>>>>>>>>>>>>收到的好友请求%@",informationDict);
        
        NSString *idNumberString = informationDict[@"invitor_id"];
        NSNumber *idNumber = [[NSNumber alloc]initWithInt:idNumberString.intValue];
        [adddict setObject:idNumber forKey:@"senderID"];
        //加好友喵喵类型为4
        NSString *miaomiaoTypeString = [NSString stringWithFormat:@"4"];
        [adddict setObject:miaomiaoTypeString forKey:@"miaomiaoTypeID"];
        [adddict setObject:informationDict[@"invitor_portrait"] forKey:@"portrait"];
        [adddict setObject:informationDict[@"invitor_name"] forKey:@"name"];
        [adddict setObject:informationDict[@"remark"] forKey:@"remark"];
        
        //表示新增加的未读消息
        NSString *unReadString = [NSString stringWithFormat:@"1"];
        [adddict setObject:unReadString forKey:@"unread"];
        [adddict setObject:@"" forKey:@"users"];
        
        NSLog(@"存入数组库的数组%@",adddict);
        
        if([[myAppDataBase sharedInstance]isExistMiaoMiaoRecordWithSenderID:idNumber miaomiaoType:@"4"])
        {
            [[myAppDataBase sharedInstance]deleteMiaoMiaoRecordWithSenderID:idNumber miaomiaoType:@"4"];
        }
        [[myAppDataBase sharedInstance]addMiaoMiaoReordWithDicitionary:adddict recordType:RecoredTypeAttention];
    }
    
    //当添加好友的接受者接受添加好友和拒绝添加好友（当为接受的时候 好友关系保存到本地数据库  喵喵消息界面提示接受添加）(当为拒绝的时候 好友关系不保存 喵喵消息界面提示拒绝添加) ——————————对于发起者的界面显示 （这里用数据中的remark字段代替accept  来显示是否接受添加好友）
    if([codeString isEqualToString:@"CON_FRIEND"])
    {
        NSMutableDictionary *adddict = [[NSMutableDictionary alloc]init];
        
        NSDictionary *informationDict = dict[@"arguments"];
        NSString *idNumberString = informationDict[@"receivor_id"];
        NSNumber *idNumber = [[NSNumber alloc]initWithInt:idNumberString.intValue];
        [adddict setObject:idNumber forKey:@"senderID"];
       
        [adddict setObject:@"5" forKey:@"miaomiaoTypeID"];
        [adddict setObject:informationDict[@"receivor_portrait"] forKey:@"portrait"];
        [adddict setObject:informationDict[@"receivor_name"] forKey:@"name"];
        
        //1接受 0拒绝
        [adddict setObject:dict[@"accept"] forKey:@"remark"];
        
        //表示新增加的未读消息
        [adddict setObject:@"1" forKey:@"unread"];
        [adddict setObject:@"" forKey:@"users"];
        [[myAppDataBase sharedInstance]addMiaoMiaoReordWithDicitionary:adddict recordType:RecoredTypeAttention];
        
        //判断（当为接受的时候 需要在本地保存好友关系）
        NSString *acceptString = [NSString stringWithFormat:@"%@",dict[@"accept"]];
        if([acceptString isEqualToString:@"1"])
        {
                        //好友关系保存到本地数据库中 -（对于发起者而言）
//                        NSString *senderIDString = dict[@"senderID"];
//                        NSNumber *senderIDNumber = [[NSNumber alloc]initWithInt:senderIDString.intValue];
            if(![[myAppDataBase sharedInstance]isExistUserInformationRecordWithUserID:idNumberString recordType:RecoredTypeAttention])
            {
                        NSMutableDictionary *addDict = [[NSMutableDictionary alloc]init];
                        NSString *mcodeString = [NSString stringWithFormat:@"m%@",idNumberString];
                        [addDict setObject:idNumber forKey:@"frdID"];
                        [addDict setObject:@"" forKey:@"rmkName"];
                        [addDict setObject:informationDict[@"receivor_name"] forKey:@"nickName"];
                        [addDict setObject:mcodeString forKey:@"mcode"];
                        [addDict setObject:informationDict[@"receivor_portrait"] forKey:@"portrait"];
            
                            [[myAppDataBase sharedInstance]addUserInformationRecordWithDicitionary:addDict recordType:RecoredTypeAttention];
            }

        }
        
    }
    
    //商家粉丝店的推送消息
    if([codeString isEqualToString:@"SEND_FANS_M"])
    {
        
        //1.添加到喵喵消息表
        NSMutableDictionary *adddict = [[NSMutableDictionary alloc]init];
        NSString *idNumberString = dict[@"shop"];
        NSNumber *idNumber = [[NSNumber alloc]initWithInt:idNumberString.intValue];
        [adddict setObject:idNumber forKey:@"senderID"];
        
        [adddict setObject:@"2" forKey:@"miaomiaoTypeID"];
        [adddict setObject:@"" forKey:@"portrait"];
        [adddict setObject:@"" forKey:@"name"];
        [adddict setObject:@"" forKey:@"remark"];
        
        [adddict setObject:@"" forKey:@"users"];
        //表示新增加的未读消息
        [adddict setObject:@"1" forKey:@"unread"];
    
        //2.添加到商家推送消息表中
        
        NSMutableDictionary *addDict2 = [[NSMutableDictionary alloc]init];
       // NSMutableDictionary *shopPushMessageDict = dict[@"body"];
        [addDict2 setObject:idNumber forKey:@"shopID"];
        [addDict2 setObject:dict[@"body"] forKey:@"text"];
        [addDict2 setObject:dict[@"time"] forKey:@"time"];
        
        //先判断是否设置了接受粉丝店的消息
        NSArray *fansShopInformationArray = [[myAppDataBase sharedInstance]getOneFansShopRecordWith:idNumber];
        fansShopDataBaseModel *model = fansShopInformationArray[0];
        if([model.msgEnable isEqualToString:@"1"])
        {
            
            //先判断喵喵消息表中是否存在当前商家的推送的消息（存在则合并，不存在则插入）
            if([[myAppDataBase sharedInstance]isExistMiaoMiaoRecordWithSenderID:idNumber miaomiaoType:@"2"])
            {
                [[myAppDataBase sharedInstance]deleteMiaoMiaoRecordWithSenderID:idNumber miaomiaoType:@"2"];
            }
        [[myAppDataBase sharedInstance]addMiaoMiaoReordWithDicitionary:adddict recordType:RecoredTypeAttention];
            
        [[myAppDataBase sharedInstance]addShopPushRecordWithDicitionary:addDict2 recordType:RecoredTypeAttention];
        }
    }
    
    //换设备登录提示更新
    if([codeString isEqualToString:@"CHANGE_DEVICE"])
    {
        
        //1表示更新完毕  0表示需要更新
        
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:UserDevice];
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:IsTogetherFriend];
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:IsTogetherFansShop];
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:IsTogetherCollection];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}

-(void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"错误 = %@",error);
    //自己主动断开链接  和意外断开连接 （连接错误的话 都要进行连接）
    //意外断开链接4秒后重新链接
    __block int timeout=4; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self openChatSocket];
                
            });
        }else{
            timeout--;
        }
    });
    dispatch_resume(_timer);
    
}
-(void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"webSocket closed reason = %@   code = %ld clean = %d ",reason,code,wasClean);
    
    if([reason isEqualToString:@"myClosedSocket"])
    {
        NSLog(@"我自己正常关闭聊天的链接");
    }
    if(code == 1005)
    {
        
    }
    if(code == 1001)

    {
//    自己主动断开链接  和意外断开连接
//    意外断开链接30秒后重新链接
    __block int timeout=4; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
               
                [self openChatSocket];
                
            });
        }else{
            timeout--;
        }
    });
    dispatch_resume(_timer);
    }
}


//获取商店聊天室名称
-(void)YBGetShopGnameWithShopID:(NSString *)shopIDString
{
    //NSDictionary *dict = @{@"c":@"SHOP_GNAME",@"sid":shopIDString};
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:@"SHOP_GNAME" forKey:@"c"];
    [dict setObject:shopIDString forKey:@"sid"];
    NSString *jsonString = [dict JSONString];
    [self.webSocket send:jsonString];
}

//用户进入商店的聊天室
-(void)YBEnterShopWithUserName:(NSString *)userName andGname:(NSString *)gname
{
    //NSDictionary *dict = @{@"c":@"ENTR_GROUP",@"user":userName,@"gname":gname};
     NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:@"ENTR_GROUP" forKey:@"c"];
    [dict setObject:userName forKey:@"user"];
    [dict setObject:gname forKey:@"gname"];
    NSString *jsonString = [dict JSONString];
    [self.webSocket send:jsonString];
}

//获取组成员信息
-(void)YBGetGroupUsersWithGname:(NSString *)gname
{
   // NSDictionary *dict = @{@"c":@"GROUP_USERS",@"gname":gname};
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:@"GROUP_USERS" forKey:@"c"];
    [dict setObject:gname forKey:@"gname"];
    NSString *jsonString = [dict JSONString];
    [self.webSocket send:jsonString];
}

//用户发送消息（用户发给聊天组）
-(void)YBSendMessageFromUser:(NSString *)user toGname:(NSString *)gname message:(NSString *)message messageType:(NSString *)messageType
{
    //消息体  
    //NSDictionary *messageBodyDict = @{@"user":user,@"time":@"",@"mtype":messageType,@"m":message};
    NSDictionary *messageBodyDict = [[NSDictionary alloc]initWithObjectsAndKeys:user,@"user",@"",@"time",messageType,@"mtype",message,@"m", nil];
    
//    //根据发送方和接收方的ID的大小比较得到结果填写字段
//    NSString *messageGname = [[NSString alloc]init];
//    if(user.intValue > gname.intValue)
//    {
//        messageGname = [NSString stringWithFormat:@"e2e_%@_%@",user,gname];
//    }
//    else
//    {
//        messageGname = [NSString stringWithFormat:@"e2e_%@_%@",gname,user];
//    }
    
    //NSDictionary *dict = @{@"c":@"CHAT_M",@"gname":messageGname,@"body":messageBodyDict};
    NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:@"CHAT_M",@"c",gname,@"gname",messageBodyDict,@"body", nil];
    NSString *jsonString = [dict JSONString];
    [self.webSocket send:jsonString];
}
//发送消息 （mmx ——商品,活动,商店）
-(void)YBsendMMXMessageFromUser:(NSString *)user toGname:(NSString *)gname mmxID:(NSString *)mmxID mmxImg:(NSString *)mmxImg mmxName:(NSString *)mmxName messageType:(NSString *)messageType
{
    NSDictionary *messageBodyDetailDict = [[NSDictionary alloc]initWithObjectsAndKeys:mmxID,@"id",mmxImg,@"img",mmxName,@"name" ,nil];
    NSDictionary *messageBodyDict = [[NSDictionary alloc]initWithObjectsAndKeys:user,@"user",@"",@"time",messageType,@"mtype",messageBodyDetailDict,@"m", nil];
    NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:@"CHAT_M",@"c",gname,@"gname",messageBodyDict,@"body", nil];
    NSString *jsonString = [dict JSONString];
    [self.webSocket send:jsonString];
    
}

//用户发送消息（用户发给用户 用户发给店主 ————单聊）
-(void)YBSendOnlyChatMessageFromUser:(NSString *)user toGname:(NSString *)gname message:(NSString *)message messageType:(NSString *)messageType
{
    NSDictionary *messageBodyDict = [[NSDictionary alloc]initWithObjectsAndKeys:user,@"user",@"",@"time",messageType,@"mtype",message,@"m", nil];
    
        //根据发送方和接收方的ID的大小比较得到结果填写字段
        NSString *messageGname = [[NSString alloc]init];
        if(user.intValue > gname.intValue)
        {
            messageGname = [NSString stringWithFormat:@"e2e_%@_%@",user,gname];
        }
        else
        {
            messageGname = [NSString stringWithFormat:@"e2e_%@_%@",gname,user];
        }
    
    //NSDictionary *dict = @{@"c":@"CHAT_M",@"gname":messageGname,@"body":messageBodyDict};
    NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:@"CHAT_M",@"c",messageGname,@"gname",messageBodyDict,@"body", nil];
    NSString *jsonString = [dict JSONString];
    [self.webSocket send:jsonString];

}


//退出聊天组
-(void)YBExitGroupWithUser:(NSString *)user andGname:(NSString *)gname
{
    //NSDictionary *dict = @{@"c":@"EXIT_G",@"user":user,@"gname":gname};
    NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:@"EXIT_G",@"c",user,@"user",gname,@"gname", nil];
   // NSLog(@"退出组的字典%@",dict);
    
    NSString *jsonString = [dict JSONString];
    [self.webSocket send:jsonString];
    
}

//拉多个用户（创建用户组）拉单个用户直接发消息
-(void)YBCreateGroupWithMasterUser:(NSString *)masterUser andPullInOthers:(NSArray *)otherUsersArray
{
    //NSDictionary *dict = @{@"c":@"PULL_US",@"master":masterUser,@"clients":otherUsersArray};
    NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:@"PULL_US",@"c",masterUser,@"master",otherUsersArray,@"clients", nil];
   // NSLog(@"创建讨论组发送的字典%@",dict);
    NSString *jsonString = [dict JSONString];
    [self.webSocket send:jsonString];
}

//接受邀请消息
-(void)YBAcceptInvitationFromGname:(NSString *)gname
{
   // NSDictionary *dict = @{@"c":@"ACCEPT",@"gname":gname};
    
    NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:@"ACCEPT",@"c",gname,@"gname", nil];
    NSString *jsonString = [dict JSONString];
    [self.webSocket send:jsonString];
}

//拉用户进组（组已经存在）
-(void)YBPullInUsersToGroupWithGname:(NSString *)gname andOtherUsersArray:(NSArray *)otherUsersArray
{
   // NSDictionary *dict = @{@"c":@"PULL_IN_G",@"gname":gname,@"clients":otherUsersArray};
    NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:@"PULL_IN_G",@"c",gname,@"gname",otherUsersArray,@"clients", nil];
    NSLog(@"存在讨论组 谈论组中拉人字典 %@",dict);
    NSString *jsonString = [dict JSONString];
    [self.webSocket send:jsonString];
}

//获取聊天记录（获取哪个组的 从什么时候获取的 多少条的聊天记录）
-(void)YBGetRecordWithGname:(NSString *)gname andStartTime:(NSString *)startTime andRecordCount:(NSString *)recordCount
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:@"GET_RECORD" forKey:@"c"];
    [dict setObject:gname forKey:@"gname"];
    [dict setObject:startTime forKey:@"stime"];
    [dict setObject:recordCount forKey:@"limit"];
    NSString *jsonString = [dict JSONString];
    [self.webSocket send:jsonString];
}

//摇一摇
-(void)YBShakeWithUser:(NSString *)user
{
    //NSDictionary *dict = @{@"c":@"SHAKE",@"user":user};
    NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:@"SHAKE",@"c",user,@"user", nil];
    NSString *jsonString = [dict JSONString];
    [self.webSocket send:jsonString];
}

//发消息给粉丝店
-(void)YBSendMessageToFansShopFromUser:(NSString *)user message:(NSString *)message messageType:(NSString *)messageType
{
   // NSDictionary *messageDict = @{@"user":user,@"time":@"",@"mtype":messageType,@"m":message};
    //NSDictionary *dict = @{@"c":@"SEND_FANS_M",@"body":messageDict};
    
    NSDictionary *messageDict = [[NSDictionary alloc]initWithObjectsAndKeys:user,@"user",@"",@"time",messageType,@"mtype",message,@"m", nil];
    NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:@"SEND_FANS_M",@"c",messageDict,@"body", nil];
    NSString *jsonString = [dict JSONString];
    
    [self.webSocket send:jsonString];
}

//获取用户组信息
-(void)YBGetGroupInformationWithUser:(NSString *)user
{
    //NSDictionary *dict = @{@"c":@"USER_GROUPS",@"user":user};
    NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:@"USER_GROUPS",@"c",user,@"user", nil];
    NSString *jsonString = [dict JSONString];
    [self.webSocket send:jsonString];
}

-(void)webSocketDidSendMessage:(NSString *)message
{
    //发送消息
    [_webSocket send:message];
}
@end
