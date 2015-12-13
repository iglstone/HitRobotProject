//
//  PickDeskNumViewController.m
//  HitProject
//
//  Created by 郭龙 on 15/12/2.
//  Copyright © 2015年 郭龙. All rights reserved.
//

#import "PickDeskNumViewController.h"

@interface PickDeskNumViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
{
    UIPickerView *pickView;
    NSMutableArray *pickerArray;
}

@end

@implementation PickDeskNumViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择桌数";
    self.view.backgroundColor = [CommonsFunc colorOfSystemBackground];
    NSInteger screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    pickerArray = [NSMutableArray new];
    for (int i = 1; i <= 60 ;i++) {
        NSString *st = [NSString stringWithFormat:@"%d 桌", i];
        [pickerArray addObject:st];
    }

    pickView = [UIPickerView new];
    [self.view addSubview:pickView];
    [pickView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(@(screenHeight/2));
    }];
    pickView.dataSource = self;
    pickView.delegate = self;
    pickView.showsSelectionIndicator = YES;
    [pickView selectRow:9 inComponent:0 animated:NO];
    
    UILabel *label = [UILabel new];
    [self.view addSubview:label];
    label.text = @"选择完成请点击右上角 “确定” 按钮";
    label.textColor =[UIColor lightGrayColor];
    label.font = [UIFont systemFontOfSize:14];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pickView.mas_bottom).offset(20);
        make.centerX.equalTo(pickView);
    }];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(done:)];
    self.navigationItem.rightBarButtonItem = right;
    right.tintColor = [UIColor darkGrayColor];
}

- (void)done :(id)sender {
    NSInteger row = [pickView selectedRowInComponent:0];
    NSString *string = [pickerArray objectAtIndex:row];
    NSInteger desknum = [[string substringWithRange:NSMakeRange(0, [string length]-2)] integerValue];
    NSLog(@"您选择的是 %@ ,,%ld",string,desknum);
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_PICKDESKNUM object:nil userInfo:@{@"desknum":@(desknum)}];
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [pickerArray count];
}

-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [pickerArray objectAtIndex:row];
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
