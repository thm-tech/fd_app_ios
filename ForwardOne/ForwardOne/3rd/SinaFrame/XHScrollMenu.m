//
//  XHScrollMenu.m
//  XHScrollMenu
//
//  Created by 杨波 on 14-3-8.
//  Copyright (c) 2014年杨波. All rights reserved.
//

#import "XHScrollMenu.h"

#import "UIScrollView+XHVisibleCenterScroll.h"

#define kXHMenuButtonBaseTag 100

@interface XHScrollMenu () <UIScrollViewDelegate> {
    
}

@property (nonatomic, strong) UIImageView *leftShadowView;
@property (nonatomic, strong) UIImageView *rightShadowView;

@property (nonatomic, strong) UIButton *managerMenusButton;

@property (nonatomic, strong) NSMutableArray *menuButtons;

@end

@implementation XHScrollMenu

#pragma mark - Propertys

- (NSMutableArray *)menuButtons {
    if (!_menuButtons) {
        _menuButtons = [[NSMutableArray alloc] initWithCapacity:self.menus.count];
    }
    return _menuButtons;
}

#pragma mark - Action

- (void)managerMenusButtonClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(scrollMenuDidManagerSelected:)]) {
        [self.delegate scrollMenuDidManagerSelected:self];
    }
}

- (void)menuButtonSelected:(UIButton *)sender {
    [self.menuButtons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (obj == sender) {
            sender.selected = YES;
        } else {
            UIButton *menuButton = obj;
            menuButton.selected = NO;
        }
    }];
    [self setSelectedIndex:sender.tag - kXHMenuButtonBaseTag animated:YES calledDelegate:YES];
}

#pragma mark - Life cycle

- (UIImageView *)getShadowView:(BOOL)isLeft {
//    UIImageView *shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 7, CGRectGetHeight(self.bounds))];
//    shadowImageView.image = [UIImage imageNamed:(isLeft ? @"leftShadow" : @"rightShadow")];
    /** keep this code due with layer shadow
    shadowImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowImageView.layer.shadowOffset = CGSizeMake((isLeft ? 2.5 : -1.5), 0);
    shadowImageView.layer.shadowRadius = 3.2;
    shadowImageView.layer.shadowOpacity = 0.5;
    shadowImageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowImageView.bounds].CGPath;
     */
    
//    shadowImageView.hidden = isLeft;
//    return shadowImageView;
    return nil;
}

- (void)setup {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _selectedIndex = 0;
    
    //_leftShadowView = [self getShadowView:YES];
    //_leftShadowView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    //_rightShadowView = [self getShadowView:NO];
    //_rightShadowView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
   // CGFloat width = CGRectGetHeight(self.bounds);
   // _managerMenusButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - width, 0, width, width)];
   // _managerMenusButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
  //  _managerMenusButton.backgroundColor = self.backgroundColor;
  //  [_managerMenusButton setImage:[UIImage imageNamed:@"managerMenuButton"] forState:UIControlStateNormal];
  //  [_managerMenusButton addTarget:self action:@selector(managerMenusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
   // CGRect rightShadowViewFrame = _rightShadowView.frame;
   // rightShadowViewFrame.origin = CGPointMake(CGRectGetMinX(_managerMenusButton.frame) - CGRectGetWidth(rightShadowViewFrame), 0);
   // _rightShadowView.frame = rightShadowViewFrame;
    
   // _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_leftShadowView.frame), 0, CGRectGetWidth(self.bounds) - CGRectGetWidth(rightShadowViewFrame) * 2 - CGRectGetWidth(_managerMenusButton.frame), CGRectGetHeight(self.bounds))];
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,self.bounds.size.width, self.bounds.size.height)];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    
    //Label下划线的颜色
    _indicatorView = [XHIndicatorView initIndicatorView];
    _indicatorView.alpha = 0.;
    _indicatorView.backgroundColor = [UIColor colorWithHexStr:@"#48d58b"];
    [_scrollView addSubview:self.indicatorView];
    
    [self addSubview:self.scrollView];
   // [self addSubview:self.leftShadowView];
   // [self addSubview:self.rightShadowView];
    //[self addSubview:self.managerMenusButton];
}

- (void)setupIndicatorFrame:(CGRect)menuButtonFrame animated:(BOOL)animated callDelegate:(BOOL)called {
    [UIView animateWithDuration:(animated ? 0.15 : 0) delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _indicatorView.frame = CGRectMake(CGRectGetMinX(menuButtonFrame), CGRectGetHeight(self.bounds) - kXHIndicatorViewHeight, CGRectGetWidth(menuButtonFrame), kXHIndicatorViewHeight);
    } completion:^(BOOL finished) {
        if (called) {
            if ([self.delegate respondsToSelector:@selector(scrollMenuDidSelected:menuIndex:)]) {
                [self.delegate scrollMenuDidSelected:self menuIndex:self.selectedIndex];
            }
        }
    }];
}

- (UIButton *)getButtonWithMenu:(XHMenu *)menu {
    //
//    CGSize buttonSize = [menu.title sizeWithFont:menu.titleFont constrainedToSize:CGSizeMake(MAXFLOAT, CGRectGetHeight(self.bounds) - 10) lineBreakMode:NSLineBreakByCharWrapping];
//    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonSize.width, buttonSize.height)];
   // UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0,self.bounds.size.width*0.21875, 45)];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width*((1-0.03125*self.menus.count)/self.menus.count), 45)];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = menu.titleFont;
    [button setTitle:menu.title forState:UIControlStateNormal];
    [button setTitle:menu.title forState:UIControlStateHighlighted];
    [button setTitle:menu.title forState:UIControlStateSelected];
    [button setTitleColor:menu.titleNormalColor forState:UIControlStateNormal];
    [button setTitleColor:menu.titleSelectedColor forState:UIControlStateSelected];
    [button setTitleColor:menu.titleHighlightedColor forState:UIControlStateHighlighted];
//    
//    if (!menu.titleHighlightedColor) {
//        menu.titleHighlightedColor = menu.titleNormalColor;
//    }
//    [button setTitleColor:menu.titleSelectedColor forState:UIControlStateHighlighted];
//    if (menu.titleSelectedColor) {
//        menu.titleHighlightedColor = menu.titleSelectedColor;
//    }
//    [button setTitleColor:menu.titleSelectedColor forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(menuButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

#pragma mark - Public

- (CGRect)rectForSelectedItemAtIndex:(NSUInteger)index {
    CGRect rect = ((UIView *)self.menuButtons[index]).frame;
    return rect;
}

- (XHMenuButton *)menuButtonAtIndex:(NSUInteger)index {
    return self.menuButtons[index];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)aniamted calledDelegate:(BOOL)calledDelgate {
    _selectedIndex = selectedIndex;
    //通过菜单栏上面按钮的序号得到当前按钮
    UIButton *selectedMenuButton = [self menuButtonAtIndex:_selectedIndex];
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        selectedMenuButton.selected = YES;
               
        //滚动视图的扩展类方法，菜单栏的滚动视图执行此方法，传入的参数是当前选中按钮的frame
        [self.scrollView scrollRectToVisibleCenteredOn:selectedMenuButton.frame animated:NO];
    } completion:^(BOOL finished) {
        
        //根据菜单栏上面当前选中的按钮来动态设置横线label的位置
        [self setupIndicatorFrame:selectedMenuButton.frame animated:aniamted callDelegate:calledDelgate];
    }];
}
-(void)setUnSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    UIButton *unSelectedButton = [self menuButtonAtIndex:_selectedIndex];
    unSelectedButton.selected = NO;
}

- (void)reloadData {
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIButton class]]) {
            [((UIButton *)obj) removeFromSuperview];
        }
    }];

    //menuButtons为一可变数组
    if (self.menuButtons.count)
        [self.menuButtons removeAllObjects];

    
    // layout subViews
    //contentWidth为设置菜单栏左右滑动的参数
    CGFloat contentWidth = 10;
    //menus为菜单栏上面按钮的数组
    //循环遍历菜单栏上面按钮的数组
    for (XHMenu *menu in self.menus) {
        //得到菜单栏上面按钮在菜单栏中得下标
        NSUInteger index = [self.menus indexOfObject:menu];
        
        //创建Button button的大小是根据titile的字体大小来设定的
        UIButton *menuButton = [self getButtonWithMenu:menu];
        menuButton.tag = kXHMenuButtonBaseTag + index;
        CGRect menuButtonFrame = menuButton.frame;
        CGFloat buttonX = 0;
        if (index) {
        
            //buttonX = kXHMenuButtonPaddingX + CGRectGetMaxX(((UIButton *)(self.menuButtons[index - 1])).frame);
             buttonX = kXHMenuButtonPaddingX + CGRectGetMaxX(((UIButton *)(self.menuButtons[index - 1])).frame);
        } else {
            buttonX = kXHMenuButtonStarX;
        }
        
        menuButtonFrame.origin = CGPointMake(buttonX, CGRectGetMidY(self.bounds) - (CGRectGetHeight(menuButtonFrame) / 2.0));
        menuButton.frame = menuButtonFrame;
        [self.scrollView addSubview:menuButton];
        [self.menuButtons addObject:menuButton];
        
        // scrollView content size width
        if (index == self.menus.count - 1) {
            contentWidth += CGRectGetMaxX(menuButtonFrame);
        }
        
        if (self.selectedIndex == index) {
            menuButton.selected = YES;
            // indicator
            _indicatorView.alpha = 1.;
            [self setupIndicatorFrame:menuButtonFrame animated:NO callDelegate:NO];
        }
    }
    //当菜单上按钮过多，当前屏幕不能完全显示的时候，需要滑动scrollView，用下面的方法
 //[self.scrollView setContentSize:CGSizeMake(contentWidth, CGRectGetHeight(self.scrollView.frame))];
    
    [self.scrollView setContentSize:CGSizeMake(self.bounds.size.width, CGRectGetHeight(self.scrollView.frame))];
    [self setSelectedIndex:self.selectedIndex animated:NO calledDelegate:YES];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGFloat contentOffsetX = scrollView.contentOffset.x;
//    CGFloat contentSizeWidth = (NSInteger)scrollView.contentSize.width;
//    CGFloat scrollViewWidth = CGRectGetWidth(scrollView.bounds);
//    if (contentSizeWidth == scrollViewWidth) {
//        self.leftShadowView.hidden = YES;
//        self.rightShadowView.hidden = YES;
//    } else if (contentSizeWidth <= scrollViewWidth) {
//        self.leftShadowView.hidden = YES;
//        self.rightShadowView.hidden = YES;
//    } else {
//        if (contentOffsetX > 0) {
//            self.leftShadowView.hidden = NO;
//        } else {
//            self.leftShadowView.hidden = YES;
//        }
//        
//        if ((contentOffsetX + scrollViewWidth) >= contentSizeWidth) {
//            self.rightShadowView.hidden = YES;
//        } else {
//            self.rightShadowView.hidden = NO;
//        }
//    }
}

@end
