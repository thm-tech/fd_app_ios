//
//  myAppDataBase.h
//  ForwardOne
//
//  Created by 杨波 on 15/7/23.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMDatabase.h"
#import "collectionDataBaseModel.h"
//管理数据库的单例类  对所有数据库的操作都放在类里面 提供简单易用的接口
typedef enum RecordType
{
    RecoredTypeAttention,
    RecoredTypeCollection
    
}RecordType;

@interface myAppDataBase : NSObject

//获取单例类
+(id)sharedInstance;

//打开数据库
-(void)openDataBase;

//关闭数据库
-(void)closedDataBase;


//粉丝店
//添加记录
-(BOOL)addFansShopRecordWithDicitionary:(NSDictionary *)dict recordType:(RecordType)recordType;

//删除记录
-(BOOL)deleteFansShopRecordWithDicitionary:(NSDictionary *)dict recordType:(RecordType)recordType;

//查某个记录是否存在
-(BOOL)isExistFansShopRecordWithDicitionary:(NSDictionary *)dict recordType:(RecordType)recordType;

//更新粉丝店是否接受推送消息
-(BOOL)upDateFansShopReceiveFansShopPushMessageWithShopID:(NSNumber *)shopID withMsgEnable:(NSNumber *)enable;

//获取某一个具体粉丝店的信息
-(NSArray *)getOneFansShopRecordWith:(NSNumber *)shopID;

//获取某种类型的数据记录
-(NSArray *)getFansShopRecordWithRecordType:(RecordType)recordType;

//收藏
//添加记录
-(BOOL)addCollectionRecordWithDicitionary:(collectionDataBaseModel *)model recordType:(RecordType)recordType;

//删除记录
-(BOOL)deleteCollectionRecordWithDicitionary:(collectionDataBaseModel *)model recordType:(RecordType)recordType;
//删除 （删除所有记录）
-(BOOL)deleteAllCollectionRecordWithRecordType:(RecordType)recordType;


//查某个记录是否存在
-(BOOL)isExistCollectionRecordWithDicitionary:(collectionDataBaseModel *)model recordType:(RecordType)recordType;

//获取某种类型的数据记录
-(NSArray *)getCollectionRecordWithRecordType:(RecordType)recordType;


//用户信息
//添加记录
-(BOOL)addUserInformationRecordWithDicitionary:(NSDictionary *)dict recordType:(RecordType)recordType;

//删除记录
-(BOOL)deleteUserInformationRecordWithDicitionary:(NSNumber *)frdID recordType:(RecordType)recordType;

//查某个记录是否存在
-(BOOL)isExistUserInformationRecordWithUserID:(NSString *)userID recordType:(RecordType)recordType;

//更新某个好友的备注名字
-(BOOL)upDateStaticUserInfoRemarkNameWithFrD:(NSNumber *)frdID remarkName:(NSString *)remarkName;

//获取某种类型的数据记录
-(NSDictionary *)getUserInformationRecordWithUserID:(NSString *)userID;

//获取所有好友的信息
-(NSArray *)getAllUserInformationWith:(RecordType)recordType;


//聊天记录
//添加  存储的消息记录
-(BOOL)addMessagesWith:(NSString *)gname andMessageBody:(NSDictionary *)messageDict;

//删除
-(BOOL)deleteMessageWith:(NSString *)gname;

//删除所有的聊天记录
-(BOOL)deleteAllMessageRecordWith:(RecordType)recordType;

//是否存在
-(BOOL)isExistMessageWith:(NSString *)gname;

//获取某个gname的消息
-(NSArray *)getMessagesWithGname:(NSString *)gname;

//逛店记录
//添加
-(BOOL)addVisitShopRecordWithDicitionary:(NSDictionary *)dict recordType:(RecordType)recordType;

//删除 (删除一个月之前 删除一年前 删除所有的逛店记录)_可以通过判断时间戳的差别来得出是否走删除记录这个方法
-(BOOL)deleteVisitShopRecordWithRecordType:(RecordType)recordType;

-(BOOL)deleteVisitShopREcordWithShopID:(NSNumber *)shopID recordType:(RecordType)recordType;


//查是否存在
-(BOOL)isExistVisitShopRecordWithShopID:(NSString *)shopID recordTyoe:(RecordType)recordType;

//获取某种类型的数据
-(NSArray *)getVisitShopRecordWithRecordTyepe:(RecordType)recordType;

//更新某个商店的访问时间
-(BOOL)upDateVisitShopTimeWithShopID:(NSString *)shopID time:(NSString *)time;

#pragma mark-(商家推送消息表)
//添加
-(BOOL)addShopPushRecordWithDicitionary:(NSDictionary *)dict recordType:(RecordType)recordType;

//删除
-(BOOL)deleteShopPushRecordWithShopID:(NSNumber *)shopID recordType:(RecordType)recordType;

//删除所有的商家推送消息
-(BOOL)deleteAllShopPushRecord;

//获取某个商家的推送消息
-(NSArray *)getShopPushAllRecordWithShopID:(NSNumber *)shopID;

#pragma mark-(系统通知消息表)
//添加
-(BOOL)addSystemRecordWithDicitionary:(NSDictionary *)dict recordType:(RecordType)recordType;

//删除
-(BOOL)deleteSystemRecordWithRecordType:(RecordType)recordType;

//获取所有的系统通知消息表
-(NSArray *)getAllSystemRecordWithRecordType:(RecordType)recordType;

#pragma mark-(喵喵消息)
//添加
-(BOOL)addMiaoMiaoReordWithDicitionary:(NSDictionary *)dict recordType:(RecordType)recordType;

//删除
-(BOOL)deleteMiaoMiaoRecordWithSenderID:(NSNumber *)senderIDString miaomiaoType:(NSString *)miaomiaoType;

-(BOOL)deleteMiaoMiaoChatRecordWithSenderID:(NSNumber *)senderId miaomiaoType:(NSString *)miaomiaoType gname:(NSString *)gname;
//删除某个类型的喵咪消息(群聊)
-(BOOL)deleteMiaoMiaoChatGroupRecordWithGname:(NSString *)gname;

//判断某个类型的喵喵消息是否存在 ()
-(BOOL)isExistMiaoMiaoRecordWithSenderID:(NSNumber *)senderId miaomiaoType:(NSString *)miaomiaoType;

//判断某个类型的喵喵消息是否存在 (专指 聊天消息)
-(BOOL)isExistMiaomiaoChatRecordWithSenderID:(NSNumber *)senderId miaomiaoType:(NSString *)miaomiaoType gname:(NSString *)gname;

//判断某个类型的喵喵消息是否存在（群聊）
-(BOOL)isExistMiaoMiaoGroupRecordWithGname:(NSString *)gname;

//更新喵喵消息里面的未读消息
-(BOOL)upDateMiaoMiaoRecordUnreadWith:(NSNumber *)senderID andMiaoMiaoType:(NSString *)miaomiaoType unread:(NSString *)unreadString;

//更新喵喵消息里面的未读消息（专指聊天消息）
-(BOOL)upDateMiaoMiaoChatRecordUnreadWith:(NSNumber *)senderID miaomiaoType:(NSString *)miaomiaoType gname:(NSString *)gname unread:(NSString *)unreadString;

-(BOOL)upDateMiaoMiaoGroupChatUnReadWithGname:(NSString *)gname unread:(NSString *)unreadString;

//更新喵喵消息里面聊天消息gname对应的聊天组名字
-(BOOL)upDateMiaoMiaoRecordGroupName:(NSString *)groupName withGname:(NSString *)gname;

//更新喵喵消息里面聊天消息gname对应的聊天组头像
-(BOOL)upDateMiaoMiaoRecordGroupImage:(NSString *)groupImage withGname:(NSString *)gname;
//更新喵喵消息里面聊天消息gname对应的组内成员IDString
-(BOOL)upDateMiaoMiaoREcordUsers:(NSString *)users withGname:(NSString *)gname;

//获取某个gname的喵喵记录
-(NSDictionary *)getOneMiaoMiaoRecordWithGname:(NSString *)gname;

//获取所有喵喵记录中的聊天记录（包括群聊和单聊）
-(NSArray *)getAllMiaoMiaoChatRecordWithMiaoMiaoTypeID:(NSString *)miaomiaoTypeID;

//获取所有的喵喵记录
-(NSArray *)getAllMiaoMiaoRecordTypeWithRecordType:(RecordType)recordType;

@end
