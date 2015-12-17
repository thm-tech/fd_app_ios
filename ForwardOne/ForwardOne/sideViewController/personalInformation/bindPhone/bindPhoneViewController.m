//
//  bindPhoneViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/4.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "bindPhoneViewController.h"

#import "utils.h"

//获取验证码
#define GETCONFIRMNUMBERURL @"http://%@/user/gencode"

//手机验证码验证
#define CONFIRMCONFIRMNUMBERURL @"http://%@/user/vercode"

//绑定手机
#define BINDPHONEURL @"http://%@/user/bindphone"


@interface bindPhoneViewController () <UITextFieldDelegate,UIAlertViewDelegate>
{
    UITextField *phoneTextFiled;
    UITextField *confirmNumberTextField;
}
@end

@implementation bindPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUINav];
    
    [self createTextUI];
    
    
    // Do any additional setup after loading the view.
}
-(void)createUINav
{
    self.title = @"绑定手机";
    self.view.backgroundColor = [UIColor whiteColor];
}

-(void)createTextUI
{
    phoneTextFiled = [ZCControl createTextFieldWithFrame:CGRectMake(SCREENWIDTH*0.145, SCREENHEIGHT*0.1, SCREENWIDTH*0.5, SCREENHEIGHT*0.06) placeholder:@"手机" passWord:nil leftImageView:nil rightImageView:nil Font:SCREENWIDTH*0.048 backgRoundImageName:nil];
    phoneTextFiled.delegate = self;
    phoneTextFiled.borderStyle = UITextBorderStyleRoundedRect;
    phoneTextFiled.keyboardType = UIKeyboardTypeNumbersAndPunctuation;;
    [self.view addSubview:phoneTextFiled];
    
    UIButton *confirmButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.655, SCREENHEIGHT*0.1, SCREENWIDTH*0.2, SCREENHEIGHT*0.06) ImageName:nil Target:self Action:@selector(confirmButtonBtn:) Title:@"验证"];
   // [confirmButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [confirmButton setBackgroundColor:[UIColor orangeColor]];
    [self.view addSubview:confirmButton];
    
    confirmNumberTextField = [ZCControl createTextFieldWithFrame:CGRectMake(SCREENWIDTH*0.145, SCREENHEIGHT*0.16, SCREENWIDTH*0.71, SCREENHEIGHT*0.06) placeholder:@"验证码" passWord:nil leftImageView:nil rightImageView:nil Font:SCREENWIDTH*0.048 backgRoundImageName:nil];
    confirmNumberTextField.delegate = self;
    confirmNumberTextField.borderStyle = UITextBorderStyleRoundedRect;
    confirmNumberTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [self.view addSubview:confirmNumberTextField];
    
    UIButton *commitButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.145, SCREENHEIGHT*0.25, SCREENWIDTH*0.71, SCREENHEIGHT*0.07) ImageName:nil Target:self Action:@selector(commitButtonBtn:) Title:@"提交"];
    [commitButton setBackgroundColor:[UIColor orangeColor]];
    [self.view addSubview:commitButton];
    
  
}

-(void)confirmButtonBtn:(UIButton *)button
{
    //判断电话号码是否合法
    if([utils validateMobile:phoneTextFiled.text])
    {
        //获取手机验证码
        NSString *urlString = [NSString stringWithFormat:GETCONFIRMNUMBERURL,DomainName];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager POST:urlString parameters:@{@"phone":phoneTextFiled.text} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSString *errString = dict[@"err"];
            if(errString.intValue == 0)
            {
                UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"验证码获取成功" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [al show];
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
    else
    {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"手机号码不正确" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
    }

}

-(void)commitButtonBtn:(UIButton *)button
{
    NSString *confirmNumString = [NSString stringWithFormat:CONFIRMCONFIRMNUMBERURL,DomainName];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:confirmNumString parameters:@{@"phone":phoneTextFiled.text,@"code":confirmNumberTextField.text} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //对验证验证码的结果进行解析
        NSDictionary *confirmConfirmNumberDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString *confirmConfirmNumberErrString = confirmConfirmNumberDict[@"err"];
        if(confirmConfirmNumberErrString.intValue == 0)
        {
            NSString *bindPhoneString = [NSString stringWithFormat:BINDPHONEURL,DomainName];
            [manager POST:bindPhoneString parameters:@{@"phone":phoneTextFiled.text} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSDictionary *bindPhoneDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                NSString *bindPhoneErrString = bindPhoneDict[@"err"];
                if(bindPhoneErrString.intValue == 0)
                {
                    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"绑定成功" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    al.tag = 700;
                    [al show];
                }
                else
                {
                    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"绑定失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    [al show];
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提交失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [al show];
            }];
        }
        else
        {
            UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提交失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [al show];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提交失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
    }];
}

//提醒视图的代理  绑定手机号码成功之后  点击确定 实现界面的跳转
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 700)
    {
        if(buttonIndex == 1)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


//键盘代理
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//查

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
