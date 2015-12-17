//
//  shopInformationViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/8.
//  Copyright (c) 2015年 杨波. All rights reserved.
//
//在商店详情界面选择聊天之后 界面之间的反向传值
@protocol YBShopInformationChangeGnameDelegate <NSObject>

-(void)YBShopInformationChangeGnameWithGname:(NSString *)gname andGroupName:(NSString *)groupName;

-(void)YBShopInformationChangeGnameWithGname:(NSString *)gname andGroupName:(NSString *)groupName andShopPic:(NSString *)shopPic andShopIDString:(NSString *)shopID andShopNameString:(NSString *)shopName;

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

@interface shopInformationViewController : UIViewController <JSMessageInputViewDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,DDEmotionsViewControllerDelegate,ChatUtilityViewControllerDelegate,UUMessageCellDelegate>


//聊天相关的
@property (strong, nonatomic) id detailItem;
@property(nonatomic,strong)JSMessageInputView *chatInputView;
@property(nonatomic,strong)ChatUtilityViewController *ddUtility;
@property(nonatomic,strong)EmotionsViewController *emotions;
//聊天的model
@property (nonatomic,strong)chatModel *chatModel;


//传入的参数
@property (copy,nonatomic) NSString *shopIDString;
@property (nonatomic,copy) NSString *shopNamestrting;
@property (copy,nonatomic) NSString *shopDistanceString;

//当前的gname（或从其他界面传值过来的）
@property (copy,nonatomic) NSString *gnameString;
@property (copy,nonatomic) NSString *invitationLabelString;

@property (nonatomic,weak) id<YBShopInformationChangeGnameDelegate>YB_delegate;


@end
