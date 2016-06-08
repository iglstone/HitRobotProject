//
//  DataCenter.m
//  HitProject
//
//  Created by 郭龙 on 16/5/23.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "DataCenter.h"

@interface DataCenter () {
    NSArray *keySettingArr;
    NSMutableArray *m_realPositionArr;
}

@end

@implementation DataCenter

+ (instancetype )sharedDataCenter {
    static DataCenter *sharedDataCenter = nil;
    static dispatch_once_t pridicate;
    dispatch_once(&pridicate, ^{
        sharedDataCenter = [[DataCenter alloc] init];
    });
    return sharedDataCenter;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        keySettingArr = @[@"vexs", @"mapW", @"mapH"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiInfo:) name:NOTI_SETTINGINFOMATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiInfo:) name:NOTI_EDITGRAPHINFO object:nil];
        return self;
    }
    return nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) notiInfo :(NSNotification *)noti {
    NSDictionary *dic = [noti userInfo];
    if ([[noti name] isEqualToString:NOTI_SETTINGINFOMATION]) {
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:NOTI_SETTINGINFOMATION];//用noti做key来保存本地
    }
    
    if ([[noti name]isEqualToString:NOTI_EDITGRAPHINFO]) {
        NSArray *modelsArr = [dic objectForKey:@"modelsArr"];
        NSMutableArray *realAngelsArr =[NSMutableArray new];
        NSMutableArray *realPositionArr =[NSMutableArray new];
        if (modelsArr) {
            // 需要先处理数据出来
            for (EditGraphModel *model in modelsArr) {
                NSArray *xys = [self sperateByComma:model.ptXYS];
                CGPoint realPt = CGPointMake([xys[0] integerValue], [xys[1] integerValue]);
                int start = (int)model.ptIndexI;
                int angel = (int)[model.ptAngelS integerValue];
                [realPositionArr insertObject:NSStringFromCGPoint(realPt) atIndex:start];
                [realAngelsArr insertObject:@(angel) atIndex:start];
            }
        }
        [self setGraphModelsArr:modelsArr];
        [self setRealPoisitonsOfArr:realPositionArr];
        [self setAngelsArr:realAngelsArr];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_REFRESHDRAW object:nil];
    }
}

#pragma mark - private 
- (void)creatMGragh :(mGraph*)graph OfModelsArr: (NSArray *)modelsArr {
    int i,j;
    m_realPositionArr =  (NSMutableArray *)[self getRealPositionsArr];
    int k = (int)[[DataCenter sharedDataCenter] getVexsNum];
    graph->numVertexes = k;
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
    
    if (modelsArr.count == 0) {
        //    //初始化一半，start < end
        [self initGrgh:graph NodeStart:0 position:CGPointFromString(m_realPositionArr[0]) end:@[@1,@3] angel:@[@-90, @180]];
        [self initGrgh:graph NodeStart:1 position:CGPointFromString(m_realPositionArr[1]) end:@[@2] angel:@[@180]];
        [self initGrgh:graph NodeStart:2 position:CGPointFromString(m_realPositionArr[2]) end:@[@3] angel:@[@90]];
    } else {
        for (EditGraphModel *model in modelsArr) {
            NSArray *ends = [self sperateByComma:model.ptJointsS];
            NSArray *angels = [self sperateByComma:model.ptJointAngelsS];
            if (ends.count == 0 || angels.count == 0) {
                continue;
            }
            int start = (int)model.ptIndexI;
            NSString *positist = model.ptXYS;
            CGPoint realPt = CGPointFromString(positist);//CGPointMake((int)xy[0],(int)xy[1]);
            [self initGrgh:graph NodeStart:start position:realPt end:ends angel:angels];
        }
    }
    
    //初始化另外一半
    for (i = 0; i < graph->numVertexes; i++) {
        for (j = 0; j < graph ->numVertexes; j++) {
            graph->weightAndAngels[j][i].weight = graph->weightAndAngels[i][j].weight; //important***,connot inverse
            int banckAngel = graph->weightAndAngels[i][j].angel + 180;
            graph->weightAndAngels[j][i].angel = banckAngel + 180 >=360 ? banckAngel - 360 : banckAngel;//返程是逆向
        }
    }
}

- (void)initGrgh:(mGraph *)g NodeStart:(int)start position:(CGPoint)pt end:(NSArray*)ends angel:(NSArray *)angels {
    for (int i = 0; i<ends.count; i++) {
        NSInteger end = [[ends objectAtIndex:i] integerValue];
        if (start >= end) {
            NSLog(@"start num >= ending num");
            continue;
        }
        CGPoint ed = CGPointFromString([m_realPositionArr objectAtIndex:end]);
        float disX = ed.x - pt.x;
        float disY = ed.y - pt.y;
        float weight = sqrtf(disX*disX + disY*disY);
        float angel = [[angels objectAtIndex:i] floatValue];
        g->weightAndAngels[start][end].weight = weight;
        g->weightAndAngels[start][end].angel = angel;
    }
}

- (NSArray *)sperateByComma : (NSString *)tmp {
    NSString *tmpJoints = [tmp stringByReplacingOccurrencesOfString:@" " withString:@""];
    tmpJoints = [tmpJoints stringByReplacingOccurrencesOfString:@"，" withString:@","];
    NSArray *arrJ = [tmpJoints componentsSeparatedByString:@","];
    return arrJ;
}

- (void)setRealPositonsOfIndex:(int)index ofPoint:(CGPoint)pt {
    NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:@"m_realPositionArr"];
    NSMutableArray *mut = [[NSMutableArray alloc] initWithArray:arr];
    [mut replaceObjectAtIndex:index withObject:NSStringFromCGPoint(pt)];
    [self setRealPoisitonsOfArr:mut];
}

- (void)setRealPoisitonsOfArr :(NSArray *)arr {
    [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"m_realPositionArr"];
}

- (NSArray *)getRealPositionsArr {
    NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:@"m_realPositionArr"];
    if (arr == nil || arr.count <=3) {
        NSMutableArray *rr = [NSMutableArray new];
        NSArray *pointsArr = @[@[@0,@0], @[@770,@0], @[@770,@400], @[@0,@400]]; //初始化四个
        for (int i = 0; i < pointsArr.count; i++) {
            int x = (int)[pointsArr[i][0] integerValue];
            int y = (int)[pointsArr[i][1] integerValue];
            CGPoint pt = CGPointMake(x, y);
            [rr insertObject:NSStringFromCGPoint(pt) atIndex:i];
        }
        [self setRealPoisitonsOfArr:rr];
        return rr;
    }
    
    return arr;
}

- (void)setGraphModelsArr :(NSArray *)arr {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:arr];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:NOTI_EDITGRAPHINFO];
}

- (NSArray *)getGraphModlesArr {
    NSData *data= [[NSUserDefaults standardUserDefaults] objectForKey:NOTI_EDITGRAPHINFO];
    if (!data) {
        EditGraphModel *model0 = [EditGraphModel new];
        model0.ptIndexI = 0; model0.ptAngelS = @"100"; model0.ptXYS =@"0,0"; model0.ptJointsS = @"1,3"; model0.ptJointAngelsS = @"-90,180";
    
        EditGraphModel *model1 = [EditGraphModel new];
        model1.ptIndexI = 1; model1.ptAngelS = @"70"; model1.ptXYS =@"770,0"; model1.ptJointsS = @"2"; model1.ptJointAngelsS = @"180";
        
        EditGraphModel *model2 = [EditGraphModel new];
        model2.ptIndexI = 2; model2.ptAngelS = @"160"; model2.ptXYS =@"770,400"; model2.ptJointsS = @"3"; model2.ptJointAngelsS = @"90";
        
        EditGraphModel *model3 = [EditGraphModel new];
        model3.ptIndexI = 3; model3.ptAngelS = @"30"; model3.ptXYS =@"0,400"; model3.ptJointsS = @""; model3.ptJointAngelsS = @"";
        return @[model0, model1, model2, model3];
    }
    NSArray<EditGraphModel *> *arr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSArray *realPsArr = [self getRealPositionsArr];
    for (int i = 0; i < arr.count; i++) {
        NSString *ptStirng = [realPsArr objectAtIndex:i];
        EditGraphModel *model = [arr objectAtIndex:i];
        model.ptXYS = ptStirng;
    }
    return arr;
}

- (void) setAngelsArr:(NSArray *)arr {
    [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"m_realAngelsArr"];
}

- (NSArray *)getAngelsArr {
    NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:@"m_realAngelsArr"];
    if (arr==nil || arr.count <=3) {
        arr = @[@100,@70,@160,@30];
    }
    return arr;
}

- (NSInteger)getVexsNum {
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:NOTI_SETTINGINFOMATION];
    NSNumber *number = [dic objectForKey:keySettingArr[0]];
    if (!number || [number integerValue] <= 3) {
        return 4;
    }
    return [number integerValue];
}

- (NSInteger)getMapWidth {
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:NOTI_SETTINGINFOMATION];
    NSNumber *number = [dic objectForKey:keySettingArr[1]];
    if (!number || [number integerValue] == 0) {
        return 1000;
    }
    return [number integerValue];
}

- (NSInteger)getMapHeight {
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:NOTI_SETTINGINFOMATION];
    NSNumber *number = [dic objectForKey:keySettingArr[2]];
    if (!number || [number integerValue] == 0) {
        return 500;
    }
    return [number integerValue];
}


@end
