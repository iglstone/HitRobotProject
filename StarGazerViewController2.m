//
//  StarGazerViewController2.m
//  HitProject
//
//  Created by 郭龙 on 16/4/25.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "StarGazerViewController2.h"


@interface StarGazerViewController2 () <UIPickerViewDelegate, UIPickerViewDataSource>
{
    ServerSocket *server;
}
@property (strong, nonatomic) IBOutlet UITextField *inputMarkHeight;
@property (strong, nonatomic) IBOutlet UITextField *inputNumOfLandmark;
@property (strong, nonatomic) IBOutlet UITextField *inputReferenceID;
@property (strong, nonatomic) IBOutlet UITextField *labelSendData;
@property (strong, nonatomic) IBOutlet UIPickerView *markTypePickview;

@end

@implementation StarGazerViewController2
#pragma mark - lifeCicle
- (void)viewDidLoad {
    [super viewDidLoad];
    server = [ServerSocket sharedSocket];
    self.markTypePickview.delegate = self;
    self.markTypePickview.dataSource = self;
    // Do any additional setup after loading the view from its nib.
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

#pragma mark - delegates
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 6;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSArray *MarkTypeArrays = @[@"xxx",@"ooo",@"ooo",@"ccc",@"ggg",@"eee"];
    return [MarkTypeArrays objectAtIndex:row];
}

#pragma mark - cmds
- (IBAction)calcStop:(id)sender {
    [server sendMessage:[self stringOfPara:@"CalcStop" num:nil] debugstring:@"停止计算"];
}

- (IBAction)sendNumOfMark:(id)sender {
    NSString *numOfMark = self.inputNumOfLandmark.text;
    if (numOfMark.length > 0) {
        NSInteger num = [numOfMark integerValue];
        if (num <= 0) {
            return;
        }
        NSLog(@"sendNumOfMark %@",[self stringOfPara:@"IDNum" num:numOfMark]);
        [server sendMessage:[self stringOfPara:@"IDNum" num:numOfMark] debugstring:@"发送定标数"];
    }
}

- (IBAction)sendReferenceID:(id)sender {
    NSString *reference = self.inputReferenceID.text;
    if (reference.length > 0) {
        NSInteger num = [reference integerValue];
        if (num <= 0) {
            return;
        }
        NSLog(@"sendNumOfMark %@",[self stringOfPara:@"RefID" num:reference]);
        [server sendMessage:[self stringOfPara:@"IDNum" num:reference] debugstring:@"发送初始ID"];
    }
}

- (IBAction)senHeightFixYes:(id)sender {
    [server sendMessage:[self stringOfPara:@"HeightFix" num:@"Yes"] debugstring:@"发送高度固定"];
}

- (IBAction)sendHeightFixNo:(id)sender {
    [server sendMessage:[self stringOfPara:@"HeightFix" num:@"No"] debugstring:@"发送高度不固定"];
}

- (IBAction)sendMarkHeight:(id)sender {
    NSString *height = self.inputMarkHeight.text;
    if (height.length <= 3) {
        NSLog(@"args error");
        return;
    }
    [server sendMessage:[self stringOfPara:@"MarkHeight" num:height] debugstring:@"发送顶标高度"];
}

- (IBAction)sendMarkType:(id)sender {
}

- (IBAction)sendMarkModeAlone:(id)sender {
    [server sendMessage:[self stringOfPara:@"MarkMode" num:@"Alone"] debugstring:@"发送定标独立模式"];
}

- (IBAction)sendMarkModeMap:(id)sender {
    [server sendMessage:[self stringOfPara:@"MarkMode" num:@"Map"] debugstring:@"发送定标独立模式"];
}

- (IBAction)setEnd:(id)sender {
    [server sendMessage:[self stringOfPara:@"SetEnd" num:nil] debugstring:@"设置完成"];
}

- (IBAction)HeightMeasureStart:(id)sender {
}

- (IBAction)mapBuildingProcessStart:(id)sender {
    [server sendMessage:[self stringOfPara:@"MapMode" num:@"Start"] debugstring:@"地图构建"];
}

- (IBAction)calcStart:(id)sender {
    [server sendMessage:[self stringOfPara:@"CalcStart" num:nil] debugstring:@"开始计算"];
}

#pragma mark - privateMotheds
- (NSString *)stringOfPara:(NSString *)paraString num:(NSString *)numString {
    NSString *tmp;
    if (numString == nil) {
        tmp = [NSString stringWithFormat:@"~#%@", paraString];
    }else
        tmp = [NSString stringWithFormat:@"~#%@|%@", paraString, numString];
    self.labelSendData.text = tmp;
    return tmp;
}

@end
