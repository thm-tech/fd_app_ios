//
//  invivateFriendsShoppingViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/26.
//  Copyright (c) 2015年 杨波. All rights reserved.
//
//反向传值协议  传（gname）
@protocol YBInvivateFriendGnameDelegate <NSObject>

-(void)YBgetWebSocketGname:(NSString *)gname;
-(void)YBChangeGroupTableViewReloadData;
@end


#import <UIKit/UIKit.h>

@interface invivateFriendsShoppingViewController : UIViewController

@property (nonatomic,weak)id<YBInvivateFriendGnameDelegate>YB_GnameDelegate;

@property (copy,nonatomic) NSString *usersIDString;

//单聊的时候创建讨论组 需要加入单聊的ID
@property (copy,nonatomic) NSString *senderIDString;

//群聊的时候的讨论组gname
@property (copy,nonatomic) NSString *gnameString;

@end
