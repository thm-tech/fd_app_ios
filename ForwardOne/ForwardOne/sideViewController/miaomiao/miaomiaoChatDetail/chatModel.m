//
//  chatModel.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/22.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "chatModel.h"

//消息内容
#import "UUMessage.h"
#import "UUMessageFrame.h"
#import "staticUserInfo.h"
#import "JSONKit.h"

#import <AVFoundation/AVFoundation.h>

@implementation chatModel

static NSString *previousMyTime = nil;
//数据源数组包括所有的消息（自己的消息也在里面）
-(void)populateRandomDataSource:(NSArray *)array
{
    
    
    self.dataSource = [NSMutableArray array];
    NSMutableArray *result = [NSMutableArray array];
    //根据传过来的消息数组 得到完善的个人资料的消息数组
     NSMutableArray *allInformationArray = [[NSMutableArray alloc]init];
    
    for(int i = 0;i<array.count;i++)
    {
        NSDictionary *messageDetailDict = array[i];
       // NSLog(@"chatModel里面消息数组的每一个消息字典 = %@",messageDetailDict);
        NSString *userIDString = messageDetailDict[@"user"];
        NSDictionary *userInformationDict = [staticUserInfo getUserInformationWithUserID:userIDString];
        //NSLog(@"获取的字典获取的字典%@",userInformationDict);
       __block NSMutableDictionary *allInformationDict = [[NSMutableDictionary alloc]init];
        
        //赋值user完整信息的字典
        
        //判断消息是否是自己发出的
        NSString *myIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
        
        NSString *chatUserString = [NSString stringWithFormat:@"%@",messageDetailDict[@"user"]];
        if([myIDString isEqualToString:chatUserString])
        {
            //自己发送的消息  自己发送的消息
            [allInformationDict setObject:@(UUMessageFromMe) forKey:@"from"];
            NSString *myNickName = [[NSUserDefaults standardUserDefaults]objectForKey:MyNickName];
            
            [allInformationDict setObject:myNickName forKey:@"strName"];
            
            NSString *myHeadImageUrl = [[NSUserDefaults standardUserDefaults]objectForKey:MyPhotoImageURL];
            [allInformationDict setObject:myHeadImageUrl forKey:@"strIcon"];
            
        }
        else
        {
            [allInformationDict setObject:@(UUMessageFromOther) forKey:@"from"];
            //用户头像
            [allInformationDict setObject:userInformationDict[@"portrait"] forKey:@"strIcon"];
            
            NSString *userRmkName = userInformationDict[@"rmkName"];
            
            //判断是否存在备注名字
            if(userRmkName.length != 0)
            {
                [allInformationDict setObject:userInformationDict[@"rmkName"] forKey:@"strName"];
            }
            else
            {
                [allInformationDict setObject:userInformationDict[@"nickName"] forKey:@"strName"];
            }
            
        }
        //时间  由时间戳获取到当前时间
        NSString *timeString = [NSString stringWithFormat:@"%@",messageDetailDict[@"time"]];
        NSTimeInterval timeInterval = timeString.floatValue;
        timeInterval = timeInterval;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        //设置时间的格式
        NSString *finalDate = [[NSString alloc]init];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateStyle:kCFDateFormatterFullStyle];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        finalDate  = [formatter stringFromDate:date];
        [allInformationDict setObject:finalDate forKey:@"strTime"];

        
        //判断消息类型 文字 图片 语音
        if([messageDetailDict[@"mtype"] isEqualToString:@"text"])
        {
            [allInformationDict setObject:messageDetailDict[@"m"] forKey:@"strContent"];
            [allInformationDict setObject:@(UUMessageTypeText) forKey:@"type"];
        }
        else if ([messageDetailDict[@"mtype"] isEqualToString:@"image/png"]||[messageDetailDict[@"mtype"] isEqualToString:@"image/jpg"]||[messageDetailDict[@"mtype"] isEqualToString:@"image/jpeg"])
        {
            [allInformationDict setObject:messageDetailDict[@"m"] forKey:@"picture"];
            [allInformationDict setObject:@(UUMessageTypePicture) forKey:@"type"];
            [allInformationDict setObject:@"" forKey:@"title"];
            [allInformationDict setObject:@"png" forKey:@"mmx/type"];
            
        }
        else if([messageDetailDict[@"mtype"] isEqualToString:@"audio/mp3"])
        {
            
            [allInformationDict setObject:messageDetailDict[@"m"] forKey:@"voice"];
            //语音的时间
            [allInformationDict setObject:@"" forKey:@"strVoiceTime"];
            [allInformationDict setObject:@(UUMessageTypeVoice) forKey:@"type"];
           
        }
        //发送商品
        else if([messageDetailDict[@"mtype"] isEqualToString:@"mmx/goods"])
        {
            NSString *sendDetailString = messageDetailDict[@"m"];
            //NSLog(@"嘿嘿嘿嘿嘿嘿嘿嘿%@",sendDetailString);
            NSDictionary *sendDetailDict = [sendDetailString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
            //NSLog(@"哈哈哈哈哈哈哈%@",sendDetailDict);
             [allInformationDict setObject:sendDetailDict[@"img"] forKey:@"picture"];
            [allInformationDict setObject:@(UUMessageTypePicture) forKey:@"type"];
            [allInformationDict setObject:sendDetailDict[@"name"] forKey:@"title"];
            [allInformationDict setObject:@"mmx/goods" forKey:@"mmx/type"];
        }
        //发送活动
        else if ([messageDetailDict[@"mtype"] isEqualToString:@"mmx/act"])
        {
            NSString *sendDetailString = messageDetailDict[@"m"];
            NSDictionary *sendDetailDict = [sendDetailString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
            
            [allInformationDict setObject:sendDetailDict[@"img"] forKey:@"picture"];
            [allInformationDict setObject:@(UUMessageTypePicture) forKey:@"type"];
            [allInformationDict setObject:sendDetailDict[@"name"] forKey:@"title"];
            [allInformationDict setObject:@"mmx/act" forKey:@"mmx/type"];
        }
        //发送商店
        else if ([messageDetailDict[@"mtype"] isEqualToString:@"mmx/shop"])
        {
            NSString *sendDetailString = messageDetailDict[@"m"];
            NSDictionary *sendDetailDict = [sendDetailString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
            
            [allInformationDict setObject:sendDetailDict[@"img"] forKey:@"picture"];
            [allInformationDict setObject:@(UUMessageTypePicture) forKey:@"type"];
            [allInformationDict setObject:sendDetailDict[@"name"] forKey:@"title"];
            [allInformationDict setObject:@"mmx/shop" forKey:@"mmx/type"];
        }
        
        [allInformationArray addObject:allInformationDict];
    }
    
    for(int i = 0;i<allInformationArray.count;i++)
    {
        NSDictionary *dict = allInformationArray[i];
        UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
        UUMessage *message = [[UUMessage alloc]init];
        [message setWithDict:dict];
        //消息是否显示时间
        [message minuteOffSetStart:previousMyTime end:dict[@"strTime"]];
        //消息是否显示时间传递给UI
        messageFrame.showTime = message.showDateLabel;
        [messageFrame setMessage:message];
        if(message.showDateLabel)
        {
            previousMyTime = dict[@"strTime"];
        }
        
        [result addObject:messageFrame];
    }
    [self.dataSource addObjectsFromArray:result];
    
}

//添加一条聊天消息（来消息来的时候的及时显示）
-(void)insertOneMessageToTableViewWithDict:(NSDictionary *)dict
{
   
        NSDictionary *messageDetailDict = dict;
        // NSLog(@"chatModel里面消息数组的每一个消息字典 = %@",messageDetailDict);
        NSString *userIDString = messageDetailDict[@"user"];
        NSDictionary *userInformationDict = [staticUserInfo getUserInformationWithUserID:userIDString];
        //NSLog(@"获取的字典获取的字典%@",userInformationDict);
        __block NSMutableDictionary *allInformationDict = [[NSMutableDictionary alloc]init];
        
        //赋值user完整信息的字典
        
        //判断消息是否是自己发出的
        NSString *myIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
        
        NSString *chatUserString = [NSString stringWithFormat:@"%@",messageDetailDict[@"user"]];
        if([myIDString isEqualToString:chatUserString])
        {
            //自己发送的消息
            [allInformationDict setObject:@(UUMessageFromMe) forKey:@"from"];
            NSString *myNickName = [[NSUserDefaults standardUserDefaults]objectForKey:MyNickName];
            NSLog(@"我自己的nickName = %@",myNickName);
            [allInformationDict setObject:myNickName forKey:@"strName"];
            
            NSString *myHeadImageUrl = [[NSUserDefaults standardUserDefaults]objectForKey:MyPhotoImageURL];
            [allInformationDict setObject:myHeadImageUrl forKey:@"strIcon"];
            
        }
        else
        {
            [allInformationDict setObject:@(UUMessageFromOther) forKey:@"from"];
            //用户头像
            [allInformationDict setObject:userInformationDict[@"portrait"] forKey:@"strIcon"];
            
            NSString *userRmkName = userInformationDict[@"rmkName"];
            
            //判断是否存在备注名字
            if(userRmkName.length != 0)
            {
                [allInformationDict setObject:userInformationDict[@"rmkName"] forKey:@"strName"];
            }
            else
            {
                [allInformationDict setObject:userInformationDict[@"nickName"] forKey:@"strName"];
            }
            
        }
        //时间  由时间戳获取到当前时间
        NSString *timeString = [NSString stringWithFormat:@"%@",messageDetailDict[@"time"]];
        NSTimeInterval timeInterval = timeString.floatValue;
        timeInterval = timeInterval;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        //设置时间的格式
        NSString *finalDate = [[NSString alloc]init];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateStyle:kCFDateFormatterFullStyle];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        finalDate  = [formatter stringFromDate:date];
        [allInformationDict setObject:finalDate forKey:@"strTime"];
        
        
        //判断消息类型 文字 图片 语音
        if([messageDetailDict[@"mtype"] isEqualToString:@"text"])
        {
            [allInformationDict setObject:messageDetailDict[@"m"] forKey:@"strContent"];
            [allInformationDict setObject:@(UUMessageTypeText) forKey:@"type"];
        }
        else if ([messageDetailDict[@"mtype"] isEqualToString:@"image/png"]||[messageDetailDict[@"mtype"] isEqualToString:@"image/jpg"]||[messageDetailDict[@"mtype"] isEqualToString:@"image/jpeg"])
        {
            [allInformationDict setObject:messageDetailDict[@"m"] forKey:@"picture"];
            [allInformationDict setObject:@(UUMessageTypePicture) forKey:@"type"];
            [allInformationDict setObject:@"" forKey:@"title"];
            [allInformationDict setObject:@"png" forKey:@"mmx/type"];
            
        }
        else if([messageDetailDict[@"mtype"] isEqualToString:@"audio/mp3"])
        {
            
            [allInformationDict setObject:messageDetailDict[@"m"] forKey:@"voice"];
            //语音的时间
            [allInformationDict setObject:@"" forKey:@"strVoiceTime"];
            [allInformationDict setObject:@(UUMessageTypeVoice) forKey:@"type"];
            
        }
        //发送商品
        else if([messageDetailDict[@"mtype"] isEqualToString:@"mmx/goods"])
        {
            NSString *sendDetailString = messageDetailDict[@"m"];
            //NSLog(@"嘿嘿嘿嘿嘿嘿嘿嘿%@",sendDetailString);
            NSDictionary *sendDetailDict = [sendDetailString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
            //NSLog(@"哈哈哈哈哈哈哈%@",sendDetailDict);
            [allInformationDict setObject:sendDetailDict[@"img"] forKey:@"picture"];
            [allInformationDict setObject:@(UUMessageTypePicture) forKey:@"type"];
            [allInformationDict setObject:sendDetailDict[@"name"] forKey:@"title"];
            [allInformationDict setObject:@"mmx/goods" forKey:@"mmx/type"];
        }
        //发送活动
        else if ([messageDetailDict[@"mtype"] isEqualToString:@"mmx/act"])
        {
            NSString *sendDetailString = messageDetailDict[@"m"];
            NSDictionary *sendDetailDict = [sendDetailString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
            
            [allInformationDict setObject:sendDetailDict[@"img"] forKey:@"picture"];
            [allInformationDict setObject:@(UUMessageTypePicture) forKey:@"type"];
            [allInformationDict setObject:sendDetailDict[@"name"] forKey:@"title"];
            [allInformationDict setObject:@"mmx/act" forKey:@"mmx/type"];
        }
        //发送商店
        else if ([messageDetailDict[@"mtype"] isEqualToString:@"mmx/shop"])
        {
            NSString *sendDetailString = messageDetailDict[@"m"];
            NSDictionary *sendDetailDict = [sendDetailString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
            
            [allInformationDict setObject:sendDetailDict[@"img"] forKey:@"picture"];
            [allInformationDict setObject:@(UUMessageTypePicture) forKey:@"type"];
            [allInformationDict setObject:sendDetailDict[@"name"] forKey:@"title"];
            [allInformationDict setObject:@"mmx/shop" forKey:@"mmx/type"];
        }
        
//        [allInformationArray addObject:allInformationDict];
//    }
    
//    for(int i = 0;i<allInformationArray.count;i++)
//    {
//        NSDictionary *dict = allInformationArray[i];
        UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
        UUMessage *message = [[UUMessage alloc]init];
        [message setWithDict:allInformationDict];
        //消息是否显示时间
        [message minuteOffSetStart:previousMyTime end:dict[@"strTime"]];
        //消息是否显示时间传递给UI
        messageFrame.showTime = message.showDateLabel;
        [messageFrame setMessage:message];
        if(message.showDateLabel)
        {
            previousMyTime = dict[@"strTime"];
        }
        
//        [result addObject:messageFrame];
//    }
    [self.dataSource addObject:messageFrame];
}

-(void)addMoreChatData:(NSArray *)array
{
    
    NSMutableArray *result = [NSMutableArray array];
    //根据传过来的消息数组 得到完善的个人资料的消息数组
    NSMutableArray *allInformationArray = [[NSMutableArray alloc]init];
    
    for(int i = array.count-1;i>=0;i--)
    {
        NSDictionary *messageDetailDict = array[i];
        // NSLog(@"chatModel里面消息数组的每一个消息字典 = %@",messageDetailDict);
        NSString *userIDString = messageDetailDict[@"user"];
        NSDictionary *userInformationDict = [staticUserInfo getUserInformationWithUserID:userIDString];
        //NSLog(@"获取的字典获取的字典%@",userInformationDict);
        __block NSMutableDictionary *allInformationDict = [[NSMutableDictionary alloc]init];
        
        //赋值user完整信息的字典
        
        //判断消息是否是自己发出的
        NSString *myIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
        
        NSString *chatUserString = [NSString stringWithFormat:@"%@",messageDetailDict[@"user"]];
        if([myIDString isEqualToString:chatUserString])
        {
            //自己发送的消息
            [allInformationDict setObject:@(UUMessageFromMe) forKey:@"from"];
            NSString *myNickName = [[NSUserDefaults standardUserDefaults]objectForKey:MyNickName];
            
            [allInformationDict setObject:myNickName forKey:@"strName"];
            
            NSString *myHeadImageUrl = [[NSUserDefaults standardUserDefaults]objectForKey:MyPhotoImageURL];
            [allInformationDict setObject:myHeadImageUrl forKey:@"strIcon"];
            
        }
        else
        {
            [allInformationDict setObject:@(UUMessageFromOther) forKey:@"from"];
            //用户头像
            [allInformationDict setObject:userInformationDict[@"portrait"] forKey:@"strIcon"];
            
            NSString *userRmkName = userInformationDict[@"rmkName"];
            
            //判断是否存在备注名字
            if(userRmkName.length != 0)
            {
                [allInformationDict setObject:userInformationDict[@"rmkName"] forKey:@"strName"];
            }
            else
            {
                [allInformationDict setObject:userInformationDict[@"nickName"] forKey:@"strName"];
            }
            
        }
        //时间  由时间戳获取到当前时间
        NSString *timeString = [NSString stringWithFormat:@"%@",messageDetailDict[@"time"]];
        NSTimeInterval timeInterval = timeString.floatValue;
        timeInterval = timeInterval;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        //设置时间的格式
        NSString *finalDate = [[NSString alloc]init];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateStyle:kCFDateFormatterFullStyle];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        finalDate  = [formatter stringFromDate:date];
        [allInformationDict setObject:finalDate forKey:@"strTime"];
        
        
        //判断消息类型 文字 图片 语音
        if([messageDetailDict[@"mtype"] isEqualToString:@"text"])
        {
            [allInformationDict setObject:messageDetailDict[@"m"] forKey:@"strContent"];
            [allInformationDict setObject:@(UUMessageTypeText) forKey:@"type"];
        }
        else if ([messageDetailDict[@"mtype"] isEqualToString:@"image/png"]||[messageDetailDict[@"mtype"] isEqualToString:@"image/jpg"]||[messageDetailDict[@"mtype"] isEqualToString:@"image/jpeg"])
        {
            [allInformationDict setObject:messageDetailDict[@"m"] forKey:@"picture"];
            [allInformationDict setObject:@(UUMessageTypePicture) forKey:@"type"];
            [allInformationDict setObject:@"" forKey:@"title"];
            [allInformationDict setObject:@"png" forKey:@"mmx/type"];
            
        }
        else if([messageDetailDict[@"mtype"] isEqualToString:@"audio/mp3"])
        {
            
            [allInformationDict setObject:messageDetailDict[@"m"] forKey:@"voice"];
            //语音的时间
            [allInformationDict setObject:@"" forKey:@"strVoiceTime"];
            [allInformationDict setObject:@(UUMessageTypeVoice) forKey:@"type"];
            
        }
        //发送商品
        else if([messageDetailDict[@"mtype"] isEqualToString:@"mmx/goods"])
        {
            NSString *sendDetailString = messageDetailDict[@"m"];
            //NSLog(@"嘿嘿嘿嘿嘿嘿嘿嘿%@",sendDetailString);
            NSDictionary *sendDetailDict = [sendDetailString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
            //NSLog(@"哈哈哈哈哈哈哈%@",sendDetailDict);
            [allInformationDict setObject:sendDetailDict[@"img"] forKey:@"picture"];
            [allInformationDict setObject:@(UUMessageTypePicture) forKey:@"type"];
            [allInformationDict setObject:sendDetailDict[@"name"] forKey:@"title"];
            [allInformationDict setObject:@"mmx/goods" forKey:@"mmx/type"];
        }
        //发送活动
        else if ([messageDetailDict[@"mtype"] isEqualToString:@"mmx/act"])
        {
            NSString *sendDetailString = messageDetailDict[@"m"];
            NSDictionary *sendDetailDict = [sendDetailString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
            
            [allInformationDict setObject:sendDetailDict[@"img"] forKey:@"picture"];
            [allInformationDict setObject:@(UUMessageTypePicture) forKey:@"type"];
            [allInformationDict setObject:sendDetailDict[@"name"] forKey:@"title"];
            [allInformationDict setObject:@"mmx/act" forKey:@"mmx/type"];
        }
        //发送商店
        else if ([messageDetailDict[@"mtype"] isEqualToString:@"mmx/shop"])
        {
            NSString *sendDetailString = messageDetailDict[@"m"];
            NSDictionary *sendDetailDict = [sendDetailString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
            
            [allInformationDict setObject:sendDetailDict[@"img"] forKey:@"picture"];
            [allInformationDict setObject:@(UUMessageTypePicture) forKey:@"type"];
            [allInformationDict setObject:sendDetailDict[@"name"] forKey:@"title"];
            [allInformationDict setObject:@"mmx/shop" forKey:@"mmx/type"];
        }
        
        [allInformationArray addObject:allInformationDict];
    }
    
    for(int i = 0;i<allInformationArray.count;i++)
    {
        NSDictionary *dict = allInformationArray[i];
        UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
        UUMessage *message = [[UUMessage alloc]init];
        [message setWithDict:dict];
        //消息是否显示时间
        [message minuteOffSetStart:previousMyTime end:dict[@"strTime"]];
        //消息是否显示时间传递给UI
        messageFrame.showTime = message.showDateLabel;
        [messageFrame setMessage:message];
        if(message.showDateLabel)
        {
            previousMyTime = dict[@"strTime"];
        }
        
        [result addObject:messageFrame];
        
        [self.dataSource insertObject:messageFrame atIndex:0];
        
    }
    
    
}


//下拉加载更多消息内容
-(void)addRandomItemsToDataSource:(NSInteger)number
{
    for (int i=0; i<number; i++) {
        [self.dataSource insertObject:[[self additems:1] firstObject] atIndex:0];
    }
}

//添加自己的item
-(void)addSpecifiedItem:(NSDictionary *)dic
{
    UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
    UUMessage *message = [[UUMessage alloc] init];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    NSString *URLStr = @"http://img0.bdstatic.com/img/image/shouye/xinshouye/mingxing16.jpg";
    [dataDic setObject:@(UUMessageFromMe) forKey:@"from"];
    
    //设置发送消息的当前时间————获取当前时间
    NSString *date = [[NSString alloc]init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    date = [formatter stringFromDate:[NSDate date]];
    [dataDic setObject:date forKey:@"strTime"];
    
    //用户名和用户头像
    [dataDic setObject:@"Hello,Sister" forKey:@"strName"];
    [dataDic setObject:URLStr forKey:@"strIcon"];
    
    [message setWithDict:dataDic];
    
    //聊天消息之间是否显示当前时间的判断
    [message minuteOffSetStart:previousTime end:dataDic[@"strTime"]];
    messageFrame.showTime = message.showDateLabel;
    [messageFrame setMessage:message];
    
    if (message.showDateLabel) {
        previousTime = dataDic[@"strTime"];
    }
    [self.dataSource addObject:messageFrame];
}

//添加聊天item （一个cell的内容）（别人的内容）
static NSString *previousTime = nil;
- (NSArray *)additems:(NSInteger)number
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (int i=0; i<number; i++) {
        
        NSDictionary *dataDic = [self getDic];
        UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
        UUMessage *message = [[UUMessage alloc] init];
        [message setWithDict:dataDic];
        
        //消息是否显示时间
        [message minuteOffSetStart:previousTime end:dataDic[@"strTime"]];
        //消息是否显示时间传递给UI
        messageFrame.showTime = message.showDateLabel;
        
        [messageFrame setMessage:message];
        
        if (message.showDateLabel) {
            previousTime = dataDic[@"strTime"];
        }
        [result addObject:messageFrame];
    }
    return result;
    
}

//如下：（群聊和私聊的判断）
static int dateNum = 10;

//每一个数据源数组
- (NSDictionary *)getDic
{
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    //别人的消息内容的（这里是随机选择是图片消息还是文字消息）
    int randomNum = arc4random()%5;
    if (randomNum == UUMessageTypePicture) {
        [dictionary setObject:[UIImage imageNamed:[NSString stringWithFormat:@"%zd.jpeg",arc4random()%2]] forKey:@"picture"];
    }else{
        // 文字出现概率4倍于图片（暂不出现Voice类型）
        randomNum = UUMessageTypeText;
        [dictionary setObject:[self getRandomString] forKey:@"strContent"];
    }
    NSDate *date = [[NSDate date]dateByAddingTimeInterval:arc4random()%1000*(dateNum++) ];
    //标明消息内容来源（来自他人）
    [dictionary setObject:@(UUMessageFromOther) forKey:@"from"];
    [dictionary setObject:@(randomNum) forKey:@"type"];
    [dictionary setObject:[date description] forKey:@"strTime"];
    // 这里判断是否是私人会话、群会话 （判断是私聊还是群聊 然后选择用户的名字和头像）
    int index = _isGroupChat ? arc4random()%6 : 0;
    [dictionary setObject:[self getName:index] forKey:@"strName"];
    [dictionary setObject:[self getImageStr:index] forKey:@"strIcon"];
    
    return dictionary;

}

- (NSString *)getRandomString {
    
    NSString *lorumIpsum = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent non quam ac massa viverra semper. Maecenas mattis justo ac augue volutpat congue. Maecenas laoreet, nulla eu faucibus gravida, felis orci dictum risus, sed sodales sem eros eget risus. Morbi imperdiet sed diam et sodales.";
    
    NSArray *lorumIpsumArray = [lorumIpsum componentsSeparatedByString:@" "];
    
    int r = arc4random() % [lorumIpsumArray count];
    r = MAX(6, r); // no less than 6 words
    NSArray *lorumIpsumRandom = [lorumIpsumArray objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, r)]];
    
    return [NSString stringWithFormat:@"%@!!", [lorumIpsumRandom componentsJoinedByString:@" "]];
}

- (NSString *)getImageStr:(NSInteger)index{
    NSArray *array = @[@"http://www.120ask.com/static/upload/clinic/article/org/201311/201311061651418413.jpg",
                       @"http://p1.qqyou.com/touxiang/uploadpic/2011-3/20113212244659712.jpg",
                       @"http://www.qqzhi.com/uploadpic/2014-09-14/004638238.jpg",
                       @"http://e.hiphotos.baidu.com/image/pic/item/5ab5c9ea15ce36d3b104443639f33a87e950b1b0.jpg",
                       @"http://ts1.mm.bing.net/th?&id=JN.C21iqVw9uSuD2ZyxElpacA&w=300&h=300&c=0&pid=1.9&rs=0&p=0",
                       @"http://ts1.mm.bing.net/th?&id=JN.7g7SEYKd2MTNono6zVirpA&w=300&h=300&c=0&pid=1.9&rs=0&p=0"];
    return array[index];
}

- (NSString *)getName:(NSInteger)index{
    
    //用户名称Name
    NSArray *array = @[@"Hi,Daniel",@"Hi,Juey",@"Hey,Jobs",@"Hey,Bob",@"Hah,Dane",@"Wow,Boss"];
    return array[index];
}



@end
