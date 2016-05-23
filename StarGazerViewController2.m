//
//  StarGazerViewController2.m
//  HitProject
//
//  Created by 郭龙 on 16/4/25.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "StarGazerViewController2.h"


#define CALCSTOPTAG  101
#define CALCSTARTTAG 102
#define POINTRADIUS  7
#define DRAWVIEWWIDTH 200
#define DRAWVIEWHEIGHT 100


@interface StarGazerViewController2 () <UIPickerViewDelegate, UIPickerViewDataSource>
{
    ServerSocket *server;
    NSString *longString;
    UIView *drawView;
    CAShapeLayer *pointShapeLayer;
    UIBezierPath *pointPath;
}
@property (strong, nonatomic) IBOutlet UITextField *inputMarkHeight;
@property (strong, nonatomic) IBOutlet UITextField *inputNumOfLandmark;
@property (strong, nonatomic) IBOutlet UITextField *inputReferenceID;
@property (strong, nonatomic) IBOutlet UITextField *labelSendData;
@property (strong, nonatomic) IBOutlet UIPickerView *markTypePickview;
@property (strong, nonatomic) IBOutlet UITextField *outputAck;
@property (strong, nonatomic) IBOutlet UIView *settingContainerView;
@property (strong, nonatomic) IBOutlet UILabel *mapInfoLabel;

@end

@implementation StarGazerViewController2
#pragma mark - lifeCicle
- (void)viewDidLoad {
    [super viewDidLoad];
    server = [ServerSocket sharedSocket];
    self.markTypePickview.delegate = self;
    self.markTypePickview.dataSource = self;
    longString  = nil;
    
    
//    [self setSettingContainerViewEnableNo];
    
    drawView = [UIView new];
    [self.view addSubview:drawView];
    drawView.backgroundColor = [UIColor orangeColor];
    [drawView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.height.mas_equalTo(DRAWVIEWHEIGHT);
        make.width.mas_equalTo(DRAWVIEWWIDTH);
    }];
    
    pointShapeLayer = [CAShapeLayer new];
    pointShapeLayer.strokeColor = [UIColor redColor].CGColor;
    pointPath = [UIBezierPath new];
    [drawView.layer addSublayer:pointShapeLayer];
    
//    [server addObserver:self forKeyPath:@"starGazerAckString" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"starGazerAckString"]) {
        NSString *newString  = [change objectForKey:@"new"];
        longString = [longString stringByAppendingString:[NSString stringWithFormat:@"%@\n",newString]];
        self.outputAck.text = newString;
        self.mapInfoLabel.text = longString;
        
        STModel *model = [STModel stmodelWithString:newString];
        [self drawModelInLayer:model];
    }
}

- (void)drawModelInLayer :(STModel *)model {
    CGPoint pointPosition = CGPointMake(model.modelX, model.modelY);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:[self changePointToDrawView:pointPosition] radius:POINTRADIUS startAngle:0.0 endAngle:2 * M_PI clockwise:0];
    [pointPath appendPath:path];
    pointShapeLayer.path = pointPath.CGPath;
}

- (CGPoint)changePointToDrawView :(CGPoint )pt{
    NSInteger screenW = self.view.frame.size.width;
    NSInteger screenH = self.view.frame.size.height;
    float newX = (DRAWVIEWWIDTH / screenW) * pt.x + (screenW - DRAWVIEWWIDTH);
    float newY = (DRAWVIEWHEIGHT / screenH) * pt.y + (screenH - DRAWVIEWHEIGHT);
    return CGPointMake(newX, newY);
}

- (void)dealloc {
    [server removeObserver:self forKeyPath:@"starGazerAckString"];
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

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSArray *MarkTypeArrays = @[@"3-s",@"3-m",@"3-l",@"4-s",@"4-m",@"4-l"];
    return [MarkTypeArrays objectAtIndex:row];
}

#pragma mark - private methods
- (void)setSettingContainerViewEnableNo {
    for (UIView *view in self.settingContainerView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn =(UIButton *)view;
            btn.enabled = NO;
        }
        view.alpha = 0.4;
    }
    UIButton *stopBtn = (UIButton *) [self.settingContainerView viewWithTag:CALCSTOPTAG];
    stopBtn.enabled = YES;
    stopBtn.alpha = 0;
}

#pragma mark - cmds
- (IBAction)calcStop:(id)sender {
    for (UIView *view in self.settingContainerView.subviews) {
        view.alpha = 0;
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn =(UIButton *)view;
            btn.enabled = YES;
        }
    }
    [server sendMessage:[self stringOfPara:@"CalcStop" num:nil] debugstring:@"停止计算"];
    self.mapInfoLabel.text = nil;//清空
}

- (IBAction)calcStart:(id)sender {
    [self setSettingContainerViewEnableNo];
    [server sendMessage:[self stringOfPara:@"CalcStart" num:nil] debugstring:@"开始计算"];
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
