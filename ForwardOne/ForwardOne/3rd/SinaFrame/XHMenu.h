//
//  XHMenu.h
//  XHScrollMenu
//
//  Created by 杨波 on 14-3-8.
//  Copyright (c) 2014年 杨波. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XHMenu : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleNormalColor;
@property (nonatomic, strong) UIColor *titleSelectedColor;
@property (nonatomic, strong) UIColor *titleHighlightedColor;

@end
