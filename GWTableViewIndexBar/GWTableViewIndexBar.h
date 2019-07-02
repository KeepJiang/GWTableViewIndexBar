//
//  GWTableViewIndexBar.h
//  GWTableViewIndexBar
//
//  Created by JZW on 2019/6/26.
//  Copyright © 2019 Beijing Gengwu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 索引栏显示方式

 - kGWTableViewIndexBarPermanentShowStyle: 常驻显示
 - kGWTableViewIndexBarScrollShowStyle: 开始滚动显示，滚动停止消失
 */
typedef NS_ENUM(NSInteger, kGWTableViewIndexBarShowStyle){
    kGWTableViewIndexBarPermanentShowStyle,
    kGWTableViewIndexBarScrollShowStyle
};
@class GWTableViewIndexBar;

@protocol GWTableViewIndexBarDelegate <NSObject>

/**
 当前选中了index位置的索引
 @param indexBar 索引栏
 @param index    选中位置
 */
- (void)tableViewIndexBar:(GWTableViewIndexBar *)indexBar didSelectRowAtIndex:(NSInteger) index;
@end

@interface GWTableViewIndexBar : UIView
/*! @brief 代理 */
@property(nonatomic, weak) id<GWTableViewIndexBarDelegate> delegate;
/*! @brief tableView */
@property(nonatomic, weak) UITableView *tableView;
/*! @brief 显示的最小section值的数量，默认10 */
@property(nonatomic, assign) NSInteger minimumShowCount;
/*! @brief 显示风格, 默认常驻显示 */
@property(nonatomic, assign) kGWTableViewIndexBarShowStyle showStyle;
/*! @brief 索引文字正常颜色，默认黑色 */
@property(nonatomic, strong) UIColor *normalTitleColor;
/*! @brief 索引文字正常字体，默认系统16号字体 */
@property(nonatomic, strong) UIFont *titleFont;
/*! @brief 索引文字高亮颜色 */
@property(nonatomic, strong) UIColor *highlighTitletColor;
/*! @brief 内间距，主要用来设置上下的间距，做圆角 */
@property(nonatomic, assign) UIEdgeInsets contentInset;
/*! @brief 单个索引的高度 */
@property(nonatomic, assign) CGFloat titleHeight;
/*! @brief 是否圆角，默认NO */
@property(nonatomic, assign) BOOL isCorner;
/*! @brief 索引文字高亮字体，默认同normalColor*/
//@property(nonatomic, strong) UIFont *highlightFont;//暂时未实现高亮字体大小和常规字体不同，会引起高度变化影响到布局
/*! @brief 索引文字数组 */
@property(nonatomic, strong) NSArray<NSString *> *indexTitlesArray;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
@end

NS_ASSUME_NONNULL_END
