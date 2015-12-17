//
//  UIColor+Category.m
//  Test
//
//  Created by 潇哥 on 15/7/9.
//  Copyright (c) 2015年 潇哥. All rights reserved.
//

#import "UIColor+Category.h"

@implementation UIColor (Category)

+ (UIColor *)colorWithHexStr:(NSString *)hex {
    
    NSRange rang;
    rang.location = 0;
    rang.length = 1;
    NSString *first = [hex substringWithRange:rang];
    if ([first isEqualToString:@"#"]) {
        hex = [hex substringFromIndex:1];
    }
    rang.length = 2;
    NSString *rStr = [hex substringWithRange:rang];
    rang.location = 2;
    NSString *gStr = [hex substringWithRange:rang];
    rang.location = 4;
    NSString *bStr = [hex substringWithRange:rang];
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rStr] scanHexInt:&r];
    [[NSScanner scannerWithString:gStr] scanHexInt:&g];
    [[NSScanner scannerWithString:bStr] scanHexInt:&b];
    
    return [UIColor colorWithRed:(float)r/255 green:(float)g/255 blue:(float)b/255 alpha:1];
}

@end
