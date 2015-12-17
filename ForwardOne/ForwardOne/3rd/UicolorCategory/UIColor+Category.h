//
//  UIColor+Category.h
//  Test
//
//  Created by 潇哥 on 15/7/9.
//  Copyright (c) 2015年 潇哥. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Category)

/**
 *  @brief  根据十六进制色值字符串返回对应的颜色
 */
+ (UIColor *)colorWithHexStr:(NSString *)hex;

@end
