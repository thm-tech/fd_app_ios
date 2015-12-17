//
//  inShopActivityViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/9/30.
//  Copyright (c) 2015年 杨波. All rights reserved.
//
//发送活动界面选择聊天之后 界面进行反向传值
@protocol YBSendActivityDelegate <NSObject>

-(void)YBSendActivityDelgateWithGname:(NSString *)gname andGroupName:(NSString *)groupName;

-(void)YBSendActivityDelgateWithGname:(NSString *)gname andGroupName:(NSString *)groupName andShopID:(NSString *)shopID andShopPic:(NSString *)shopPic andShopName:(NSString *)shopName;

@end




#import <UIKit/UIKit.h>

#import "JSMessageInputView.h"
#import "JSMessageTextView.h"
#import "EmotionsViewController.h"

#import "ChatUtilityViewController.h"

#import "MJRefresh.h"
#import "UUMessageCell.h"
#import "chatModel.h"
#import "UUMessageFrame.h"
#import "UUMessage.h"

@interface inShopActivityViewController : UIViewController <JSMessageInputViewDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,DDEmotionsViewControllerDelegate,ChatUtilityViewControllerDelegate,UUMessageCellDelegate>

//聊天相关的
@property (strong, nonatomic) id detailItem;
@property(nonatomic,strong)JSMessageInputView *chatInputView;
@property(nonatomic,strong)ChatUtilityViewController *ddUtility;
@property(nonatomic,strong)EmotionsViewController *emotions;
//聊天的model
@property (nonatomic,strong)chatModel *chatModel;


//当前的gname（或从其他界面传值过来的）
@property (copy,nonatomic) NSString *gnameString;
@property (copy,nonatomic) NSString *invitationLabelString;

@property (copy,nonatomic) NSArray *activityArray;


@property (weak,nonatomic) id<YBSendActivityDelegate>YB_delegate;

@end
