//
//  utils.h
//  ForwardOne
//
//  Created by 杨波 on 15/7/1.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface utils : NSObject
+ (BOOL) validateMobile:(NSString *)mobile ;
+ (BOOL) validatePassword:(NSString *)passWord;
+ (BOOL) validateUserName:(NSString *)name;
@end
