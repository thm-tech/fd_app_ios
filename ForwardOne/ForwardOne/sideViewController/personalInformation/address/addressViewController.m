//
//  addressViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/4.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "addressViewController.h"
#import "addAddressViewController.h"
#import "addressTableViewCell.h"


//增删改查用户的地址信息
#define USERADRESSINFORMATION @"http://%@/user/address"

//设置用户默认地址
#define USERDEFAULTADDRESS @"http://%@/user/address/default"

@interface addressViewController ()<UITableViewDelegate,UITableViewDataSource,YBSettingAdressDelegate>
{
    UITableView *_tableView;
    
   //地址信息的数组
    NSMutableArray *_addressArray;
}
@end

@implementation addressViewController

//当视图即将出现的时候 调用经过增删改查之后地址信息的数据
-(void)viewWillAppear:(BOOL)animated
{
    [self downLoadAdressData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUINav];
    
    [self createTabelView];
    
    //数据源数组  改变数据源数组里面的数组的元素 来动态显示tableView里面的组数
   // [self downLoadAdressData];
    
    
    // Do any additional setup after loading the view.
}
-(void)downLoadAdressData
{
    _addressArray = [[NSMutableArray alloc]init];
    NSString *adressStringUrl = [NSString stringWithFormat:USERADRESSINFORMATION,DomainName];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:adressStringUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *addressDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"地址信息字典%@",addressDict);
        NSString *addressErrString  =addressDict[@"err"];
        if(addressErrString.intValue == 0)
        {
            NSArray *array = addressDict[@"addressList"];
            for(NSDictionary *addressDetailDict in array)
            {
                [_addressArray addObject:addressDetailDict];
            }
            //数据下载之后 tableView重新加载数据
            [_tableView reloadData];
        }
        else
        {
            UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"获取地址信息失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [al show];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"获取地址信息失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
    }];
    
    
}


-(void)createTabelView
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT-64) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
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
#pragma mark-(tableView代理)
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _addressArray.count;
   
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    addressTableViewCell *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
    if(cell == nil)
    {
        cell = [[addressTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
     
    }
    cell.YB_SettingButtonDelegate = self;
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dict = _addressArray[indexPath.row];
    cell.nameLabel.text = dict[@"name"];
    cell.phoneLabel.text = dict[@"phone"];
    cell.addressLabel.text = dict[@"address"];
    NSString *defaultString = [NSString stringWithFormat:@"%@",dict[@"default"]];
    
    if([defaultString isEqualToString:@"0"])
    {
        [cell.settingButton setTitle:@"设为默认" forState:UIControlStateNormal];
        [cell.settingButton setTitleColor:[UIColor colorWithHexStr:@"#666666"] forState:UIControlStateNormal];
    }
   else
   {
       [cell.settingButton setTitle:@"默认地址" forState:UIControlStateNormal];
       [cell.settingButton setTitleColor:[UIColor colorWithHexStr:@"#48d58b"] forState:UIControlStateNormal];
   }
    return cell;
}

//设置各种高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREENHEIGHT*0.15;
}
//cell上面的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)createUINav
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"收货地址"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    //导航栏右按钮
    UIButton *rightButton = [ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(rightItemBtn) Title:nil];
    [rightButton setImage:[UIImage  imageNamed:@"添加_location"] forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //导航栏左按钮
    UIButton *imageLeftButton  =[ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(imageLeftItemBtn) Title:nil];
    [imageLeftButton setImage:[UIImage imageNamed:@"店铺-店铺详情_03"] forState:UIControlStateNormal];
    UIBarButtonItem *imageLeftItem = [[UIBarButtonItem alloc]initWithCustomView:imageLeftButton];
    self.navigationItem.leftBarButtonItem = imageLeftItem;
    
    
}
-(void)imageLeftItemBtn
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightItemBtn
{
    addAddressViewController *aavc = [[addAddressViewController alloc]init];
    [self.navigationController pushViewController:aavc animated:YES];
}

//设置默认地址的协议代理方法
-(void)YBSettingButtonDidClick:(UIButton *)button
{
    //得到点击（默认地址）按钮的所在行
    addressTableViewCell * cell = (addressTableViewCell *) button.superview.superview;
    NSIndexPath * path = [_tableView indexPathForCell:cell];
    
    //下载过来的地址信息的字典
    NSDictionary *addressDict = _addressArray[path.row];
    NSLog(@"点击哪一个Button%ld",path.row);
    
    NSString *urlString = [NSString stringWithFormat:USERDEFAULTADDRESS,DomainName];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:urlString parameters:@{@"addrID":addressDict[@"addrID"]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //对结果进行解析
        NSDictionary *errDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"设置地址的结果字典%@",errDict);
        NSString *errString = errDict[@"err"];
        if(errString.intValue == 0)
        {
            //当设置默认地址成功之后  tableView reloadData  让设置的默认地址显示为默认地址 其他显示为非默认地址
            [self downLoadAdressData];
            
            [self.YB_locationDelegate YBMyLocationAddressButtonDidClick:addressDict[@"address"]];
        }
        else
        {
            UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"设置失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [al show];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"设置失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
    }];

    
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
