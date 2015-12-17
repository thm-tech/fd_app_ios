//
//  registerViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/14.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "registerViewController.h"
#import "loginViewController.h"

#import "utils.h"
#import "NSString+Hashing.h"
//获取验证码URL
#define GETCONFIRMNUMBERURL @"http://%@/user/gencode"

//手机验证码验证
#define CONFIRMCONFIRMNUMBERURL @"http://%@/user/vercode"

//注册的URL
#define RESGISTERURL @"http://%@/user/register"

@interface registerViewController () <UITextFieldDelegate,UIAlertViewDelegate>
{
    UITextField *phoneTextField;
    UITextField *confirmNumberTextField;
    UITextField *passwordTextField;
    UIButton *confirmButton;
}
@end

@implementation registerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUINAv];
    
    [self createTextUI];
    
    //添加手势 回收键盘
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealWithTap:)];
    [self.view addGestureRecognizer:tap];
    
    // Do any additional setup after loading the view.
}
-(void)dealWithTap:(UITapGestureRecognizer *)tap

{
    [phoneTextField resignFirstResponder];
    [confirmNumberTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
}

-(void)createTextUI
{
    
    //logo
    UIImageView *logoImageView = [ZCControl createImageViewWithFrame:CGRectMake(SCREENWIDTH*0.25, SCREENHEIGHT*0.025, SCREENWIDTH*0.5, SCREENHEIGHT*0.15) ImageName:@""];
    logoImageView.backgroundColor = [UIColor whiteColor];
    //[self.view addSubview:logoImageView];

    UIView *textFieldView = [[UIView alloc]initWithFrame:CGRectMake(SCREENWIDTH*0.1, SCREENHEIGHT*0.2, SCREENWIDTH*0.8, SCREENHEIGHT*0.18)];
    textFieldView.backgroundColor = [UIColor whiteColor];
    textFieldView.layer.cornerRadius = 10;
    textFieldView.layer.masksToBounds = YES;
    [self.view addSubview:textFieldView];
    
    phoneTextField = [ZCControl createTextFieldWithFrame:CGRectMake(0, 0, SCREENWIDTH*0.8, SCREENHEIGHT*0.06) placeholder:@"手机" passWord:NO leftImageView:nil rightImageView:nil Font:SCREENWIDTH*0.048];
    phoneTextField.delegate  =self;
    phoneTextField.borderStyle = UITextBorderStyleRoundedRect;
    //phoneTextField.background = [UIImage  imageNamed:@"54"];
    [textFieldView addSubview:phoneTextField];
    
    confirmButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.55, SCREENHEIGHT*0.06, SCREENWIDTH*0.25, SCREENHEIGHT*0.06) ImageName:@"" Target:self Action:@selector(confirmButtonBtnClick:) Title:@"获取验证码"];
    confirmButton.backgroundColor = [UIColor whiteColor];
    [confirmButton setTitleColor:[UIColor colorWithHexStr:@"#56b585"] forState:UIControlStateNormal];
    [textFieldView addSubview:confirmButton];
    
    confirmNumberTextField = [ZCControl createTextFieldWithFrame:CGRectMake(0, SCREENHEIGHT*0.06, SCREENWIDTH*0.55, SCREENHEIGHT*0.06) placeholder:@"验证码" passWord:NO leftImageView:nil rightImageView:nil Font:SCREENWIDTH*0.048];
    confirmNumberTextField.borderStyle = UITextBorderStyleRoundedRect;
    //confirmNumberTextField.background = [UIImage imageNamed:@"54"];
    //confirmNumberTextField.backgroundColor = [UIColor whiteColor];
    confirmNumberTextField.delegate = self;
    confirmNumberTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [textFieldView addSubview:confirmNumberTextField];
    
    passwordTextField = [ZCControl createTextFieldWithFrame:CGRectMake(0, SCREENHEIGHT*0.12, SCREENWIDTH*0.8, SCREENHEIGHT*0.06) placeholder:@"密码" passWord:NO leftImageView:nil rightImageView:nil Font:SCREENWIDTH*0.048];
    passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
   // passwordTextField.background = [UIImage imageNamed:@"54"];
    passwordTextField.delegate = self;
    passwordTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [textFieldView addSubview:passwordTextField];
    
    UIButton *registerButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.1, SCREENHEIGHT*0.42, SCREENWIDTH*0.8, SCREENHEIGHT*0.08) ImageName:@"" Target:self Action:@selector(registerButtonBtn:) Title:@"注册"];
    [registerButton setBackgroundColor:[UIColor colorWithHexStr:@"#56d585"]];
    registerButton.layer.cornerRadius = YES;
    registerButton.layer.masksToBounds = YES;
    [self.view addSubview:registerButton];
    
}
//注册
-(void)registerButtonBtn:(UIButton *)button
{
    //注册成功后 跳入登录界面进行登录
    NSString *confirmConfirmNumberString = [NSString stringWithFormat:CONFIRMCONFIRMNUMBERURL,DomainName];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:confirmConfirmNumberString parameters:@{@"phone":phoneTextField.text,@"code":confirmNumberTextField.text} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //对验证验证码的结果进行解析
        NSDictionary *confirmConfirmNumberDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"验证码结果字典%@",confirmConfirmNumberDict);
        NSString *confirmConfirmNumberErrString = confirmConfirmNumberDict[@"err"];
        if(confirmConfirmNumberErrString.intValue == 0)
        {
            
            //验证码结果正确的时候调用注册的协议
            if([utils validatePassword:passwordTextField.text])
            {
            
            NSString *resgisterString = [NSString stringWithFormat:RESGISTERURL,DomainName];
                NSString *passwordString = [passwordTextField.text MD5Hash];
            [manager POST:resgisterString parameters:@{@"phone":phoneTextField.text,@"password":passwordString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSDictionary *resgisterDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                NSLog(@"注册结果的字典%@",resgisterDict);
                NSString *registerErrString = resgisterDict[@"err"];
                if(registerErrString.intValue == 0)
                {
                    
                    //当注册成功后 这里需要记录注册成功后生成的ID，用户名，密码
//                    [[NSUserDefaults standardUserDefaults]setObject:resgisterDict[@"accID"] forKey:UserAccount];
//                    [[NSUserDefaults standardUserDefaults]setObject:phoneTextField.text forKey:UserPhone];
//                    [[NSUserDefaults standardUserDefaults]setObject:passwordTextField.text forKey:UserPassword];
//                    [[NSUserDefaults standardUserDefaults]synchronize];
                    
                    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"注册成功" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                    al.tag = 1001;
                    [al show];
                    
                }
                else
                {
                    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"注册失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    [al show];
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"注册失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [al show];
            }];
            }
            else
            {
                UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"请输入6位以上密码" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [al show];
            }
        }
        else
        {
            UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"验证码不正确" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [al show];

        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"验证码不正确" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
       
    }];
    
   
   // [self.navigationController popViewControllerAnimated:YES];
    
}
//alertView代理
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1001)
    {
        if(buttonIndex == 0)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

//验证
-(void)confirmButtonBtnClick:(UIButton *)button
{
   //判断电话号码是否合法
    if([utils validateMobile:phoneTextField.text])
    {
        //获取手机验证码
        NSString *urlString = [NSString stringWithFormat:GETCONFIRMNUMBERURL,DomainName];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        [manager POST:urlString parameters:@{@"phone":phoneTextField.text} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           // NSLog(@"******字典%@",dict);
            NSString *errString = dict[@"err"];
            if(errString.intValue == 0)
            {
//                UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"验证码获取成功" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//                [al show];
                [self getGCD];
            }
            
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"验证码获取失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [al show];
            
        }];
    }
    else
    {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"手机号码不正确" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
    }
    
}
-(void)getGCD
{
    __block int timeout=30; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [confirmButton setTitle:@"获取验证码" forState:UIControlStateNormal];
                confirmButton.userInteractionEnabled = YES;
            });
        }else{
            //            int minutes = timeout / 60;
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                //NSLog(@"____%@",strTime);
                [confirmButton setTitle:[NSString stringWithFormat:@"%@秒后重新获取",strTime] forState:UIControlStateNormal];
                confirmButton.userInteractionEnabled = NO;
                
            });
            timeout--;
            
        }
    });
    dispatch_resume(_timer);
    

}

-(void)createUINAv
{
    self.view.backgroundColor = [UIColor colorWithHexStr:@"#555555"];
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"注册"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
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
