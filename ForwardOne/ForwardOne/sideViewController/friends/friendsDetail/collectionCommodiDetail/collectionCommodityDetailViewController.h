//
//  collectionCommodityDetailViewController.h
//  ForwardOne
//
//  Created by 杨波 on 15/5/8.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface collectionCommodityDetailViewController : UIViewController

//传递过来的goodsID
@property (copy,nonatomic) NSString *goodsIDString;
@property (copy,nonatomic) NSString *shopIDString;

@end
