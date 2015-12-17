//
//  findPassWordViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/14.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "findPassWordViewController.h"

#import "newPasswordViewController.h"

#import "utils.h"

//获取验证码
#define GETCONFIRMNUMBERURL @"http://%@/user/gencode"

//手机验证码验证
#define CONFIRMCONFIRMNUMBERURL @"http://%@/user/vercode"

@interface findPassWordViewController () <UITextFieldDelegate,UIAlertViewDelegate>
{
    UITextField *phoneTextField;
    UITextField *confirmNumberTextField;
    UIButton *confirmButton;
}
@end

@implementation findPassWordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUINA];
    
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
    
}

-(void)createTextUI
{
    UIView *textFiledView = [[UIView alloc]initWithFrame:CGRectMake(SCREENWIDTH*0.1, SCREENHEIGHT*0.2, SCREENWIDTH*0.8, SCREENHEIGHT*0.12)];
    textFiledView.backgroundColor = [UIColor whiteColor];
    textFiledView.layer.cornerRadius = 10;
    textFiledView.layer.masksToBounds = YES;
    [self.view addSubview:textFiledView];
    
    phoneTextField = [ZCControl createTextFieldWithFrame:CGRectMake(0, 0, SCREENWIDTH*0.8, SCREENHEIGHT*0.06) placeholder:@"手机" passWord:NO leftImageView:nil rightImageView:nil Font:SCREENWIDTH*0.048];
    phoneTextField.delegate  =self;
    phoneTextField.borderStyle = UITextBorderStyleRoundedRect;
    [textFiledView addSubview:phoneTextField];
    
    confirmButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.55, SCREENHEIGHT*0.06, SCREENWIDTH*0.25, SCREENHEIGHT*0.06) ImageName:@"" Target:self Action:@selector(confirmButtonBtn:) Title:@"获取验证码"];
    confirmButton.backgroundColor = [UIColor whiteColor];
    [confirmButton setTitleColor:[UIColor colorWithHexStr:@"#56b585"] forState:UIControlStateNormal];
    [textFiledView addSubview:confirmButton];
    
    confirmNumberTextField = [ZCControl createTextFieldWithFrame:CGRectMake(0, SCREENHEIGHT*0.06, SCREENWIDTH*0.55, SCREENHEIGHT*0.06) placeholder:@"验证码" passWord:NO leftImageView:nil rightImageView:nil Font:SCREENWIDTH*0.048];
    confirmNumberTextField.borderStyle = UITextBorderStyleRoundedRect;
    confirmNumberTextField.delegate = self;
    confirmNumberTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [textFiledView addSubview:confirmNumberTextField];
    
    UIButton *commitButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.1, SCREENHEIGHT*0.36, SCREENWIDTH*0.8, SCREENHEIGHT*0.08) ImageName:@"" Target:self Action:@selector(commitButtonBtn:) Title:@"下一步"];
    commitButton.backgroundColor = [UIColor colorWithHexStr:@"#56b585"];
    commitButton.layer.cornerRadius = 10;
    commitButton.layer.masksToBounds = YES;
    [self.view addSubview:commitButton];
    
}
//提交
-(void)commitButtonBtn:(UIButton *)button
{
   // newPasswordViewController *nvc = [[newPasswordViewController alloc]init];
    //[self.navigationController pushViewController:nvc animated:YES];

    if([utils validateMobile:phoneTextField.text]&&confirmNumberTextField.text!=nil)
    {
    NSString *confirmConfirmNumberString = [NSString stringWithFormat:CONFIRMCONFIRMNUMBERURL,DomainName];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:confirmConfirmNumberString parameters:@{@"phone":phoneTextField.text,@"code":confirmNumberTextField.text}  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //对验证码验证的结果进行解析
        NSDictionary *confirmConfirmDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString *confrimConfrimNumberErrString = confirmConfirmDict[@"err"];
        if(confrimConfrimNumberErrString.intValue == 0)
        {
//            UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提交成功" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//            al.tag = 200;
//            [al show];
            newPasswordViewController *nvc = [[newPasswordViewController alloc]init];
            nvc.findPasswordPhoneString = phoneTextField.text;
            [self.navigationController pushViewController:nvc animated:YES];
        }
        else
        {
            UIAlertView  *al = [[UIAlertView alloc]initWithTitle:@"验证失败" message:nil
                                                        delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [al show];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        UIAlertView  *al = [[UIAlertView alloc]initWithTitle:@"验证失败" message:nil
    delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
        
    }];
    }
    else
    {
        UIAlertView  *al = [[UIAlertView alloc]initWithTitle:@"验证失败" message:nil
                                                    delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
    
    }
    
}
//代理 ————提醒视图上面点击确定之后跳转界面
//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if(alertView.tag == 200)
//    {
//        if(buttonIndex == 1)
//        {
//                newPasswordViewController *nvc = [[newPasswordViewController alloc]init];
//               [self.navigationController pushViewController:nvc animated:YES];
//        }
//    }
//}


//验证
-(void)confirmButtonBtn:(UIButton *)button
{
    //判断电话号码是否合法
    if([utils validateMobile:phoneTextField.text])
    {
        
        //先判断输入的手机号码是否为绑定的手机号码(不需要判断，当我从一部手机换到另一部手机进行登录的时候 忘记了密码 这个时候)
        //获取手机验证码
        NSString *urlString = [NSString stringWithFormat:GETCONFIRMNUMBERURL,DomainName];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        [manager POST:urlString parameters:@{@"phone":phoneTextField.text} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSString *errString = dict[@"err"];
            if(errString.intValue == 0)
            {
//                UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"验证码获取成功" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//                [al show];
                
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


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)createUINA
{
    self.view.backgroundColor = [UIColor colorWithHexStr:@"#555555"];
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"找回密码"];
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
