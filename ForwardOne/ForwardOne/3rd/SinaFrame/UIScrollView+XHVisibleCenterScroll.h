//
//  UIScrollView+XHVisibleCenterScroll.h
//  XHScrollMenu
//
//  Created by 杨波 on 14-3-9.
//  Copyright (c) 2014年 杨波. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (XHVisibleCenterScroll)

- (void)scrollRectToVisibleCenteredOn:(CGRect)visibleRect
                             animated:(BOOL)animated;

@end
