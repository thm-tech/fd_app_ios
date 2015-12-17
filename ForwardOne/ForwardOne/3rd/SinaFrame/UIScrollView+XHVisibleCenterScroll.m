//
//  UIScrollView+XHVisibleCenterScroll.m
//  XHScrollMenu
//
//  Created by 杨波 on 14-3-9.
//  Copyright (c) 杨波. All rights reserved.
//

#import "UIScrollView+XHVisibleCenterScroll.h"

@implementation UIScrollView (XHVisibleCenterScroll)

- (void)scrollRectToVisibleCenteredOn:(CGRect)visibleRect
                             animated:(BOOL)animated {
    
    //注释：当菜单栏上面按钮比较多时，当前屏幕不能完全显示出来，这时采用以下方法，来动态显示菜单栏上面的按钮
    
    //visibleRect为当前选中按钮的frame
//    CGRect centeredRect = CGRectMake(visibleRect.origin.x + visibleRect.size.width/2.0 - self.frame.size.width/2.0,
//                                     visibleRect.origin.y + visibleRect.size.height/2.0 - self.frame.size.height/2.0,
//                                     self.frame.size.width,
//                                     self.frame.size.height);
    CGRect centeredRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height );
    [self scrollRectToVisible:centeredRect
                     animated:animated];
}

@end
