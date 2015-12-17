//
//  myLookedShopViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/9.
//  Copyright (c) 2015年 杨波. All rights reserved.
//
@protocol YBMyLookedShopChatChangeGroupGnameDelegate <NSObject>

-(void)YBMyLookedShopChatChangeGroupNameWithGname:(NSString *)gname andGroupName:(NSString *)groupName;

@end


#import <UIKit/UIKit.h>

@interface myLookedShopViewController : UIViewController

@property (copy,nonatomic) NSString *invitationLabelString;
@property (copy,nonatomic) NSString *gnameString;

@property (nonatomic,weak) id<YBMyLookedShopChatChangeGroupGnameDelegate>YB_delegate;

@end
