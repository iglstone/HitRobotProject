//
//  EditGraphViewController.m
//  HitProject
//
//  Created by 郭龙 on 16/5/23.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "DataCenter.h"
#import "EditGraphModelAndCell.h"
#import "EditGraphViewController.h"

@interface EditGraphViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *m_tableView;
    NSInteger screenW;
    NSInteger screenH;
    DataCenter *dataCenter;
    
    NSArray *dataSourceArr;
}
@end
@implementation EditGraphViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[CommonsFunc colorOfMiddle]];
    screenW =[[UIScreen mainScreen] bounds].size.width;
    screenH = [[UIScreen mainScreen] bounds].size.height;
    m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(50, 49, screenW - 100 , screenH - 49 *2 ) style:UITableViewStylePlain];
    [self.view addSubview:m_tableView];
    m_tableView.backgroundColor = [UIColor whiteColor];
    m_tableView.dataSource = self;
    m_tableView.delegate = self;
    
    dataCenter = [DataCenter sharedDataCenter];
    dataSourceArr = [dataCenter getGraphModlesArr];
    
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
    
    cell.pointIndexL.text = [NSString stringWithFormat:@"%ld", indexPath.row];
    if (dataSourceArr.count >= 4) {
        if (indexPath.row < dataSourceArr.count) {
            EditGraphModel *model = [dataSourceArr objectAtIndex:indexPath.row];
            [cell initCellWithModel:model];
        }
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return dataSourceArr.count == 0? 4 :dataSourceArr.count;
    return [[DataCenter sharedDataCenter] getVexsNum];//dataSourceArr.count == 0? 4 :dataSourceArr.count;
}

- (void) btnTaped:(UIButton *)btn {
    NSString *title = btn.titleLabel.text;
    if ([title isEqualToString:@"完成"]) {
        NSMutableArray *dicsArr = [NSMutableArray new];
        for (int i = 0; i < [dataCenter getVexsNum]; i++) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
            EditGraphCell *cell = [m_tableView cellForRowAtIndexPath:path];
            NSInteger index = [cell.pointIndexL.text integerValue];
            NSString *xy = cell.pointXYT.text;
            NSString *angel = cell.pointAngelT.text;
            NSString *joints = cell.pointJointsT.text;
            NSString *jointsAngels = cell.pointJointAngelsT.text;
            if (xy.length == 0 || angel.length == 0) {
                [self.view makeToast:@"参数有缺失" duration:1.5 position:CSToastPositionCenter];
                return;
            }
            EditGraphModel *model = [EditGraphModel new];
            model.ptIndexI = index; model.ptXYS = xy; model.ptAngelS = angel;
            model.ptJointsS = joints; model.ptJointAngelsS = jointsAngels;
            [dicsArr insertObject:model atIndex:index];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_EDITGRAPHINFO object:nil userInfo:@{@"modelsArr":dicsArr}];
        [self dismissViewControllerAnimated:YES completion:^{
        }];
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


