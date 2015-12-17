//
//  myFansShopViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/9.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

@protocol YBMyFanShopChatChangeGnameDelegate <NSObject>

-(void)YBMyFanShopChatChangeGnameWithGname:(NSString *)gname andGroupName:(NSString *)groupName;

@end


#import <UIKit/UIKit.h>

@interface myFansShopViewController : UIViewController

@property (copy,nonatomic) NSString *invitationLabelString;
@property (copy,nonatomic) NSString *gnameString;

@property (nonatomic,weak) id<YBMyFanShopChatChangeGnameDelegate> YB_delegate;

@end
