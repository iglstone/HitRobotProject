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
    CAShapeLayer *touchPointLayer;
    NSData *mapImageData ;
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
    
//    self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - 49)];
    UIEdgeInsets edge = UIEdgeInsetsMake(RIGHTBACKGROUNDVIEWOFSEET, RIGHTBACKGROUNDVIEWOFSEET, RIGHTBACKGROUNDVIEWOFSEET + 49, RIGHTBACKGROUNDVIEWOFSEET);
    self.imgView = [[UIImageView alloc] initWithFrame:UIEdgeInsetsInsetRect(self.view.frame, edge)];
    self.imgView.backgroundColor = [UIColor clearColor];
    self.imgView.contentMode = UIViewContentModeScaleToFill;// UIViewContentModeScaleAspectFit ;
    [self.view addSubview:self.imgView];
    mapImageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"mapImageData"];
    UIImage *image = [UIImage imageWithData:mapImageData];
    if (image) {
        self.imgView.image = image;
    }
    
    /*****合并画画View***/
    [self addDrawViews];
    /******************/
    
    [self initPara];
    [self creatMGragh];//初始信息需要手动输入
    
    [FloydAlgorithm initSingelPointIdAndAngel:&vexsAngel withIdAndAngels:@[@100,@70,@160,@30]];
    [FloydAlgorithm floydShortestPath:&m_graph pointsTabel:&vexsPre2D shortTable:&distanceSum2D];
    NSString *pathTo = [FloydAlgorithm findShortestPath:&m_graph from:0 to:2 pointsTabel:&vexsPre2D robotAngels:&vexsAngel];
    NSString *pathBack = [FloydAlgorithm findShortestPath:&m_graph from:2 to:0 pointsTabel:&vexsPre2D robotAngels:&vexsAngel];
    NSLog(@"pathTo: %@ \n PathBack: %@" , pathTo, pathBack);
    
    [self logSomeThing];
    
    //数据驱动绘图
    RouteView *routeView = [[RouteView alloc] initWithFrame:CGRectMake(0, 0, screenWidth - 2* RIGHTBACKGROUNDVIEWOFSEET, screenHeight -RIGHTBACKGROUNDVIEWOFSEET *2 - 49)];
    [backgroundView insertSubview:routeView belowSubview: backgroundView];
//    routeView.m_pointPositionsArray = m_realPosotionsArray;
    [routeView drawLineAndPoints:&m_graph withPointsArray:m_realPosotionsArray withTailAngel:&vexsAngel];
    
    //点击出红点
    touchPointLayer = [CAShapeLayer new];
    touchPointLayer.fillColor = [UIColor redColor].CGColor;
    touchPointLayer.strokeColor = [UIColor orangeColor].CGColor;
    [backgroundView.layer addSublayer:touchPointLayer];
    CGPoint pt = CGPointMake(100, 100);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:pt radius:10 startAngle:0 endAngle:2*M_PI clockwise:YES];
    touchPointLayer.path = path.CGPath;
}

- (void) initPara {
    NSArray *pointsArr = @[@[@0,@0], @[@770,@0], @[@770,@400], @[@0,@400]];
    for (int i = 0; i < pointsArr.count; i++) {
        int x = (int)[pointsArr[i][0] integerValue];
        int y = (int)[pointsArr[i][1] integerValue];
        CGPoint pt = CGPointMake(x, y);
        [m_realPosotionsArray insertObject:[NSValue valueWithCGPoint:pt] atIndex:i];
    }
    
    NSArray *angels = @[@-90, @180, @90, @0];
    if (angels.count != pointsArr.count) {
        NSLog(@"error angels Num:%lu and points Num:%lu",(unsigned long)angels.count, (unsigned long)pointsArr.count);
        return;
    }
    if (angels.count != m_graph.numVertexes) {
        NSLog(@"miss or add some other point");
        return;
    }
    for (int v = 0; v < MAXVEX; v++) {
        float angel = [[angels objectAtIndex:v] floatValue];
        vexsAngel[v] = angel;
    }
    
    //draw-datasource
    m_realPosotionsArray = [[NSMutableArray alloc] initWithCapacity:m_graph.numVertexes];//顶点个数
    for (int v = 0; v < m_graph.numVertexes; v++) {
        [m_realPosotionsArray insertObject:[NSValue valueWithCGPoint:CGPointMake(0, 0)] atIndex:v];
    }
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

#pragma mark - initNodeFonc
- (void)creatMGragh {
    mGraph *graph = &m_graph;
    int i,j;
    graph->numEdges = MAXEDGE;
    graph->numVertexes = MAXVEX;//POINTSNUM; // point num
    for (i = 0; i < graph->numVertexes; i++) {// init vexs
        graph->vexs[i] = i;
    }
    for (i = 0; i< graph->numVertexes; i++) { // init arcs
        for (j = 0; j< graph->numVertexes; j++) {
            if (i == j) {
                graph -> weightAndAngels[i][j].weight = 0;
                graph -> weightAndAngels[i][j].angel = 0;
            }else {
                graph -> weightAndAngels[i][j].weight = graph ->weightAndAngels[j][i].weight = INTMAX;
            }
        }
    }
    
    //初始化一半，start < end
    [self initGrghNodeStart:0 end:@[@1,@3] angel:@[@-90, @180]];
    [self initGrghNodeStart:1 end:@[@2]    angel:@[@180]];
    [self initGrghNodeStart:2 end:@[@3]    angel:@[@90]];
    
    //初始化另外一半
    for (i = 0; i < graph->numVertexes; i++) {
        for (j = 0; j < graph ->numVertexes; j++) {
            graph->weightAndAngels[j][i].weight = graph->weightAndAngels[i][j].weight; //important***,connot inverse
            int banckAngel = graph->weightAndAngels[i][j].angel + 180;
            graph->weightAndAngels[j][i].angel = banckAngel + 180 >=360 ? banckAngel - 360 : banckAngel;//返程是逆向
        }
    }
}

/**
 *  辅助初始化mGragh函数, 只初始化一半, 自己计算距离和角度
 *  @param g      gragh
 *  @param start,要求 start < end
 *  @param end
 *  @param weight
 *  @param angles
 */
- (void)initGrghNodeStart:(int)start end:(NSArray*)ends {
    mGraph *g = &m_graph;
    for (int i = 0; i<ends.count; i++) {
        NSInteger end = [[ends objectAtIndex:i] integerValue];
        if (start >= end) {
            NSLog(@"start num >= ending num");
            continue;
        }
        
        CGPoint st = [[m_realPosotionsArray objectAtIndex:start] CGPointValue];
        CGPoint ed = [[m_realPosotionsArray objectAtIndex:end] CGPointValue];
        float disX = ed.x - st.x;
        float disY = ed.y - st.y;
        float weight = sqrtf(disX*disX + disY*disY);
        float angelf = atan2f(disY, disX);//  atan2f(disY/disX);
        int angel = (int) (angelf / M_PI *180);
        //        if (angel < 0) {
        //            angel = angel +180;
        //        }
        g->weightAndAngels[start][end].weight = weight;
        g->weightAndAngels[start][end].angel = angel;
    }
}

/**
 *  辅助初始化mGragh函数, 只初始化一半, 带绝对角度，不是相对角度的，自计算距离
 *  @param g      gragh
 *  @param start,要求 start < end
 *  @param end
 *  @param angles
 */
- (void)initGrghNodeStart:(int)start end:(NSArray*)ends angel:(NSArray *)angels {
    mGraph *g = &m_graph;
    for (int i = 0; i<ends.count; i++) {
        NSInteger end = [[ends objectAtIndex:i] integerValue];
        if (start >= end) {
            NSLog(@"start num >= ending num");
            continue;
        }
        
        CGPoint st = [[m_realPosotionsArray objectAtIndex:start] CGPointValue];
        CGPoint ed = [[m_realPosotionsArray objectAtIndex:end] CGPointValue];
        float disX = ed.x - st.x;float disY = ed.y - st.y;
        float weight = sqrtf(disX*disX + disY*disY);
        float angel = [[angels objectAtIndex:i] floatValue];
        g->weightAndAngels[start][end].weight = weight;
        g->weightAndAngels[start][end].angel = angel;
    }
}

/**
 *  辅助初始化mGragh函数, 只初始化一半, 带绝对距离和角度，非计算距离与计算角度
 *  @param g      gragh
 *  @param start,要求 start < end
 *  @param end
 *  @param weight
 *  @param angles
 */
- (void)initGrghStart:(int)start end:(NSArray*)ends weight:(NSArray *)weight angle:(NSArray *)angles {
    mGraph *graph = &m_graph;
    if ([ends count] != [weight count]) {
        return;
    }
    for (int i = 0; i<ends.count; i++) {
        NSInteger end = [[ends objectAtIndex:i] integerValue];
        if (start >= end) {
            NSLog(@"start num >= ending num");
            continue;
        }
        float angel = [[angles objectAtIndex:i] floatValue];
        float weights = [[weight objectAtIndex:i] floatValue];
        graph->weightAndAngels[start][end].weight = weights;
        graph->weightAndAngels[start][end].angel = angel;
    }
}
#pragma mark - addDrawViews
- (void)addDrawViews {
    backgroundView = [[UIView alloc] initWithFrame:CGRectMake(RIGHTBACKGROUNDVIEWOFSEET, RIGHTBACKGROUNDVIEWOFSEET, screenWidth-RIGHTBACKGROUNDVIEWOFSEET * 2, screenHeight- RIGHTBACKGROUNDVIEWOFSEET *2 - 49)];
//    backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    backgroundView.backgroundColor = [UIColor clearColor];// [UIColor lightGrayColor];
//    backgroundRightView.backgroundColor = [CommonsFunc colorOfSystemBackground];// [UIColor lightGrayColor];
    [self.view addSubview:backgroundView];
    
    [self addBtns];
}

- (void)addBtns {
    rightContainer = [[UIView alloc] initWithFrame:CGRectMake(screenWidth - 120, 20, 100, screenHeight - 49 - 20*2)];
    rightContainer.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:rightContainer];
    
    deskNameArr = @[@"隐藏", @"参数设置", @"选择地图", @"EditGraph", @"201桌", @"202桌", @"203桌",@"204桌"];
    for (int i = 0; i < deskNameArr.count; i++) {
        UIButton *positionBtn = [UIButton new];
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

#pragma mark - btn taped

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
//    UIImage *imge = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    UIImage *imge = [info objectForKey:@"UIImagePickerControllerOriginalImage"];

    [self dismissViewControllerAnimated:YES completion:^{
        self.imgView.image = imge;
        mapImageData = UIImageJPEGRepresentation(imge, 0.6);
        [[NSUserDefaults standardUserDefaults] setObject:mapImageData forKey:@"mapImageData"];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    NSLog(@"ooo");
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *tou = [touches anyObject];
    
    CGPoint pt = [tou locationInView:backgroundView];
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:pt radius:10 startAngle:0 endAngle:2*M_PI clockwise:YES];
    touchPointLayer.path = path.CGPath;
    CGPoint realPosition = [FloydAlgorithm changeCoodToRealPosition:pt];
    [[HitControl sharedControl] sendTouchPointToRobot:realPosition];
    [super touchesEnded:touches withEvent:event];
}


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
        [self presentViewController:[SettingViewController new] animated:YES completion:nil];
        return;
    }
    
    if ([title isEqualToString:@"选择地图"]) {
        UIImagePickerController *imgPick = [UIImagePickerController new];
        imgPick.delegate = self;
        imgPick.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imgPick.view.backgroundColor = [UIColor whiteColor];
//        imgPick.allowsEditing = YES;
        [self presentViewController:imgPick animated:YES completion:nil];
        return;
    }
    
    if ([title isEqualToString:@"EditGraph"]) {
        EditGraphViewController *edit = [EditGraphViewController new];
        [self presentViewController:edit animated:YES completion:nil];
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
    
    NSLog(@"最短路劲distanceSum2D:distance：");
    for (v = 0; v < m_graph.numVertexes; v++) {
        NSString *t = @"";
        for (w = 0; w < m_graph.numVertexes; w++) {
            NSString *tmp = [NSString stringWithFormat:@"  %d",distanceSum2D[v][w]];
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
