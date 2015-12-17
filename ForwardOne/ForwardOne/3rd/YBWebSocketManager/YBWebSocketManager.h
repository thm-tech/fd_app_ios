//
//  YBWebSocketManager.h
//  webSocketDemo
//
//  Created by 杨波 on 15/7/15.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SRWebSocket.h"

@interface YBWebSocketManager : NSObject <SRWebSocketDelegate>
//获取单例类
+(id)sharedInstance;

//打开Socket连接
-(void)openChatSocket;

//关闭Socket连接
-(void)closedChatScoket;


//Socketd的属性
@property (strong,nonatomic) SRWebSocket *webSocket;

//获取商店聊天室名称
-(void)YBGetShopGnameWithShopID:(NSString *)shopIDString;

//用户进入商店的聊天室
-(void)YBEnterShopWithUserName:(NSString *)userName andGname:(NSString *)gname;

//获取组成员信息
-(void)YBGetGroupUsersWithGname:(NSString *)gname;

//用户发送消息（用户发给聊天组）
-(void)YBSendMessageFromUser:(NSString *)user toGname:(NSString *)gname message:(NSString *)message messageType:(NSString *)messageType;

-(void)YBSendOnlyChatMessageFromUser:(NSString *)user toGname:(NSString *)gname message:(NSString *)message messageType:(NSString *)messageType;

//发送消息 （mmx ——商品,活动,商店）
-(void)YBsendMMXMessageFromUser:(NSString *)user toGname:(NSString *)gname mmxID:(NSString *)mmxID mmxImg:(NSString *)mmxImg mmxName:(NSString *)mmxName messageType:(NSString *)messageType;

//退出聊天组
-(void)YBExitGroupWithUser:(NSString *)user andGname:(NSString *)gname;

//拉多个用户（创建用户组）拉单个用户直接发消息
-(void)YBCreateGroupWithMasterUser:(NSString *)masterUser andPullInOthers:(NSArray *)otherUsersArray;

//接收邀请消息
-(void)YBAcceptInvitationFromGname:(NSString *)gname;

//拉用户进组（组已经存在）
-(void)YBPullInUsersToGroupWithGname:(NSString *)gname andOtherUsersArray:(NSArray *)otherUsersArray;

//获取聊天记录（获取哪个组的 从什么时候获取的 多少条的聊天记录）
-(void)YBGetRecordWithGname:(NSString *)gname andStartTime:(NSString *)startTime andRecordCount:(NSString *)recordCount;

//摇一摇
-(void)YBShakeWithUser:(NSString *)user;

//发消息给粉丝店
-(void)YBSendMessageToFansShopFromUser:(NSString *)user message:(NSString *)message messageType:(NSString *)messageType;

//换设备登录（平台会检测到新设备登陆并发出这条消息 client收到消息作出相应的处理就可以）这是收到消息做相应的处理

//获取用户组信息
-(void)YBGetGroupInformationWithUser:(NSString *)user;


-(void)webSocketDidSendMessage:(NSString *)message;


@end
