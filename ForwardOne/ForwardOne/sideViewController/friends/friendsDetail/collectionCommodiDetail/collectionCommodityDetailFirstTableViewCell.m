//
//  collectionCommodityDetailFirstTableViewCell.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/8.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "collectionCommodityDetailFirstTableViewCell.h"

#define pictureNumber 3

@interface collectionCommodityDetailFirstTableViewCell ()<UIScrollViewDelegate>

@end

@implementation collectionCommodityDetailFirstTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        [self createUI];
    }
    return self;
}
-(void)createUI
{
    //滚动视图
    _imageScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(5, 10, SCREENWIDTH-5, SCREENHEIGHT*0.6*0.8)];
    _imageScrollView.delegate = self;
    _imageScrollView.contentSize = CGSizeMake((SCREENWIDTH-5)*pictureNumber, SCREENHEIGHT*0.6*0.8);
    _imageScrollView.pagingEnabled = YES;
    _imageScrollView.showsHorizontalScrollIndicator = NO;
    _imageScrollView.showsVerticalScrollIndicator = NO;
    for(int i=1;i<=pictureNumber;i++)
    {
        double W = SCREENWIDTH-10;
        double h = SCREENHEIGHT*0.6*0.8;
        double x = (i-1) * W+(i-1)*5;
        double y = 0;
        
        UIImageView *backImageView = [[UIImageView alloc]initWithFrame:CGRectMake(x, y, W, h)];
        backImageView.image = [UIImage imageNamed:@"s"];
        [_imageScrollView addSubview:backImageView];
    }
    [self.contentView addSubview:_imageScrollView];
    
    //pageControl
   _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, 0,SCREENWIDTH*0.1, SCREENHEIGHT*0.6*0.05)];
    //NSLog(@"%f",_pageControl.frame.size.width);
   // _pageControl = [[UIPageControl alloc]init];
    _pageControl.pageIndicatorTintColor = [UIColor blackColor];
   //_pageControl.backgroundColor = [UIColor orangeColor];
   _pageControl.center = CGPointMake(SCREENWIDTH*0.5-_pageControl.frame.size.width/2, SCREENHEIGHT*0.6*0.8);
    _pageControl.numberOfPages = pictureNumber;
    [_pageControl addTarget:self action:@selector(dealPageControl:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:_pageControl];
    
    _priceLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.1, SCREENHEIGHT*0.6*0.85, SCREENWIDTH*0.5, SCREENHEIGHT*0.6*0.05) Font:SCREENWIDTH*0.048 Text:@"￥200000"];
    _priceLabel.textColor = [UIColor redColor];
    //_priceLabel.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_priceLabel];
    
    _commodityNameLabel = [ZCControl createLabelWithFrame:CGRectMake(10, SCREENHEIGHT*0.6*0.9, SCREENWIDTH*0.6, SCREENHEIGHT*0.6*0.1) Font:SCREENWIDTH*0.048 Text:@"很好看的白色瘦身连衣裙子"];
    [self.contentView addSubview:_commodityNameLabel];
    
    _attentionButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.8, SCREENHEIGHT*0.6*0.85, SCREENWIDTH*0.08, SCREENHEIGHT*0.6*0.05) ImageName:@"love-@2x" Target:self Action:@selector(attentionButtonBtn:) Title:nil];
    [self.contentView addSubview:_attentionButton];
    
    
}
-(void)attentionButtonBtn:(UIButton *)button
{
    
}


-(void)dealPageControl:(UIPageControl *)pc
{
    double x = (SCREENWIDTH-5) * pc.currentPage;
    _imageScrollView.contentOffset = CGPointMake(x, 0);
    
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float index = scrollView.contentOffset.x/(SCREENWIDTH-5);
    _pageControl.currentPage = index;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
