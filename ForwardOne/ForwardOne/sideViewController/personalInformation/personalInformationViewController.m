//
//  personalInformationViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/4/27.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "personalInformationViewController.h"
#import "SidebarViewController.h"

#import "bindPhoneViewController.h"
#import "modityBindPhoneViewController.h"
#import "twoDimensionalCodeViewController.h"

#import "QRCodeGenerator.h"
#import "HZAreaPickerView.h"
#import "addressViewController.h"
#import "ASIFormDataRequest.h"

#import "myAppDataBase.h"


//个人信息的URL
#define PERSONALINFORMATION @"http://%@/user/personal"




@interface personalInformationViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,HZAreaPickerDelegate,UIGestureRecognizerDelegate,ASIHTTPRequestDelegate,YBMyLocationAddressDelegate>
{
    UITableView *_tableView;
    
    //标题数据源
    NSArray *_titleArray;
    
    //修改BOOL的值  检查是否已经更新
    BOOL isUpDate;
   
   //头像
   UIImageView *photoImageView;
    
}

@property (nonatomic,strong) NSDictionary *dic;

//保存个人信息的属性
@property (nonatomic,strong) NSData *photoData;
@property (nonatomic,strong) NSString *photoUrlString;
@property (nonatomic,strong) NSString *nickName;
@property (nonatomic,strong) NSString *sexName;
@property (nonatomic,strong) NSString *miaomiaoNumber;
@property (nonatomic,strong) NSString *phoneNumber;
@property (nonatomic,strong) NSString *cityName;
@property (nonatomic,strong) NSString *qCode;
@property (nonatomic,strong) NSString *locatation;


//userName用于生成二维码
@property (nonatomic,strong) NSString *userName;

//城市选择器
@property (strong, nonatomic) HZAreaPickerView *locatePicker;


@end

@implementation personalInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
//   __weak typeof(self) weakSelf = self;
//   if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
//   {
//      self.navigationController.interactivePopGestureRecognizer.delegate = weakSelf;
//   }
   
    //创建导航栏控件
    [self createUINav];
    
    //创建tableView
    [self createTableView];
    
    //创建本地固定不变数据
    [self createLoaclData];
    
    //下载网络数据
   //[self loadNetData];
   //[self createData];
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
   [self loadNetData];
}


#pragma mark-(下载网络数据)
-(void)loadNetData
{
   //先从后台去下载个人信息的相关的数据  退出个人信息界面的时候 将self.dict里面字典的属性对应各个值进行上传
   NSString *getPersonalInformationString = [NSString stringWithFormat:PERSONALINFORMATION,DomainName];
   NSLog(@"个人信息%@",getPersonalInformationString);
   AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
   manager.responseSerializer = [AFHTTPResponseSerializer serializer];
   [manager GET:getPersonalInformationString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
      
      NSDictionary *informationDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
      
      NSString *informationErrString = informationDict[@"err"];
      if(informationErrString.intValue == 0)
      {
         NSDictionary *informationDetailDict = informationDict[@"info"];
         NSLog(@"个人信息字典%@",informationDetailDict);
         //得到个人信息的字典之后 赋值
         self.nickName = informationDetailDict[@"name"];
         //图像的URL 利用AF去获取图像的图片
         self.photoUrlString = informationDetailDict[@"portrait"];
//          photoImageView = [ZCControl createImageViewWithFrame:CGRectMake(WIDTH*0.82, HEIGHT*0.1*0.1, WIDTH*0.14, HEIGHT*0.1*0.8) ImageName:nil];
//         [photoImageView sd_setImageWithURL:[NSURL URLWithString:self.photoUrlString]];
//         self.photoData = UIImageJPEGRepresentation(photoImageView.image, 0.1);
         
         self.sexName = [NSString stringWithFormat:@"%@",informationDetailDict[@"gender"]];
         self.cityName = [NSString stringWithFormat:@"%@",informationDetailDict[@"city"]];
         self.phoneNumber = [NSString stringWithFormat:@"%@",informationDetailDict[@"phone"]];
         self.miaomiaoNumber = [NSString stringWithFormat:@"%@",informationDetailDict[@"mcode"]];
         self.qCode = informationDetailDict[@"qrcode"];
      
         [self createData];
         
      }
      else
      {
         UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"个人信息获取失败，请检查网络设置" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
         [al show];
      }
      
   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"个人信息获取失败，请检查网络设置" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
      [al show];
   }];
   
   
   
   
   
//   NSDictionary *dict = [[NSUserDefaults standardUserDefaults]objectForKey:@"personalInformation"];
//   NSLog(@"%@",dict);
}


#pragma mark-(创建本地固定不变数据)
-(void)createLoaclData
{
    _titleArray = @[@[@"头像",@"昵称",@"性别",@"喵喵号",@"二维码名片",@"手机号"],@[@"地区",@"地址"]];
    
    
}
-(void)createData
{
    //图像
    NSString *headerImageString;
    if(self.photoUrlString == nil)
    {
        headerImageString = @"";
    }
    else
    {
       headerImageString = self.photoUrlString;
    }
    
    //昵称
    NSString *nickName;
    if(self.nickName)
    {
        nickName = self.nickName;
      //NSLog(@"名字%@",nickName);
    }
    else
    {
        nickName = @"这家伙很懒什么都没留下";
    }

    //性别
    NSString *sex;
    if(self.sexName)
    {
        sex = self.sexName;
       //NSLog(@"性别%@",sex);
    }
    else
    {
        sex = @"请选择性别";
    }

    //喵喵号
    NSString *miaomiaoNumber;
    if(self.miaomiaoNumber)
    {
        miaomiaoNumber = self.miaomiaoNumber;
    }
    else
    {
        miaomiaoNumber = @"";
    }
   
//   //二维码
//   NSString *qCode;
//   if(self.qCode)
//   {
//      qCode = self.qCode;
//   }
//   else
//   {
//      qCode = @"";
//     
//   }
   
    //手机号
    NSString *phoneNumber;
    if(self.phoneNumber)
    {
        phoneNumber = self.phoneNumber;
    }
    else
    {
        phoneNumber = @"";
    }
    
    //地区
   NSString *cityName;
   NSString *myCityPickerName = [[NSUserDefaults standardUserDefaults]objectForKey:MyCityPickerName];
   if(myCityPickerName)
   {
      cityName = myCityPickerName;
   }
   else
   {
    if(![self.cityName isEqualToString:@"<null>"])
    {
        cityName = self.cityName;
    }
    else
    {
        cityName = @"请选择地区";
    }
   }
   
    //地址  （设计缺陷 用户信息表中rmkName字段存储的自己的默认地址的信息）
   NSString *myIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
   NSDictionary *myDict = [[myAppDataBase sharedInstance]getUserInformationRecordWithUserID:myIDString];
   NSString *locatation = myDict[@"rmkName"];
   self.locatation = locatation;
   NSLog(@"未设置的默认地址的信息 = %@",self.locatation);
    if(![self.locatation isEqualToString:@""])
    {
        locatation = self.locatation;
    }
    else
    {
        locatation = @"请填写地址";
    }
    

//    self.dic = @{@"头像":headerImage,@"昵称":nickName,@"性别":sex,@"喵喵号":miaomiaoNumber,@"手机号":phoneNumber,@"地区":cityName,@"地址":locatation};
    
    self.dic = @{@"头像":headerImageString,@"昵称":nickName,@"性别":sex,@"喵喵号":miaomiaoNumber,@"手机号":phoneNumber,@"地区":cityName,@"地址":locatation};
   
   //个人信息每修改一次 tableView更新一次 与后台交互一次（后台交互成功之后再更新本地的tableView）
   
   
    [_tableView reloadData];
}


#pragma mark-(创建tableView)
-(void)createTableView
{
    _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
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
    
    //添加轻击手势 取消城市选择器
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealTap:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

//手势取消城市选择器的监听
-(void)dealTap:(UITapGestureRecognizer *)tap
{
    [self cancleLocatePicker];
}
//判断手势是否起作用
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if(self.locatePicker == nil)
    {
        return NO;
    }
    else
    {
        return YES;
    }
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
        return 6;
    }
    else
    {
        return 2;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        
        //tableView的优化 在里面创建并且赋值
        UIImageView *imageView = [ZCControl createImageViewWithFrame:CGRectMake(WIDTH*0.82, HEIGHT*0.1*0.1, WIDTH*0.11, WIDTH*0.11) ImageName:@"logo_2@2x"];
        //imageView.backgroundColor = [UIColor orangeColor];
        imageView.layer.cornerRadius = WIDTH*0.11/2;
        imageView.layer.masksToBounds = YES;
        imageView.tag = 100;
        [cell.contentView addSubview:imageView];
        
    }
    if(indexPath.section == 0)
    {
        if(indexPath.row == 3 )
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
    }
   
    cell.textLabel.text = _titleArray[indexPath.section][indexPath.row];
    cell.detailTextLabel.text = nil;
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:100];
    imageView.hidden = YES;
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            imageView.hidden = NO;
           //判断有没有上传头像 没有的话使用系统默认的
            [imageView sd_setImageWithURL:[NSURL URLWithString:self.dic[cell.textLabel.text]]];

            //赋值
        }
        else if (indexPath.row == 1)
        {
            cell.detailTextLabel.text = self.dic[cell.textLabel.text];
        }
        else if (indexPath.row == 2)
        {
           if([self.dic[cell.textLabel.text] isEqualToString:@"1"])
           {
            cell.detailTextLabel.text = @"男";
           }
           else if([self.dic[cell.textLabel.text] isEqualToString:@"2"])
           {
              cell.detailTextLabel.text = @"女";
           }
           else if([self.dic[cell.textLabel.text] isEqualToString:@"男"])
           {
              cell.detailTextLabel.text = @"男";
           }
           else if([self.dic[cell.textLabel.text] isEqualToString:@"女"])
           {
              cell.detailTextLabel.text = @"女";
           }
        }
        else if (indexPath.row == 3)
        {
           //喵喵号
            cell.detailTextLabel.text = self.dic[cell.textLabel.text];
        }
        
        else if(indexPath.row == 4)
        {
            //需要生成二维码图片
            imageView.hidden = NO;
            
            //二维码
          
            UIImage *image = [QRCodeGenerator qrImageForString:self.qCode imageSize:200];
            imageView.image = image;
            
        }
        else
        {
           cell.detailTextLabel.text = self.dic[cell.textLabel.text];
        }
    }
    else
    {
       
        cell.detailTextLabel.text = self.dic[cell.textLabel.text];
    }
    return cell;
    
}
//设置各种高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 0.1f;
    }
    else
    {
       return  HEIGHT*0.02;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HEIGHT*0.1;
}
//cell上面的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            //头像选择 调用本地相册
            UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相机",@"相册", nil];
            sheet.tag = 100;
            [sheet showInView:self.view];
        }
        else if (indexPath.row == 1)
        {
            [self createAlertView:@"请输入昵称" tag:100];
        }
        else if (indexPath.row == 2)
        {
            //[self createAlertView:@"请输入性别" tag:200];
            UIActionSheet *sexSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男♂",@"女♀", nil];
            sexSheet.tag = 200;
            [sexSheet showInView:self.view];
            
        }
        else if (indexPath.row == 3)
        {
            
        }
        else if (indexPath.row == 4)
        {
            twoDimensionalCodeViewController *tdcvc = [[twoDimensionalCodeViewController alloc]init];
           tdcvc.qcodeString = self.qCode;
            [self.navigationController pushViewController:tdcvc animated:YES];
        }
       else
       {
          // [self createAlertView:@"请输入手机号" tag:400];
           //这里需要判断是否已经绑定手机
         //  bindPhoneViewController *bpvc = [[bindPhoneViewController alloc]init];
         //  [self.navigationController pushViewController:bpvc animated:YES];
          modityBindPhoneViewController *mbpvc = [[modityBindPhoneViewController alloc]init];
           [self.navigationController pushViewController:mbpvc animated:YES];
           
       }
    }
    else
    {
        if(indexPath.row == 0)
        {
            
            
             //城市选择器
            [self cancleLocatePicker];
            self.locatePicker = [[HZAreaPickerView alloc]initWithStyle:HZAreaPickerWithStateAndCity delegate:self];
            [self.locatePicker showInView:self.view];
           
           
           //处理选择过后的结果
           NSString *str = [NSString stringWithFormat:@"%@ %@",self.locatePicker.locate.state,self.locatePicker.locate.city];
           self.cityName = str;
           isUpDate = YES;
           
           //保存我选择的城市
           
           [[NSUserDefaults standardUserDefaults]setObject:self.cityName forKey:MyCityPickerName];
           [[NSUserDefaults standardUserDefaults]synchronize];
           
           //选择地区之后 将地区ID进行转换 然后上传
           [self createData];

           
        }
        else
        {
            //增加选择地址
            addressViewController *advc = [[addressViewController alloc]init];
            advc.YB_locationDelegate = self;
            [self.navigationController pushViewController:advc animated:YES];
        }
    }
}
//选择地址之后的协议
-(void)YBMyLocationAddressButtonDidClick:(NSString *)locationString
{
//   [[NSUserDefaults standardUserDefaults]setObject:locationString forKey:MyLocationAddress];
//   [[NSUserDefaults standardUserDefaults]synchronize];
//   
//   [self createData];
   
   //选择默认地址之后存储在用户信息表中自己信息的rmkName字段中
   NSString *myIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
   NSNumber *myIDNumber = [[NSNumber alloc]initWithInt:myIDString.intValue];
   
   [[myAppDataBase sharedInstance]upDateStaticUserInfoRemarkNameWithFrD:myIDNumber remarkName:locationString];
   
}

//城市地区选择器代理
-(void)cancleLocatePicker
{
    [self.locatePicker cancelPicker];
    self.locatePicker.delegate = nil;
    self.locatePicker = nil;
    
}
-(void)pickerDidChaneStatus:(HZAreaPickerView *)picker
{
    //处理选择过后的结果
   NSString *str = [NSString stringWithFormat:@"%@ %@",picker.locate.state,picker.locate.city];
   self.cityName = str;
   isUpDate = YES;
   
   //保存我选择的城市
   
   [[NSUserDefaults standardUserDefaults]setObject:self.cityName forKey:MyCityPickerName];
   [[NSUserDefaults standardUserDefaults]synchronize];
   
   
   //选择地区之后 将地区ID进行转换 然后上传
   [self createData];
}



//创建更改信息的提示框
-(void)createAlertView:(NSString *)title tag:(int)tag
{
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:title message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    al.alertViewStyle = UIAlertViewStylePlainTextInput;
    al.tag = tag;
    [al show];
}

//更改信息提示框代理
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        return;
    }
    if(alertView.tag == 100)
    {
    UITextField *textField = [alertView textFieldAtIndex:0];
    NSString *nickNameString = textField.text;
       
    self.nickName = nickNameString;
    isUpDate = YES;
       //将更改之后的信息进行上传服务器
       NSString *informationUrlString = [NSString stringWithFormat:PERSONALINFORMATION,DomainName];
       AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
       
       //设置post请求的请求头
       manager.responseSerializer = [AFHTTPResponseSerializer serializer];
       manager.requestSerializer = [AFJSONRequestSerializer serializer];
       manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
       NSNumber *number = [[NSNumber alloc]initWithInt:1];
       
       NSDictionary *informationDict = @{@"attr":number,@"name":self.nickName,@"portrait":@"",@"gender":@"",@"city":@""};
       //NSLog(@"信息提交字典%@",informationDict);
       [manager POST:informationUrlString parameters:informationDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
          
          NSDictionary *informationErrDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
         // NSLog(@"信息提交结果字典%@",informationErrDict);
          NSString *informationErrString = informationErrDict[@"err"];
          if(informationErrString.intValue == 0)
          {
             [self createData];
             
             //实现通知传值
             NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
             [nc postNotificationName:@"changeMyNickName" object:nil userInfo:nil];
             
          }
          
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          
       }];
    }
   
}

//actionSheet的代理
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 2)
    {
        return;
    }
    if(actionSheet.tag == 100)
    {
       UIImagePickerController *picker = [[UIImagePickerController alloc]init];
       if(buttonIndex == 0)
        {
        //相机
        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
        {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        }
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
   //选择性别
    if(actionSheet.tag == 200)
    {
        if(buttonIndex == 0)
        {
           self.sexName = @"男";
        }
       if(buttonIndex == 1)
       {
          self.sexName = @"女";
       }
       
       //将更改之后的信息进行上传服务器
       NSString *informationUrlString = [NSString stringWithFormat:PERSONALINFORMATION,DomainName];
       AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
       
       //设置post请求的请求头
       manager.responseSerializer = [AFHTTPResponseSerializer serializer];
       manager.requestSerializer = [AFJSONRequestSerializer serializer];
       manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
       NSNumber *number = [[NSNumber alloc]initWithInt:3];
       NSNumber *sexNumber = [[NSNumber alloc]init];
       if([self.sexName isEqualToString:@"男"])
       {
          sexNumber = [NSNumber numberWithInt:1];
       }
       else if ([self.sexName isEqualToString:@"女"])
       {
          sexNumber = [NSNumber numberWithInt:2];
       }
       
       NSDictionary *informationDict = @{@"attr":number,@"name":@"",@"portrait":@"",@"gender":sexNumber,@"city":@""};
       //NSLog(@"信息提交字典%@",informationDict);
       [manager POST:informationUrlString parameters:informationDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
          
          NSDictionary *informationErrDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           NSLog(@"信息提交结果字典%@",informationErrDict);
          NSString *informationErrString = informationErrDict[@"err"];
          if(informationErrString.intValue == 0)
          {
             
             [self createData];
          }
          
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          
       }];
    }
//   isUpDate = YES;
//   [self createData];
}

//相机代理
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    //保存本地 跟新操作
    self.photoData = UIImageJPEGRepresentation(image, 0.1);
   
   //先把图片上传到服务器得到图片URL 然后把图片URL上传到服务器
   NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
   NSString* documentsDirectory = [paths objectAtIndex:0];
   NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:@"myPhoto.png"];
   [self.photoData writeToFile:fullPathToFile atomically:YES];
   NSURL*url=[NSURL URLWithString:@"http://chat.immbear.com:8889/file/uploader"];
   ASIFormDataRequest*logpicrequest=[ASIFormDataRequest requestWithURL:url];
   logpicrequest.delegate=self;
   [self.photoData writeToFile:fullPathToFile atomically:NO];
   [logpicrequest setFile:fullPathToFile forKey:@"uploadFile"];
   // [logpicrequest   setData:imageData forKey:@"cont"];
   logpicrequest.tag=105;
   [logpicrequest startAsynchronous];//异步开始

   
//    isUpDate = YES;
//    [self createData];
   
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)requestFinished:(ASIHTTPRequest *)request
{
   if(request.tag == 105)
   {
   NSDictionary *picDict = [request.responseString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
      NSLog(@"返回图片字典%@",picDict);
      
      //将图片URL上传服务器
      self.photoUrlString = picDict[@"url"];
      //将更改之后的信息进行上传服务器
      NSString *informationUrlString = [NSString stringWithFormat:PERSONALINFORMATION,DomainName];
      AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
      
      //设置post请求的请求头
      manager.responseSerializer = [AFHTTPResponseSerializer serializer];
      manager.requestSerializer = [AFJSONRequestSerializer serializer];
      manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
      NSNumber *number = [[NSNumber alloc]initWithInt:2];
      
      NSDictionary *informationDict = @{@"attr":number,@"name":@"",@"portrait":self.photoUrlString,@"gender":@"",@"city":@""};
      //NSLog(@"信息提交字典%@",informationDict);
      [manager POST:informationUrlString parameters:informationDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSDictionary *informationErrDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
         // NSLog(@"信息提交结果字典%@",informationErrDict);
         NSString *informationErrString = informationErrDict[@"err"];
         if(informationErrString.intValue == 0)
         {
            
            [self createData];
            
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:@"changeMyHeaderImage" object:nil userInfo:nil];
         }
         
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
      }];

      
   }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark-(创建导航栏控件)
-(void)createUINav
{
    self.view.backgroundColor = [UIColor whiteColor];
   UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"个人信息"];
   titleLabel.textAlignment = NSTextAlignmentCenter;
   titleLabel.textColor = [UIColor whiteColor];
   self.navigationItem.titleView = titleLabel;
   
   //导航栏左按钮
   UIButton *imageLeftButton  =[ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(imageLeftItemBtnClick) Title:nil];
   [imageLeftButton setImage:[UIImage imageNamed:@"店铺-店铺详情_03"] forState:UIControlStateNormal];
   UIBarButtonItem *imageLeftItem = [[UIBarButtonItem alloc]initWithCustomView:imageLeftButton];
   self.navigationItem.leftBarButtonItem = imageLeftItem;
}
-(void)imageLeftItemBtnClick
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
