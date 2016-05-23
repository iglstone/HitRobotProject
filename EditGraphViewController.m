//
//  EditGraphViewController.m
//  HitProject
//
//  Created by 郭龙 on 16/5/23.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "DataCenter.h"
#import "EditGraphViewController.h"

@interface EditGraphCell : UITableViewCell
@property (nonatomic) UILabel *pointIndexL;
@property (nonatomic) UITextField *pointXYT;            // seprate by ‘,’
@property (nonatomic) UITextField *pointAngelT;
@property (nonatomic) UITextField *pointJointsT;        //must bigger, seprate by ','
@property (nonatomic) UITextField *pointJointAngelsT;   // seprate by ‘,’

@end

@implementation EditGraphCell
#define SUBWIDTH 150
#define SUBHEIGHT 45

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _pointIndexL = [UILabel new];
        _pointIndexL.text = @"0";
        _pointIndexL.textAlignment = NSTextAlignmentCenter;
        _pointIndexL.backgroundColor = [UIColor orangeColor];
        [self.contentView addSubview:_pointIndexL];
        
        _pointXYT = [UITextField new];
        _pointXYT.placeholder = @"input x,y";
        [self.contentView addSubview:_pointXYT];
        
        _pointAngelT = [UITextField new];
        _pointAngelT.placeholder = @"input angel";
        [self.contentView addSubview:_pointAngelT];
        
        _pointJointsT = [UITextField new];
        _pointJointsT.placeholder = @"input Joints";
        [self.contentView addSubview:_pointJointsT];
        
        _pointJointAngelsT = [UITextField new];
        _pointJointAngelsT.placeholder = @"input Joints angels";
        [self.contentView addSubview:_pointJointAngelsT];
        
        [_pointIndexL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(SUBWIDTH , SUBHEIGHT));
        }];
        
        [_pointXYT mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_pointIndexL.mas_right).offset(20);
            make.size.mas_equalTo(CGSizeMake(SUBWIDTH , SUBHEIGHT));
        }];
        
        [_pointAngelT mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_pointXYT.mas_right).offset(20);
            make.size.mas_equalTo(CGSizeMake(SUBWIDTH , SUBHEIGHT));
        }];
        
        [_pointJointsT mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_pointAngelT.mas_right).offset(20);
            make.size.mas_equalTo(CGSizeMake(SUBWIDTH , SUBHEIGHT));
        }];
        [_pointJointAngelsT mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_pointJointsT.mas_right).offset(20);
            make.size.mas_equalTo(CGSizeMake(SUBWIDTH , SUBHEIGHT));
        }];
        
        return self;
    }
    return nil;
}

@end

@interface EditGraphViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *m_tableView;
    NSInteger screenW;
    NSInteger screenH;
    DataCenter *dataCenter;
}
@end
@implementation EditGraphViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    screenW =[[UIScreen mainScreen] bounds].size.width;
    screenH = [[UIScreen mainScreen] bounds].size.height;
    m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(50, 49, screenW - 100 , screenH - 49 *2 ) style:UITableViewStylePlain];
    [self.view addSubview:m_tableView];
    m_tableView.backgroundColor = [UIColor whiteColor];
    m_tableView.dataSource = self;
    m_tableView.delegate = self;
    
    dataCenter = [DataCenter new];
    
    UIButton *cancelBtn = [UIButton new];
    cancelBtn.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:cancelBtn];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10);
        make.left.equalTo(self.view).offset(20);
        make.width.mas_equalTo(@100);
    }];
    [cancelBtn addTarget:self action:@selector(btnTaped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *doneBtn = [UIButton new];
    doneBtn.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:doneBtn];
    [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    [doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cancelBtn);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.width.mas_equalTo(cancelBtn);
    }];
    [doneBtn addTarget:self action:@selector(btnTaped:) forControlEvents:UIControlEventTouchUpInside];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *st = @"tableOfEdit";
    EditGraphCell *cell = [tableView dequeueReusableCellWithIdentifier:st];
    if (cell == nil) {
        cell = [[EditGraphCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:st];
    }
    cell.pointIndexL.text = [NSString stringWithFormat:@"%ld", indexPath.row];// indexPath.row;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataCenter getGraphArr].count == 0 ? 4 : [dataCenter getGraphArr].count;
}

- (void) btnTaped:(UIButton *)btn {
    NSString *title = btn.titleLabel.text;
    if ([title isEqualToString:@"完成"]) {
        NSMutableArray *dicsArr = [NSMutableArray new];
        NSArray *keyArr = @[@"ptXY", @"ptAngel", @"ptJoints", @"ptJointsAngels"];
        for (int i = 0; i < [dataCenter getVexsNum]; i++) {
            EditGraphCell *cell = [m_tableView cellForRowAtIndexPath:[NSIndexPath indexPathWithIndex:i]];
            NSString *xy = cell.pointXYT.text;
            NSString *angel = cell.pointAngelT.text;
            NSString *joints = cell.pointJointsT.text;
            NSString *jointsAngels = cell.pointJointAngelsT.text;
            if (!xy || !angel || !joints || !jointsAngels) {
                [self.view makeToast:@"参数有缺失" duration:1.5 position:CSToastPositionCenter];
                return;
            }
            NSDictionary *dic = @{keyArr[0]:xy, keyArr[1]:angel, keyArr[2]:joints, keyArr[3]: jointsAngels};
            [dicsArr addObject:dic];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_EDITGRAPHINFO object:nil  userInfo:@{@"dicsArr":dicsArr}];
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    if ([title isEqualToString:@"取消"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end




@interface SettingViewController ()
{
    NSInteger screenW;
    NSInteger screenH;
}
@end
@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    screenW =[[UIScreen mainScreen] bounds].size.width;
    screenH = [[UIScreen mainScreen] bounds].size.height;
    
    UIButton *cancelBtn = [UIButton new];
    cancelBtn.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:cancelBtn];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10);
        make.left.equalTo(self.view).offset(20);
        make.width.mas_equalTo(@100);
    }];
    [cancelBtn addTarget:self action:@selector(btnTaped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *doneBtn = [UIButton new];
    doneBtn.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:doneBtn];
    [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    [doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cancelBtn);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.width.mas_equalTo(cancelBtn);
    }];
    [doneBtn addTarget:self action:@selector(btnTaped:) forControlEvents:UIControlEventTouchUpInside];
    
    
    int i = 0;
    NSArray *arr = @[@"点个数", @"地图宽度(cm)", @"地图长度(cm)"];
    NSArray *arrTag = @[@"100", @"101", @"102"];
    NSArray *arr2 = @[@">=3", @"1000", @"500"];
    for (i = 0 ; i < arr.count; i++) {
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentCenter ;
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view.mas_centerX).offset(-20);
            make.top.equalTo(self.view.mas_top).offset(40 + 65 *i);
            make.size.mas_equalTo(CGSizeMake(120, 45));
        }];
        
        UITextField *text = [UITextField new];
        [self.view addSubview:text];
        text.tag = [arrTag[i] integerValue];
        text.placeholder = arr2[i] ;
        [text mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_centerX).offset(20);
            make.top.equalTo(label);
            make.size.mas_equalTo(label);
        }];
    }
    
}

- (void) btnTaped:(UIButton *)btn {
    NSString *title = btn.titleLabel.text;
    if ([title isEqualToString:@"完成"]) {
        NSArray *keyArr = @[@"vexs", @"mapW", @"mapH"];
        NSDictionary *dic = [NSDictionary new];
        for (int i = 0; i < keyArr.count; i++) {
            UITextField *te = (UITextField *) [self.view viewWithTag:100 + i];
            if (te.text.length == 0 || [te.text isEqualToString:@"0"]) {
                [self.view makeToast:@"参数不完整" duration:1.2 position:CSToastPositionCenter];
                return;
            }
            [dic setValue:te.text forKey:keyArr[i]];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_SETTINGINFOMATION object:nil userInfo:dic];
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    if ([title isEqualToString:@"取消"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

