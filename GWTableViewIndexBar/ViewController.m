//
//  ViewController.m
//  GWTableViewIndexBar
//
//  Created by JZW on 2019/6/18.
//  Copyright © 2019 Beijing Gengwu. All rights reserved.
//

#import "ViewController.h"
#import "GWTableViewIndexBar.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, GWTableViewIndexBarDelegate>
/*! @brief tableView */
@property(nonatomic, weak) UITableView *tableView;
/*! @brief 数据 */
@property(nonatomic, strong) NSDictionary *dataDic;
/*! @brief section数据 */
@property(nonatomic, strong) NSArray *sectionArray;
/*! @brief indexBar */
@property(nonatomic, strong) GWTableViewIndexBar *indexBar;
@end

@implementation ViewController
#pragma mark -- lifycycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self _initDatas];
    [self _initTableView];
    [self _initIndexBar];
}
#pragma mark -- initDatas
- (void)_initDatas{
    NSString *string = @"ABCDEFGHIJKLMNABCDEFGHIJKLMNABCDEFGHIJKLMNABCDEFGHIJKLMN";
    NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:string.length];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithCapacity:string.length];
    for (NSInteger i = 0; i < string.length; i++) {
        NSString *key = [string substringWithRange:NSMakeRange(i, 1)];
        if (![sectionArray containsObject:key]) {
            [sectionArray addObject:key];
        }
        if ([dataDic.allKeys containsObject:key]) {
            NSArray *rowArray = [dataDic objectForKey:key];
            NSMutableArray *arrayM = [NSMutableArray arrayWithArray:rowArray];
            [arrayM addObject:key];
            [dataDic setObject:[arrayM copy] forKey:key];
        }else{
             NSMutableArray *arrayM = [NSMutableArray arrayWithObject:key];
            [dataDic setObject:[arrayM copy] forKey:key];
        }
    }
    self.dataDic = [dataDic copy];
    self.sectionArray = [sectionArray copy];
}


#pragma mark -- initUI
- (void)_initTableView{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    if (@available(iOS 11.0, *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
}

- (void)_initIndexBar{
    CGFloat width = 20.0;
    CGFloat height = CGRectGetHeight(self.tableView.frame);
    CGFloat x = CGRectGetMaxX(self.tableView.frame) - width - 15.0;
    CGFloat y = CGRectGetMinY(self.tableView.frame);
    GWTableViewIndexBar *indexBar = [[GWTableViewIndexBar alloc] initWithFrame:CGRectMake(x, y, width, height)];//像正常View一样初始化
    indexBar.backgroundColor = [UIColor whiteColor];//配置背景色
    indexBar.normalTitleColor = [UIColor blackColor];//配置索引栏标题正常色
    indexBar.highlighTitletColor = [UIColor blueColor];//配置索引栏标题高亮色
    indexBar.titleFont = [UIFont boldSystemFontOfSize:12.0];//配置索引栏标题字体大小
    indexBar.showStyle = kGWTableViewIndexBarScrollShowStyle;//配置索引栏风格
    indexBar.contentInset = UIEdgeInsetsMake(10.0, 0, 10.0, 0);//配置索引栏内间距
    indexBar.isCorner = YES;//切圆角
    indexBar.tableView = self.tableView;//绑定tableview
    indexBar.delegate = self;//设置代理
    [self.view addSubview:indexBar];//添加到视图
    indexBar.indexTitlesArray = self.sectionArray;//配置索引数据
    self.indexBar = indexBar;
}
#pragma mark -- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString *sectionTitle = self.sectionArray[section];
    NSArray *array = [self.dataDic objectForKey:sectionTitle];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSString *sectionTitle = self.sectionArray[indexPath.section];
    NSArray *array = [self.dataDic objectForKey:sectionTitle];
    NSString *title = array[indexPath.row];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = @"详细介绍";
    return cell;
}

//- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
//    return self.sectionArray;
//}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.sectionArray[section];
}
#pragma mark -- UITableViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //调用索引栏对应方法即可
    [self.indexBar scrollViewDidScroll:scrollView];
//    NSLog(@"isDragging：%d", self.tableView.isDragging);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //调用索引栏对应方法即可
    [self.indexBar scrollViewDidEndDecelerating:scrollView];
//    NSLog(@"isDragging：%d", self.tableView.isDragging);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //调用索引栏对应方法即可
    [self.indexBar scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
//    NSLog(@"isDragging：%d", self.tableView.isDragging);
}
#pragma mark -- GWTableViewIndexBarDelegate
- (void)tableViewIndexBar:(GWTableViewIndexBar *)indexBar didSelectRowAtIndex:(NSInteger)index{
    NSLog(@"选中了%ld", index);
}
@end
