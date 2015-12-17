//
//  collectionCommodityDetailViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/8.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "collectionCommodityDetailViewController.h"
#import "collectionCommodityDetailFirstTableViewCell.h"
#import "collectionCommodityDetailSecondTableViewCell.h"
#import "collectionCommodityDetailThirdTableViewCell.h"
#import "collectionCommodityDetailForthTableViewCell.h"
#import "collectionCommodityDetailFiveTableViewCell.h"
#import "collectionCommodityDetailSixTableViewCell.h"
#import "collectionCommodityDetailSevenTableViewCell.h"

#import "inShopActivityModel.h"
#import "goodsStyleInformationModel.h"
#import "collectionDataBaseModel.h"

//数据库
#import "myAppDataBase.h"

//商品详情
#define COMMODITYDETAILURL @"http://%@/user/goods/info?gid=%d&barcode=xd124784"

//客户试穿
#define CUSTOMERPICTUREURL @"http://%@/user/goods/fit?gid=%d&offset=%d&count=%d"

//下载数据库中收藏商品的信息
#define COMMODITYDATABASEURL @"http://%@/user/favorite/info?gid=%d"

//收藏和取消收藏商品
#define COLLECTIONURL @"http://%@/user/goods/concern?gid=%d"

@interface collectionCommodityDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UIActionSheetDelegate>
{
    UITableView *_tableView;
    NSDictionary *_commodityDetailDict;
    NSMutableArray *_goodsStyleInformationDataArray;
    
     NSMutableArray *_customerPictureArray;
    int customerPictureOffect;
    int customerPictureCount;
    
    //数据库中下载数据的数组
    NSMutableArray *_dataBaseArray;
    
    //数据库中的单例类
    myAppDataBase *dc;
    
}

@property (nonatomic,strong) UIScrollView *imageScrollView;
@property (nonatomic,strong) UILabel *priceLabel;
@property (nonatomic,strong) UILabel *commodityNameLabel;
@property (nonatomic,strong) UIButton *attentionButton;
@property (nonatomic,strong) UIPageControl *pageControl;

@end

@implementation collectionCommodityDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //收藏中数据库
    dc = [myAppDataBase sharedInstance];
    
    [self createUINav];
    
    [self createTableView];
    
    //下载商品详情的数据
    [self downLoadCommodityData];
    
    //下载客户试穿的图片的数据
    [self downLOadCuntomerPictureData];
    
    //下载数据库中商品信息数据
    //[self downLoadCommodityDataBaseData];
    
    
    // Do any additional setup after loading the view.
}
#pragma mark-(下载数据库中商店的信息数据)
-(void)downLoadCommodityDataBaseData
{
    _dataBaseArray = [[NSMutableArray alloc]init];
    
    NSString *urlString = [NSString stringWithFormat:COMMODITYDATABASEURL,DomainName,self.goodsIDString.intValue];
    NSLog(@"数据库%@",urlString);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
            NSArray *array = dict[@"goodsList"];
            NSDictionary *goodDict = array[0];
        
            collectionDataBaseModel *model = [[collectionDataBaseModel alloc]init];
            [model setValuesForKeysWithDictionary:goodDict];
            [_dataBaseArray addObject:model];
            
            //刷新
            [_tableView reloadData];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}



#pragma mark-(客户试穿的图片的数据)
-(void)downLOadCuntomerPictureData
{
    _customerPictureArray = [[NSMutableArray alloc]init];
    customerPictureOffect = 0;
    customerPictureCount = 20;
    
    NSString *urlString = [NSString stringWithFormat:CUSTOMERPICTUREURL,DomainName,self.goodsIDString.intValue,customerPictureOffect,customerPictureCount];
    NSLog(@"客户试穿%@",urlString);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlString parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
             NSString *errString = dict[@"err"];
             if(errString.intValue == 0)
             {
                 _customerPictureArray = dict[@"picList"];
             }
             
             [_tableView reloadData];
             
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"error = %@",error);
         }];
    
    
}

#pragma mark-（商品详情的数据）
-(void)downLoadCommodityData
{
    
    _goodsStyleInformationDataArray = [[NSMutableArray alloc]init];
    
    NSString *urlString = [NSString stringWithFormat:COMMODITYDETAILURL,DomainName,self.goodsIDString.intValue];
    NSLog(@"***********************%@",urlString);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        //NSLog(@"商品详情信息字典%@",dict);
        
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
            NSDictionary *goodsDict = dict[@"info"];
           
            _commodityDetailDict = [[NSDictionary alloc]init];
            _commodityDetailDict = goodsDict;
            
            //解析商品的款式参数
            NSString *goodsStyleInformationString = goodsDict[@"basic"];
            NSData *goodsStyleInformationData = [goodsStyleInformationString dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *goodsStyleInformationArray = [NSJSONSerialization JSONObjectWithData:goodsStyleInformationData options:NSJSONReadingMutableContainers error:nil];
            for(NSDictionary *goodsStyleInformationDict2 in goodsStyleInformationArray)
            {
                goodsStyleInformationModel *model = [[goodsStyleInformationModel alloc]init];
                [model setValuesForKeysWithDictionary:goodsStyleInformationDict2];
                
                [_goodsStyleInformationDataArray addObject:model];
            }
        
            [_tableView reloadData];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"err = %@",error);
    }];
    
}

-(void)createTableView
{
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, SCREENHEIGHT-64) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
     _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //设置表格视图左边短15像素问题
    if([_tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if([_tableView  respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    
    [self.view addSubview:_tableView];
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
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        if(_goodsStyleInformationDataArray.count == 0)
        {
            return 0;
        }
        else
        {
            return _goodsStyleInformationDataArray.count+1;
        }
    }
    else
    {
        if(_customerPictureArray.count == 0)
        {
            return 0;
        }
        else
        {
            return _customerPictureArray.count+1;
        }
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
        static NSString *cellID = @"cell";
        UITableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        }
        //config cell
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"基本信息";
            cell.textLabel.textColor = [UIColor colorWithHexStr:@"#333333"];
        return cell;
        }
        else
        {
            static NSString *cellID = @"cell";
            UITableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
            if(cell == nil)
            {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
            }
            //config cell
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            goodsStyleInformationModel *model = _goodsStyleInformationDataArray[indexPath.row-1];
            cell.textLabel.text = [NSString stringWithFormat:@"%@：  %@",model.paramsName,model.paramsValue];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.textLabel.textColor = [UIColor colorWithHexStr:@"#666666"];
            return cell;
        }

    }
    else
    {
        if(indexPath.row == 0)
        {
            static NSString *cellID = @"cell";
            UITableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
            if(cell == nil)
            {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
            }
            //config cell
            cell.textLabel.text = @"客户秀";
            cell.textLabel.textColor = [UIColor colorWithHexStr:@"#333333"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else
        {
            static NSString *cellID = @"cell";
            collectionCommodityDetailThirdTableViewCell  *cell  =[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
            if(cell == nil)
            {
                cell = [[collectionCommodityDetailThirdTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
            }
            //config cell
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            NSNumber *widthNumber = [[NSNumber alloc]initWithLong:(long)(SCREENWIDTH-20)];
            NSNumber *heightNumber = [[NSNumber alloc]initWithLong:(long)(SCREENHEIGHT*0.4*0.9)];
            [cell.iconImageView1 sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@@%@w_%@h_1e_0l_1c",_customerPictureArray[indexPath.row-1],widthNumber,heightNumber]]];
            return cell;
        }
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return SCREENHEIGHT*0.6+20;
    }
    else
    {
    return 0.1f;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == 1)
    {
        return 0.1f;
    }
    else
    {
        return 20;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   if (indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
        return SCREENHEIGHT*0.06;
        }
        else
        {
            return SCREENHEIGHT*0.14;
        }
        
    }
    else
    {
        if(indexPath.row == 0)
        {
            return SCREENHEIGHT*0.06;
        }
        else
        {
            return SCREENHEIGHT*0.4;
        }
    }
}
//tableView的头部视图
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        
    UIView *backgroundView = [[UIView alloc]init];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT*0.6)];
    view.backgroundColor = [UIColor whiteColor];
    [backgroundView addSubview:view];
       
        NSArray *imageArray = _commodityDetailDict[@"picList"];
        
        //滚动视图
        _imageScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(5, 10, SCREENWIDTH-5, SCREENHEIGHT*0.6*0.8)];
        _imageScrollView.delegate = self;
        _imageScrollView.contentSize = CGSizeMake((SCREENWIDTH-5)*imageArray.count, SCREENHEIGHT*0.6*0.8);
        _imageScrollView.pagingEnabled = YES;
        _imageScrollView.showsHorizontalScrollIndicator = NO;
        _imageScrollView.showsVerticalScrollIndicator = NO;
        
        for(int i=1;i<=imageArray.count;i++)
        {
            double W = SCREENWIDTH-10;
            double h = SCREENHEIGHT*0.6*0.8;
            double x = (i-1) * W+(i-1)*5;
            double y = 0;
            
            UIImageView *backImageView = [[UIImageView alloc]initWithFrame:CGRectMake(x, y, W, h)];
            //backImageView.image = [UIImage imageNamed:@"s"];
            NSNumber *widthNumber = [[NSNumber alloc]initWithLong:(long)(SCREENWIDTH-10)];
            NSNumber *heightNumber = [[NSNumber alloc]initWithLong:(long)(SCREENHEIGHT*0.6*0.8)];
            
            
            [backImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@@%@w_%@h_1e_0l_1c",imageArray[i-1],widthNumber,heightNumber]]];
            [_imageScrollView addSubview:backImageView];
        }
        [view addSubview:_imageScrollView];
        
        
        //pageControl
        _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, 0,SCREENWIDTH*0.1, SCREENHEIGHT*0.6*0.05)];
        //NSLog(@"%f",_pageControl.frame.size.width);
        // _pageControl = [[UIPageControl alloc]init];
        _pageControl.pageIndicatorTintColor = [UIColor colorWithHexStr:@"#666666"];
        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithHexStr:@"#48d58b"];
        //_pageControl.backgroundColor = [UIColor orangeColor];
        _pageControl.center = CGPointMake(SCREENWIDTH*0.5, SCREENHEIGHT*0.6*0.8);
        if(imageArray.count == 1)
        {
            _pageControl.numberOfPages = 0;
        }
        else
        {
        _pageControl.numberOfPages = imageArray.count;
        }
        [_pageControl addTarget:self action:@selector(dealPageControl:) forControlEvents:UIControlEventValueChanged];
        [view addSubview:_pageControl];
        
        _priceLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.1, SCREENHEIGHT*0.6*0.85, SCREENWIDTH*0.5, SCREENHEIGHT*0.6*0.05) Font:SCREENWIDTH*0.048 Text:@""];
        
        NSString *priceLabelNullString = [NSString stringWithFormat:@"%@",_commodityDetailDict[@"price"]];
        if(![priceLabelNullString isEqualToString:@"<null>"])
        {
        _priceLabel.text = [NSString stringWithFormat:@"￥ %@",_commodityDetailDict[@"price"]];
        }
        _priceLabel.textColor = [UIColor colorWithHexStr:@"#ff0000"];
        //_priceLabel.backgroundColor = [UIColor orangeColor];
        [view addSubview:_priceLabel];
        
        _commodityNameLabel = [ZCControl createLabelWithFrame:CGRectMake(10, SCREENHEIGHT*0.6*0.9, SCREENWIDTH*0.6, SCREENHEIGHT*0.6*0.1) Font:SCREENWIDTH*0.048 Text:@""];
        _commodityNameLabel.text = _commodityDetailDict[@"desp"];
        _commodityNameLabel.textColor = [UIColor colorWithHexStr:@"#333333"];
        [view addSubview:_commodityNameLabel];
        
        UILabel *collectionLabel = [ZCControl createLabelWithFrame:CGRectMake(SCREENWIDTH*0.85, SCREENHEIGHT*0.6*0.9, SCREENWIDTH*0.1, SCREENHEIGHT*0.6*0.1) Font:SCREENWIDTH*0.0426 Text:@"收藏"];
        collectionLabel.textColor = [UIColor colorWithHexStr:@"#666666"];
        collectionLabel.textAlignment = NSTextAlignmentCenter;
        //collectionLabel.backgroundColor = [UIColor orangeColor];
        [view addSubview:collectionLabel];
        
        _attentionButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.7, SCREENHEIGHT*0.6*0.9, SCREENWIDTH*0.25, SCREENHEIGHT*0.6*0.1) ImageName:@"" Target:self Action:@selector(attentionButtonBtn:) Title:nil];
        //[_attentionButton setBackgroundColor:[UIColor orangeColor]];
        //设置关注按钮的图片
        collectionDataBaseModel *model = [[collectionDataBaseModel alloc]init];
        NSNumber *gidNumber = [[NSNumber alloc]initWithInt:self.goodsIDString.intValue];
        [model setValue:gidNumber forKey:@"gid"];
        if([dc isExistCollectionRecordWithDicitionary:model recordType:RecoredTypeAttention] == YES)
        {
            [_attentionButton setImage:[UIImage imageNamed:@"收藏_goods"] forState:UIControlStateNormal];
          
        }
        else
        {
            [_attentionButton setImage:[UIImage imageNamed:@"店铺-商品_03"] forState:UIControlStateNormal];
            
        }
        
        [view addSubview:_attentionButton];

    return backgroundView;
    }
    else
    {
        return nil;
    }
}

//关注收藏品的按钮的点击
-(void)attentionButtonBtn:(UIButton *)button
{
    //与后台通讯
    NSString *urlString =[NSString stringWithFormat:COLLECTIONURL,DomainName,self.goodsIDString.intValue];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    
    collectionDataBaseModel *model = [[collectionDataBaseModel alloc]init];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    NSNumber *gidNumber = [[NSNumber alloc]initWithInt:self.goodsIDString.intValue];
    NSArray *picArray = _commodityDetailDict[@"picList"];
    NSString *sidString = [NSString stringWithFormat:@"%@",self.shopIDString];
    NSString *priceString = [NSString stringWithFormat:@"%@",_commodityDetailDict[@"price"]];
    NSString *promotString = [NSString stringWithFormat:@"%@",_commodityDetailDict[@"promot"]];
    
    [dict setObject:gidNumber forKey:@"gid"];
    [dict setObject:sidString forKey:@"sid"];
    [dict setObject:_commodityDetailDict[@"desp"] forKey:@"desp"];
    [dict setObject:priceString forKey:@"price"];
    [dict setObject:promotString forKey:@"promot"];
    [dict setObject:picArray[0] forKey:@"pic"];
    NSLog(@"增加收藏的字典%@",dict);
    
    [model setValuesForKeysWithDictionary:dict];
    
    if([dc isExistCollectionRecordWithDicitionary:model recordType:RecoredTypeAttention] == NO)
    {
        //不存在 增加收藏
        [manager POST:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSString *errString = dict[@"err"];
            if(errString.intValue == 0)
            {
                [button setImage:[UIImage imageNamed:@"收藏_goods"] forState:UIControlStateNormal];
                [dc addCollectionRecordWithDicitionary:model recordType:RecoredTypeAttention];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
    else
    {
        //存在 删除收藏
        [manager DELETE:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSString *errString = dict[@"err"];
            if(errString.intValue == 0)
            {
                [button setImage:[UIImage imageNamed:@"店铺-商品_03"] forState:UIControlStateNormal];
                [dc deleteCollectionRecordWithDicitionary:model recordType:RecoredTypeAttention];
            }

            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
        
    }
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



-(void)createUINav
{
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"商品详情"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *imageLeftButton  =[ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(leftBtn:) Title:nil];
    [imageLeftButton setImage:[UIImage imageNamed:@"店铺-店铺详情_03"] forState:UIControlStateNormal];
    UIBarButtonItem *imageLeftItem = [[UIBarButtonItem alloc]initWithCustomView:imageLeftButton];
    self.navigationItem.leftBarButtonItem = imageLeftItem;
    
    //UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"分享"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBtn:)];
//    UIButton *rightButton = [ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(rightBtn:) Title:nil];
//    [rightButton setImage:[UIImage imageNamed:@"分享"] forState:UIControlStateNormal];
//    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
//    self.navigationItem.rightBarButtonItem = right;

}
-(void)rightBtn:(UIButton *)button
{
    //商品分享
    UIActionSheet *sharedSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"微信",@"新浪微博",@"QQ好友",@"朋友圈",@"短信消息", nil];
    [sharedSheet showInView:self.view];
}

-(void)leftBtn:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
