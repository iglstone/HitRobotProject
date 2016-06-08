//
//  RobotRouteViewController.m
//  TourRobot
//
//  Created by 郭龙 on 16/5/5.
//  Copyright © 2016年 郭龙. All rights reserved.
//  copy form:http://blog.chinaunix.net/uid-26548237-id-3834873.html

#import "RobotRouteViewController2.h"
#import "RouteHeader.h"
#import "FloydAlgorithm.h"
#import "RouteView.h"
#import "ZDStickerView.h"

#define TABLEVIEWWIDTH 100
#define TOUCHPINCHTHRESHHOLD 10
#define TABLEVIEWTOPOFFSET 0
#define RIGHTBACKGROUNDVIEWOFSEET 30

@interface RobotRouteViewController2 () <UITableViewDataSource, UITableViewDelegate, ZDStickerViewDelegate>
{
    mGraph m_graph;
    NSMutableArray *m_realPosotionsArray;
    vexAngels vexsAngel;
    vexsPre2DTabel vexsPre2D;
    distancesSum2DTabel distanceSum2D;
    
    UIView *backgroundRightView;
    UITableView *leftTabelView;
    NSInteger screenHeight;
    NSInteger screenWidth;
    UIView *tmpPickedView;
    NSMutableArray *zdsticks;
    BOOL canEdit;
    NSArray *deskNameArr;
    UIView *rightContainer;
    CAShapeLayer *touchPointLayer;
}
@end

@implementation RobotRouteViewController2

#pragma mark - life cicle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    m_realPosotionsArray = [NSMutableArray new];
    screenHeight = [[UIScreen mainScreen] bounds].size.height;
    screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
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
    RouteView *routeView = [[RouteView alloc] initWithFrame:CGRectMake(0, 0, screenWidth , screenHeight)];
    [backgroundRightView insertSubview:routeView belowSubview: backgroundRightView];
    [routeView drawLineAndPoints:&m_graph withPointsArray:m_realPosotionsArray withTailAngel:&vexsAngel vexsTabel:&vexsPre2D];
    
    touchPointLayer = [CAShapeLayer new];
    touchPointLayer.fillColor = [UIColor redColor].CGColor;
    [backgroundRightView.layer addSublayer:touchPointLayer];
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
    
//    [self initGrghNodeStart:1 end:@[@2]];
//    [self initGrghNodeStart:2 end:@[@3,@6]];
//    [self initGrghNodeStart:3 end:@[@4,@5]];
//    [self initGrghNodeStart:4 end:@[@5]];
//    [self initGrghNodeStart:5 end:@[@6]];
//    [self initGrghNodeStart:6 end:@[@7]];
//    [self initGrghNodeStart:7 end:@[@8]];
    
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
        
        CGPoint st = CGPointFromString([m_realPosotionsArray objectAtIndex:start] );
        CGPoint ed = CGPointFromString([m_realPosotionsArray objectAtIndex:end] );
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
        
        CGPoint st = CGPointFromString([m_realPosotionsArray objectAtIndex:start] );
        CGPoint ed = CGPointFromString([m_realPosotionsArray objectAtIndex:end] );
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
    zdsticks  = [NSMutableArray new];
    
    backgroundRightView = [[UIView alloc] initWithFrame:CGRectMake(RIGHTBACKGROUNDVIEWOFSEET, RIGHTBACKGROUNDVIEWOFSEET, screenWidth-RIGHTBACKGROUNDVIEWOFSEET * 2, screenHeight- RIGHTBACKGROUNDVIEWOFSEET *2 - 49)];
    backgroundRightView.backgroundColor = [CommonsFunc colorOfSystemBackground];// [UIColor lightGrayColor];
    [self.view addSubview:backgroundRightView];
    
    [self addBtns];
    
    leftTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, TABLEVIEWTOPOFFSET, TABLEVIEWWIDTH, screenHeight - 49) style:UITableViewStylePlain];
    leftTabelView.frame = CGRectMake(0, TABLEVIEWTOPOFFSET, 0, screenHeight -  49);
    [self.view addSubview:leftTabelView];
    leftTabelView.dataSource = self;
    leftTabelView.delegate = self;
    leftTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    leftTabelView.showsVerticalScrollIndicator = NO;
    leftTabelView.backgroundColor = [UIColor clearColor];

}

- (void)addBtns {
    rightContainer = [[UIView alloc] initWithFrame:CGRectMake(screenWidth - 120, 20, 100, screenHeight - 49 - 20*2)];
    rightContainer.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:rightContainer];
    
    UIButton *editBtn = [UIButton new];
    editBtn.backgroundColor = [UIColor orangeColor];
    [rightContainer addSubview:editBtn];
    [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.width.mas_equalTo(@100);
    }];
    [editBtn addTarget:self action:@selector(btnTaped:) forControlEvents:UIControlEventTouchUpInside];

    deskNameArr = @[@"201桌", @"202桌", @"203桌",@"204桌"];
    for (int i = 0; i < deskNameArr.count; i++) {
        UIButton *positionBtn = [UIButton new];
        positionBtn.backgroundColor = [UIColor orangeColor];
        [rightContainer addSubview:positionBtn];
        [positionBtn setTitle:deskNameArr[i] forState:UIControlStateNormal];
        [positionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(editBtn.mas_bottom).offset(20 + 55 * i);
            make.right.equalTo(editBtn);
            make.width.mas_equalTo(editBtn);
        }];
        [positionBtn addTarget:self action:@selector(btnTaped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
}

#pragma mark - btn taped

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *tou = [touches anyObject];
    
    CGPoint pt = [tou locationInView:backgroundRightView];
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:pt radius:10 startAngle:0 endAngle:2*M_PI clockwise:YES];
    touchPointLayer.path = path.CGPath;
    CGPoint realPosition = [FloydAlgorithm changeCoodToRealPosition:pt];
    [[HitControl sharedControl] sendTouchPointToRobot:realPosition];
    [super touchesEnded:touches withEvent:event];
}


- (void) btnTaped:(UIButton *)btn {
    NSString *title = btn.titleLabel.text;
    if ([title isEqualToString:@"编辑"]) {
        canEdit = YES;
        [btn setTitle:@"完成" forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor redColor];
        
        [UIView beginAnimations:@"table" context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        leftTabelView.frame = CGRectMake(0, TABLEVIEWTOPOFFSET, TABLEVIEWWIDTH, screenHeight -  49);
        backgroundRightView.frame = CGRectMake( TABLEVIEWWIDTH + RIGHTBACKGROUNDVIEWOFSEET, RIGHTBACKGROUNDVIEWOFSEET, screenWidth - TABLEVIEWWIDTH - RIGHTBACKGROUNDVIEWOFSEET * 2 , screenHeight - RIGHTBACKGROUNDVIEWOFSEET * 2 - 49 );
        for (UIButton *btn in rightContainer.subviews) {
            if ([btn.titleLabel.text isEqualToString:@"完成"]) {
                continue;
            }
            btn.hidden = YES;
        }
        rightContainer.frame = CGRectMake(screenWidth - 120, 20, 100, 35);
        [UIView commitAnimations];
        
        for (ZDStickerView *st in zdsticks) {
            [st showEditingHandles];
        }
        return;
    }
    if ([btn.titleLabel.text isEqualToString:@"完成"]) {
        canEdit = NO;
        [btn setTitle:@"编辑" forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor orangeColor];
        
        [UIView beginAnimations:@"table" context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        leftTabelView.frame = CGRectMake(0, 0, 0, screenHeight - 49);
        backgroundRightView.frame = CGRectMake(RIGHTBACKGROUNDVIEWOFSEET, RIGHTBACKGROUNDVIEWOFSEET, screenWidth - RIGHTBACKGROUNDVIEWOFSEET * 2, screenHeight - RIGHTBACKGROUNDVIEWOFSEET *2 - 49 );
        rightContainer.frame = CGRectMake(screenWidth - 120, 20, 100, screenHeight - 49 - 20*2);
        for (UIButton *btn in rightContainer.subviews) {
            if ([btn.titleLabel.text isEqualToString:@"编辑"]) {
                continue;
            }
            btn.hidden = NO;
        }
        [UIView commitAnimations];
        
        for (ZDStickerView *st in zdsticks) {
            [st hideEditingHandles];
        }
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
    [[HitControl sharedControl] sendPathToRobot:index ofRealPosition:m_realPosotionsArray ofDeskNum:deskNameArr];
}

#pragma  mark - table dele
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *st = @"leftabtlview";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:st];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"leftTableView"];
    }
    //    cell.textLabel.text = @"桌子";
    cell.imageView.image = [UIImage imageNamed:@"desk_red"];
    cell.backgroundColor = [UIColor orangeColor];
    cell.imageView.image = [CommonsFunc imagePinch:[UIImage imageNamed:@"desk_white"] width:60 height:60];
    switch (indexPath.row) {
        case 0:
            cell.imageView.image = [CommonsFunc imagePinch:[UIImage imageNamed:@"desk_red"] width:60 height:60];
            break;
        case 1:
            cell.imageView.image = [CommonsFunc imagePinch:[UIImage imageNamed:@"robot_2"] width:60 height:60];
            break;
        case 2:
            cell.imageView.image = [CommonsFunc imagePinch:[UIImage imageNamed:@"robot_3"] width:60 height:60];
        default:
            break;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *pickedView = [cell imageView];
    UIImage *new = [CommonsFunc imagePinch:[pickedView image] width:pickedView.frame.size.width height:pickedView.frame.size.height];
    tmpPickedView = [[UIImageView alloc] initWithImage:new];
    CGRect rectInTableView = [tableView rectForRowAtIndexPath:indexPath];
//    CGRect rect1 = [tableView convertRect:pickedView.frame toView:self.view];
    CGRect rect1 = [tableView convertRect:rectInTableView toView:self.view];
    ZDStickerView *zt = [[ZDStickerView alloc] initWithFrame:CGRectMake(rect1.origin.x, rect1.origin.y -RIGHTBACKGROUNDVIEWOFSEET, rect1.size.width, rect1.size.height - 15)];//130 - 30
    zt.contentView = tmpPickedView;
    zt.stickerViewDelegate = self;
    [zt showEditingHandles];
    zt.translucencySticker = NO;
    zt.preventsPositionOutsideSuperview = NO;
    [backgroundRightView addSubview:zt];
    [zdsticks addObject:zt];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130;
}

#pragma mark - privateMethod 
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
