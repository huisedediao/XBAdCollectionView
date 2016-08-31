//
//  XBADCollectionViewCell.m
//  XBADCollectionView
//
//  Created by XXB on 16/6/30.
//  Copyright © 2016年 XXB. All rights reserved.
//

#import "XBADCollectionViewCell.h"
#import "UIImageView+WebCache.h"

@interface XBADCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end


@implementation XBADCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}


-(void)setImageUrl:(NSString *)imageUrl
{
    _imageUrl=imageUrl;
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:self.placeholderImageName]];
}

-(void)setImageName:(NSString *)imageName
{
    _imageName=imageName;
    
    self.imageView.image=[UIImage imageNamed:imageName];
}
@end
