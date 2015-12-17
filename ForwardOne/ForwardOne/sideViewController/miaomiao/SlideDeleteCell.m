//
//  SlideDeleteCell.m
//  RHSlideDeleteTableViewCell
//
//  Created by london on 14-2-21.
//  Copyright (c) 2014年 Robin_Huang. All rights reserved.
//

#import "SlideDeleteCell.h"

#define kRotationRadian  90.0/360.0
#define kVelocity        100

@interface SlideDeleteCell()

@property(assign, nonatomic) CGPoint currentPoint;
@property(assign, nonatomic) CGPoint previousPoint;
@property(strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property(assign, nonatomic) float offsetRate;

@end

@implementation SlideDeleteCell
@synthesize delegate;

#pragma mark - Initialization -

- (id)init
{
    if (self = [super init])
	{
        [self addPanGestureRecognizer];
    }
	
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
	{
        [self addPanGestureRecognizer];
    }
	
    return self;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self addPanGestureRecognizer];
        [self createUI];
    }
    return self;
}
-(void)createUI
{
    _iconImageView = [ZCControl createImageViewWithFrame:CGRectMake(10, SCREENHEIGHT*0.15*0.1, SCREENHEIGHT*0.15*0.8, SCREENHEIGHT*0.15*0.8) ImageName:@""];
    _iconImageView.layer.cornerRadius = SCREENHEIGHT*0.15*0.8/2;
    _iconImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:_iconImageView];
    
    _nameLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.28, SCREENHEIGHT*0.15*0.1, SCREENWIDTH*0.6, SCREENHEIGHT*0.15*0.3) Font:SCREENWIDTH*0.048 Text:nil];
   // _nameLabel.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_nameLabel];
    
    _messageLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.28, SCREENHEIGHT*0.15*0.4, SCREENWIDTH*0.65, SCREENHEIGHT*0.15*0.5) Font:SCREENWIDTH*0.0426 Text:nil];
    _messageLabel.textColor = [UIColor grayColor];
    //_messageLabel.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:_messageLabel];
    
    _pointImageView = [ZCControl createImageViewWithFrame:CGRectMake(SCREENWIDTH*0.9, SCREENHEIGHT*0.15*0.1, SCREENHEIGHT*0.15*0.1, SCREENHEIGHT*0.15*0.1) ImageName:nil];
    _pointImageView.backgroundColor = [UIColor colorWithHexStr:@"FF3030"];
    _pointImageView.layer.cornerRadius = SCREENHEIGHT*0.15*0.1/2;
    _pointImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:_pointImageView];
    
    _refuseButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.65, SCREENHEIGHT*0.15*0.3, SCREENWIDTH*0.15, SCREENHEIGHT*0.15*0.4) ImageName:@"不同意BG" Target:self Action:@selector(buttonDidClick:) Title:@"拒绝"];
    _refuseButton.tag = 501;
    //_refuseButton.backgroundColor = [UIColor colorWithHexStr:@"#666666"];
    //[_refuseButton setImage:[UIImage imageNamed:@"不同意BG"] forState:UIControlStateNormal];
    [self.contentView addSubview:_refuseButton];
    
    _receiveButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.82, SCREENHEIGHT*0.15*0.3, SCREENWIDTH*0.15, SCREENHEIGHT*0.15*0.4) ImageName:@"同意bg" Target:self Action:@selector(buttonDidClick:) Title:@"同意"];
    _receiveButton.tag = 502;
    //[_receiveButton setImage:[UIImage imageNamed:@"同意bg"] forState:UIControlStateNormal];
    //_receiveButton.backgroundColor = [UIColor colorWithHexStr:@"#48d58b"];
    [self.contentView addSubview:_receiveButton];
    
}

-(void)buttonDidClick:(UIButton *)button
{
    [self.YB_cellDelegate YBMiaoMiaoCellButtonDidClick:button];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
	{
		[self addPanGestureRecognizer];
	}
	
	return self;
}

-(void)addPanGestureRecognizer{
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(slideToDeleteCell:)];
    _panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_panGestureRecognizer];
    
}

#pragma mark UIGestureRecognizerDelegate------------------------------------------------
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer{
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint velocityPoint = [gestureRecognizer velocityInView:self];
        if (fabsf(velocityPoint.x) > kVelocity) {
            return YES;
        }else
            return NO;
    }else
        return NO;
    
}

-(void)slideToDeleteCell:(UIPanGestureRecognizer *)panGestureRecognizer{
    
    _previousPoint = [panGestureRecognizer locationInView:self.superview];
    
    static CGPoint originalCenter;
    UIGestureRecognizerState state = panGestureRecognizer.state;
    if (state == UIGestureRecognizerStateBegan) {
        
        originalCenter = self.center;
        [self.superview bringSubviewToFront:self];
    }else if (state == UIGestureRecognizerStateChanged){
        CGPoint diff = CGPointMake(_previousPoint.x - _currentPoint.x, _previousPoint.y - _currentPoint.y);
        [self handleOffset:diff];
    }else if (state == UIGestureRecognizerStateEnded){
        if (_offsetRate < 0.5) {
            [UIView animateWithDuration:0.2 animations:^{
                
                self.transform = CGAffineTransformIdentity;
                self.center = originalCenter;
                self.alpha = 1.0;
                
            }];
        }else{
            [UIView animateWithDuration:0.2 animations:^{
                self.center = CGPointMake(self.center.x * 2, self.center.y);
                self.alpha = 0.0;
                
            } completion:^(BOOL finsh){
                if ([delegate respondsToSelector:@selector(slideToDeleteCell:)]) {
                    [delegate slideToDeleteCell:self];
                }
                
                
            }];
        }
    }
    _currentPoint = _previousPoint;
    
}

-(void)handleOffset:(CGPoint)offset{
    
    self.center = CGPointMake(self.center.x + offset.x, self.center.y);
    float distance = self.frame.size.width/2 - self.center.x;
    float distanceAbs = fabsf(distance);
    float distanceRate = (self.frame.size.width - distanceAbs) / self.frame.size.width;
    self.alpha = distanceRate;
    
    _offsetRate = 1 -distanceRate;
    
    if (distance >= 0) {
        self.transform = CGAffineTransformMakeRotation(-_offsetRate * kRotationRadian);
    }else
        self.transform = CGAffineTransformMakeRotation(_offsetRate * kRotationRadian);
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
}

@end
