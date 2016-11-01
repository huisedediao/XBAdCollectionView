# XBAdCollectionView
<br>
###使用：<br>
* 0.添加masonry，添加sdWebImage<br>
* 1.设置位置<br>
* 2.设置占位图片(可不设)：placeholderImageName<br>
* 3.设置图片数组（支持本地图片名称数组和网络图片url数组）<br>

<br><br>
###添加功能
<br><br>如果要添加功能，直接继承，重写setNeedParamsWithImageIndex：方法即可
传入的参数index即为当前显示的图片序号
<br><br>
###效果图
<br><br>
 ![image](https://github.com/huisedediao/XBAdCollectionView/raw/master/show.png)
<br>
<br>
###示例代码<br><br><br>
<pre>
@interface ViewController ()\<XBADCollectionViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
[super viewDidLoad];

XBADCollectionView *adV=[XBADCollectionView new];
[self.view addSubview:adV];
adV.frame=CGRectMake(0, 80, 320, 160);

adV.placeholderImageName=@"placeholderImage";
adV.imageUrlArr=@[@"https://ss2.baidu.com/6ONYsjip0QIZ8tyhnq/it/u=1269384707,518933899&fm=80&w=179&h=119&img.JPEG",@"https://ss2.baidu.com/6ONYsjip0QIZ8tyhnq/it/u=2066656253,3120099901&fm=80&w=179&h=119&img.JPEG"];
adV.delegate=self;
}

-(void)xbADCollectionView:(XBADCollectionView *)xbADCollectionView clickAtIndex:(NSInteger)index
{
NSLog(@"%zd",index);
}
@end
</pre>

