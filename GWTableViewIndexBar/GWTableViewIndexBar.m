//
//  GWTableViewIndexBar.m
//  GWTableViewIndexBar
//
//  Created by JZW on 2019/6/26.
//  Copyright © 2019 Beijing Gengwu. All rights reserved.
//

#import "GWTableViewIndexBar.h"

static const CGFloat kDefaultTitleFontSize = 13.0;     //默认字体大小
static const CGFloat kDefaultIndexFontSize = 25.0;     //默认指引字体大小
static const CGFloat kDefaultTitleHeight = 20.0;       //默认字体高度
static const CGFloat kShowIndexBarAnimationTime = 0.5; //显示indexBar的动画时长
static const CGFloat kDisimissIndexBarAnimationTime = 1.0; //隐藏indexBar的动画时长
static const CGFloat kIndicatorAnimationTime = 0.5;    //显示和隐藏指示器的动画时长
static  NSString * const kTableViewKVOContentOffSetName = @"contentOffset";

@interface GWTableViewIndexBar()
/*! @brief 存储titleLabel数组，Label复用 */
@property(nonatomic, strong) NSMutableArray *titleLabelArray;
/*! @brief 当前选中的index */
@property(nonatomic, assign) NSInteger currentIndex;
/*! @brief 显示当前索引字母的Label */
@property(nonatomic, strong) UILabel *indexTitleLabel;
/*! @brief 当前索引字母的背景ImageView */
@property(nonatomic, strong) UIImageView *indexTitleBgView;

@end
@implementation GWTableViewIndexBar
#pragma mark -- init
- (instancetype)init{
    if (self = [super init]) {
        //初始化属性默认值
        [self _initProperties];
        //初始化子视图
        [self _initViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //初始化属性默认值
        [self _initProperties];
        //初始化子视图
        [self _initViews];
    }
    return self;
}
/**
 初始化默认属性
 */
- (void)_initProperties{
    _minimumShowCount = 10;//默认最小显示个数为10
    _showStyle = kGWTableViewIndexBarPermanentShowStyle;//默认是常驻显示风格
    _normalTitleColor = [UIColor blackColor];//默认是索引标题黑色
    _highlighTitletColor = _normalTitleColor;//默认是索引高亮色和正常色一样
    _titleFont = [UIFont systemFontOfSize:kDefaultTitleFontSize];//默认是索引正常字体13.0
    _titleLabelArray = [NSMutableArray arrayWithCapacity:_minimumShowCount];//默认是数组容器大小为最小显示阈值
    _titleHeight = kDefaultTitleHeight;//默认是索引标题高度20
    _contentInset = UIEdgeInsetsZero;//默认上下左右内间距为0
}

/**
 初始化子视图
 */
- (void)_initViews{
    //初始化索引指引背景视图
    UIImage *image = [UIImage imageNamed:@"bg_retrieving_letter"];
    _indexTitleBgView = [[UIImageView alloc] initWithImage:image];
    _indexTitleBgView.backgroundColor = [UIColor clearColor];
    //初始化索引指引标题视图
    _indexTitleLabel = [[UILabel alloc] init];
    _indexTitleLabel.textAlignment = NSTextAlignmentCenter;
    _indexTitleLabel.textColor = [UIColor whiteColor];
    _indexTitleLabel.font = [UIFont systemFontOfSize:kDefaultIndexFontSize];
    _indexTitleLabel.backgroundColor = [UIColor clearColor];
    [_indexTitleBgView addSubview:_indexTitleLabel];
}

- (void)dealloc{
    [_tableView removeObserver:self forKeyPath:kTableViewKVOContentOffSetName];
}
#pragma mark -- 布局
- (void)layoutSubviews{
    [super layoutSubviews];
    //根据索引数量修改self的高度,并保持self居中显示
    CGPoint center = self.center;
    CGRect rect = self.frame;
    rect.size.height = self.titleHeight * self.titleLabelArray.count + self.contentInset.top + self.contentInset.bottom;
    self.frame = rect;
    self.center = center;
    //是否切圆角
    if (self.isCorner) {
        //设置圆角
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:self.bounds.size];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        //设置大小
        maskLayer.frame = self.bounds;
        //设置图形样子
        maskLayer.path = maskPath.CGPath;
        self.layer.mask = maskLayer;
    }
    //初始化索引Label的frame相关参数
    CGFloat width = CGRectGetWidth(self.frame);
    for (NSInteger i = 0; i < self.titleLabelArray.count; i++) {
        UILabel *label = self.titleLabelArray[i];
        CGRect frame = CGRectMake(0, i * self.titleHeight + self.contentInset.top, width, self.titleHeight);
        label.frame  = frame;
    }
    //初始化索引指引背景视图的frame相关参数
    CGRect indexFrame = self.indexTitleBgView.frame;
    CGFloat indexWidth = CGRectGetWidth(indexFrame);
    CGFloat indexHeight = CGRectGetHeight(indexFrame);
    indexFrame.origin.x = CGRectGetMinX(self.frame) - indexWidth;
    self.indexTitleBgView.frame = indexFrame;
    //初始化指引label的frame相关参数
    self.indexTitleLabel.frame = CGRectMake(0, 0, indexWidth * 0.5, indexHeight * 0.5);
    self.indexTitleLabel.center  = CGPointMake(indexWidth * 0.5, indexHeight * 0.5);
}
#pragma mark -- 刷新视图
- (void)reloadData{
    NSInteger count = _indexTitlesArray.count;
    //先将所有label从视图移出
    for (UILabel *label in _titleLabelArray) {
        [label removeFromSuperview];
    }
    //如果当前tableview可见cell的indexpath数据不为空，初始化当前选中的index为第一个可见indexpath的section
    if (self.tableView.indexPathsForVisibleRows.count > 0) {
        self.currentIndex = self.tableView.indexPathsForVisibleRows[0].section;
    }
    //如果索引数组大于最小显示个数则创建Label并显示
    if (count >= _minimumShowCount) {
        for (NSInteger i = 0; i < count; i++) {
            NSString *title = _indexTitlesArray[i];
            UILabel *label;
            //如果i小于保存的label数组，则直接从数据中取label即可，不需要重新创建，节省性能，否则才重新创建，并保存到数组中
            if (i < _titleLabelArray.count) {
                label = _titleLabelArray[i];
            }else{
                label = [[UILabel alloc] init];
                [_titleLabelArray addObject:label];
            }
            if (i == self.currentIndex) {
                label.textColor = _highlighTitletColor;
            }else{
                label.textColor = _normalTitleColor;
            }
            label.font = _titleFont;
            label.textAlignment = NSTextAlignmentCenter;
            label.lineBreakMode = NSLineBreakByClipping;
            label.text = title;
            [self addSubview:label];
        }
        //如果保存的label比需要的多，删除多余的lable
        if (_titleLabelArray.count > count) {
            [_titleLabelArray removeObjectsInRange:NSMakeRange(count, _titleLabelArray.count - count)];
        }
        if (kGWTableViewIndexBarPermanentShowStyle == _showStyle) {
            self.hidden = NO;
        }else{
            self.hidden = YES;
        }
    }else{
        self.hidden = YES;
    }
}
#pragma mark -- setter &  getter
- (void)setIndexTitlesArray:(NSArray<NSString *> *)indexTitlesArray{
    _indexTitlesArray = indexTitlesArray;
    [self reloadData];
}

- (void)setTableView:(UITableView *)tableView{
    [_tableView removeObserver:self forKeyPath:kTableViewKVOContentOffSetName];
    _tableView = tableView;
    [_tableView addObserver:self forKeyPath:kTableViewKVOContentOffSetName options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
}


#pragma mark -- events
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self handleTouches:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    [self handleTouches:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    [self handleEndTouches:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    [self handleEndTouches:touches withEvent:event];
}

/**
处理触摸结束和取消事件

@param touches touch数组
@param event   event
*/
- (void)handleEndTouches:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //延迟隐藏指示器
    [self performSelector:@selector(dismissIndecatorTitle) withObject:nil afterDelay:1.0];
    [self dismissIndecatorTitle];
    //根据是否滑动显示延迟隐藏indexbar
    if (kGWTableViewIndexBarScrollShowStyle == self.showStyle && !self.hidden) {
        [self performSelector:@selector(dismissIndexBar) withObject:nil afterDelay:1.0];
    }
}

/**
 处理触摸事件

 @param touches touch数组
 @param event   event
 */
- (void)handleTouches:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //获取触摸点位置
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    if (touchPoint.x < 0) return;
    //通过触摸的位置计算出选中的索引
    NSInteger index = (touchPoint.y - self.contentInset.top) / (long)self.titleHeight;
    if (index < 0) {
        index = 0;
    }else if (index >= self.indexTitlesArray.count){
        index = self.indexTitlesArray.count - 1;
    }
    [self didSelectRowIndex:index byTouch:YES];
}

/**
 选中索引操作
 @param index   索引的位置
 @param isTouch 是否是触摸触发
 */
- (void)didSelectRowIndex:(NSInteger)index byTouch:(BOOL)isTouch{
    //如果选中的索引超出标题数组，或者和当前选中的相同则直接return
    if (index >= self.titleLabelArray.count || index < 0 || index == self.currentIndex) {
        return;
    }
    if (self.currentIndex != index) {
        if (kGWTableViewIndexBarScrollShowStyle == self.showStyle) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissIndexBar) object:nil];
        }
        //保存当前选中的index
        self.currentIndex = index;
        //如果正常状态颜色和高亮颜色则循环遍历设置选中的index为高亮颜色
        if (![self.normalTitleColor isEqual:self.highlighTitletColor]) {
            for (NSInteger i = 0; i < self.titleLabelArray.count; i++) {
                UILabel *label = self.titleLabelArray[i];
                if (index == i) {
                    label.textColor = self.highlighTitletColor;
                }else{
                    label.textColor = self.normalTitleColor;
                }
            }
        }
        //如果是用户触摸indexBar触发选中索引则滚动tableView并通知代理
        if (isTouch) {
            //显示指示器
            UILabel *label = self.titleLabelArray[index];
            NSString *title = self.indexTitlesArray[index];
            [self showIndecatorWithTitle:title andcenterY:(CGRectGetMidY(label.frame) + CGRectGetMinY(self.frame))];
            //如果当前选中的index在tablview的section范围内，则滚动tableview到相应位置
            if (index < self.tableView.numberOfSections) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
            //通知代理
            if([self.delegate respondsToSelector:@selector(tableViewIndexBar:didSelectRowAtIndex:)]){
                [self.delegate tableViewIndexBar:self didSelectRowAtIndex:index];
            }
        }
    }
}
#pragma mark -- kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:kTableViewKVOContentOffSetName])
    {
        NSValue *oldvalue = change[NSKeyValueChangeOldKey];
        NSValue *newvalue = change[NSKeyValueChangeNewKey];
        CGFloat oldoffset_y = oldvalue.UIOffsetValue.vertical;
        CGFloat newoffset_y = newvalue.UIOffsetValue.vertical;
        NSLog(@"Old:%f\nNew:%f",oldoffset_y,newoffset_y);
        NSLog(@"isTracking:%d---isDragging:%d----isDecelerating:%d", self.tableView.isTracking, self.tableView.isDragging, self.tableView.isDecelerating);
        // 这个if条件的意思是scrollView的滑动不是由手指拖拽产生
        if (!self.tableView.isDragging && !self.tableView.isDecelerating) {return;}

        // 当滑到边界时，继续通过scrollView的bouces效果滑动时，直接return
        if (self.tableView.contentOffset.y < 0 || self.tableView.contentOffset.y > self.tableView.contentSize.height - self.tableView.bounds.size.height) {
            return;
        }
        //如果contenoffset不变了说明停止滚动了，否则还在滚动
        if(newoffset_y == oldoffset_y){
            [self tableViewDidEndScroll];
        }else{
            [self tableViewDidScroll];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#pragma mark -- scroll
/**
 tableView滚动
 */
- (void)tableViewDidScroll{
    //开始滚动，首先判断索引栏是常驻显示还是
    //计算出当前滚动到的section
    NSInteger index = self.tableView.indexPathsForVisibleRows[0].section;
    [self didSelectRowIndex:index byTouch:NO];
    //如果是滚动显示并且当前是隐藏状态
    if (kGWTableViewIndexBarScrollShowStyle == self.showStyle && self.hidden && self.indexTitlesArray.count >= self.minimumShowCount) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissIndexBar) object:nil];
        [self showIndexBar];
    }
}
/**
 tableView停止滚动
 */
- (void)tableViewDidEndScroll{
    if (kGWTableViewIndexBarScrollShowStyle == self.showStyle && !self.hidden) {
        [self performSelector:@selector(dismissIndexBar) withObject:nil afterDelay:1.0];
    }
}
#pragma mark -- animation
/**
 显示索引栏
 */
- (void)showIndexBar{
    if (!self.hidden) {
        return;
    }
    self.hidden = NO;
    self.alpha = 0.0;
    [UIView animateWithDuration:kShowIndexBarAnimationTime animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.alpha = 1.0;
    }];
}
/**
 隐藏索引栏
 */
- (void)dismissIndexBar{
    if (self.hidden) {
        return;
    }
    [UIView animateWithDuration:kDisimissIndexBarAnimationTime delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.alpha = 1.0;
        self.hidden = YES;
    }];
}

/**
 显示指示器

 @param titleStr 指示器的标题
 @param centerY  指示器的中心点Y值
 */
- (void)showIndecatorWithTitle:(NSString *)titleStr andcenterY:(CGFloat)centerY{
    //取消隐藏指示器的方法
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissIndecatorTitle) object:nil];
    //根据指示器的中心Y值计算出Center
    CGPoint center = self.indexTitleBgView.center;
    center.y = centerY;
    self.indexTitleBgView.center = center;
    self.indexTitleLabel.text = titleStr;
    //如果指示器背景视图已添加到父视图，说明已经显示，只用做位移动画，否则做透明度动画
    if (self.indexTitleBgView.superview) {
        [self.superview bringSubviewToFront:self.indexTitleBgView];
        self.indexTitleBgView.alpha = 1.0;
    }else{
        self.indexTitleBgView.center = center;
        [self.superview addSubview:self.indexTitleBgView];
        [self.superview bringSubviewToFront:self.indexTitleBgView];
        self.indexTitleBgView.alpha = 0.0;
        [UIView animateWithDuration:kIndicatorAnimationTime
                              delay:0.0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.indexTitleBgView.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             self.indexTitleBgView.alpha = 1.0;
                             //用户操作完后延迟执行隐藏指示器
                             [self performSelector:@selector(dismissIndecatorTitle) withObject:nil afterDelay:1.0];
                         }];
    }
    
}

/**
 隐藏指示器
 */
- (void)dismissIndecatorTitle{
    if (self.indexTitleBgView.superview) {
        [UIView animateWithDuration:kIndicatorAnimationTime
             delay:0.0
           options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut
        animations:^{
            self.indexTitleBgView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.indexTitleBgView.alpha = 0.0;
            [self.indexTitleBgView removeFromSuperview];
        }];
    }
}
@end
