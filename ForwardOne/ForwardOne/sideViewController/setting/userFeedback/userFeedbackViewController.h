//
//  userFeedbackViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/9.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UUMessageCell.h"
#import "userFeedbackChatModel.h"
#import "UUMessageFrame.h"
#import "UUMessage.h"

@interface userFeedbackViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,UUMessageCellDelegate>

@property (strong, nonatomic) id detailItem;

//聊天的model

@property (nonatomic,strong)userFeedbackChatModel *chatModel;

@end
