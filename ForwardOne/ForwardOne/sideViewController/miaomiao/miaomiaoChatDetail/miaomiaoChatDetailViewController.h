//
//  miaomiaoChatDetailViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/21.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

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


@interface miaomiaoChatDetailViewController : UIViewController <JSMessageInputViewDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,DDEmotionsViewControllerDelegate,ChatUtilityViewControllerDelegate,UUMessageCellDelegate>


@property (strong, nonatomic) id detailItem;
@property(nonatomic,strong)JSMessageInputView *chatInputView;
@property(nonatomic,strong)ChatUtilityViewController *ddUtility;
@property(nonatomic,strong)EmotionsViewController *emotions;


//聊天的model
@property (nonatomic,strong)chatModel *chatModel;

@property (nonatomic,copy) NSString *gnameString;
@property (nonatomic,copy) NSString *chatTitleName;
@property (nonatomic,copy) NSString *usersIDString;
@property (copy,nonatomic) NSString *senderIDString;



@end
