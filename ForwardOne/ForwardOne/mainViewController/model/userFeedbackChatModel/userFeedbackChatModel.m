//
//  userFeedbackChatModel.m
//  ForwardOne
//
//  Created by 杨波 on 15/7/10.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "userFeedbackChatModel.h"

//消息内容
#import "UUMessage.h"
#import "UUMessageFrame.h"

@implementation userFeedbackChatModel


static NSString *previousMyTime = nil;
//数据源数组中添加别人的消息内容的数据源 （其中也有自己的消息内容  根据key为from进行判断）
-(void)populateRandomDataSource:(NSArray *)array
{
    //消息数据源数组以及在界面上面显示的cell的函行数
    self.dataSource = [NSMutableArray array];
     NSMutableArray *result = [NSMutableArray array];
   
       for(NSDictionary *dict in array)
    {
        NSMutableDictionary *messageDict = [[NSMutableDictionary alloc]init];
        [messageDict setObject:dict[@"content"] forKey:@"strContent"];
        NSString *string = dict[@"direction"];
        if(string.intValue == 1)
        {
            //消息来源是自己
            [messageDict setObject:@(UUMessageFromMe) forKey:@"from"];
            //名称
            [messageDict setObject:@"" forKey:@"strName"];
            //头像
            NSString *photoImageUrl = [[NSUserDefaults standardUserDefaults]objectForKey:MyPhotoImageURL];
            [messageDict setObject:photoImageUrl forKey:@"strIcon"];
        }
        else
        {
            //消息来源是平台
            [messageDict setObject:@(UUMessageFromOther) forKey:@"from"];
            //名称
            [messageDict setObject:@"" forKey:@"strName"];
            //头像
            [messageDict setObject:@"http://img.immbear.com/46804488224a8bca3220b9d41b87be10.png" forKey:@"strIcon"];
        }
        [messageDict setObject:@(UUMessageTypeText) forKey:@"type"];
        [messageDict setObject:dict[@"time"] forKey:@"strTime"];
       
        UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
        UUMessage *message  = [[UUMessage alloc]init];
        [message setWithDict:messageDict];
        
        //消息是否显示时间
        [message minuteOffSetStart:previousMyTime end:messageDict[@"strTime"]];
        //消息是否显示时间传递给UI
        messageFrame.showTime = message.showDateLabel;
        [messageFrame setMessage:message];
        if(message.showDateLabel)
        {
            previousMyTime = messageDict[@"strTime"];
        }
     
        [result addObject:messageFrame];
    }
    [self.dataSource addObjectsFromArray:result];

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
    
    NSString *URLStr = [[NSUserDefaults standardUserDefaults]objectForKey:MyPhotoImageURL];
    [dataDic setObject:@(UUMessageFromMe) forKey:@"from"];
    
    //设置发送消息的当前时间————获取当前时间
    NSString *date = [[NSString alloc]init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:kCFDateFormatterFullStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    date = [formatter stringFromDate:[NSDate date]];
    
    
    [dataDic setObject:date forKey:@"strTime"];
    
    //用户名和用户头像
    [dataDic setObject:@"" forKey:@"strName"];
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
    //标明消息内容来源（来自他人）-标明消息的来源（是不是自己发送的消息）
    [dictionary setObject:@(UUMessageFromOther) forKey:@"from"];
    [dictionary setObject:@(randomNum) forKey:@"type"];
    [dictionary setObject:[date description] forKey:@"strTime"];
    
    NSLog(@"**************时间%@",date);
    NSLog(@"**************时间描述%@",date.description);
    
    
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
