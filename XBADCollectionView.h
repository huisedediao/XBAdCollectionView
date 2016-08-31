//
//  XBADCollectionView.h
//  XBADCollectionView
//
//  Created by XXB on 16/6/30.
//  Copyright © 2016年 XXB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XBADCollectionView;

@protocol XBADCollectionViewDelegate <NSObject>

-(void)xbADCollectionView:(XBADCollectionView *)xbADCollectionView clickAtIndex:(NSInteger)index;

@end

@interface XBADCollectionView : UIView

@property (nonatomic,strong) UICollectionView *xbCollectionView;
@property (strong,nonatomic) UIPageControl *xbPageControl;


/** 图片url数据源 */
@property (strong,nonatomic) NSArray *imageUrlArr;
/** 图片名称数据源 */
@property (strong,nonatomic) NSArray *imageNameArr;


/** 图片滚动时间间隔,默认4秒 */
@property (assign,nonatomic) CGFloat timeOfImageChange;
/** 占位图片名,在设置图片数据源之前设置此项 */
@property (copy,nonatomic) NSString *placeholderImageName;


/** 自动滚动或者手动滚动后需要设置的参数或者调用的方法,留子类继承用 */
//-(void)setNeedParams;


/** 代理 */
@property (nonatomic,weak) id <XBADCollectionViewDelegate> delegate;

/** 手动调用,修复滚动中切换界面卡顿,切回以后卡住的问题 */
-(void)feint;

/**
 *  子类继承方法,重写需要调用[super setNeedParamsWithImageIndex:index];
 *
 *  @param index:代表当前显示的是第几张图片
 */
//滚动结束后(不论手动还是自动)需要调用的方法
-(void)setNeedParamsWithImageIndex:(NSInteger)index;
@end
