//
//  MyCollectionViewCell.m
//  AppDevelopment
//
//  Created by 杨波 on 15/1/6.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "MyCollectionViewCell.h"

@implementation MyCollectionViewCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *label = [ZCControl createLabelWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width*0.22,[UIScreen mainScreen].bounds.size.height*0.06) Font:18 Text:nil];
        label.textAlignment = NSTextAlignmentCenter;
      //  label.backgroundColor = [UIColor orangeColor];
        [self.contentView addSubview:label];
       
        _label = label;
        
        _iconImageView = [ZCControl createImageViewWithFrame:CGRectMake(0, 0, (SCREENWIDTH-15)/2, SCREENHEIGHT*0.4*0.85) ImageName:nil];
        [self.contentView addSubview:_iconImageView];
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        
        _goodsNameLabel = [ZCControl createLabelWithFrame:CGRectMake(0, SCREENHEIGHT*0.4*0.85, (SCREENWIDTH-15)/2, SCREENHEIGHT*0.4*0.1) Font:SCREENWIDTH*0.0426 Text:nil];
        [self.contentView addSubview:_goodsNameLabel];
        
        
        //self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bottom.@2x"]];
        
//        _boomImageView = [ZCControl createImageViewWithFrame:CGRectMake(0, SCREENHEIGHT*0.3*0.84, SCREENWIDTH, SCREENHEIGHT*0.3*0.16) ImageName:nil];
//        _boomImageView.backgroundColor = [UIColor whiteColor];
//        _boomImageView.alpha = 0.6;
//        [self.contentView addSubview:_boomImageView];
        
//        _priceLabel  = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.03, SCREENHEIGHT*0.3*0.88, SCREENWIDTH*0.2, SCREENHEIGHT*0.3*0.2*0.6) Font:SCREENWIDTH*0.048 Text:@""];
//        _priceLabel.textAlignment = NSTextAlignmentCenter;
//        _priceLabel.textColor = [UIColor colorWithHexStr:@"#999999"];
//        //_priceLabel.backgroundColor = [UIColor orangeColor];
//        [self.contentView addSubview:_priceLabel];
//    
//        _lineIamgeView = [ZCControl createImageViewWithFrame:CGRectMake(SCREENWIDTH*0.05, SCREENHEIGHT*0.3*0.94, SCREENWIDTH*0.17, 1) ImageName:nil];
//        _lineIamgeView.backgroundColor = [UIColor colorWithHexStr:@"#999999"];
//        [self.contentView addSubview:_lineIamgeView];
//        
//        _promoteLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.22, SCREENHEIGHT*0.3*0.88, SCREENWIDTH*0.25, SCREENHEIGHT*0.3*0.2*0.6) Font:SCREENWIDTH*0.053 Text:@""];
//        _promoteLabel.textAlignment = NSTextAlignmentCenter;
//        _promoteLabel.textColor = [UIColor colorWithHexStr:@"#ff0000"];
//        [self.contentView addSubview:_promoteLabel];
        
    }
    return self;
}

@end
