//
//  mapViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/10/27.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "mapViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "CLLocation+Sino.h"

@interface mapViewController ()
{
    MKMapView *_mapView;
}
@end

@implementation mapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建导航栏
    [self createUINav];
    
    [self createMapView];
    
    // Do any additional setup after loading the view.
}

//创建地图
-(void)createMapView
{
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    //_mapView.delegate = self;
    //基本设置
    //设置显示当前位置
    _mapView.userTrackingMode = MKUserTrackingModeFollow;
    //是否显示当前位置
    _mapView.showsUserLocation = YES;
    //设置地图类型
    //MKMapTypeStandard = 0,
    //MKMapTypeSatellite,
    //MKMapTypeHybrid
    _mapView.mapType = MKMapTypeStandard;
    //设置显示区域
    //注意: 不设置区域默认显示美国
    // MKCoordinateRegion表示区域
    //  理解为经纬度+半径
    //    // 40.0357402456,116.3642983592
    // CLLocationCoordinate2D coordinate2D = CLLocationCoordinate2DMake( 40.0357402456, 116.3642983592);
    
    //百度地图的坐标 是在火星坐标的基础上又做一次偏移处理 （其他地图使用的是火星坐标）
    //所以需要做的就是
    CLLocation *hahaLocation = [[CLLocation alloc]initWithLatitude:self.latti.floatValue longitude:self.longti.floatValue];
    hahaLocation = [hahaLocation locationMarsFromBearPaw];
    //    hahaLocation = [hahaLocation locationMarsFromEarth];
    _mapView.region = MKCoordinateRegionMake(hahaLocation.coordinate, MKCoordinateSpanMake(0.001, 0.001));
    
    //定位
    //[self startLocation];
    
    
    [self.view addSubview:_mapView];
    
    //国内常用的地址体系3种
    //  国际地址-地球地址
    //      (google地球,CLLocationManager)
    //
    //  天朝-火星地址, 国家龟腚
    //      中国出版的所有地图经纬度都做了加密偏移
    //      高德地图,搜狗地图,苹果地图--都是火星地址
    //  百度地址体系
    //      百度定位-百度地图
    
    //  <3>添加大头针
    //      简单添加
    //    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deallongPress:)];
    //    [_mapView addGestureRecognizer:longPress];
    
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    //    annotation.title = @"点击的位置";
    //    annotation.subtitle = [NSString stringWithFormat:@"lan:%f,long:%f",hahaLocation.coordinate.latitude,hahaLocation.coordinate.longitude];
    annotation.coordinate = hahaLocation.coordinate;
    
    //地图上添加注释(大头针)
    [_mapView addAnnotation:annotation];

}


//创建导航栏
-(void)createUINav
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"地图"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    UIButton *imageLeftButton  =[ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(imageLeftItemBtn) Title:nil];
    [imageLeftButton setImage:[UIImage imageNamed:@"店铺-店铺详情_03"] forState:UIControlStateNormal];
    UIBarButtonItem *imageLeftItem = [[UIBarButtonItem alloc]initWithCustomView:imageLeftButton];
    self.navigationItem.leftBarButtonItem = imageLeftItem;
}
-(void)imageLeftItemBtn
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
