//
//  TMQuiltView
//
//  Created by Bruno Virlet on 7/20/12.
//
//  Copyright (c) 2012 1000memories

//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR 
//  OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
//  DEALINGS IN THE SOFTWARE.
//


#import "TMPhotoQuiltViewCell.h"

const CGFloat kTMPhotoQuiltViewMargin = 1;

@implementation TMPhotoQuiltViewCell

@synthesize photoView = _photoView;
@synthesize nameLabel = _nameLabel;
@synthesize distanceLabel = _distanceLabel;
@synthesize attentionImageView = _attentionImageView;
@synthesize attentionLabel = _attentionLabel;
@synthesize onLinePeopleImageView = _onLinePeopleImageView;
@synthesize onLinePeopelLabel = _onLinePeopelLabel;

- (void)dealloc {
    [_photoView release], _photoView = nil;
    [_nameLabel release], _nameLabel = nil;
    [_distanceLabel release],_distanceLabel = nil;
    [_attentionImageView release],_attentionImageView = nil;
    [_attentionLabel release],_attentionLabel = nil;
    [_onLinePeopleImageView release],_onLinePeopleImageView = nil;
    [_onLinePeopelLabel release],_onLinePeopelLabel = nil;
    
    [super dealloc];
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
       // self.backgroundColor = [UIColor redColor];
    }
    return self;
}
//商店图片
- (UIImageView *)photoView {
    if (!_photoView) {
        _photoView = [[UIImageView alloc] init];
       // _photoView.contentMode = UIViewContentModeScaleAspectFill;
       // _photoView.clipsToBounds = YES;
        [self addSubview:_photoView];
    }
    return _photoView;
}
//店名
-(UILabel *)nameLabel
{
    if(!_nameLabel)
    {
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.font = [UIFont systemFontOfSize:SCREENWIDTH*0.04];
        _nameLabel.adjustsFontSizeToFitWidth = YES;
        //_nameLabel.backgroundColor = [UIColor orangeColor];
        [self addSubview:_nameLabel];
    }
    return _nameLabel;
}
//距离
-(UILabel *)distanceLabel
{
    if(!_distanceLabel)
    {
        _distanceLabel = [[UILabel alloc]init];
         _distanceLabel.font = [UIFont systemFontOfSize:SCREENWIDTH*0.04];
        _distanceLabel.adjustsFontSizeToFitWidth = YES;
        //_distanceLabel.textAlignment = NSTextAlignmentRight;
        //_distanceLabel.backgroundColor = [UIColor orangeColor];
        [self addSubview:_distanceLabel];
    }
    return _distanceLabel;
        
}
//关注的imageView
-(UIImageView *)attentionImageView
{
    if(!_attentionImageView)
    {
        _attentionImageView = [[UIImageView alloc]init];
        _attentionImageView.image = [UIImage imageNamed:@"收藏"];
        //_attentionImageView.backgroundColor = [UIColor orangeColor];
        [self addSubview:_attentionImageView];
    }
    return _attentionImageView;
}
//关注人数
-(UILabel *)attentionLabel
{
    if(!_attentionLabel)
    {
        _attentionLabel = [[UILabel alloc]init];
         _attentionLabel.font = [UIFont systemFontOfSize:SCREENWIDTH*0.03];
        _attentionLabel.adjustsFontSizeToFitWidth = YES;
        //_attentionLabel.backgroundColor = [UIColor orangeColor];
        [self addSubview:_attentionLabel];
    }
    return _attentionLabel;
}
//在线人数view
-(UIImageView *)onLinePeopleImageView
{
    if(!_onLinePeopleImageView)
    {
        _onLinePeopleImageView = [[UIImageView alloc]init];
        _onLinePeopleImageView.image = [UIImage imageNamed:@"人数"];
        //_onLinePeopleImageView.backgroundColor = [UIColor orangeColor];
        [self addSubview:_onLinePeopleImageView];
    }
    return _onLinePeopleImageView;
}
//关注人数label
-(UILabel *)onLinePeopelLabel
{
    if(!_onLinePeopelLabel)
    {
        _onLinePeopelLabel = [[UILabel alloc]init];
         _onLinePeopelLabel.font = [UIFont systemFontOfSize:SCREENWIDTH*0.03];
        _onLinePeopelLabel.adjustsFontSizeToFitWidth = YES;
        //_onLinePeopelLabel.backgroundColor = [UIColor orangeColor];
        [self addSubview:_onLinePeopelLabel];
    }
    return _onLinePeopelLabel;
}

- (void)layoutSubviews {
    
    //瀑布流里面每个流内容控件的UI坐标
    //self.photoView.frame = CGRectInset(self.bounds, kTMPhotoQuiltViewMargin, kTMPhotoQuiltViewMargin);
    //    self.titleLabel.frame = CGRectMake(kTMPhotoQuiltViewMargin, self.bounds.size.height - 20 - kTMPhotoQuiltViewMargin,
    //                                       self.bounds.size.width - 2 * kTMPhotoQuiltViewMargin, 20);
    
    
    self.photoView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height-40);
    
    self.nameLabel.frame = CGRectMake(0, self.bounds.size.height-40+2,self.bounds.size.width*0.7, 15);
    
    self.distanceLabel.frame = CGRectMake(self.bounds.size.width*0.7, self.bounds.size.height-40+2, self.bounds.size.width*0.3, 15);

    self.attentionImageView.frame = CGRectMake(10, self.bounds.size.height-40+25, self.bounds.size.width*0.1, 15);
    
    self.attentionLabel.frame = CGRectMake(self.bounds.size.width*0.1+20, self.bounds.size.height-40+25, self.bounds.size.width*0.3, 15);
    
    self.onLinePeopleImageView.frame = CGRectMake(self.bounds.size.width*0.55, self.bounds.size.height-40+25, self.bounds.size.width*0.1, 15);
    
    self.onLinePeopelLabel.frame = CGRectMake(self.bounds.size.width*0.7, self.bounds.size.height-40+25, self.bounds.size.width*0.3, 15);
}

@end
