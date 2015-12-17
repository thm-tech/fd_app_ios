//
//  XHScrollMenu.h
//  XHScrollMenu
//
//  Created by 杨波 on 14-3-8.
//  Copyright (c) 2014年 杨波 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHIndicatorView.h"
#import "XHMenu.h"
#import "XHMenuButton.h"

//菜单栏按钮的间距
//#define kXHMenuButtonPaddingX self.bounds.size.width * 0.125
#define kXHMenuButtonPaddingX self.bounds.size.width * 0.03125

//菜单栏第一个按钮的开始坐标
//#define kXHMenuButtonStarX self.bounds.size.width * 0.0625
#define kXHMenuButtonStarX self.bounds.size.width * 0.015625


//引入XHScrollMenu的类
@class XHScrollMenu;

//菜单栏上面的协议代理事件
@protocol XHScrollMenuDelegate <NSObject>

//菜单栏上面按钮的点击事件
- (void)scrollMenuDidSelected:(XHScrollMenu *)scrollMenu menuIndex:(NSUInteger)selectIndex;

//菜单栏右边管理按钮的点击事件
- (void)scrollMenuDidManagerSelected:(XHScrollMenu *)scrollMenu;

@end

@interface XHScrollMenu : UIView

//继承UIView 遵守自己制定的协议 <XHScrollMenuDelegate>
@property (nonatomic, assign) id <XHScrollMenuDelegate> delegate;

// UI  菜单栏上面的滚动视图，以及下面横线label的View
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) XHIndicatorView *indicatorView;

// DataSource menus菜单栏上面的按钮数组
@property (nonatomic, strong) NSArray *menus;

// select 菜单栏上面被选中按钮的序号
@property (nonatomic, assign) NSUInteger selectedIndex; // default is 0


//根据菜单栏上面当前选中的按钮来设置其他按钮的位置，以及横线label的位置
- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)aniamted calledDelegate:(BOOL)calledDelgate;

//添加的方法：
-(void)setUnSelectedIndex:(NSInteger)selectedIndex;

//由菜单栏上面选择按钮的序号返回坐标
- (CGRect)rectForSelectedItemAtIndex:(NSUInteger)index;

//通过菜单栏上面按钮的序号返回当前按钮
- (XHMenuButton *)menuButtonAtIndex:(NSUInteger)index;

// reload dataSource  重新刷新视图
- (void)reloadData;

@end
