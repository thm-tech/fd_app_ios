//
//  shakeAndShakeViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/26.
//  Copyright (c) 2015年 杨波. All rights reserved.
//
@protocol YBShakeChangeChatDelegate <NSObject>

-(void)YBShakeChangeChatWithGname:(NSString *)gname andGroupName:(NSString *)groupName;

@end


#import <UIKit/UIKit.h>

@interface shakeAndShakeViewController : UIViewController

//聊天组的gname传值
@property (copy,nonatomic) NSString *invitationLabelString;
@property (copy,nonatomic) NSString *gnameString;

@property (nonatomic,weak) id<YBShakeChangeChatDelegate>YB_delegate;

@end
