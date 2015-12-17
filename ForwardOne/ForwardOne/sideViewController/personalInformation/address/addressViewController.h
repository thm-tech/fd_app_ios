//
//  addressViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/4.
//  Copyright (c) 2015年 杨波. All rights reserved.
//
//地址信息的界面的反响传值
@protocol YBMyLocationAddressDelegate <NSObject>

-(void)YBMyLocationAddressButtonDidClick:(NSString *)locationString;

@end


#import <UIKit/UIKit.h>

@interface addressViewController : UIViewController

@property (nonatomic,weak) id<YBMyLocationAddressDelegate>YB_locationDelegate;

@end
