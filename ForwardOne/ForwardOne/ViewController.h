//
//  ViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/4/7.
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


@interface ViewController : UIViewController <JSMessageInputViewDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,DDEmotionsViewControllerDelegate,ChatUtilityViewControllerDelegate,UUMessageCellDelegate>

//从菜单栏上面传过来用来保存title的参数
@property (nonatomic,strong) NSString *titleString;


//聊天相关的
@property (strong, nonatomic) id detailItem;
@property(nonatomic,strong)JSMessageInputView *chatInputView;
@property(nonatomic,strong)ChatUtilityViewController *ddUtility;
@property(nonatomic,strong)EmotionsViewController *emotions;
//聊天的model
@property (nonatomic,strong)chatModel *chatModel;

//选择城市的ID
@property (copy,nonatomic)  NSString *cityIDString;


@end

