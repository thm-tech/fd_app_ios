//
//  myAppDataBase.m
//  ForwardOne
//
//  Created by 杨波 on 15/7/23.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "myAppDataBase.h"

#import "fansShopDataBaseModel.h"
#import "myLookedShopModel.h"

@implementation myAppDataBase

{
    FMDatabase *_dataBase;
}
//获取单例对象
+(id)sharedInstance
{
    //myAppDataBase *dc = nil;
    static myAppDataBase *dc = nil;
    if(dc == nil)
    {
        dc = [[[self class]alloc]init];
    }
    return dc;
}
-(id)init
{
    if(self = [super init])
    {
        [self initDataBase];
    }
    return self;
}

-(void)openDataBase
{
    [self initDataBase];
}
-(void)closedDataBase
{
    NSString *loginString = [[NSUserDefaults standardUserDefaults]objectForKey:IsLogin];
    if([loginString isEqualToString:@"login"])
    {
        
        NSString *userAccountString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
        
        NSString *path = [NSString stringWithFormat:@"%@/Documents/%@.sqlite",NSHomeDirectory(),userAccountString];
        _dataBase = [[FMDatabase alloc]initWithPath:path];
        [_dataBase close];
    }

}


-(void)initDataBase
{
    
    //创建数据库 （在登录以后创建 一个用户对应一个数据库）
    NSString *loginString = [[NSUserDefaults standardUserDefaults]objectForKey:IsLogin];
    if([loginString isEqualToString:@"login"])
    {
        
        NSString *userAccountString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
        
    NSString *path = [NSString stringWithFormat:@"%@/Documents/%@.sqlite",NSHomeDirectory(),userAccountString];
    _dataBase = [[FMDatabase alloc]initWithPath:path];
    [_dataBase shouldCacheStatements];
    NSLog(@"数据库路径%@",path);
    //打开数据库
    if(_dataBase.open == NO)
    {
        NSLog(@"数据库打开失败");
        return;
    }
    NSLog(@"数据库打开成功");
    //创建表    粉丝店
    NSString *sql = @"create table if not exists fansShop  ("
    " id integer primary key autoincrement not null, "
    " recordType varchar(32), "
    " fansShopId integer not null, "
    " name varchar(128), "
    " pic varchar(512), "
    " time varchar(512) ,"
    " msgEnable integer "
    ");";
    BOOL b = [_dataBase executeUpdate:sql];
    NSLog(@"create fansShopTable = %d",b);
    
    
    //创建表   我的收藏
    NSString *sql1 = @"create table if not exists collection  ("
    " id integer primary key autoincrement not null, "
    " recordType varchar(32), "
    " gid integer not null, "
    " sid varchar(128), "
    " desp varchar(1024), "
    " price varchar(128), "
    " promot varchar(128), "
    " pic varchar(512) "
    ");";
    BOOL b1 = [_dataBase executeUpdate:sql1];
    NSLog(@"create collecTable = %d",b1);
    
    //创建表   用户信息
    NSString *sql2 = @"create table if not exists staticUserInfo  ("
    " id integer primary key autoincrement not null, "
    " recordType varchar(32), "
    " frdID integer not null, "
    " rmkName varchar(128), "
    " nickName varchar(128), "
    " mcode varchar(128) ,"
    " portrait varchar(512) "
    ");";
    BOOL b2 = [_dataBase executeUpdate:sql2];
    NSLog(@"create staticUserInfo = %d",b2);
    
    //创建表   消息记录
    NSString *sql3 = @"create table if not exists messageRecord  ("
    " id integer primary key autoincrement not null, "
    " user integer not null, "
    " time varchar(128), "
    " mtype varchar(128), "
    " gname varchar(128) ,"
    " m varchar(2048) "
    ");";
    BOOL b3 = [_dataBase executeUpdate:sql3];
    NSLog(@"create messageRecord = %d",b3);


    //创建逛店记录表
    NSString *sql4 = @"create table if not exists visitShopRecord  ("
    " id integer primary key autoincrement not null, "
    " recordType varchar(32), "
    " shopID integer not null, "
    " shopName varchar(128), "
    " time varchar(128), "
    " shopPic varchar(512) "
    ");";
    BOOL b4 = [_dataBase executeUpdate:sql4];
    NSLog(@"create visitShopRecord = %d",b4);
    
    //创建喵喵消息表
    NSString *sql5 = @"create table if not exists miaomiaoRecord  ("
    " id integer primary key autoincrement not null, "
    " recordType varchar(32), "
    " senderID integer not null, "
    " miaomiaoType varchar(32), "
    " portrait varchar(512), "
    " name varchar(128), "
    " remark varchar(128), "
    " users varchar(128), "
    " unread varchar(32) "
    ");";
    BOOL b5 = [_dataBase executeUpdate:sql5];
    NSLog(@"create miaomiaoRecord = %d",b5);
    
    
    //创建系统通知消息表(系统只有一个，ID为0)
    NSString *sql6 = @"create table if not exists systemRecord  ("
    " id integer primary key autoincrement not null, "
    " recordType varchar(32), "
    " systemID integer not null, "
    " text varchar(2048), "
    " time varchar(128) "
    ");";
    BOOL b6 = [_dataBase executeUpdate:sql6];
    NSLog(@"create systemRecord = %d",b6);

    //创建商家推送消息表（每个推送的商家的ID都不唯一）
    NSString *sql7 = @"create table if not exists shopPushRecord  ("
    " id integer primary key autoincrement not null, "
    " recordType varchar(32), "
    " shopID integer not null, "
    " text varchar(2048), "
    " time varchar(128) "
    ");";
    BOOL b7 = [_dataBase executeUpdate:sql7];
    NSLog(@"create shopPushRecord = %d",b7);
    }
   
}
#pragma mark-(商家推送消息表)
//添加
-(BOOL)addShopPushRecordWithDicitionary:(NSDictionary *)dict recordType:(RecordType)recordType
{
    NSString *sql = @"insert into shopPushRecord(recordType,shopID,text,time) values(?,?,?,?)";
    BOOL b = [_dataBase executeUpdate:sql,[NSString stringWithFormat:@"%d",recordType],dict[@"shopID"],dict[@"text"],dict[@"time"]];
    NSLog(@"insert b = %d",b);
    return b;
 
}
//删除
-(BOOL)deleteShopPushRecordWithShopID:(NSNumber *)shopID recordType:(RecordType)recordType
{
    NSString *sql = @"delete from shopPushRecord where shopID=? and recordType=?";
    BOOL b = [_dataBase executeUpdate:sql,shopID,[NSString stringWithFormat:@"%d",recordType]];
    NSLog(@"delete b = %d",b);
    return b;
}

//删除所有的商家推送消息
-(BOOL)deleteAllShopPushRecord
{
    NSString *sql = @"delete from shopPushRecord";
    BOOL b = [_dataBase executeUpdate:sql];
    NSLog(@"delete b = %d",b);
    return b;
}


//获取某个商家的推送消息
-(NSArray *)getShopPushAllRecordWithShopID:(NSNumber *)shopID
{
    NSString *sql = @"select * from shopPushRecord where shopID=?";
    FMResultSet *resultSet = [_dataBase executeQuery:sql,shopID];
    //返回多条信息
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    while ([resultSet next]) {
        NSMutableDictionary *dict  = [[NSMutableDictionary alloc]init];
        [dict setObject:[resultSet stringForColumn:@"shopID"] forKey:@"shopID"];
        [dict setObject:[resultSet stringForColumn:@"text"] forKey:@"text"];
        [dict setObject:[resultSet stringForColumn:@"time"] forKey:@"time"];
        
        [array addObject:dict];
        
    }
    return array;

}


#pragma mark-(系统通知消息表)
//添加
-(BOOL)addSystemRecordWithDicitionary:(NSDictionary *)dict recordType:(RecordType)recordType
{
    NSString *sql = @"insert into systemRecord(recordType,systemID,text,time) values(?,?,?,?)";
    BOOL b = [_dataBase executeUpdate:sql,[NSString stringWithFormat:@"%d",recordType],dict[@"systemID"],dict[@"text"],dict[@"time"]];
    NSLog(@"insert b = %d",b);
    return b;
}

//删除
-(BOOL)deleteSystemRecordWithRecordType:(RecordType)recordType
{
    NSString *sql = @"delete from systemRecord where recordType=?";
    BOOL b = [_dataBase executeUpdate:sql,[NSString stringWithFormat:@"%d",recordType]];
    NSLog(@"delete b = %d",b);
    return b;
}

//获取所有的系统通知消息表
-(NSArray *)getAllSystemRecordWithRecordType:(RecordType)recordType
{
    NSString *sql = @"select * from systemRecord where recordType=?";
    FMResultSet *resultSet = [_dataBase executeQuery:sql,[NSString stringWithFormat:@"%d",recordType]];
    //返回多条信息
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    while ([resultSet next]) {
        NSMutableDictionary *dict  = [[NSMutableDictionary alloc]init];
        [dict setObject:[resultSet stringForColumn:@"systemID"] forKey:@"systemID"];
        [dict setObject:[resultSet stringForColumn:@"text"] forKey:@"text"];
        [dict setObject:[resultSet stringForColumn:@"time"] forKey:@"time"];
        
        [array addObject:dict];
        
    }
    return array;
}

#pragma mark-(喵喵消息)  
//添加
-(BOOL)addMiaoMiaoReordWithDicitionary:(NSDictionary *)dict recordType:(RecordType)recordType
{
    NSLog(@"*****************%@",dict);
    
    NSString *sql = @"insert into miaomiaoRecord(recordType,senderID,miaomiaoType,portrait,name,remark,users,unread) values(?,?,?,?,?,?,?,?)";
    BOOL b = [_dataBase executeUpdate:sql,[NSString stringWithFormat:@"%d",recordType],dict[@"senderID"],dict[@"miaomiaoTypeID"],dict[@"portrait"],dict[@"name"],dict[@"remark"],dict[@"users"],dict[@"unread"]];
    NSLog(@"insert  b = %d",b);
    return b;

}
//删除
-(BOOL)deleteMiaoMiaoRecordWithSenderID:(NSNumber *)senderIDString miaomiaoType:(NSString *)miaomiaoType
{
    NSString *sql = @"delete from miaomiaoRecord where senderID=? and miaomiaoType=?";
    BOOL b = [_dataBase executeUpdate:sql,senderIDString,miaomiaoType];
    NSLog(@"delete b = %d",b);
    return b;
}
//删除某个类型的喵喵消息(专指聊天消息_单聊)
-(BOOL)deleteMiaoMiaoChatRecordWithSenderID:(NSNumber *)senderId miaomiaoType:(NSString *)miaomiaoType gname:(NSString *)gname
{
    NSString *sql = @"delete from miaomiaoRecord where senderID=? and miaomiaoType=? and remark=?";
    BOOL b = [_dataBase executeUpdate:sql,senderId,miaomiaoType,gname];
    NSLog(@"delete b = %d",b);
    return b;
}

//删除某个类型的喵咪消息(群聊)
-(BOOL)deleteMiaoMiaoChatGroupRecordWithGname:(NSString *)gname
{
    NSString *sql = @"delete from miaomiaoRecord where remark=?";
    BOOL b = [_dataBase executeUpdate:sql,gname];
    NSLog(@"delete b = %d",b);
    return b;
}

//更新喵喵消息里面的未读消息
-(BOOL)upDateMiaoMiaoRecordUnreadWith:(NSNumber *)senderID andMiaoMiaoType:(NSString *)miaomiaoType unread:(NSString *)unreadString
{
    NSString *sql = @"UPDATE miaomiaoRecord SET unread = ? WHERE senderID = ? and miaomiaoType=?";
    BOOL b = [_dataBase executeUpdate:sql,unreadString,senderID,miaomiaoType];
    NSLog(@"UPDATE 111 b = %d",b);
    return b;
}

//更新聊天组的未读消息
-(BOOL)upDateMiaoMiaoGroupChatUnReadWithGname:(NSString *)gname unread:(NSString *)unreadString
{
    NSString *sql = @"UPDATE miaomiaoRecord SET unread = ? WHERE remark = ?";
    BOOL b = [_dataBase executeUpdate:sql,unreadString,gname];
    NSLog(@"UPDATE 222 b = %d",b);
    return b;
}


//更新喵喵消息里面的未读消息（专指聊天消息）
-(BOOL)upDateMiaoMiaoChatRecordUnreadWith:(NSNumber *)senderID miaomiaoType:(NSString *)miaomiaoType gname:(NSString *)gname unread:(NSString *)unreadString
{
    NSString *sql = @"UPDATE miaomiaoRecord SET unread = ? WHERE senderID = ? and miaomiaoType=? and remark=?";
    BOOL b = [_dataBase executeUpdate:sql,unreadString,senderID,miaomiaoType,gname];
    NSLog(@"UPDATE b = %d",b);
    return b;
}

//更新喵喵消息里面聊天消息gname对应的聊天组名字
-(BOOL)upDateMiaoMiaoRecordGroupName:(NSString *)groupName withGname:(NSString *)gname
{
    NSString *sql = @"UPDATE miaomiaoRecord SET name = ? WHERE remark = ?";
    BOOL b = [_dataBase executeUpdate:sql,groupName,gname];
    NSLog(@"UPDATE b = %d",b);
    return b;
}

//更新喵喵消息里面聊天消息gname对应的组内成员IDString
-(BOOL)upDateMiaoMiaoREcordUsers:(NSString *)users withGname:(NSString *)gname
{
    NSString *sql = @"UPDATE miaomiaoRecord SET users = ? WHERE remark = ?";
    BOOL b = [_dataBase executeUpdate:sql,users,gname];
    NSLog(@"UPDATE b = %d",b);
    return b;
}

//更新喵喵消息里面聊天消息gname对应的聊天组头像
-(BOOL)upDateMiaoMiaoRecordGroupImage:(NSString *)groupImage withGname:(NSString *)gname
{
    NSString *sql = @"UPDATE miaomiaoRecord SET portrait = ? WHERE remark = ?";
    BOOL b = [_dataBase executeUpdate:sql,groupImage,gname];
    NSLog(@"UPDATE b = %d",b);
    return b;
}

//判断某个类型的喵喵消息是否存在 ()
-(BOOL)isExistMiaoMiaoRecordWithSenderID:(NSNumber *)senderId miaomiaoType:(NSString *)miaomiaoType
{
    NSString *sql = @"select count(*) from miaomiaoRecord where senderID=? and miaomiaoType=?";
    FMResultSet *resultSet = [_dataBase executeQuery:sql,senderId,miaomiaoType];
    int count=0;
    if([resultSet next])
    {
        count = [resultSet intForColumnIndex:0];
    }
    return count>0;
}

//判断某个类型的喵喵消息是否存在 (专指 聊天消息-单聊)
-(BOOL)isExistMiaomiaoChatRecordWithSenderID:(NSNumber *)senderId miaomiaoType:(NSString *)miaomiaoType gname:(NSString *)gname
{
    NSString *sql = @"select count(*) from miaomiaoRecord where senderID=? and miaomiaoType=? and remark=?";
    FMResultSet *resultSet = [_dataBase executeQuery:sql,senderId,miaomiaoType,gname];
    int count=0;
    if([resultSet next])
    {
        count = [resultSet intForColumnIndex:0];
    }
    return count>0;
}

//判断某个类型的喵喵消息是否存在（群聊）
-(BOOL)isExistMiaoMiaoGroupRecordWithGname:(NSString *)gname
{
    NSString *sql = @"select count(*) from miaomiaoRecord where remark=?";
    FMResultSet *resultSet = [_dataBase executeQuery:sql,gname];
    int count=0;
    if([resultSet next])
    {
        count = [resultSet intForColumnIndex:0];
    }
    return count>0;
}


//获取某个gname的喵喵记录 ——群聊
-(NSDictionary *)getOneMiaoMiaoRecordWithGname:(NSString *)gname
{
    NSString *sql = @"select * from miaomiaoRecord where remark=?";
    FMResultSet *resultSet = [_dataBase executeQuery:sql,gname];
    
    //返回一条信息
    NSMutableDictionary *dict  = [[NSMutableDictionary alloc]init];
    
    while ([resultSet next]) {
    
        [dict setObject:[resultSet stringForColumn:@"senderID"] forKey:@"senderID"];
        [dict setObject:[resultSet stringForColumn:@"miaomiaoType"] forKey:@"miaomiaoTypeID"];
        
        [dict setObject:[resultSet stringForColumn:@"portrait"] forKey:@"portrait"];
        [dict setObject:[resultSet stringForColumn:@"name"] forKey:@"name"];
        [dict setObject:[resultSet stringForColumn:@"remark"] forKey:@"remark"];
        
        [dict setObject:[resultSet stringForColumn:@"unread"] forKey:@"unread"];
        [dict setObject:[resultSet stringForColumn:@"users"] forKey:@"users"];
        
        
    }
    return dict;
}
//获取所有喵喵记录中的聊天记录（包括群聊和单聊）
-(NSArray *)getAllMiaoMiaoChatRecordWithMiaoMiaoTypeID:(NSString *)miaomiaoTypeID
{
    NSString *sql = @"select * from miaomiaoRecord where miaomiaoType=?";
    FMResultSet *resultSet = [_dataBase executeQuery:sql,miaomiaoTypeID];
    
    //返回多条信息
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    while ([resultSet next]) {
        
        NSMutableDictionary *dict  = [[NSMutableDictionary alloc]init];
        [dict setObject:[resultSet stringForColumn:@"senderID"] forKey:@"senderID"];
        [dict setObject:[resultSet stringForColumn:@"miaomiaoType"] forKey:@"miaomiaoTypeID"];
        
        [dict setObject:[resultSet stringForColumn:@"portrait"] forKey:@"portrait"];
        [dict setObject:[resultSet stringForColumn:@"name"] forKey:@"name"];
        [dict setObject:[resultSet stringForColumn:@"remark"] forKey:@"remark"];
        
        [dict setObject:[resultSet stringForColumn:@"unread"] forKey:@"unread"];
        [dict setObject:[resultSet stringForColumn:@"users"] forKey:@"users"];
        [array addObject:dict];
        
    }
    return array;

}

//获取所有的喵喵记录
-(NSArray *)getAllMiaoMiaoRecordTypeWithRecordType:(RecordType)recordType
{
    NSString *sql = @"select * from miaomiaoRecord where recordType=?";
    FMResultSet *resultSet = [_dataBase executeQuery:sql,[NSString stringWithFormat:@"%d",recordType]];

    //返回多条信息
    NSMutableArray *array = [[NSMutableArray alloc]init];
   
    while ([resultSet next]) {
        
         NSMutableDictionary *dict  = [[NSMutableDictionary alloc]init];
        [dict setObject:[resultSet stringForColumn:@"senderID"] forKey:@"senderID"];
        [dict setObject:[resultSet stringForColumn:@"miaomiaoType"] forKey:@"miaomiaoTypeID"];
        
        [dict setObject:[resultSet stringForColumn:@"portrait"] forKey:@"portrait"];
        [dict setObject:[resultSet stringForColumn:@"name"] forKey:@"name"];
        [dict setObject:[resultSet stringForColumn:@"remark"] forKey:@"remark"];
        
        [dict setObject:[resultSet stringForColumn:@"unread"] forKey:@"unread"];
        [dict setObject:[resultSet stringForColumn:@"users"] forKey:@"users"];
        [array addObject:dict];
        
    }
    return array;
}


#pragma mark-(逛店记录)
//添加
-(BOOL)addVisitShopRecordWithDicitionary:(NSDictionary *)dict recordType:(RecordType)recordType
{
    NSString *sql = @"insert into visitShopRecord(recordType,shopID,shopName,time,shopPic) values(?,?,?,?,?)";
    BOOL b = [_dataBase executeUpdate:sql,[NSString stringWithFormat:@"%d",recordType],dict[@"shopID"],dict[@"shopName"],dict[@"time"],dict[@"shopPic"]];
    NSLog(@"insert b = %d",b);
    return b;
}
//删除 (删除一个月之前 删除一年前 删除所有的逛店记录)_可以通过判断时间戳的差别来得出是否走删除记录这个方法)(缓存设置里面的删除)
-(BOOL)deleteVisitShopRecordWithRecordType:(RecordType)recordType
{
    NSString *sql = @"delete from visitShopRecord where recordType=?";
    BOOL b = [_dataBase executeUpdate:sql,[NSString stringWithFormat:@"%d",recordType]];
    NSLog(@"delete b = %d",b);
    return b;
}
//删除 (删除指定的某个记录)
-(BOOL)deleteVisitShopREcordWithShopID:(NSNumber *)shopID recordType:(RecordType)recordType
{
    NSString *sql = @"delete from visitShopRecord where shopID=? and recordType=?";
    BOOL b = [_dataBase executeUpdate:sql,shopID,[NSString stringWithFormat:@"%d",recordType]];
    NSLog(@"delete b = %d",b);
    return b;
}

//查是否存在
-(BOOL)isExistVisitShopRecordWithShopID:(NSString *)shopID recordTyoe:(RecordType)recordType
{
    NSString *sql = @"select count(*) from visitShopRecord where shopID=? and recordType=?";
    FMResultSet *resultSet = [_dataBase executeQuery:sql,shopID,[NSString stringWithFormat:@"%d",recordType]];
    int count=0;
    if([resultSet next])
    {
        count = [resultSet intForColumnIndex:0];
    }
    return count>0;

}
//获取某种类型的数据
-(NSArray *)getVisitShopRecordWithRecordTyepe:(RecordType)recordType
{
    NSString *sql = @"select * from visitShopRecord where recordType=?";
    FMResultSet *resultSet = [_dataBase executeQuery:sql,[NSString stringWithFormat:@"%d",recordType]];
    //返回多条信息
    NSMutableArray *array = [[NSMutableArray alloc]init];
    while ([resultSet next]) {
        
        myLookedShopModel *model = [[myLookedShopModel alloc]init];
        model.id = [resultSet stringForColumn:@"shopID"];
        model.name = [resultSet stringForColumn:@"shopName"];
        model.shopPic = [resultSet stringForColumn:@"shopPic"];
        model.time = [resultSet stringForColumn:@"time"];
        
        [array addObject:model];
    }
    return array;
}

//更新某个商店的访问时间
-(BOOL)upDateVisitShopTimeWithShopID:(NSString *)shopID time:(NSString *)time
{
    NSString *sql = @"UPDATE visitShopRecord SET time = ? WHERE shopID = ?";
    BOOL b = [_dataBase executeUpdate:sql,time,shopID];
    NSLog(@"UPDATE b = %d",b);
    return b;
}


#pragma mark-(粉丝店)
//添加
-(BOOL)addFansShopRecordWithDicitionary:(NSDictionary *)dict recordType:(RecordType)recordType
{
    NSString *sql = @"insert into fansShop(recordType,fansShopId,name,pic,time,msgEnable) values(?,?,?,?,?,?)";
    BOOL b = [_dataBase executeUpdate:sql,[NSString stringWithFormat:@"%d",recordType],dict[@"id"],dict[@"name"],dict[@"pic"],dict[@"time"],dict[@"msgEnable"]];
    NSLog(@"insert b = %d",b);
    return b;
}

//删除
-(BOOL)deleteFansShopRecordWithDicitionary:(NSDictionary *)dict recordType:(RecordType)recordType
{
    NSString *sql = @"delete from fansShop where fansShopId=? and recordType=?";
    BOOL b = [_dataBase executeUpdate:sql,dict[@"id"],[NSString stringWithFormat:@"%d",recordType]];
    NSLog(@"delete b = %d",b);
    return b;
    
}

//更新粉丝店是否接受推送消息
-(BOOL)upDateFansShopReceiveFansShopPushMessageWithShopID:(NSNumber *)shopID withMsgEnable:(NSNumber *)enable
{
    NSString *sql = @"UPDATE fansShop SET msgEnable = ? WHERE fansShopId = ?";
    BOOL b = [_dataBase executeUpdate:sql,enable,shopID];
    NSLog(@"UPDATE b = %d",b);
    return b;
}

//查是否存在
-(BOOL)isExistFansShopRecordWithDicitionary:(NSDictionary *)dict recordType:(RecordType)recordType
{
    NSString *sql = @"select count(*) from fansShop where fansShopId=? and recordType=?";
    FMResultSet *resultSet = [_dataBase executeQuery:sql,dict[@"id"],[NSString stringWithFormat:@"%d",recordType]];
    int count=0;
    if([resultSet next])
    {
        count = [resultSet intForColumnIndex:0];
    }
    return count>0;
    
}
//获取某一个具体粉丝店的信息
-(NSArray *)getOneFansShopRecordWith:(NSNumber *)shopID
{
    NSString *sql = @"select * from fansShop where fansShopId=?";
    FMResultSet *resultSet = [_dataBase executeQuery:sql,shopID];
    //返回多条信息
    NSMutableArray *array = [[NSMutableArray alloc]init];
    while ([resultSet next]) {
        
        fansShopDataBaseModel *model = [[fansShopDataBaseModel alloc]init];
        model.id = [resultSet stringForColumn:@"fansShopId"];
        model.name = [resultSet stringForColumn:@"name"];
        model.pic = [resultSet stringForColumn:@"pic"];
        model.time = [resultSet stringForColumn:@"time"];
        model.msgEnable = [resultSet stringForColumn:@"msgEnable"];
        [array addObject:model];
    }
    return array;
}


//获取某种类型 （所有的粉丝店的信息）
-(NSArray *)getFansShopRecordWithRecordType:(RecordType)recordType
{
    NSString *sql = @"select * from fansShop where recordType=?";
    FMResultSet *resultSet = [_dataBase executeQuery:sql,[NSString stringWithFormat:@"%d",recordType]];
    //返回多条信息
    NSMutableArray *array = [[NSMutableArray alloc]init];
    while ([resultSet next]) {
        
        fansShopDataBaseModel *model = [[fansShopDataBaseModel alloc]init];
        model.id = [resultSet stringForColumn:@"fansShopId"];
        model.name = [resultSet stringForColumn:@"name"];
        model.pic = [resultSet stringForColumn:@"pic"];
        model.time = [resultSet stringForColumn:@"time"];
        model.msgEnable = [resultSet stringForColumn:@"msgEnable"];
        [array addObject:model];
    }
    return array;
}

#pragma mark-(收藏)
//添加
-(BOOL)addCollectionRecordWithDicitionary:(collectionDataBaseModel *)model recordType:(RecordType)recordType
{
    
    NSString *sql = @"insert into collection(recordType,gid,sid,desp,price,promot,pic) values(?,?,?,?,?,?,?)";
    BOOL b = [_dataBase executeUpdate:sql,[NSString stringWithFormat:@"%d",recordType],model.gid,model.sid,model.desp,model.price,model.promot,model.pic];
    NSLog(@"insert b = %d",b);
    return b;
    
}
//删除(某一个指定的记录)
-(BOOL)deleteCollectionRecordWithDicitionary:(collectionDataBaseModel *)model recordType:(RecordType)recordType
{
    NSString *sql = @"delete from collection where gid=? and recordType=?";
    BOOL b = [_dataBase executeUpdate:sql,model.gid,[NSString stringWithFormat:@"%d",recordType]];
    NSLog(@"delete b = %d",b);
    return b;
}
//删除 （删除所有记录）
-(BOOL)deleteAllCollectionRecordWithRecordType:(RecordType)recordType
{
    NSString *sql = @"delete from collection where recordType=?";
    BOOL b = [_dataBase executeUpdate:sql,[NSString stringWithFormat:@"%d",recordType]];
    NSLog(@"delete all b = %d",b);
    return b;

}


//查是否存在
-(BOOL)isExistCollectionRecordWithDicitionary:(collectionDataBaseModel *)model recordType:(RecordType)recordType
{
    NSString *sql = @"select count(*) from collection where gid=? and recordType=?";
    FMResultSet *resultSet = [_dataBase executeQuery:sql,model.gid,[NSString stringWithFormat:@"%d",recordType]];
    int count=0;
    if([resultSet next])
    {
        count = [resultSet intForColumnIndex:0];
    }
    return count>0;
    
}

//获取某种类型的记录
-(NSArray *)getCollectionRecordWithRecordType:(RecordType)recordType
{
    NSString *sql = @"select * from collection where recordType=?";
    FMResultSet *resultSet = [_dataBase executeQuery:sql,[NSString stringWithFormat:@"%d",recordType]];
    //返回多条信息
    NSMutableArray *array = [[NSMutableArray alloc]init];
    while ([resultSet next]) {
        
        collectionDataBaseModel *model = [[collectionDataBaseModel alloc]init];
        model.gid = [resultSet stringForColumn:@"gid"];
        model.sid = [resultSet stringForColumn:@"sid"];
        model.desp = [resultSet stringForColumn:@"desp"];
        model.price = [resultSet stringForColumn:@"price"];
        model.promot = [resultSet stringForColumn:@"promot"];
        model.pic = [resultSet stringForColumn:@"pic"];
        [array addObject:model];
    }
    return array;
    
}

#pragma mark-(用户信息)
//添加记录
-(BOOL)addUserInformationRecordWithDicitionary:(NSDictionary *)dict recordType:(RecordType)recordType
{
    NSString *sql = @"insert into staticUserInfo(recordType,frdID,rmkName,nickName,mcode,portrait) values(?,?,?,?,?,?)";
    BOOL b = [_dataBase executeUpdate:sql,[NSString stringWithFormat:@"%d",recordType],dict[@"frdID"],dict[@"rmkName"],dict[@"nickName"],dict[@"mcode"],dict[@"portrait"]];
    NSLog(@"insert b = %d",b);
    return b;
}

//删除记录
-(BOOL)deleteUserInformationRecordWithDicitionary:(NSNumber *)frdID recordType:(RecordType)recordType
{
    NSString *sql = @"delete from staticUserInfo where frdID=? and recordType=?";
    BOOL b = [_dataBase executeUpdate:sql,frdID,[NSString stringWithFormat:@"%d",recordType]];
    NSLog(@"delete b = %d",b);
    return b;
}

//更新某个好友的备注名字
-(BOOL)upDateStaticUserInfoRemarkNameWithFrD:(NSNumber *)frdID remarkName:(NSString *)remarkName
{
    NSString *sql = @"UPDATE staticUserInfo SET rmkName = ? WHERE frdID = ?";
    BOOL b = [_dataBase executeUpdate:sql,remarkName,frdID];
    NSLog(@"UPDATE b = %d",b);
    return b;
}

//查某个记录是否存在
-(BOOL)isExistUserInformationRecordWithUserID:(NSString *)userID recordType:(RecordType)recordType
{
    NSString *sql = @"select count(*) from staticUserInfo where frdID=? and recordType=?";
    NSNumber *userIDNumber = [[NSNumber alloc]initWithInt:userID.intValue];
    FMResultSet *resultSet = [_dataBase executeQuery:sql,userIDNumber,[NSString stringWithFormat:@"%d",recordType]];
    int count=0;
    if([resultSet next])
    {
        count = [resultSet intForColumnIndex:0];
    }
    return count>0;
}



//获取某种类型的数据记录-某个好友的信息
-(NSDictionary *)getUserInformationRecordWithUserID:(NSString *)userID
{
    NSString *sql = @"select * from staticUserInfo where frdID=?";
    NSNumber *userIDNumber = [[NSNumber alloc]initWithInt:userID.intValue];
    FMResultSet *resultSet = [_dataBase executeQuery:sql,userIDNumber];
    //返回多条信息
    NSMutableDictionary *finalDict = [[NSMutableDictionary alloc]init];
    while ([resultSet next]) {
         NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setObject:[resultSet stringForColumn:@"frdID"] forKey:@"frdID"];
        [dict setObject:[resultSet stringForColumn:@"rmkName"] forKey:@"rmkName"];
        [dict setObject:[resultSet stringForColumn:@"nickName"] forKey:@"nickName"];
        [dict setObject:[resultSet stringForColumn:@"mcode"] forKey:@"mcode"];
        [dict setObject:[resultSet stringForColumn:@"portrait"] forKey:@"portrait"];
        finalDict = dict;
    }
    return finalDict;
}



//获取所有好友的信息
-(NSArray *)getAllUserInformationWith:(RecordType)recordType
{
    NSString *sql = @"select * from staticUserInfo where recordType=?";
    FMResultSet *resultSet = [_dataBase executeQuery:sql,[NSString stringWithFormat:@"%d",recordType]];
    //返回多条信息
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    while ([resultSet next]) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setObject:[resultSet stringForColumn:@"frdID"] forKey:@"frdID"];
        [dict setObject:[resultSet stringForColumn:@"rmkName"] forKey:@"rmkName"];
        [dict setObject:[resultSet stringForColumn:@"nickName"] forKey:@"nickName"];
        [dict setObject:[resultSet stringForColumn:@"mcode"] forKey:@"mcode"];
        [dict setObject:[resultSet stringForColumn:@"portrait"] forKey:@"portrait"];
        [array addObject:dict];
    }
    return array;
}



#pragma mark-(消息记录)
//添加
-(BOOL)addMessagesWith:(NSString *)gname andMessageBody:(NSDictionary *)messageDict
{
    NSLog(@"存入数据库的字典%@",messageDict);
    
    NSString *userString = [NSString stringWithFormat:@"%@",messageDict[@"user"]];
//    NSString *emojiString = [NSString stringWithFormat:@"%@",messageDict[@"m"]];
//    NSString *finalEmojiString = [NSString stringWithFormat:@"%s",[emojiString cStringUsingEncoding:NSUnicodeStringEncoding]];
    
    NSString *sql = @"insert into messageRecord(user,time,mtype,gname,m) values(?,?,?,?,?)";
    BOOL b = [_dataBase executeUpdate:sql,userString,messageDict[@"time"],messageDict[@"mtype"],gname,messageDict[@"m"]];
    NSLog(@"insert messageRecord b = %d",b);
    
    return b;

}

//删除（某一个gname）
-(BOOL)deleteMessageWith:(NSString *)gname
{
    NSString *sql = @"delete from messageRecord where gname=?";
    BOOL b = [_dataBase executeUpdate:sql,gname];
    NSLog(@"delete b = %d",b);
    return b;
}

//删除所有的聊天记录
-(BOOL)deleteAllMessageRecordWith:(RecordType)recordType
{
    NSString *sql = @"delete from messageRecord";
    BOOL b = [_dataBase executeUpdate:sql];
    NSLog(@"delete b = %d",b);
    return b;
}

//是否存在
-(BOOL)isExistMessageWith:(NSString *)gname
{
    NSString *sql = @"select count(*) from messageRecord where gname=?";
    FMResultSet *resultSet = [_dataBase executeQuery:sql,gname];
    int count=0;
    if([resultSet next])
    {
        count = [resultSet intForColumnIndex:0];
    }
    return count>0;
}

//获取某个gname的消息
-(NSArray *)getMessagesWithGname:(NSString *)gname
{
    NSString *sql = @"select * from messageRecord where gname=?";
    FMResultSet *resultSet = [_dataBase executeQuery:sql,gname];
    //返回多条信息
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    while ([resultSet next]) {
        NSMutableDictionary *dict  = [[NSMutableDictionary alloc]init];
        [dict setObject:[resultSet stringForColumn:@"user"] forKey:@"user"];
        [dict setObject:[resultSet stringForColumn:@"time"] forKey:@"time"];
        [dict setObject:[resultSet stringForColumn:@"mtype"] forKey:@"mtype"];
        [dict setObject:[resultSet stringForColumn:@"m"] forKey:@"m"];
        [array addObject:dict];
        
    }
    return array;
    
}

@end
