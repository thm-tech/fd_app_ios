//
//  searchModel.h
//  ForwardOne
//
//  Created by 杨波 on 15/9/7.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface searchModel : NSObject

@property (copy,nonatomic) NSString *id;
@property (copy,nonatomic) NSString *name;
@property (copy,nonatomic) NSArray *picList;
@property (copy,nonatomic) NSString *distance;
@property (copy,nonatomic) NSString *fans;
@property (copy,nonatomic) NSString *customers;

@end
