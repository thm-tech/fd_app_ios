//
//  modityBindPhoneViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/4.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "modityBindPhoneViewController.h"

//获取验证码
#define GETCONFIRMNUMBERURL @"http://%@/user/gencode"

//手机验证码验证
#define CONFIRMCONFIRMNUMBERURL @"http://%@/user/vercode"

//绑定手机
#define BINDPHONEURL @"http://%@/user/bindphone"

@interface modityBindPhoneViewController () <UITextFieldDelegate,UIAlertViewDelegate>
{
    UITextField *phoneTextFiled;
    UITextField *newPhoneTextField;
    UITextField *confirmNumberTextField;
    UIButton *confirmButton;
}
@end

@implementation modityBindPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUINav];
    
    [self createTextUI];
    
    //添加手势 回收键盘
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealWithTap:)];
    [self.view addGestureRecognizer:tap];
    
    // Do any additional setup after loading the view.
}
-(void)dealWithTap:(UITapGestureRecognizer *)tap

{
    [confirmNumberTextField resignFirstResponder];
    [newPhoneTextField resignFirstResponder];
}

-(void)createTextUI
{
    
    UIView *textFieldView = [[UIView alloc]initWithFrame:CGRectMake(SCREENWIDTH*0.1, SCREENHEIGHT*0.1, SCREENWIDTH*0.8, SCREENHEIGHT*0.18)];
    textFieldView.backgroundColor = [UIColor colorWithHexStr:@"#eeeeee"];
    textFieldView.layer.cornerRadius = 10;
    textFieldView.layer.masksToBounds = YES;
    [self.view addSubview:textFieldView];
    
    //默认为之间绑定的手机号码】
    NSString *placeholderString = [[NSUserDefaults standardUserDefaults]objectForKey:UserPhone];
    phoneTextFiled = [ZCControl createTextFieldWithFrame:CGRectMake(0, 0, SCREENWIDTH*0.8, SCREENHEIGHT*0.06) placeholder:placeholderString passWord:nil leftImageView:nil rightImageView:nil Font:SCREENWIDTH*0.048 backgRoundImageName:nil];
    phoneTextFiled.delegate = self;
    //让输入框不可编辑 
    phoneTextFiled.enabled = NO;
    //phoneTextFiled.clearButtonMode = UITextFieldViewModeAlways;
    phoneTextFiled.borderStyle = UITextBorderStyleRoundedRect;
    phoneTextFiled.keyboardType = UIKeyboardTypeNumbersAndPunctuation;;
    [textFieldView addSubview:phoneTextFiled];
    
    confirmButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.55, SCREENHEIGHT*0.06, SCREENWIDTH*0.25, SCREENHEIGHT*0.06) ImageName:nil Target:self Action:@selector(confirmButtonBtn:) Title:@"获取验证码"];
    // [confirmButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    confirmButton.backgroundColor = [UIColor whiteColor];
    [confirmButton setTitleColor:[UIColor colorWithHexStr:@"#56b585"] forState:UIControlStateNormal];
    [textFieldView addSubview:confirmButton];
    
   confirmNumberTextField = [ZCControl createTextFieldWithFrame:CGRectMake(0, SCREENHEIGHT*0.06, SCREENWIDTH*0.55, SCREENHEIGHT*0.06) placeholder:@"验证码" passWord:nil leftImageView:nil rightImageView:nil Font:SCREENWIDTH*0.048 backgRoundImageName:nil];
    confirmNumberTextField.delegate = self;
    confirmNumberTextField.borderStyle = UITextBorderStyleRoundedRect;
    confirmNumberTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [textFieldView addSubview:confirmNumberTextField];
    
    newPhoneTextField = [ZCControl createTextFieldWithFrame:CGRectMake(0, SCREENHEIGHT*0.12, SCREENWIDTH*0.8, SCREENHEIGHT*0.06) placeholder:@"新手机号" passWord:nil leftImageView:nil rightImageView:nil Font:SCREENWIDTH*0.048 backgRoundImageName:nil];
    newPhoneTextField.delegate = self;
    newPhoneTextField.borderStyle = UITextBorderStyleRoundedRect;
    newPhoneTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [textFieldView addSubview:newPhoneTextField];
    
    UIButton *commitButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.1, SCREENHEIGHT*0.32, SCREENWIDTH*0.8, SCREENHEIGHT*0.08) ImageName:nil Target:self Action:@selector(commitButtonBtn:) Title:@"提交"];
    commitButton.layer.cornerRadius  = 10;
    commitButton.layer.masksToBounds = YES;
    [commitButton setBackgroundColor:[UIColor colorWithHexStr:@"#56d585"]];
    [self.view addSubview:commitButton];
    
    
}
-(void)commitButtonBtn:(UIButton *)button
{
    //判断更改绑定的手机号是否跟之间的一致 如果相同 则不允许更改
    if([newPhoneTextField.text isEqualToString:phoneTextFiled.placeholder])
    {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"请输入不同的手机号码" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
    }
    else
    {
        //当手机号码不同的时候 进行手机验证码的验证
        NSString *confirmNumberString = [NSString stringWithFormat:CONFIRMCONFIRMNUMBERURL,DomainName];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        [manager POST:confirmNumberString parameters:@{@"phone":phoneTextFiled.placeholder,@"code":confirmNumberTextField.text} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *confirmNumberDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            //NSLog(@"验证码验证字典%@",confirmNumberDict);
            NSString *confirmNumberErrString = confirmNumberDict[@"err"];
            if(confirmNumberErrString.intValue == 0)
            {
                NSString *bindPhoneString = [NSString stringWithFormat:BINDPHONEURL,DomainName];
                [manager POST:bindPhoneString parameters:@{@"phone":newPhoneTextField.text} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    NSDictionary *bindPhoneDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                    NSLog(@"修改绑定的字典%@",bindPhoneDict);
                    NSString *bindPhoneErrString = bindPhoneDict[@"err"];
                    if(bindPhoneErrString.intValue == 0)
                    {
                        //保存修改之后的手机号码
                        [[NSUserDefaults standardUserDefaults]setObject:newPhoneTextField.text forKey:UserPhone];
                        [[NSUserDefaults standardUserDefaults]synchronize];
                        
                        
                        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提交成功" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                        al.tag = 800;
                        [al show];
                    }
                    else
                    {
                        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提交失败" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                        [al show];
                    }
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提交失败" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    [al show];
                }];
            }
            else
            {
                UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提交失败" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [al show];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           
            UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提交失败" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [al show];
            
        }];
    }
}

//提醒视图的代理
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 800)
    {
        if(buttonIndex == 1)
        {
            //这里是绑定手机号码成功后 推荐返回上级界面  在返回之间需要把新的绑定手机进行存储
            [[NSUserDefaults standardUserDefaults]setObject:newPhoneTextField.text forKey:UserPhone];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

-(void)confirmButtonBtn:(UIButton *)button
{
    //获取手机验证码
    NSString *urlString = [NSString stringWithFormat:GETCONFIRMNUMBERURL,DomainName];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:urlString parameters:@{@"phone":phoneTextFiled.placeholder} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
//            UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"验证码获取成功" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//            [al show];
            [self getGCD];
        }
        else
        {
            UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"验证码获取失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [al show];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"验证码获取失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
    }];
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


//键盘代理
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


-(void)createUINav
{
    self.view.backgroundColor = [UIColor colorWithHexStr:@"#eeeeee"];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"修改绑定"];
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
