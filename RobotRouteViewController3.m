//
//  RobotRouteViewController.m
//  TourRobot
//
//  Created by 显示 on 16/5/5.
//  Copyright © 2016年 郭龙. All rights reserved.
//  copy form:http://blog.chinaunix.net/uid-26548237-id-3834873.html

#import "RobotRouteViewController3.h"
#import "RouteHeader.h"
#import "FloydAlgorithm.h"
#import "RouteView.h"
#import "EditGraphViewController.h"
#import "DataCenter.h"
#import "MapInfoViewController.h"

#define TOUCHPINCHTHRESHHOLD 10
#define RIGHTBACKGROUNDVIEWOFSEET 30

@interface RobotRouteViewController3 () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    mGraph m_graph;
    NSMutableArray *m_realPosotionsArray;
    vexAngels vexsAngel;
    vexsPre2DTabel vexsPre2D;
    distancesSum2DTabel distanceSum2D;
    
    UIView *backgroundView;
    NSInteger screenHeight;
    NSInteger screenWidth;
    UIView *tmpPickedView;
    NSArray *deskNameArr;
    UIView *rightContainer;
    NSData *mapImageData ;
    
    DataCenter *sharedData;
    
    RouteView *routeView;
}
@end

@implementation RobotRouteViewController3
#pragma mark - life cicle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    m_realPosotionsArray = [NSMutableArray new];
    screenHeight = [[UIScreen mainScreen] bounds].size.height;
    screenWidth = [[UIScreen mainScreen] bounds].size.width;
    sharedData = [DataCenter sharedDataCenter];
    
    UIEdgeInsets edge = UIEdgeInsetsMake(RIGHTBACKGROUNDVIEWOFSEET, RIGHTBACKGROUNDVIEWOFSEET, RIGHTBACKGROUNDVIEWOFSEET + 49, RIGHTBACKGROUNDVIEWOFSEET);
    self.imgView = [[UIImageView alloc] initWithFrame:UIEdgeInsetsInsetRect(self.view.frame, edge)];
    self.imgView.backgroundColor = [UIColor clearColor];
    self.imgView.contentMode = UIViewContentModeScaleToFill;// UIViewContentModeScaleAspectFit ;
    [self.view addSubview:self.imgView];
    
    mapImageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"mapImageData"];
    UIImage *image = [UIImage imageWithData:mapImageData];
    if (image) {
        self.imgView.image = image ;
    }
    
    backgroundView = [[UIView alloc] initWithFrame:CGRectMake(30, 30, self.imgView.frame.size.width, self.imgView.frame.size.height)];
    backgroundView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:backgroundView];
    
    routeView = [[RouteView alloc] initWithFrame:CGRectMake(0, 0, self.imgView.frame.size.width, self.imgView.frame.size.height)];
    [routeView setCanEdit:YES];
    [backgroundView insertSubview:routeView belowSubview: backgroundView];
    
    [self addBtns];
    [self drawRouteView];
    
    //refresh the draw
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawRouteView) name:NOTI_REFRESHDRAW object:nil];
}

- (void) drawRouteView {
    m_realPosotionsArray = [NSMutableArray arrayWithArray:[sharedData getRealPositionsArr]];
    NSArray *arr = [sharedData getGraphModlesArr];
    [sharedData creatMGragh:&m_graph OfModelsArr:arr];
    
    [FloydAlgorithm initSingelPointIdAndAngel:&vexsAngel withIdAndAngels:[sharedData getAngelsArr]];
    [FloydAlgorithm floydShortestPath:&m_graph pointsTabel:&vexsPre2D shortTable:&distanceSum2D];
    
    NSString *pathTo = [FloydAlgorithm findShortestPath:&m_graph from:0 to:2 pointsTabel:&vexsPre2D robotAngels:&vexsAngel];
    NSString *pathBack = [FloydAlgorithm findShortestPath:&m_graph from:2 to:0 pointsTabel:&vexsPre2D robotAngels:&vexsAngel];
    NSLog(@"pathTo: %@ \n PathBack: %@" , pathTo, pathBack);
    
    [self logSomeThing];
    
    //数据驱动绘图, 需要传很多参数进去
    [routeView drawLineAndPoints:&m_graph withPointsArray:m_realPosotionsArray withTailAngel:&vexsAngel vexsTabel:&vexsPre2D ];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated ];
    UITabBarController *tab = self.tabBarController;
    if ([tab isKindOfClass:[MainViewController class]]) {
        MainViewController *main = (MainViewController *)tab;
        [main hideTabelAndDebugLabel];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    UITabBarController *tab = self.tabBarController;
    if ([tab isKindOfClass:[MainViewController class]]) {
        MainViewController *main = (MainViewController *)tab;
        [main showTabelAndDebugLabel];
    }
}

#pragma mark - delegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *imge = [info objectForKey:@"UIImagePickerControllerOriginalImage"];

    [self dismissViewControllerAnimated:YES completion:^{
        self.imgView.image = imge;
        mapImageData = UIImageJPEGRepresentation(imge, 0.6);
        [[NSUserDefaults standardUserDefaults] setObject:mapImageData forKey:@"mapImageData"];
    }];
}

#pragma mark - addViews
- (void)addBtns {
    rightContainer = [[UIView alloc] initWithFrame:CGRectMake(screenWidth - 120, 20, 100, screenHeight - 49 - 20*2)];
    rightContainer.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:rightContainer];
    
    deskNameArr = @[@"隐藏", @"参数设置", @"选择地图", @"EditGraph", @"隐藏路径", @"201桌", @"202桌", @"203桌",@"204桌"];
    for (int i = 0; i < deskNameArr.count; i++) {
        UIButton *positionBtn = [UIButton new];
        if (i==4) {
            positionBtn.backgroundColor = [UIColor redColor];
        }else
            positionBtn.backgroundColor = [UIColor orangeColor];
        [rightContainer addSubview:positionBtn];
        [positionBtn setTitle:deskNameArr[i] forState:UIControlStateNormal];
        [positionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(20 + 55 * i);
            make.right.equalTo(self.view).offset(-20);
            make.width.mas_equalTo(@100);
        }];
        [positionBtn addTarget:self action:@selector(btnTaped:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - actions
- (void) btnTaped:(UIButton *)btn {
    NSString *title = btn.titleLabel.text;
    if ([btn.titleLabel.text isEqualToString:@"隐藏"]) {
        [btn setTitle:@"显示" forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor redColor];
        
        [UIView beginAnimations:@"ani" context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        rightContainer.frame = CGRectMake(screenWidth - 120, 20, 100, 35);
        [UIView commitAnimations];
        
        for (UIButton *btn in rightContainer.subviews) {
            if ([btn.titleLabel.text isEqualToString:@"显示"]) {
                continue;
            }
            btn.hidden = YES;
        }
        return;
    }
    if ([btn.titleLabel.text isEqualToString:@"显示"]) {
        [btn setTitle:@"隐藏" forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor orangeColor];
        
        [UIView beginAnimations:@"ani" context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        rightContainer.frame = CGRectMake(screenWidth - 120, 20, 100, screenHeight - 49 - 20*2);
        [UIView commitAnimations];
        
        for (UIButton *btn in rightContainer.subviews) {
            if ([btn.titleLabel.text isEqualToString:@"隐藏"]) {
                continue;
            }
            btn.hidden = NO;
        }
        return;
    }
    
    if ([title isEqualToString:@"参数设置"]) {
        [self presentViewController:[MapInfoViewController new] animated:YES completion:nil];
        return;
    }
    
    if ([title isEqualToString:@"选择地图"]) {
        UIImagePickerController *imgPick = [UIImagePickerController new];
        imgPick.delegate = self;
        imgPick.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imgPick.view.backgroundColor = [UIColor whiteColor];
        [self presentViewController:imgPick animated:YES completion:nil];
        return;
    }
    
    if ([title isEqualToString:@"EditGraph"]) {
        EditGraphViewController *edit = [EditGraphViewController new];
        [self presentViewController:edit animated:YES completion:nil];
        return;
    }
    
    if ([title isEqualToString:@"隐藏路径"]) {
        [routeView setCanEdit:NO];
        [btn setTitle:@"显示路径" forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor orangeColor]];
        return;
    }
    
    if ([title isEqualToString:@"显示路径"]) {
        [routeView setCanEdit:YES];
        [routeView saveRoute];
        [btn setTitle:@"隐藏路径" forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor redColor]];
        return;
    }
    
    // send position message
    NSString *deskNum = btn.titleLabel.text;
    NSInteger index = [deskNameArr indexOfObjectPassingTest:^BOOL(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([deskNum isEqualToString:obj]) {
            return YES;
        }
        return NO;
    }];
    if (index != NSNotFound) {
        [[HitControl sharedControl] sendPathToRobot:index ofRealPosition:m_realPosotionsArray ofDeskNum:deskNameArr];
    }
}

- (void)logSomeThing {
    //    NSLog(@"各顶点间最短路径如下：");
    //    [self printShortestPath:&graph pointsTabel:&vexsPre2D shortestTabel:&distanceSum2D];
    
    NSLog(@"最短路劲P：position");
    int v,w;
    for (v = 0; v < m_graph.numVertexes; v++) {
        NSString *t = @"";
        for (w = 0; w < m_graph.numVertexes; w++) {
            NSString *tmp = [NSString stringWithFormat:@" %d",vexsPre2D[v][w]];
            t = [t stringByAppendingString:tmp];
        }
        NSLog(@"%@",t);
    }
    
    NSLog(@"路径距离表：");
    for (v = 0; v < m_graph.numVertexes; v++) {
        NSString *t = @"";
        for (w = 0; w < m_graph.numVertexes; w++) {
            NSString *tmp = [NSString stringWithFormat:@"    %.0f",m_graph.weightAndAngels[v][w].weight];
            t = [t stringByAppendingString:tmp];
        }
        NSLog(@"%@",t);
    }
    
    NSLog(@"最短路劲distanceSum2D:distance：");
    for (v = 0; v < m_graph.numVertexes; v++) {
        NSString *t = @"";
        for (w = 0; w < m_graph.numVertexes; w++) {
            NSString *tmp = [NSString stringWithFormat:@" %d",distanceSum2D[v][w]];
            t = [t stringByAppendingString:tmp];
        }
        NSLog(@"%@",t);
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
