//
//  PopoverView.m
//  ArrowView
//
//  Created by guojiang on 4/9/14.
//  Copyright (c) 2014年 LINAICAI. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "PopoverView.h"
#import "PopoverTableViewCell.h"
#import "PopoverFirstTableViewCell.h"
#import "ViewController.h"


#define kArrowHeight SCREENWIDTH*0.03125
#define kArrowCurvature 2.f
#define SPACE 2.f
#define ROW_HEIGHT SCREENWIDTH*0.1375
//定制cell的高度
#define ROW_HEIGHT1 SCREENWIDTH*0.23
//定制cell的个数
#define ROW_NUMBER 2

#define TITLE_FONT [UIFont systemFontOfSize:SCREENWIDTH*0.05]
#define RGB(r, g, b)    [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1.f]

@interface PopoverView ()<UITableViewDataSource, UITableViewDelegate,YBCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) NSArray *firstTitleArray;
@property (nonatomic, strong) NSArray *secondTitleArray;
@property (nonatomic, strong) NSArray *thirdTitleArray;


@property (nonatomic) CGPoint showPoint;

@property (nonatomic, strong) UIButton *handerView;

@end

@implementation PopoverView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.borderColor = RGB(200, 199, 204);
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}


-(id)initWithPoint:(CGPoint)point titles:(NSArray *)titles images:(NSArray *)images
{
    self = [super init];
    if (self) {
        self.showPoint = point;
        self.titleArray = titles;
        self.imageArray = images;
        
        self.firstTitleArray = @[@"",@"",@"鞋",@"",@"美甲",@"",@"",@""];
        self.secondTitleArray = @[@"",@"",@"帽",@"",@"美发",@"",@"",@""];
        self.thirdTitleArray = @[@"",@"",@"箱包",@"",@"个护化妆",@"",@"",@""];
        
        self.frame = [self getViewFrame];
        
        [self addSubview:self.tableView];
        
    }
    return self;
}

-(CGRect)getViewFrame
{
    CGRect frame = CGRectZero;
    
    //设置弹出视图的高度  当弹出视图的cell需要定制的时候  在这里设置高度 否则高度会出现问题
    frame.size.height = (self.titleArray.count - ROW_NUMBER) * ROW_HEIGHT +ROW_HEIGHT1*ROW_NUMBER+ SPACE + kArrowHeight;
    
    for (NSString *title in self.titleArray) {
        CGFloat width =  [title sizeWithFont:TITLE_FONT constrainedToSize:CGSizeMake(SCREENWIDTH*0.9375, 100) lineBreakMode:NSLineBreakByCharWrapping].width;
        frame.size.width = MAX(width, frame.size.width);
    }
    
    if ([self.titleArray count] == [self.imageArray count]) {
        
        //frame.size.width = 10 + 25 + 10 + frame.size.width + 40;
        frame.size.width = SCREENWIDTH*0.265625+frame.size.width;
    }else{
        //frame.size.width = 10 + frame.size.width + 40;
        frame.size.width = SCREENWIDTH*0.15625+frame.size.width;
    }
    
    frame.origin.x = self.showPoint.x - frame.size.width/2;
    frame.origin.y = self.showPoint.y;
    
    //左间隔最小5x
    if (frame.origin.x < 5) {
        frame.origin.x = 5;
    }
    //右间隔最小5x
    if ((frame.origin.x + frame.size.width) > SCREENWIDTH*0.984375) {
        frame.origin.x = SCREENWIDTH*0.984375 - frame.size.width;
    }
    
    return frame;
}


-(void)show
{
    self.handerView = [UIButton buttonWithType:UIButtonTypeCustom];
    [_handerView setFrame:[UIScreen mainScreen].bounds];
    [_handerView setBackgroundColor:[UIColor clearColor]];
    [_handerView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_handerView addSubview:self];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [window addSubview:_handerView];
    
    CGPoint arrowPoint = [self convertPoint:self.showPoint fromView:_handerView];
    self.layer.anchorPoint = CGPointMake(arrowPoint.x / self.frame.size.width, arrowPoint.y / self.frame.size.height);
    self.frame = [self getViewFrame];
    
    self.alpha = 0.f;
    self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.08f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}

-(void)dismiss
{
    [self dismiss:YES];
}

-(void)dismiss:(BOOL)animate
{
    if (!animate) {
        [_handerView removeFromSuperview];
        return;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [_handerView removeFromSuperview];
    }];
    
}


#pragma mark - UITableView

-(UITableView *)tableView
{
    if (_tableView != nil) {
        return _tableView;
    }
    
    CGRect rect = self.frame;
    rect.origin.x = SPACE;
    rect.origin.y = kArrowHeight + SPACE;
    rect.size.width -= SPACE * 2;
    rect.size.height -= (SPACE - kArrowHeight);
    
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.alwaysBounceHorizontal = NO;
    _tableView.alwaysBounceVertical = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.scrollEnabled = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    
    
    //设置表格视图左边短15像素问题
    if([_tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if([_tableView  respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    
   
    
   return _tableView;
    
}
#pragma mark-(设置解决表格视图左边短15像素问题)
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}



#pragma mark - UITableView DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_titleArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    //定制cell
    if(indexPath.row == 2)
    {
     
        static NSString *identifier = @"cell";
        PopoverTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[PopoverTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.YBCell_delegate = self;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundView = [[UIView alloc] init];
        cell.backgroundView.backgroundColor = RGB(245, 245, 245);
        cell.iconImageView.image = [UIImage imageNamed:[_imageArray objectAtIndex:indexPath.row]];
        cell.titleLabel.text = [_titleArray objectAtIndex:indexPath.row];
        [cell.firstButton setTitle:_firstTitleArray[indexPath.row] forState:UIControlStateNormal];
        [cell.secondButton setTitle:_secondTitleArray[indexPath.row] forState:UIControlStateNormal];
        [cell.thirdButton setTitle:_thirdTitleArray[indexPath.row] forState:UIControlStateNormal];
        return cell;
        
    }
    else if (indexPath.row == 4)
    {
        static NSString *identifier = @"cell";
        PopoverTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[PopoverTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.YBCell_delegate = self;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.backgroundView = [[UIView alloc] init];
        cell.backgroundView.backgroundColor = RGB(245, 245, 245);
        
        cell.iconImageView.image = [UIImage imageNamed:[_imageArray objectAtIndex:indexPath.row]];
        cell.titleLabel.text = [_titleArray objectAtIndex:indexPath.row];
        [cell.firstButton setTitle:_firstTitleArray[indexPath.row] forState:UIControlStateNormal];
        [cell.secondButton setTitle:_secondTitleArray[indexPath.row] forState:UIControlStateNormal];
        [cell.thirdButton setTitle:_thirdTitleArray[indexPath.row] forState:UIControlStateNormal];
        
        return cell;
        
    }
    else
    {
    static NSString *identifier = @"cell";
    PopoverFirstTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[PopoverFirstTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
        //设置默认选中第一个cell
//        cell.selected = YES;
//        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
//        [_tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionTop];
//        self.selectRowAtIndex = 0;
//        if(self.selectRowAtIndex)
//        {
//            self.selectRowAtIndex(0);
//        }
        
    cell.backgroundView = [[UIView alloc] init];
    cell.backgroundView.backgroundColor = RGB(245, 245, 245);
    
//    if ([_imageArray count] == [_titleArray count]) {
//        cell.imageView.image = [UIImage imageNamed:[_imageArray objectAtIndex:indexPath.row]];
//    }
//    cell.textLabel.font = [UIFont systemFontOfSize:16];
//    cell.textLabel.text = [_titleArray objectAtIndex:indexPath.row];
        cell.iconImageView.image = [UIImage imageNamed:[_imageArray objectAtIndex:indexPath.row]];
        cell.titleLabel.text = [_titleArray objectAtIndex:indexPath.row];
        
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return cell;
    }
}
//自己制定的协议上面cell上面button点击事件
-(void)YBCellButtonDidClicked:(UIButton *)button andTitle:(NSString *)title
{
    [self dismiss:YES];
    
    [self.YBMenu_delegate YBMenUTableViewButtonBtn:title];
}


#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if(indexPath.row == 2)
    {
        
    }
    else if (indexPath.row == 4)
    {
        
    }
    else
    {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.selectRowAtIndex) {
        self.selectRowAtIndex(indexPath.row);
    }
        
        
    [self dismiss:YES];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 2)
    {
        return SCREENWIDTH*0.23;
    }
    else if (indexPath.row == 4)
    {
        return SCREENWIDTH*0.23;
    }
    else
    {
    return ROW_HEIGHT;
    }
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self.borderColor set]; //设置线条颜色
    
    CGRect frame = CGRectMake(0, 10, self.bounds.size.width, self.bounds.size.height - kArrowHeight);
    
    float xMin = CGRectGetMinX(frame);
    float yMin = CGRectGetMinY(frame);
    
    float xMax = CGRectGetMaxX(frame);
    float yMax = CGRectGetMaxY(frame);
    
    CGPoint arrowPoint = [self convertPoint:self.showPoint fromView:_handerView];
    
    UIBezierPath *popoverPath = [UIBezierPath bezierPath];
    [popoverPath moveToPoint:CGPointMake(xMin, yMin)];//左上角
    
    /********************向上的箭头**********************/
    [popoverPath addLineToPoint:CGPointMake(arrowPoint.x - kArrowHeight, yMin)];//left side
    [popoverPath addCurveToPoint:arrowPoint
                   controlPoint1:CGPointMake(arrowPoint.x - kArrowHeight + kArrowCurvature, yMin)
                   controlPoint2:arrowPoint];//actual arrow point
    
    [popoverPath addCurveToPoint:CGPointMake(arrowPoint.x + kArrowHeight, yMin)
                   controlPoint1:arrowPoint
                   controlPoint2:CGPointMake(arrowPoint.x + kArrowHeight - kArrowCurvature, yMin)];//right side
    /********************向上的箭头**********************/
    
    
    [popoverPath addLineToPoint:CGPointMake(xMax, yMin)];//右上角
    
    [popoverPath addLineToPoint:CGPointMake(xMax, yMax)];//右下角
    
    [popoverPath addLineToPoint:CGPointMake(xMin, yMax)];//左下角
    
    //填充颜色
    [RGB(245, 245, 245) setFill];
    [popoverPath fill];
    
    [popoverPath closePath];
    [popoverPath stroke];
}


@end
