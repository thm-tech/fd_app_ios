//
//  invivateFriendsShoppingViewController.m
//  ForwardOne
//
//  Created by 杨波 on 15/5/26.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "invivateFriendsShoppingViewController.h"
#import "MJNIndexView.h"

#import "friendsDetailViewController.h"

#import "myAppDataBase.h"

#import "PinYin4Objc.h"

#define FRIENDDIFFERENTURL @"http://%@/user/friend/diff"

#define FRIENDINFORMATIONURL @"http://%@/user/friend?"

#import "OpenUDID.h"

#import "myFriendTableViewCell.h"

#import "miaomiaoChatDetailViewController.h"
#import "miaomiaoViewController.h"
#import "miaomiaoChatGroupSettingViewController.h"

#import <QuartzCore/QuartzCore.h>

#define CRAYON_NAME(CRAYON)	[[CRAYON componentsSeparatedByString:@"#"] objectAtIndex:0]

@interface invivateFriendsShoppingViewController ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate,
MJNIndexViewDataSource>
{
    YBWebSocketManager *socketManager;
    
    //gname
    NSString *_gname;
    
}
//保存索引的属性数组
@property (nonatomic,strong) NSArray *titleArray;

//拉好友一起逛选择好友的数组
@property (nonatomic,strong) NSMutableArray *selectedFriendsArray;

// properties for section array
@property (nonatomic, strong) NSString *pathname;
@property (nonatomic, strong) NSArray *crayons;
@property (nonatomic, strong) NSString *alphaString;
@property (nonatomic, strong) NSMutableArray *sectionArray;

// properties for tableView
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIColor *tableColor;
@property (nonatomic, strong) UIColor *tableTextColor;
@property (nonatomic, strong) UIColor *tableSeparatorColor;
@property (nonatomic, strong) UIColor *tableHeaderColor;
@property (nonatomic, strong) UIColor *tableHeaderTextColor;
@property (nonatomic, strong) UIFont *font;


// MJNIndexView
@property (nonatomic, strong) MJNIndexView *indexView;

// settings, scrollView

// properties for exampleView delegate
@property (nonatomic, strong) NSArray * allExamples;



#pragma mark all properties from MJNIndexView

// set this to NO if you want to get selected items during the pan (default is YES)
@property (nonatomic, assign) BOOL getSelectedItemsAfterPanGestureIsFinished;

// set the font of the selected index item (usually you should choose the same font with a bold style and much larger)
// (default is the same font as previous one with size 40.0 points)
@property (nonatomic, strong) UIFont *selectedItemFont;

// set the color for index items
@property (nonatomic, strong) UIColor *fontColor;

// set if items in index are going to darken during a pan (default is YES)
@property (nonatomic, assign) BOOL darkening;

// set if items in index are going ti fade during a pan (default is YES)
@property (nonatomic, assign) BOOL fading;

// set the color for the selected index item
@property (nonatomic, strong) UIColor *selectedItemFontColor;

// set index items aligment (NSTextAligmentLeft, NSTextAligmentCenter or NSTextAligmentRight - default is NSTextAligmentCenter)
@property (nonatomic, assign) NSTextAlignment itemsAligment;

// set the right margin of index items (default is 10.0)
@property (nonatomic, assign) CGFloat rightMargin;

// set the upper margin of index items (default is 20.0)
// please remember that margins are set for the largest size of selected item font
@property (nonatomic, assign) CGFloat upperMargin;

// set the lower margin of index items (default is 20.0)
// please remember that margins are set for the largest size of selected item font
@property (nonatomic, assign) CGFloat lowerMargin;

// set the maximum amount for item deflection (default is 75.0)
@property (nonatomic,assign) CGFloat maxItemDeflection;

// set the number of items deflected below and above the selected one (default is 5)
@property (nonatomic, assign) int rangeOfDeflection;

// set the curtain color if you want a curtain to appear (default is none)
@property (nonatomic, strong) UIColor *curtainColor;

// set the amount of fading for the curtain between 0 to 1 (default is 0.2)
@property (nonatomic, assign) CGFloat curtainFade;

// set if you need a curtain not to hide completely
@property (nonatomic, assign) BOOL curtainStays;

// set if you want a curtain to move while panning (default is NO)
@property (nonatomic, assign) BOOL curtainMoves;

// set if you need curtain to have the same upper and lower margins (default is NO)
@property (nonatomic, assign) BOOL curtainMargins;

// set this property to YES and it will automatically set margins so that gaps between items are 5.0 points (default is YES)
@property BOOL ergonomicHeight;


@end

@implementation invivateFriendsShoppingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //单例 Socket
    socketManager = [YBWebSocketManager sharedInstance];

    [self createUINav];
    
    
    //选择拉好友一起逛的数据源
    self.selectedFriendsArray = [[NSMutableArray alloc]init];
    //先判断是否登录
    NSString *loginString = [[NSUserDefaults standardUserDefaults]objectForKey:IsLogin];
    if([loginString isEqualToString:@"login"])
    {
        [self refreshTable];
        
        //[self firstTableExample];
        
        //从数据库中读取所有好友的数据
        //[self loadFriendDataFromDataBase];
        
    }
    else
    {
        UILabel *label = [ZCControl createLabelWithFrame:CGRectMake(0, SCREENHEIGHT*0.2, SCREENWIDTH, SCREENHEIGHT*0.1) Font:SCREENWIDTH*0.048 Text:@"你还没登录，请先登录"];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
    }

    
   
    // Do any additional setup after loading the view.
}
#pragma mark reading/writting attributes for MJNIndexItemsForTableView

- (void)readAttributes
{
    self.getSelectedItemsAfterPanGestureIsFinished = self.indexView.getSelectedItemsAfterPanGestureIsFinished;
    self.font = self.indexView.font;
    self.selectedItemFont = self.indexView.selectedItemFont;
    self.fontColor = self.indexView.fontColor;
    self.selectedItemFontColor = self.indexView.selectedItemFontColor;
    self.darkening = self.indexView.darkening;
    self.fading = self.indexView.fading;
    self.itemsAligment = self.indexView.itemsAligment;
    self.rightMargin = self.indexView.rightMargin;
    self.upperMargin = self.indexView.upperMargin;
    self.lowerMargin = self.indexView.lowerMargin;
    self.maxItemDeflection = self.indexView.maxItemDeflection;
    self.rangeOfDeflection = self.indexView.rangeOfDeflection;
    self.curtainColor = self.indexView.curtainColor;
    self.curtainFade = self.indexView.curtainFade;
    self.curtainMargins = self.indexView.curtainMargins;
    self.curtainStays = self.indexView.curtainStays;
    self.curtainMoves = self.indexView.curtainMoves;
    self.ergonomicHeight = self.indexView.ergonomicHeight;
}


#pragma mark settigns examples of tableView and MJNIndexView


- (void)firstTableExample
{
    //好友数组列表存入文件中 得到好友数组列表所在的文件的文件名 取出数组
    //NSBundle里面的路径名
    self.pathname = [[NSBundle mainBundle]  pathForResource:@"hha" ofType:@"txt"];
    // NSLog(@"文件名为@@@@@@@@@@@@@@@@@@@@————————————%@",self.pathname);
    self.tableColor = [UIColor whiteColor];
    self.tableTextColor = [UIColor blackColor];
    self.tableSeparatorColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    self.tableHeaderColor = [UIColor colorWithRed:80.0/255.0 green:215.0/255.0 blue:250.0/255.0 alpha:1.0];
    self.tableHeaderTextColor = [UIColor whiteColor];
    //[self refreshTable];
}

- (void)firstAttributesForMJNIndexView
{
    
    self.indexView.getSelectedItemsAfterPanGestureIsFinished = YES;
    self.indexView.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0];
    self.indexView.selectedItemFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:40.0];
    self.indexView.backgroundColor = [UIColor clearColor];
    self.indexView.curtainColor = nil;
    self.indexView.curtainFade = 0.0;
    self.indexView.curtainStays = NO;
    self.indexView.curtainMoves = YES;
    self.indexView.curtainMargins = NO;
    self.indexView.ergonomicHeight = NO;
    self.indexView.upperMargin = 22.0;
    self.indexView.lowerMargin = 22.0;
    self.indexView.rightMargin = 10.0;
    self.indexView.itemsAligment = NSTextAlignmentCenter;
    self.indexView.maxItemDeflection = 100.0;
    self.indexView.rangeOfDeflection = 5;
    self.indexView.fontColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
    self.indexView.selectedItemFontColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    self.indexView.darkening = NO;
    self.indexView.fading = YES;
    
}


// refreshing table with a contents of file stored in self.pathname
- (void)refreshTable
{
    //判断当前设备是否和上次登录的设备一致
    NSString *lastUserDevice = [[NSUserDefaults standardUserDefaults]objectForKey:UserDevice];
    NSString *nowUserDevice = [OpenUDID value];
    if([lastUserDevice isEqualToString:nowUserDevice])
    {
        [self getFriendInformationData];
    }
    else
    {
        NSString *friendTogetherString = [[NSUserDefaults standardUserDefaults]objectForKey:IsTogetherFriend];
        if([friendTogetherString isEqualToString:@"1"])
        {
            [self getFriendInformationData];
        }
        else
        {

            [self downLoadDifferentFriendInformation];
            
            [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:IsTogetherFriend];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
        }

    }

}
-(void)getFriendInformationData
{
    NSMutableArray *crayonColors = [NSMutableArray new];
    NSArray *array = [[myAppDataBase sharedInstance]getAllUserInformationWith:RecoredTypeAttention];
    NSLog(@"好友数组************%@",array);
    if(array.count >1)
    {
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width*0.9, SCREENHEIGHT-64) style:UITableViewStylePlain];
        
        [self.tableView registerClass:[UITableViewCell class]forCellReuseIdentifier:@"cell"];
        [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"header"];
        self.tableView.editing = YES;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.showsVerticalScrollIndicator = NO;
        //    //设置表格视图左边短15像素问题
        //    if([self.tableView respondsToSelector:@selector(setSeparatorInset:)])
        //    {
        //        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        //    }
        //    if([self.tableView  respondsToSelector:@selector(setLayoutMargins:)])
        //    {
        //        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
        //    }
        
        [self.view addSubview:self.tableView];
        
        // initialise MJNIndexView
        self.indexView = [[MJNIndexView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-64)];
        self.indexView.dataSource = self;
        [self firstTableExample];
        [self firstAttributesForMJNIndexView];
        [self readAttributes];
        [self.view addSubview:self.indexView];
        
        for(NSDictionary *friendInformationDict in array)
        {
            NSString *myIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
            NSString *userIDString = friendInformationDict[@"frdID"];
            if([myIDString isEqualToString:userIDString])
            {
                
            }
            else
            {
            NSString *rmkName = friendInformationDict[@"rmkName"];
            //判断备注名存在还是不存在
            if(rmkName.length != 0)
            {
                [crayonColors addObject:friendInformationDict[@"rmkName"]];
            }
            else
            {
                [crayonColors addObject:friendInformationDict[@"nickName"]];
            }
            }
        }
        NSLog(@"好友名字%@",crayonColors);
        
        //将汉字转为拼音
        HanyuPinyinOutputFormat *outputFormat=[[HanyuPinyinOutputFormat alloc] init];
        [outputFormat setToneType:ToneTypeWithoutTone];
        [outputFormat setVCharType:VCharTypeWithV];
        [outputFormat setCaseType:CaseTypeLowercase];
        
        NSMutableArray *pinyinArray = [[NSMutableArray alloc]init];
        
        for(NSString *nameString in crayonColors)
        {
            if([nameString rangeOfString:@" "].location != NSNotFound)
            {
                NSString *newNameString = [[NSString alloc]init];
                newNameString = [nameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSString *outputPinyin=[PinyinHelper toHanyuPinyinStringWithNSString:newNameString withHanyuPinyinOutputFormat:outputFormat withNSString:@" "];
                [pinyinArray addObject:outputPinyin];
            }
            else
            {
                NSString *outputPinyin=[PinyinHelper toHanyuPinyinStringWithNSString:nameString withHanyuPinyinOutputFormat:outputFormat withNSString:@" "];
                [pinyinArray addObject:outputPinyin];
            }
            
        }
        
        
        self.alphaString = @"";
        //self.crayons = pinyinArray;
        NSArray *newPinyinArray = [pinyinArray sortedArrayUsingSelector:@selector(compare:)];
        self.crayons = newPinyinArray;
        self.sectionArray = [NSMutableArray array];
        NSLog(@"好友拼音%@",self.crayons);
        int numberOfFirstLetters = [self countFirstLettersInArray:self.crayons];
        NSLog(@"组数%d",numberOfFirstLetters);
        
        //分组之后的拼音数组
        NSMutableArray *finalPinyinArray = [[NSMutableArray alloc]init];
        
        //将整个好友数组进行分组  以索引首字符为分组标志
        for (int i=0; i< numberOfFirstLetters; i++) {
            [finalPinyinArray addObject:[self itemsInSection:i]];
        }
        NSLog(@"分组之后的好友数组%@",finalPinyinArray);
        
        self.sectionArray = finalPinyinArray;
        
        NSLog(@"分组之后的好友数组%@",self.sectionArray);
        
        [self.indexView refreshIndexItems];
        
        // NSLog(@"分组之后的好友数组%@",self.sectionArray);
        [self.tableView setSeparatorColor:self.tableSeparatorColor];
        [self.tableView reloadData];
        [self.tableView reloadSectionIndexTitles];
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:[self.sectionArray count] -1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];

    }
    else
    {
        UILabel *label = [ZCControl createLabelWithFrame:CGRectMake(0, SCREENHEIGHT*0.2, SCREENWIDTH, SCREENHEIGHT*0.1) Font:SCREENWIDTH*0.048 Text:@"你还没好友哟，请先添加好友吧"];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];

    }
    
}

-(void)downLoadDifferentFriendInformation
{
    //获得本地存储的好友ID
    NSArray *array = [[myAppDataBase sharedInstance]getAllUserInformationWith:RecoredTypeAttention];
    NSMutableArray *frdIDArray = [[NSMutableArray alloc]init];
    for(NSDictionary *userInformationDict in array)
    {
        NSString *myIDString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
        NSString *frdIDString = userInformationDict[@"frdID"];
        if(![myIDString isEqualToString:frdIDString])
        {
        NSNumber *frdIDNumber = [[NSNumber alloc]initWithInt:frdIDString.intValue];
        [frdIDArray addObject:frdIDNumber];
        }
    }
    
    NSString *urlString = [NSString stringWithFormat:FRIENDDIFFERENTURL,DomainName];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:urlString parameters:@{@"frdIDs":frdIDArray} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
            NSArray *addArray = dict[@"addFrdIDs"];
            NSArray *deleteArray = dict[@"delFrdIDs"];
            
            //删除数据库中需要删除的好友ID
            for(int i = 0;i<deleteArray.count;i++)
            {
                NSString *deleteIDString = [NSString stringWithFormat:@"%@",deleteArray[i]];
                NSNumber *deleteIDNumber = [[NSNumber alloc]initWithInt:deleteIDString.intValue];
                [[myAppDataBase sharedInstance]deleteUserInformationRecordWithDicitionary:deleteIDNumber recordType:RecoredTypeAttention];
            }
            
            if(addArray.count == 0&&deleteArray.count == 0)
            {
                [self getFriendInformationData];
            }
            else
            {
                //                [self getFriendInformationData];
                
                [self downLoadAddFriendDataWithAddArray:addArray];
                
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
}
-(void)downLoadAddFriendDataWithAddArray:(NSArray *)array
{
    NSString *frdIDString = [[NSString alloc]init];
    NSString *string = [NSString stringWithFormat:FRIENDINFORMATIONURL,DomainName];
    
    for(int i = 0;i<array.count;i++)
    {
        if(i == array.count-1)
        {
            frdIDString = [NSString stringWithFormat:@"uid=%@",array[i]];
        }
        else
        {
            frdIDString = [NSString stringWithFormat:@"uid=%@&",array[i]];
        }
        string = [string stringByAppendingString:frdIDString];
    }
    //下载需要增加的好友信息
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:string parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString *errString = dict[@"err"];
        if(errString.intValue == 0)
        {
            NSArray *addFriendArray = dict[@"frdList"];
            for(NSDictionary *addFriendDict in addFriendArray)
            {
                [[myAppDataBase sharedInstance]addUserInformationRecordWithDicitionary:addFriendDict recordType:RecoredTypeAttention];
            }
            
            if(addFriendArray.count != 0)
            {
                [self getFriendInformationData];
            }
            else
            {
                UILabel *label = [ZCControl createLabelWithFrame:CGRectMake(0, SCREENHEIGHT*0.2, SCREENWIDTH, SCREENHEIGHT*0.1) Font:SCREENWIDTH*0.048 Text:@"你还没有任何好友，请先添加好友吧"];
                label.textAlignment = NSTextAlignmentCenter;
                [self.view addSubview:label];
            }

        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
}




# pragma mark TableView datasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sectionArray[section]count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    myFriendTableViewCell *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:cellID];
    if(cell == nil)
    {
        cell = [[myFriendTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    //将汉字转为拼音
    HanyuPinyinOutputFormat *outputFormat=[[HanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];
    [outputFormat setVCharType:VCharTypeWithV];
    [outputFormat setCaseType:CaseTypeLowercase];
    
    //用户图像
    NSString *friendNameString = self.sectionArray[indexPath.section][indexPath.row];
    NSArray *friendArray = [[myAppDataBase sharedInstance]getAllUserInformationWith:RecoredTypeAttention];
    NSString *myFirendNameString = [[NSString alloc]init];
    for(NSDictionary *friendInformationDict in friendArray)
    {
        
        NSString *rmkNameString = friendInformationDict[@"rmkName"];
        if(rmkNameString.length != 0)
        {
            if([rmkNameString rangeOfString:@" "].location != NSNotFound)
            {
                myFirendNameString = [rmkNameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            }
            else
            {
                myFirendNameString = rmkNameString;
            }

        }
        else
        {
            NSString *nickName = friendInformationDict[@"nickName"];
            if([nickName rangeOfString:@" "].location != NSNotFound)
            {
                myFirendNameString = [nickName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            }
            else
            {
                myFirendNameString = nickName;
            }

        }
        
        NSString *outputPinyin=[PinyinHelper toHanyuPinyinStringWithNSString:myFirendNameString withHanyuPinyinOutputFormat:outputFormat withNSString:@" "];
        if([friendNameString isEqualToString:outputPinyin])
        {
            [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:friendInformationDict[@"portrait"]]];
            cell.iconImageView.layer.cornerRadius = (SCREENHEIGHT*0.1-10)/2;
            cell.iconImageView.layer.masksToBounds = YES;
            cell.nameLabel.text = myFirendNameString;
            cell.nameLabel.backgroundColor = [UIColor clearColor];
            cell.nameLabel.textColor = self.tableTextColor;
            cell.contentView.backgroundColor = self.tableColor;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        
        
    }
    
    return cell;
    
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.titleArray[section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREENHEIGHT*0.1;
}

//当选择一个单元格的时候执行
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //将汉字转为拼音
    HanyuPinyinOutputFormat *outputFormat=[[HanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];
    [outputFormat setVCharType:VCharTypeWithV];
    [outputFormat setCaseType:CaseTypeLowercase];
    
    //用户图像
    NSString *friendNameString = self.sectionArray[indexPath.section][indexPath.row];
    NSArray *friendArray = [[myAppDataBase sharedInstance]getAllUserInformationWith:RecoredTypeAttention];
    NSString *myFirendNameString = [[NSString alloc]init];
    for(NSDictionary *friendInformationDict in friendArray)
    {
        
        NSString *rmkNameString = friendInformationDict[@"rmkName"];
        if(rmkNameString.length != 0)
        {
            if([rmkNameString rangeOfString:@" "].location != NSNotFound)
            {
                myFirendNameString = [rmkNameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            }
            else
            {
                myFirendNameString = rmkNameString;
            }
        }
        else
        {
            NSString *nickName = friendInformationDict[@"nickName"];
            if([nickName rangeOfString:@" "].location != NSNotFound)
            {
                myFirendNameString = [nickName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            }
            else
            {
                myFirendNameString = nickName;
            }

        }
        
        NSString *outputPinyin=[PinyinHelper toHanyuPinyinStringWithNSString:myFirendNameString withHanyuPinyinOutputFormat:outputFormat withNSString:@" "];
        if([friendNameString isEqualToString:outputPinyin])
        {
            [self.selectedFriendsArray addObject:friendInformationDict[@"frdID"]];
        }
    }
    NSLog(@"选择的好友111111%@",self.selectedFriendsArray);

}
//当取消选择一个单元格的时候执行
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //将汉字转为拼音
    HanyuPinyinOutputFormat *outputFormat=[[HanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];
    [outputFormat setVCharType:VCharTypeWithV];
    [outputFormat setCaseType:CaseTypeLowercase];
    
    //用户图像
    NSString *friendNameString = self.sectionArray[indexPath.section][indexPath.row];
    NSArray *friendArray = [[myAppDataBase sharedInstance]getAllUserInformationWith:RecoredTypeAttention];
    NSString *myFirendNameString = [[NSString alloc]init];
    for(NSDictionary *friendInformationDict in friendArray)
    {
        
        NSString *rmkNameString = friendInformationDict[@"rmkName"];
        if(rmkNameString.length != 0)
        {
            if([rmkNameString rangeOfString:@" "].location != NSNotFound)
            {
                myFirendNameString = [rmkNameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            }
            else
            {
                myFirendNameString = rmkNameString;
            }
        }
        else
        {
            NSString *nickName = friendInformationDict[@"nickName"];
            if([nickName rangeOfString:@" "].location != NSNotFound)
            {
                myFirendNameString = [nickName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            }
            else
            {
                myFirendNameString = nickName;
            }

        }
        
        NSString *outputPinyin=[PinyinHelper toHanyuPinyinStringWithNSString:myFirendNameString withHanyuPinyinOutputFormat:outputFormat withNSString:@" "];
        if([friendNameString isEqualToString:outputPinyin])
        {
            [self.selectedFriendsArray removeObject:friendInformationDict[@"frdID"]];
        }
        
        
    }

    NSLog(@"选择的好友2222222222%@",self.selectedFriendsArray);
}

//修改单元格cell的编辑风格
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleInsert|UITableViewCellEditingStyleDelete;
    return UITableViewCellEditingStyleNone;
}


//- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
//    headerView.tintColor = self.tableHeaderColor;
//    headerView.textLabel.textColor = self.tableHeaderTextColor;
//    headerView.textLabel.font = [UIFont fontWithName:self.indexView.selectedItemFont.fontName size:headerView.textLabel.font.pointSize];
//    [[headerView textLabel] setText:[NSString stringWithFormat:@"     %@",[self firstLetter:section]]];
//    return headerView;
//}


#pragma mark building sectionArray for the tableView
- (NSString *)categoryNameAtIndexPath: (NSIndexPath *)path
{
    NSArray *currentItems = self.sectionArray[path.section];
    NSString *category = currentItems[path.row];
    return category;
}

//mark
- (int) countFirstLettersInArray:(NSArray *)categoryArray
{
    NSMutableArray *existingLetters = [NSMutableArray array];
    for (NSString *name in categoryArray){
        NSString *firstLetterInName = [name substringToIndex:1];
        // NSLog(@"嘿嘿****************************%@",firstLetterInName);
        NSCharacterSet *notAllowed = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz"] invertedSet];
        NSRange range = [firstLetterInName rangeOfCharacterFromSet:notAllowed];
        
        if (![existingLetters containsObject:firstLetterInName] && range.location == NSNotFound ) {
            [existingLetters addObject:firstLetterInName];
            
            //根据好友数据元素得到好友索引列表
            self.alphaString = [self.alphaString stringByAppendingString:firstLetterInName];
            // NSLog(@"heiheiheiehieheieheiheieheih%@",self.alphaString);
        }
    }
    //  NSLog(@"数组个数个数个数个数个数个数个数%ld",[existingLetters count]);
    return [existingLetters count];
}


//mark
- (NSArray *) itemsInSection: (NSInteger)section
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF beginswith[cd] %@",[self firstLetter:section]];
    return [self.crayons filteredArrayUsingPredicate:predicate];
}

//mark
- (NSString *) firstLetter: (NSInteger) section
{
    return [[self.alphaString substringFromIndex:section] substringToIndex:1];
}


#pragma mark MJMIndexForTableView datasource methods
- (NSArray *)sectionIndexTitlesForMJNIndexView:(MJNIndexView *)indexView
{
    NSMutableArray *results = [NSMutableArray array];
    
    for (int i = 0; i < [self.alphaString length]; i++)
    {
        //NSLog(@"哈哈______%@",self.alphaString);
        NSString *substr = [self.alphaString substringWithRange:NSMakeRange(i,1)];
        [results addObject:substr];
    }
    self.titleArray = results;
    return results;
    
}


- (void)sectionForSectionMJNIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    
    //tableView上面的滚动  当选择索引上面一个字符的时候 表格视图自动滚动到索引所指向的区域  表格视图的显示
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:index] atScrollPosition: UITableViewScrollPositionTop animated:YES];
}

////webSocket  代理
//-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
//{
//    //拉好友创建组之后 得到聊天的gname
//    NSString *messageString = message;
//    NSDictionary *dict = [messageString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
//    //聊天gname
//    NSString *gnameString = dict[@"gname"];
//    
//    //传递gname参数
//    _gname = [[NSString alloc]init];
//    _gname = gnameString;
//}



-(void)createUINav
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [ZCControl createLabelWithFrame:CGRectMake(0, 0, 100, 30) Font:22 Text:@"拉好友"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    //导航栏左按钮
    UIButton *imageLeftButton  =[ZCControl createButtonWithFrame:CGRectMake(0, 0, 25, 20) ImageName:@"" Target:self Action:@selector(imageLeftItemBtn) Title:nil];
    [imageLeftButton setImage:[UIImage imageNamed:@"店铺-店铺详情_03"] forState:UIControlStateNormal];
    UIBarButtonItem *imageLeftItem = [[UIBarButtonItem alloc]initWithCustomView:imageLeftButton];
    self.navigationItem.leftBarButtonItem = imageLeftItem;
    
    //导航栏右按钮
    UIButton *rightButton = [ZCControl createButtonWithFrame:CGRectMake(0, 0, 40, 50) ImageName:@"" Target:self Action:@selector(rightItemBtn:) Title:@"完成"];
    //[rightButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}
-(void)imageLeftItemBtn
{
    [self.navigationController popViewControllerAnimated:YES];
}

//导航右按钮的点击
-(void)rightItemBtn:(UIButton *)button
{
    //跳转到聊天界面上面去
    NSArray *array = [[myAppDataBase sharedInstance]getAllUserInformationWith:RecoredTypeAttention];
    if(array.count == 0)
    {
    }
    else
    {
    NSArray *array = self.navigationController.viewControllers;
    NSString *userString = [[NSUserDefaults standardUserDefaults]objectForKey:UserAccount];
    if(array[1] == self)
    {
         //这里都是为创建讨论组 (需要区分创建的时候是单聊还是群聊)
        
        //单聊
        if(self.selectedFriendsArray.count == 1)
        {
            //在退出之前需要把选择一起逛的好友的gname进行传递
            [self.YB_GnameDelegate YBChangeGroupTableViewReloadData];
            [self.YB_GnameDelegate YBgetWebSocketGname:self.selectedFriendsArray[0]];
            
            //加入喵喵表中
            NSString *otherUserString = [NSString stringWithFormat:@"%@",self.selectedFriendsArray[0]];
            NSString *messageGname = [[NSString alloc]init];
            if(userString.intValue > otherUserString.intValue)
            {
                messageGname = [NSString stringWithFormat:@"e2e_%@_%@",userString,otherUserString];
            }
            else
            {
                messageGname = [NSString stringWithFormat:@"e2e_%@_%@",otherUserString,userString];
            }
            NSMutableDictionary *adddict = [[NSMutableDictionary alloc]init];
            
            NSNumber *idNumber = [[NSNumber alloc]initWithInt:otherUserString.intValue];
            [adddict setObject:idNumber forKey:@"senderID"];
            
            [adddict setObject:@"3" forKey:@"miaomiaoTypeID"];
            [adddict setObject:@"" forKey:@"portrait"];
            [adddict setObject:@"" forKey:@"name"];
            [adddict setObject:messageGname forKey:@"remark"];
            
            //表示新增加的未读消息
            [adddict setObject:@"1" forKey:@"unread"];
            [adddict setObject:@"" forKey:@"users"];
 
            if([[myAppDataBase sharedInstance]isExistMiaomiaoChatRecordWithSenderID:idNumber miaomiaoType:@"3" gname:messageGname])
            {
                [[myAppDataBase sharedInstance]deleteMiaoMiaoChatRecordWithSenderID:idNumber miaomiaoType:@"3" gname:messageGname];
            }
            [[myAppDataBase sharedInstance]addMiaoMiaoReordWithDicitionary:adddict recordType:RecoredTypeAttention];
            
        }
        else
        {
            [socketManager YBCreateGroupWithMasterUser:userString andPullInOthers:self.selectedFriendsArray];
            [self.YB_GnameDelegate YBChangeGroupTableViewReloadData];
            
        }
        
    }
    else if (array[2] == self)
    {
        //这里都是为创建讨论组 (需要区分创建的时候是单聊还是群聊)
        
        //单聊
        if(self.selectedFriendsArray.count == 1)
        {
            //在退出之前需要把选择一起逛的好友的gname进行传递
            [self.YB_GnameDelegate YBChangeGroupTableViewReloadData];
            [self.YB_GnameDelegate YBgetWebSocketGname:self.selectedFriendsArray[0]];
            
            //在退出之前需要把选择一起逛的好友的gname进行传递
            //[self.YB_GnameDelegate YBgetWebSocketGname:self.selectedFriendsArray[0]];
            
            //加入喵喵表中
            NSString *otherUserString = self.selectedFriendsArray[0];
            NSString *messageGname = [[NSString alloc]init];
            if(userString.intValue > otherUserString.intValue)
            {
                messageGname = [NSString stringWithFormat:@"e2e_%@_%@",userString,otherUserString];
            }
            else
            {
                messageGname = [NSString stringWithFormat:@"e2e_%@_%@",otherUserString,userString];
            }
            NSMutableDictionary *adddict = [[NSMutableDictionary alloc]init];
            
            NSNumber *idNumber = [[NSNumber alloc]initWithInt:otherUserString.intValue];
            [adddict setObject:idNumber forKey:@"senderID"];
            
            [adddict setObject:@"3" forKey:@"miaomiaoTypeID"];
            [adddict setObject:@"" forKey:@"portrait"];
            [adddict setObject:@"" forKey:@"name"];
            [adddict setObject:messageGname forKey:@"remark"];
            
            //表示新增加的未读消息
            [adddict setObject:@"1" forKey:@"unread"];
            [adddict setObject:@"" forKey:@"users"];
            
            if([[myAppDataBase sharedInstance]isExistMiaomiaoChatRecordWithSenderID:idNumber miaomiaoType:@"3" gname:messageGname])
            {
                [[myAppDataBase sharedInstance]deleteMiaoMiaoChatRecordWithSenderID:idNumber miaomiaoType:@"3" gname:messageGname];
            }
            [[myAppDataBase sharedInstance]addMiaoMiaoReordWithDicitionary:adddict recordType:RecoredTypeAttention];
            
        }
        else
        {
            [socketManager YBCreateGroupWithMasterUser:userString andPullInOthers:self.selectedFriendsArray];
             [self.YB_GnameDelegate YBChangeGroupTableViewReloadData];
        }

    }
   else if (array[3] == self)
   {
       //这里都是为创建讨论组 (需要区分创建的时候是单聊还是群聊)
       
       //单聊
       if(self.selectedFriendsArray.count == 1)
       {
           //在退出之前需要把选择一起逛的好友的gname进行传递
           [self.YB_GnameDelegate YBChangeGroupTableViewReloadData];
           [self.YB_GnameDelegate YBgetWebSocketGname:self.selectedFriendsArray[0]];
           
           //在退出之前需要把选择一起逛的好友的gname进行传递
           //[self.YB_GnameDelegate YBgetWebSocketGname:self.selectedFriendsArray[0]];
           
           //加入喵喵表中
           NSString *otherUserString = self.selectedFriendsArray[0];
           NSString *messageGname = [[NSString alloc]init];
           if(userString.intValue > otherUserString.intValue)
           {
               messageGname = [NSString stringWithFormat:@"e2e_%@_%@",userString,otherUserString];
           }
           else
           {
               messageGname = [NSString stringWithFormat:@"e2e_%@_%@",otherUserString,userString];
           }
           NSMutableDictionary *adddict = [[NSMutableDictionary alloc]init];
           
           NSNumber *idNumber = [[NSNumber alloc]initWithInt:otherUserString.intValue];
           [adddict setObject:idNumber forKey:@"senderID"];
           
           [adddict setObject:@"3" forKey:@"miaomiaoTypeID"];
           [adddict setObject:@"" forKey:@"portrait"];
           [adddict setObject:@"" forKey:@"name"];
           [adddict setObject:messageGname forKey:@"remark"];
           
           //表示新增加的未读消息
           [adddict setObject:@"1" forKey:@"unread"];
           [adddict setObject:@"" forKey:@"users"];
           
           if([[myAppDataBase sharedInstance]isExistMiaomiaoChatRecordWithSenderID:idNumber miaomiaoType:@"3" gname:messageGname])
           {
               [[myAppDataBase sharedInstance]deleteMiaoMiaoChatRecordWithSenderID:idNumber miaomiaoType:@"3" gname:messageGname];
           }
           [[myAppDataBase sharedInstance]addMiaoMiaoReordWithDicitionary:adddict recordType:RecoredTypeAttention];
           
       }
       else
       {
           [socketManager YBCreateGroupWithMasterUser:userString andPullInOthers:self.selectedFriendsArray];
            [self.YB_GnameDelegate YBChangeGroupTableViewReloadData];
       }

   }
    else if(array[4] == self)
    {
        //选择完好友之后 拉好友进组 创建用户组 调用webSocket协议
        if([array[3] isKindOfClass:[miaomiaoChatGroupSettingViewController class]])
        {
        //这里需要区分是否为创建讨论组
        if([self.usersIDString isEqualToString:@""])
        {
            //加入单聊时候的ID
            [self.selectedFriendsArray addObject:self.senderIDString];
            [socketManager YBCreateGroupWithMasterUser:userString andPullInOthers:self.selectedFriendsArray];
            
        }
        //群聊中继续拉别人
        else
        {
            [socketManager YBPullInUsersToGroupWithGname:self.gnameString andOtherUsersArray:self.selectedFriendsArray];
        }
        }
        else
        {
            
            if(self.selectedFriendsArray.count == 1)
            {
                //在退出之前需要把选择一起逛的好友的gname进行传递
                [self.YB_GnameDelegate YBChangeGroupTableViewReloadData];
                [self.YB_GnameDelegate YBgetWebSocketGname:self.selectedFriendsArray[0]];
                
                //在退出之前需要把选择一起逛的好友的gname进行传递
                //[self.YB_GnameDelegate YBgetWebSocketGname:self.selectedFriendsArray[0]];
                
                //加入喵喵表中
                NSString *otherUserString = self.selectedFriendsArray[0];
                NSString *messageGname = [[NSString alloc]init];
                if(userString.intValue > otherUserString.intValue)
                {
                    messageGname = [NSString stringWithFormat:@"e2e_%@_%@",userString,otherUserString];
                }
                else
                {
                    messageGname = [NSString stringWithFormat:@"e2e_%@_%@",otherUserString,userString];
                }
                NSMutableDictionary *adddict = [[NSMutableDictionary alloc]init];
                
                NSNumber *idNumber = [[NSNumber alloc]initWithInt:otherUserString.intValue];
                [adddict setObject:idNumber forKey:@"senderID"];
                
                [adddict setObject:@"3" forKey:@"miaomiaoTypeID"];
                [adddict setObject:@"" forKey:@"portrait"];
                [adddict setObject:@"" forKey:@"name"];
                [adddict setObject:messageGname forKey:@"remark"];
                
                //表示新增加的未读消息
                [adddict setObject:@"1" forKey:@"unread"];
                [adddict setObject:@"" forKey:@"users"];
                
                if([[myAppDataBase sharedInstance]isExistMiaomiaoChatRecordWithSenderID:idNumber miaomiaoType:@"3" gname:messageGname])
                {
                    [[myAppDataBase sharedInstance]deleteMiaoMiaoChatRecordWithSenderID:idNumber miaomiaoType:@"3" gname:messageGname];
                }
                [[myAppDataBase sharedInstance]addMiaoMiaoReordWithDicitionary:adddict recordType:RecoredTypeAttention];
                
            }
            else
            {
                [socketManager YBCreateGroupWithMasterUser:userString andPullInOthers:self.selectedFriendsArray];
                [self.YB_GnameDelegate YBChangeGroupTableViewReloadData];
            }

        }
        
    }
   else if (array[5] == self)
   {
       //这里需要区分是否为创建讨论组
       if([self.usersIDString isEqualToString:@""])
       {
           //加入单聊时候的ID
           [self.selectedFriendsArray addObject:self.senderIDString];
           [socketManager YBCreateGroupWithMasterUser:userString andPullInOthers:self.selectedFriendsArray];
           
       }
       //群聊中继续拉别人
       else
       {
           [socketManager YBPullInUsersToGroupWithGname:self.gnameString andOtherUsersArray:self.selectedFriendsArray];
       }

   }
        
        else if (array[7] == self)
        {
            //这里需要区分是否为创建讨论组
            if([self.usersIDString isEqualToString:@""])
            {
                //加入单聊时候的ID
                [self.selectedFriendsArray addObject:self.senderIDString];
                [socketManager YBCreateGroupWithMasterUser:userString andPullInOthers:self.selectedFriendsArray];
                
            }
            //群聊中继续拉别人
            else
            {
                [socketManager YBPullInUsersToGroupWithGname:self.gnameString andOtherUsersArray:self.selectedFriendsArray];
            }

        }
   else if (array[9] == self)
   {
       //这里需要区分是否为创建讨论组
       if([self.usersIDString isEqualToString:@""])
       {
           //加入单聊时候的ID
           [self.selectedFriendsArray addObject:self.senderIDString];
           [socketManager YBCreateGroupWithMasterUser:userString andPullInOthers:self.selectedFriendsArray];
           
       }
       //群聊中继续拉别人
       else
       {
           [socketManager YBPullInUsersToGroupWithGname:self.gnameString andOtherUsersArray:self.selectedFriendsArray];
       }

   }
    else if (array[12] == self)
    {
        //这里需要区分是否为创建讨论组
        if([self.usersIDString isEqualToString:@""])
        {
            //加入单聊时候的ID
            [self.selectedFriendsArray addObject:self.senderIDString];
            [socketManager YBCreateGroupWithMasterUser:userString andPullInOthers:self.selectedFriendsArray];
            
        }
        //群聊中继续拉别人
        else
        {
            [socketManager YBPullInUsersToGroupWithGname:self.gnameString andOtherUsersArray:self.selectedFriendsArray];
        }

    }
        
    if(array[1] == self)
    {
        
        [self.navigationController popViewControllerAnimated:YES];

    }
    else if(array[2] == self)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (array[3] == self)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(array[4] == self)
    {
        
        if([array[3] isKindOfClass:[miaomiaoChatGroupSettingViewController class]])
        {
        UIViewController *chatVC = array[1];
        [self.navigationController popToViewController:chatVC animated:YES];
        }
        
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
        else if (array[5] == self)
        {
            miaomiaoViewController *chatVC = [[miaomiaoViewController alloc]init];
            [self.navigationController pushViewController:chatVC animated:YES];
        }
        else if (array[7] == self)
        {
            UIViewController *chatVC = array[1];
            [self.navigationController popToViewController:chatVC animated:YES];
        }
        else if (array[9] == self)
        {
            UIViewController *chatVc = array[6];
            [self.navigationController popToViewController:chatVc animated:YES];
        }
        else if (array[12] == self)
        {
            UIViewController *chatVc = array[6];
            [self.navigationController popToViewController:chatVc animated:YES];
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
