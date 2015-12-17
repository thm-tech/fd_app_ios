//
//  staticUserInfo.h
//  ForwardOne
//
//  Created by 杨波 on 15/7/21.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface staticUserInfo : NSObject


-(id)init;

//添加消息
+(void)addMessageToGname:(NSString *)gname withMessageBody:(NSDictionary *)messageBody;

//由userID获得用户信息
+(NSDictionary *)getUserInformationWithUserID:(NSString *)userID;

//由gname获得聊天记录
+(NSArray *)getMessagesWithGname:(NSString *)gname;

//由game获得组内userID (从组内messageBody中获取 即使退出群组了 但是消息记录还在 也能获取到UserID)
+(NSArray *)getUserIDFromMessageBodyWithGname:(NSString *)gname;

//添加聊天组的名字缓存在内存中(由聊天组内成员组成，由协议获得,不包括消息里面退出群组的用户)
+(void)addGruopNameToGname:(NSString *)gname withGruopName:(NSString *)groupName;


//由gname查询聊天组的名称
+(NSString *)getGroupNameWithGname:(NSString *)gname;


@end
