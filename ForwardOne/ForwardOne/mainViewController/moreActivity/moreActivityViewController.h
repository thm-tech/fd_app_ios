//
//  moreActivityViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/8/11.
//  Copyright (c) 2015年 杨波. All rights reserved.
//
@protocol YBSendMoreActivityDelegate <NSObject>

-(void)YBSendMoreActivityDelegateWithGname:(NSString *)gname andGroupName:(NSString *)groupName;

@end


#import <UIKit/UIKit.h>

@interface moreActivityViewController : UIViewController

@property (copy,nonatomic) NSArray *dataArray;
@property (weak,nonatomic) id<YBSendMoreActivityDelegate> YB_delegate;

@property (copy,nonatomic) NSString *invitationLabelString;
@property (copy,nonatomic) NSString *gnameString;

@end
