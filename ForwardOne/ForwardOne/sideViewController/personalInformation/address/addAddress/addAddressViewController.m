//
//  addAddressViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/4.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "addAddressViewController.h"
#import "HZAreaPickerView.h"

//增删改查用户的地址信息
#define USERADRESSINFORMATION @"http://%@/user/address"

@interface addAddressViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,HZAreaPickerDelegate,UIGestureRecognizerDelegate,UIAlertViewDelegate>
{
    UITableView *_tableView;
    
    NSArray *_titleArray;
    NSArray *_placeHolderArray;
    
    UITextField *_NameTextField;
    UITextField *_phoneTextField;
    UITextField *_cityTextField;
    UITextField *_locationTextField;
    UITextField *_zipCodeTextField;
    
    NSString *_cityString;
}

//城市选择器
@property (strong, nonatomic) HZAreaPickerView *locatePicker;

@end

@implementation addAddressViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUINav];
    
    [self createTextUI];
    
    [self createSaveButton];
    
    [self createDataArray];
    
    // Do any additional setup after loading the view.
}
-(void)createSaveButton
{
    UIButton *saveButton = [ZCControl createButtonWithFrame:CGRectMake(SCREENWIDTH*0.1, SCREENHEIGHT*0.44, SCREENWIDTH*0.8, SCREENHEIGHT*0.08) ImageName:nil Target:self Action:@selector(rightItemBtn:) Title:@"完成"];
    saveButton.backgroundColor = [UIColor colorWithHexStr:@"#56d585"];
    saveButton.layer.cornerRadius = 10;
    saveButton.layer.masksToBounds = YES;
    [self.view addSubview:saveButton];
}

//创建local数据源
-(void)createDataArray
{
    _titleArray = @[@"收货人",@"手机号码",@"城市",@"详细地址",@"邮编"];
    _placeHolderArray = @[@"姓名",@"手机号码",@"地区信息",@"街道门牌信息",@"邮政编码"];
}


-(void)createTextUI
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT*0.4) style:UITableViewStyleGrouped];
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
//    if(self.locatePicker == nil)
//    {
//        [_textField resignFirstResponder];
//    }
//    else
//    {
//    [self cancleLocatePicker];
//    }
    if(self.locatePicker != nil)
    {
        [self cancleLocatePicker];

    }
    else
    {
        
        [_NameTextField resignFirstResponder];
        [_phoneTextField resignFirstResponder];
        [_cityTextField resignFirstResponder];
        [_locationTextField resignFirstResponder];
        [_zipCodeTextField resignFirstResponder];
    }
    
 
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
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
      _NameTextField = [ZCControl createTextFieldWithFrame:CGRectMake(SCREENWIDTH*0.3, SCREENHEIGHT*0.08*0.2, SCREENWIDTH*0.7, SCREENHEIGHT*0.08*0.6) placeholder:_placeHolderArray[indexPath.row] passWord:NO leftImageView:nil rightImageView:nil Font:SCREENWIDTH*0.048];
        _NameTextField.returnKeyType = UIReturnKeyDone;
        _NameTextField.delegate = self;
        _NameTextField.tag = 100;
        [cell.contentView addSubview:_NameTextField];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = _titleArray[indexPath.row];
    return cell;
    }
    else if (indexPath.row == 1)
    {
        static NSString *cellID = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
            _phoneTextField = [ZCControl createTextFieldWithFrame:CGRectMake(SCREENWIDTH*0.3, SCREENHEIGHT*0.08*0.2, SCREENWIDTH*0.7, SCREENHEIGHT*0.08*0.6) placeholder:_placeHolderArray[indexPath.row] passWord:NO leftImageView:nil rightImageView:nil Font:SCREENWIDTH*0.048];
            _phoneTextField.returnKeyType = UIReturnKeyDone;
            _phoneTextField.delegate = self;
            _phoneTextField.tag = 200;
            [cell.contentView addSubview:_phoneTextField];
            
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = _titleArray[indexPath.row];
        return cell;

    }
    else if (indexPath.row == 2)
    {
        static NSString *cellID = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
            _cityTextField = [ZCControl createTextFieldWithFrame:CGRectMake(SCREENWIDTH*0.3, SCREENHEIGHT*0.08*0.2, SCREENWIDTH*0.7, SCREENHEIGHT*0.08*0.6) placeholder:_placeHolderArray[indexPath.row] passWord:NO leftImageView:nil rightImageView:nil Font:SCREENWIDTH*0.048];
            _cityTextField.returnKeyType = UIReturnKeyDone;
            _cityTextField.delegate = self;
            _cityTextField.tag = 300;
            [cell.contentView addSubview:_cityTextField];
            
        }
        UITextField *textField = (UITextField *)[cell.contentView viewWithTag:300];
        textField.enabled = NO;
        cell.textLabel.text = _titleArray[indexPath.row];
        return cell;

    }
    else if (indexPath.row == 3)
    {
        static NSString *cellID = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
            _locationTextField = [ZCControl createTextFieldWithFrame:CGRectMake(SCREENWIDTH*0.3, SCREENHEIGHT*0.08*0.2, SCREENWIDTH*0.7, SCREENHEIGHT*0.08*0.6) placeholder:_placeHolderArray[indexPath.row] passWord:NO leftImageView:nil rightImageView:nil Font:SCREENWIDTH*0.048];
            _locationTextField.returnKeyType = UIReturnKeyDone;
            _locationTextField.delegate = self;
            _locationTextField.tag = 400;
            [cell.contentView addSubview:_locationTextField];
            
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = _titleArray[indexPath.row];
        return cell;

    }
   
    else
    {
        static NSString *cellID = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
            _zipCodeTextField = [ZCControl createTextFieldWithFrame:CGRectMake(SCREENWIDTH*0.3, SCREENHEIGHT*0.08*0.2, SCREENWIDTH*0.7, SCREENHEIGHT*0.08*0.6) placeholder:_placeHolderArray[indexPath.row] passWord:NO leftImageView:nil rightImageView:nil Font:SCREENWIDTH*0.048];
            _zipCodeTextField.returnKeyType = UIReturnKeyDone;
            _zipCodeTextField.delegate = self;
            _zipCodeTextField.tag = 500;
            [cell.contentView addSubview:_zipCodeTextField];
            
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = _titleArray[indexPath.row];
        return cell;

    }

}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}

//设置各种高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREENHEIGHT*0.08;
}

//cell的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 2)
    {
        
        [_NameTextField resignFirstResponder];
        [_phoneTextField resignFirstResponder];
        [_locationTextField resignFirstResponder];
        [_zipCodeTextField resignFirstResponder];
        
        //城市选择器
        [self cancleLocatePicker];
        self.locatePicker = [[HZAreaPickerView alloc]initWithStyle:HZAreaPickerWithStateAndCity delegate:self];
        [self.locatePicker showInView:self.view];
        
       
    }
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
    _cityString = [NSString stringWithFormat:@"%@ %@",picker.locate.state,picker.locate.city];
    _cityTextField.text = _cityString;
    
}

//键盘代理
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
//当输入框开始编辑的时候  实现取消城市选择器
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self cancleLocatePicker];
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

-(void)createUINav
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"添加地址"];
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


-(void)rightItemBtn:(UIButton *)button
{
    //增加地址信息之后 上传地址信息到服务器
    if(_NameTextField.text.length&&_phoneTextField.text.length&&_locationTextField.text.length != 0)
    {
    NSString *addressStringUrl = [NSString stringWithFormat:USERADRESSINFORMATION,DomainName];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
   // NSNumber *phoneNumber = [[NSNumber alloc]initWithInt:_phoneTextField.text.intValue];
    NSNumber *cityIDNumber = [[NSNumber alloc]initWithInt:1048577];
    NSNumber *provinceNumber = [[NSNumber alloc]initWithInt:16];
        NSLog(@"添加地址url = %@",addressStringUrl);
    [manager PUT:addressStringUrl parameters:@{@"name":_NameTextField.text,@"phone":_phoneTextField.text,@"address":_locationTextField.text,@"postcode":_zipCodeTextField.text,@"province_id":provinceNumber,@"city_id":cityIDNumber} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString *errString = dict[@"err"];
        NSLog(@"添加地址信息的字典%@",dict);
        if(errString.intValue == 0)
        {
            UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"地址添加成功" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            al.tag = 900;
            [al show];
            
        }
        else
        {
            UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"地址添加失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [al show];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"地址添加失败" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
        
        NSLog(@"添加地址error = %@",error);
        
    }];
    }
    else
    {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"地址信息不能为空" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [al show];
    }
}

//提醒视图的代理
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 900)
    {
        if(buttonIndex == 1)
        {
            //信息添加成功之后 点击提醒视图上面的确定之后 视图返回 否则不返回
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
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
