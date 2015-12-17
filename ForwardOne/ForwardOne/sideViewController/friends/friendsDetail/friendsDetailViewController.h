//
//  friendsDetailViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/7.
//  Copyright (c) 2015年 杨波. All rights reserved.
//
@protocol YBFriendDetailChatDelegate <NSObject>

-(void)YBYBFriendDetailChatWithGname:(NSString *)gname andGroupName:(NSString *)groupName;

@end



#import <UIKit/UIKit.h>

@interface friendsDetailViewController : UIViewController

@property (copy,nonatomic) NSString *frdIDString;

@property (copy,nonatomic) NSString *invitationLabelString;
@property (copy,nonatomic) NSString *gnameString;

@property (nonatomic,weak) id<YBFriendDetailChatDelegate> YB_delegate;

@end
