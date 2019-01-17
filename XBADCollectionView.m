//
//  XBADCollectionView.m
//  XBADCollectionView
//
//  Created by XXB on 16/6/30.
//  Copyright © 2016年 XXB. All rights reserved.
//

#import "XBADCollectionView.h"
#import "Masonry.h"
#import "XBADCollectionViewCell.h"


@interface XBADCollectionView ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) NSTimer *time;
@property (nonatomic,strong) NSArray *imageSource;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,assign) BOOL notFirstRun;
@property (nonatomic,assign) CGFloat draggingStartTime;
@property (nonatomic,assign) CGFloat draggingEndTime;
@end

@implementation XBADCollectionView

#pragma mark - 初始化
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super initWithCoder:aDecoder])
    {
        [self initParams];
        [self setupSubviews];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame])
    {
        [self initParams];
        [self setupSubviews];
    }
    return self;
}

-(void)initParams
{
    self.timeOfImageChange=4.0;
    
    //注册监听
    //注册监听 监听APP重后台回到前台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appBecomeActiveNotification:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //注册监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
}
-(void)dealloc
{
    [self removeTime];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)setupSubviews
{
    //CollectionView相关
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    //水平滚动
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    // 每个item之间的最小间距
    flow.minimumInteritemSpacing = 0;
    // 每行最小间距
    flow.minimumLineSpacing = 0;
    
    //创建xbCollectionView
    self.xbCollectionView= [[UICollectionView alloc] initWithFrame:CGRectMake(10, 10, 100, 100) collectionViewLayout:flow];
    [self addSubview:self.xbCollectionView];
    
    self.xbCollectionView.pagingEnabled=YES;
    self.xbCollectionView.delegate = self;
    self.xbCollectionView.dataSource = self;
    self.xbCollectionView.backgroundColor=[UIColor whiteColor];
    self.xbCollectionView.showsHorizontalScrollIndicator=NO;
    self.xbCollectionView.showsVerticalScrollIndicator=NO;
    
    // 注册item:
    [self.xbCollectionView registerNib:[UINib nibWithNibName:@"XBADCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"XBADCollectionViewCell"];
    
    //布局xbCollectionView
    [self.xbCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    
    //pageControl相关
    self.xbPageControl=[[UIPageControl alloc] init];
    [self addSubview:self.xbPageControl];
    
    [self.xbPageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(20);
    }];
}


- (void)appEnterBackgroundNotification:(NSNotificationCenter *)note
{
    //APP推到后台注销掉定时器 避免在后台的时候APP闪退
    [self removeTime];
}

- (void)appBecomeActiveNotification:(NSNotificationCenter *)note
{
    [self addTime];
}
#pragma mark - collectionView代理方法
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageSource.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XBADCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"XBADCollectionViewCell" forIndexPath:indexPath];
    cell.placeholderImageName=self.placeholderImageName;
    
    NSInteger index=indexPath.item%self.imageSource.count;
    
    if (self.imageUrlArr)
    {
        cell.imageUrl=self.imageSource[index];
    }
    else if (self.imageNameArr)
    {
        cell.imageName=self.imageSource[index];
    }
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.bounds.size;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(xbADCollectionView:clickAtIndex:)])
    {
        [self.delegate xbADCollectionView:self clickAtIndex:self.index%(self.imageSource.count/2)];
    }
}


#pragma mark - UIScrollView代理方法
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self removeTime];
    self.draggingStartTime=[NSDate date].timeIntervalSince1970;
    //上一次结束拖动的时间到此次拖动的时间间隔小于0.2秒
    if (self.draggingStartTime-self.draggingEndTime<0.5)
    {
        [self addTime];
        return;
    }
    //滚动结束前不可交互
    scrollView.userInteractionEnabled=NO;
    
    XBFlog(@"%zd",self.index);
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.draggingEndTime=[NSDate date].timeIntervalSince1970;
    [self fixIndex];
    //    [self feint];
    XBFlog(@"%zd",self.index);
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self addTime];
    //    self.draggingEndTime=[NSDate date].timeIntervalSince1970;
    //    if (self.draggingEndTime-self.draggingStartTime<0.2)
    //    {
    //        return;
    //    }
    
    /*这个方法获取的坐标不准确*/
    //    NSIndexPath *visiablePath= [[self.xbCollectionView indexPathsForVisibleItems] firstObject];
    //    NSInteger index=visiablePath.item;
    
    // 将collectionView在控制器view的中心点转化成collectionView上的坐标
    CGPoint pInView = [self convertPoint:self.xbCollectionView.center toView:self.xbCollectionView];
    // 获取这一点的indexPath
    NSIndexPath *indexPathNow = [self.xbCollectionView indexPathForItemAtPoint:pInView];
    
    //在本方法中,拖动结束后,self.index只可能为1或者self.imageSource.count-1
    self.index = indexPathNow.item;
    
    
    XBFlog(@"index：%zd",indexPathNow);
    
    //滚动结束后(不论手动还是自动)需要调用的方法
    [self setNeedParamsWithImageIndex:self.index%(self.imageSource.count/2)];
    
    //视觉欺骗
    [self fixIndex];
    [self feint];
    
    //滚动结束前不可交互,滚动完成后开启交互开关
    scrollView.userInteractionEnabled=YES;
    
    
    XBFlog(@"self.index：%zd",self.index);
}
//自动滚动才跑这个方法
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    //滚动结束后(不论手动还是自动)需要调用的方法
    [self setNeedParamsWithImageIndex:self.index%(self.imageSource.count/2)];
    
    [self fixIndex];
    //先动画滚动再偷偷滚动不可行,偷偷滚动会覆盖掉动画滚动,无法显示动画,只能先判断位置,偷偷滚动,再动画滚动
    [self feint];
    
    //滚动完成后开启交互开关
    scrollView.userInteractionEnabled=YES;
    XBFlog(@"%zd",self.index);
}


#pragma mark - 其他方法
-(void)addTime
{
    
    //        return;
    if (self.imageSource.count>3 && self.time==nil)
    {
        self.time = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(nextAdv:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.time forMode:NSRunLoopCommonModes];
    }
}
-(void)removeTime
{
    
    //        return;
    [self.time invalidate];
    self.time = nil;
}
-(void)nextAdv:(NSTimer *)time
{
    
    //不可交互
    self.xbCollectionView.userInteractionEnabled=NO;
    
    if (self.notFirstRun==NO)
    {
        //第一次自动滚动前偷偷滚动到index位置,避免一次滚动多张图的情况
        [self feint];
        self.notFirstRun=YES;
    }
    
    self.index++;
    [self.xbCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}
-(void)setPageControlCurrentPage:(NSInteger)index
{
    
    self.xbPageControl.currentPage=index;
}

#pragma mark - 改变图片后需要调用的公共方法
//滚动结束后(不论手动还是自动)需要调用的方法
-(void)setNeedParamsWithImageIndex:(NSInteger)index
{
    
    [self setPageControlCurrentPage:index];
}

#pragma mark - 核心方法-欺骗视觉
-(void)fixIndex
{
    
    if (self.index==self.imageSource.count-1)
    {
        self.index=self.imageSource.count/2-1;
    }
    else if (self.index==0)
    {
        self.index=self.imageSource.count/2;
    }
}
-(void)feint
{
    
    if (self.imageSource.count>0)
    {
        [self.xbCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}



#pragma mark - 方法重写
-(void)setImageNameArr:(NSArray *)imageNameArr
{
    
    _imageNameArr=imageNameArr;
    
    if(self.imageUrlArr.count>0)
    {
        return;
    }
    
    [self setCollectionViewOffset:imageNameArr];
}
-(void)setImageUrlArr:(NSArray *)imageUrlArr
{
    
    _imageUrlArr=imageUrlArr;
    
    [self setCollectionViewOffset:imageUrlArr];
}
-(void)setCollectionViewOffset:(NSArray *)arr
{
    
    if (arr.count==0 || arr==nil)//如果数组为空或者为nil,啥也不做
    {
        return;
    }
    else if (arr.count==1)//如果数组元素数量为1,不可滚动,不显示pageControl
    {
        self.xbCollectionView.scrollEnabled=NO;
        self.xbPageControl.numberOfPages=0;
    }
    else //数组元素数量大于1
    {
        self.xbCollectionView.scrollEnabled=YES;
        self.xbPageControl.numberOfPages=arr.count;
    }
    
    NSMutableArray *arrM=[NSMutableArray arrayWithArray:arr];
    [arrM addObjectsFromArray:arr];
    self.imageSource=arrM;
    
    self.index=arr.count;
    
    //延迟刷新,等collectionView自动布局完成,保证item的size正确
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.xbCollectionView reloadData];
        [self fixIndex];
        [self feint];
        [self removeTime];
        [self addTime];
    });
}
-(void)setPlaceholderImageName:(NSString *)placeholderImageName
{
    
    _placeholderImageName=placeholderImageName;
    self.imageNameArr=@[placeholderImageName];
}



@end

