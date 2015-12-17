//
//  mapViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/10/27.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface mapViewController : UIViewController

//传过来的经纬度 （地图显示）
@property (nonatomic,copy) NSString *longti;
@property (nonatomic,copy) NSString *latti;

@end
