//
//  mainShopDetailViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/14.
//  Copyright (c) 2015年 杨波. All rights reserved.
//
//商店详情与主界面之间的gname反向传值
@protocol YBShopDetailChangeGroupNameDelegate <NSObject>

-(void)YBShopDetailChangeGroupGname:(NSString *)gname andGroupName:(NSString *)groupName;

@end



#import <UIKit/UIKit.h>
#import "iCarousel.h"

#import "JSMessageInputView.h"
#import "JSMessageTextView.h"
#import "EmotionsViewController.h"

#import "ChatUtilityViewController.h"

#import "MJRefresh.h"
#import "UUMessageCell.h"
#import "chatModel.h"
#import "UUMessageFrame.h"
#import "UUMessage.h"

@interface mainShopDetailViewController : UIViewController <iCarouselDelegate,iCarouselDataSource,JSMessageInputViewDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,DDEmotionsViewControllerDelegate,ChatUtilityViewControllerDelegate,UUMessageCellDelegate>



@property (nonatomic,strong) iCarousel *carousel;

//聊天相关的
@property (strong, nonatomic) id detailItem;
@property(nonatomic,strong)JSMessageInputView *chatInputView;
@property(nonatomic,strong)ChatUtilityViewController *ddUtility;
@property(nonatomic,strong)EmotionsViewController *emotions;
//聊天的model
@property (nonatomic,strong)chatModel *chatModel;




//传入的参数shopID
@property (copy,nonatomic) NSString *shopIDString;
@property (nonatomic,copy) NSString *shopNamestrting;
@property (nonatomic,copy) NSString *shopPic;



@property (copy,nonatomic) NSString *invitationLabelString;
@property (copy,nonatomic) NSString *gnameString;

@property (nonatomic,weak) id<YBShopDetailChangeGroupNameDelegate>YB_ShopDetailChangeDelegate;

@end
