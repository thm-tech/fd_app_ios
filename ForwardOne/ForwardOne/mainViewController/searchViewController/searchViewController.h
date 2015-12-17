//
//  searchViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/8/5.
//  Copyright (c) 2015年 杨波. All rights reserved.
//
@protocol YBSearchViewControllerChatDelegate <NSObject>

-(void)YBSearchViewControllerChangeGname:(NSString *)gname andGroupName:(NSString *)groupName;

@end



#import <UIKit/UIKit.h>

@interface searchViewController : UIViewController

@property (copy,nonatomic) NSString *cityIDString;

@property (copy,nonatomic) NSString *invitationLabelString;
@property (copy,nonatomic) NSString *gnameString;

@property (nonatomic,weak) id<YBSearchViewControllerChatDelegate>YB_delegate;


@end
