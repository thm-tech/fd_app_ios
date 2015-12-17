//
//  firendsViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/7.
//  Copyright (c) 2015年 杨波. All rights reserved.
//
@protocol YBFriendChatDelegate <NSObject>

-(void)YBFriendChatChangeGnamewithGname:(NSString *)gname andGroupName:(NSString *)groupName;

@end


#import <UIKit/UIKit.h>

@interface firendsViewController : UIViewController

@property (copy,nonatomic) NSString *invitationLabelString;
@property (copy,nonatomic) NSString *gnameString;

@property (nonatomic,weak) id<YBFriendChatDelegate> YB_deleagate;

@end
