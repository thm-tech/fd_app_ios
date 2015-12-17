//
//  miaomiaoChatGroupSettingViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/6/1.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface miaomiaoChatGroupSettingViewController : UIViewController

@property (copy,nonatomic) NSString *usersIDString;

//单聊为对方ID  群聊为创建者的ID
@property (copy,nonatomic) NSString *senderIDString;
@property (copy,nonatomic) NSString *gnameString;



@property (copy,nonatomic) NSString *invitationLabelString;
@end
