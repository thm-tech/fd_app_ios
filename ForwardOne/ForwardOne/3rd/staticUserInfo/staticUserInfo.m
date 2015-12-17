//
//  staticUserInfo.m
//  ForwardOne
//
//  Created by 杨波 on 15/7/21.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "staticUserInfo.h"
#import "myAppDataBase.h"
#import "fansShopDataBaseModel.h"

#define MESSAGEGROUPUSERINFORMATIONURL @"http://%@/user/info?uid=%d"

#define KINDSOFID @"http://%@/userweb/account/%@"

//店内主信息URL
#define INSHOPMAINURL @"http://%@/user/shop/info?sid=%d"

static NSMutableDictionary *userInfo;
static NSMutableDictionary *gnameInformation;

@implementation staticUserInfo
{
    NSMutableDictionary *dict;
}

-(id)init
{
    self = [super init];
    if(self != nil)
    {
        
        userInfo = [[NSMutableDictionary alloc]init];
        gnameInformation = [[NSMutableDictionary alloc]init];
    }
    return self;
}
//添加聊天组的名字缓存在内存中(由聊天组内成员组成，由协议获得,不包括消息里面退出群组的用户)
+(void)addGruopNameToGname:(NSString *)gname withGruopName:(NSString *)groupName
{

    NSMutableDictionary *dict = gnameInformation[gname];
    if([dict allKeys].count != 0)
    {
        [dict setObject:groupName forKey:@"groupName"];
        [gnameInformation setObject:dict forKey:gname];
    }
    else
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setObject:groupName forKey:@"groupName"];
        [gnameInformation setObject:dict forKey:gname];
    }
}

//由gname查询聊天组的名称
+(NSString *)getGroupNameWithGname:(NSString *)gname
{
    NSString *groupNameString = [[NSString alloc]init];
    //从gnameInformation中查出聊天组的名字
    
    NSDictionary *dict = gnameInformation[gname];
    groupNameString = dict[@"groupName"];
    
    return groupNameString;
}

//添加消息
+(void)addMessageToGname:(NSString *)gname withMessageBody:(NSDictionary *)messageBody
{
//    //判断是否已经存在messageBody
//    //先判断
//    NSMutableDictionary *messageBodyDict = userInfo[gname];
//    if([messageBodyDict allKeys].count != 0)
//    {
//        if([[messageBodyDict allKeys]containsObject:@"messages"])
//        {
//            
//            NSMutableArray *array = messageBodyDict[@"messages"];
//            
//            [array addObject:messageBody];
//            [messageBodyDict setObject:array forKey:@"messages"];
//            [gnameInformation setObject:messageBodyDict forKey:gname];
//        }
//        else
//        {
//            
//                NSMutableArray *messageArray = [[NSMutableArray alloc]init];
//                [messageArray addObject:messageBody];
//                [messageBodyDict setObject:messageArray forKey:@"messages"];
//                [gnameInformation setObject:messageBodyDict forKey:gname];
//      
//        }
//    }
//    else
//    {
//        NSMutableDictionary *messageDetail = [[NSMutableDictionary alloc]init];
//        NSMutableArray *messageArray = [[NSMutableArray alloc]init];
//        [messageArray addObject:messageBody];
//        [messageDetail setObject:messageArray forKey:@"messages"];
//        [gnameInformation setObject:messageDetail forKey:gname];
//        
//    }
    //存入数据库
    [[myAppDataBase sharedInstance]addMessagesWith:gname andMessageBody:messageBody];
}

//由gname获得聊天记录 
+(NSArray *)getMessagesWithGname:(NSString *)gname
{
    NSArray *messageArray = [[NSArray alloc]init];
//    if([[gnameInformation allKeys]containsObject:gname])
//    {
//        NSMutableDictionary *gnameDetailDict = gnameInformation[gname];
//        if([gnameDetailDict allKeys].count != 0)
//        {
//            if([[gnameDetailDict allKeys]containsObject:@"messages"])
//            {
//                //缓存中有
//                NSDictionary *dict = gnameInformation[gname];
//                NSArray *array = dict[@"messages"];
//                messageArray = array;
//            }
//            else
//            {
//                //从数据库中取出来
//                NSArray *array = [[myAppDataBase sharedInstance]getMessagesWithGname:gname];
//                //填充缓存
//                [gnameDetailDict setObject:array forKey:@"messages"];
//                [gnameInformation setObject:gnameDetailDict forKey:gname];
//            }
//        }
//        else
//        {
//            //从数据库取
//            NSArray *array = [[myAppDataBase sharedInstance]getMessagesWithGname:gname];
//            //填充缓存
//            NSMutableDictionary *messageDetailDict = [[NSMutableDictionary alloc]init];
//            [messageDetailDict setObject:array forKey:@"messages"];
//            [gnameInformation setObject:messageDetailDict forKey:gname];
//            messageArray = array;
//
//        }
//        
//    }
//    else
//    {
//        //从数据库取
//        NSArray *array = [[myAppDataBase sharedInstance]getMessagesWithGname:gname];
//        //填充缓存
//        NSMutableDictionary *messageDetailDict = [[NSMutableDictionary alloc]init];
//        [messageDetailDict setObject:array forKey:@"messages"];
//        [gnameInformation setObject:messageDetailDict forKey:gname];
//        messageArray = array;
//
//    }
    
    NSArray *array = [[myAppDataBase sharedInstance]getMessagesWithGname:gname];
    messageArray = array;
        
    return messageArray;
    
}

//由game获得组内userID (从组内messageBody中获取 即使退出群组了 但是消息记录还在 也能获取到UserID)
+(NSArray *)getUserIDFromMessageBodyWithGname:(NSString *)gname
{
    //得到消息记录面的userID
    NSMutableArray *userIDArray = [[NSMutableArray alloc]init];
    
    //由gname得到消息的数组
    NSArray *messageArray = [self getMessagesWithGname:gname];
    for(NSDictionary *messageDict in messageArray)
    {
        NSString *userIDString = messageDict[@"user"];
        [userIDArray addObject:userIDString];
    }
    
    return userIDArray;
}


//根据userID得到user信息 （好友信息都保存在本地 陌生人的信息都从网络上去获取）
+(NSDictionary *)getUserInformationWithUserID:(NSString *)userID
{
    
    //先判断ID是用户ID还是商店的ID （用于用户和商家之间的聊天）
   if([[myAppDataBase sharedInstance]isExistUserInformationRecordWithUserID:userID recordType:RecoredTypeAttention])
   {
       NSDictionary *dict = [[myAppDataBase sharedInstance]getUserInformationRecordWithUserID:userID];
       return dict;
   }
   else
    {
        NSMutableDictionary *isExistFansShopDict = [[NSMutableDictionary alloc]init];
        NSString *shopIDString = [NSString stringWithFormat:@"%@",userID];
        NSNumber  *shopID = [[NSNumber alloc]initWithInt:shopIDString.intValue];
        [isExistFansShopDict setObject:shopID forKey:@"id"];
        
        if([[myAppDataBase sharedInstance]isExistFansShopRecordWithDicitionary:isExistFansShopDict recordType:RecoredTypeAttention])
        {
            NSArray *shopInformationArray = [[myAppDataBase sharedInstance]getOneFansShopRecordWith:shopID];
            NSLog(@"商家的信息 = %@",shopInformationArray);
            fansShopDataBaseModel *model = shopInformationArray[0];
            NSMutableDictionary *shopDict = [[NSMutableDictionary alloc]init];
            
            [shopDict setObject:model.name forKey:@"rmkName"];
            [shopDict setObject:model.pic forKey:@"portrait"];
            return shopDict;

        }
        else
        {
            
            //判断是商家ID还是用户ID
            NSString *kindsOfIDUrlString = [NSString stringWithFormat:KINDSOFID,DomainName,userID];
            NSURL *kindsUrl = [NSURL URLWithString:kindsOfIDUrlString];
            NSURLRequest *kindsRequest = [NSURLRequest requestWithURL:kindsUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
            NSData *kindsData = [NSURLConnection sendSynchronousRequest:kindsRequest returningResponse:nil error:nil];
            NSString *kindsStr = [[NSString alloc]initWithData:kindsData encoding:NSUTF8StringEncoding];
            NSDictionary *kindsDict = [kindsStr objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
            
            NSLog(@"商家和用户不同的字典 = %@",kindsDict);
            
            NSString *typeString = [NSString stringWithFormat:@"%@",kindsDict[@"acc_type"]];
            
            if([typeString isEqualToString:@"4"])
            {
                NSString *string = [NSString stringWithFormat:MESSAGEGROUPUSERINFORMATIONURL,DomainName,userID.intValue];
                //使用get的同步请求
                NSURL *url = [NSURL URLWithString:string];
                NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
                NSData *received = [NSURLConnection  sendSynchronousRequest:request returningResponse:nil error:nil];
                NSString *str = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
                NSDictionary *dict = [str objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
                NSArray *userArray = dict[@"userList"];
                NSDictionary *userDict = userArray[0];
                // NSLog(@"陌生人信息的字典  = %@",dict);
                return userDict;

            }
            else if ([typeString isEqualToString:@"5"])
            {
                //下载商家信息
                NSString *shopInfoString = [NSString stringWithFormat:INSHOPMAINURL,DomainName,shopIDString.intValue];
                NSURL *skindsUrl = [NSURL URLWithString:shopInfoString];
                NSURLRequest *skindsRequest = [NSURLRequest requestWithURL:skindsUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
                NSData *skindsData = [NSURLConnection sendSynchronousRequest:skindsRequest returningResponse:nil error:nil];
                NSString *skindsStr = [[NSString alloc]initWithData:skindsData encoding:NSUTF8StringEncoding];
                NSDictionary *skindsDict = [skindsStr objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
                NSDictionary *shopInfomationDict = skindsDict[@"info"];
                NSArray *picArray = shopInfomationDict[@"picList"];
                NSMutableDictionary *shopDict = [[NSMutableDictionary alloc]init];
                [shopDict setObject:shopInfomationDict[@"name"] forKey:@"rmkName"];
                [shopDict setObject:picArray[0] forKey:@"portrait"];
                return shopDict;

            }
            else
            {
                return nil;
            }
        }
    }
    
    
    
//    
//    NSString *kindsOfIDUrlString = [NSString stringWithFormat:KINDSOFID,DomainName,userID];
//    NSURL *kindsUrl = [NSURL URLWithString:kindsOfIDUrlString];
//    NSURLRequest *kindsRequest = [NSURLRequest requestWithURL:kindsUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
//    NSData *kindsData = [NSURLConnection sendSynchronousRequest:kindsRequest returningResponse:nil error:nil];
//    NSString *kindsStr = [[NSString alloc]initWithData:kindsData encoding:NSUTF8StringEncoding];
//    NSDictionary *kindsDict = [kindsStr objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
//    
//    NSLog(@"商家和用户不同的字典 = %@",kindsDict);
//    
//    NSString *typeString = [NSString stringWithFormat:@"%@",kindsDict[@"acc_type"]];
//    
//    if([typeString isEqualToString:@"4"])
//    {
//        if([[myAppDataBase sharedInstance]isExistUserInformationRecordWithUserID:userID recordType:RecoredTypeAttention])
//        {
//            NSDictionary *dict = [[myAppDataBase sharedInstance]getUserInformationRecordWithUserID:userID];
//            return dict;
//            //[userInfo setObject:dict forKey:userID];
//            //userDict = userInfo[userID];
//        }
//        else
//        {
//            
//            NSString *string = [NSString stringWithFormat:MESSAGEGROUPUSERINFORMATIONURL,DomainName,userID.intValue];
//            //使用get的同步请求
//            NSURL *url = [NSURL URLWithString:string];
//            NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
//            NSData *received = [NSURLConnection  sendSynchronousRequest:request returningResponse:nil error:nil];
//            NSString *str = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
//            NSDictionary *dict = [str objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
//            NSArray *userArray = dict[@"userList"];
//            NSDictionary *userDict = userArray[0];
//            // NSLog(@"陌生人信息的字典  = %@",dict);
//            return userDict;
//            
//        }
//
//    }
//    else if ([typeString isEqualToString:@"5"])
//    {
//        //先判断是不是粉丝店
//        
//        NSMutableDictionary *isExistFansShopDict = [[NSMutableDictionary alloc]init];
//        NSString *shopIDString = [NSString stringWithFormat:@"%@",userID];
//        NSNumber  *shopID = [[NSNumber alloc]initWithInt:shopIDString.intValue];
//        [isExistFansShopDict setObject:shopID forKey:@"id"];
//        
//        if([[myAppDataBase sharedInstance]isExistFansShopRecordWithDicitionary:isExistFansShopDict recordType:RecoredTypeAttention])
//        {
//        
//        NSArray *shopInformationArray = [[myAppDataBase sharedInstance]getOneFansShopRecordWith:shopID];
//        NSLog(@"商家的信息 = %@",shopInformationArray);
//        fansShopDataBaseModel *model = shopInformationArray[0];
//        NSMutableDictionary *shopDict = [[NSMutableDictionary alloc]init];
//            
//        [shopDict setObject:model.name forKey:@"rmkName"];
//        [shopDict setObject:model.pic forKey:@"portrait"];
//        return shopDict;
//        }
//        else
//        {
//            //下载商家信息
//            NSString *shopInfoString = [NSString stringWithFormat:INSHOPMAINURL,DomainName,shopIDString.intValue];
//            NSURL *skindsUrl = [NSURL URLWithString:shopInfoString];
//            NSURLRequest *skindsRequest = [NSURLRequest requestWithURL:skindsUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
//            NSData *skindsData = [NSURLConnection sendSynchronousRequest:skindsRequest returningResponse:nil error:nil];
//            NSString *skindsStr = [[NSString alloc]initWithData:skindsData encoding:NSUTF8StringEncoding];
//            NSDictionary *skindsDict = [skindsStr objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
//            NSDictionary *shopInfomationDict = skindsDict[@"info"];
//            NSArray *picArray = shopInfomationDict[@"picList"];
//            NSMutableDictionary *shopDict = [[NSMutableDictionary alloc]init];
//            [shopDict setObject:shopInfomationDict[@"name"] forKey:@"rmkName"];
//            [shopDict setObject:picArray[0] forKey:@"portrait"];
//            return shopDict;
//            
//        }
//    }
//    else
//    {
//        return nil;
//    }
//    
       //__block NSDictionary *userDict = [[NSDictionary alloc]init];

}


@end
