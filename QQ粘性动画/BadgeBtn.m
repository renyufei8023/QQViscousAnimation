//
//  BadgeBtn.m
//  QQ粘性动画
//
//  Created by 任玉飞 on 16/6/29.
//  Copyright © 2016年 任玉飞. All rights reserved.
//

#import "BadgeBtn.h"

@interface BadgeBtn()
@property (nonatomic, strong) UIView *smalScirl;
@property (nonatomic, strong) CAShapeLayer *shaplayer;

@end
@implementation BadgeBtn

- (CAShapeLayer *)shaplayer
{
    if (_shaplayer == nil) {
        
        _shaplayer = [CAShapeLayer layer];
        _shaplayer.fillColor = [UIColor colorWithRed:0.8615 green:0.1229 blue:0.262 alpha:1.0].CGColor;
        [self.superview.layer insertSublayer:_shaplayer atIndex:0];
    }
    return _shaplayer;
}
- (void)awakeFromNib
{
    [self setUp];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    self.layer.cornerRadius = self.bounds.size.width * 0.5;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    
    _smalScirl = [[UIView alloc]initWithFrame:self.frame];
    _smalScirl.backgroundColor = [UIColor colorWithRed:0.8615 green:0.1229 blue:0.262 alpha:1.0];
    _smalScirl.layer.cornerRadius = self.layer.cornerRadius;
    [self.superview insertSubview:_smalScirl belowSubview:self];
}

- (void)pan:(UIPanGestureRecognizer *)pan
{
    //偏移量
    CGPoint point = [pan translationInView:self];
    
    CGPoint center = self.center;
    
    center.x += point.x;
    center.y += point.y;
    
    self.center = center;
    
    [pan setTranslation:CGPointZero inView:self];
    
    CGFloat distance = [self distanceWithSmallCircle:_smalScirl bigCircle:self];
    
    NSLog(@"%f",distance);
    
    CGFloat radius = self.bounds.size.width * 0.5;
    radius = radius - distance / 10.0;
    
    _smalScirl.bounds = CGRectMake(0, 0, radius * 2, radius * 2);
    _smalScirl.layer.cornerRadius = radius;
    
    
    if (self.smalScirl.hidden == NO) {
        //返回一个不规则的路径.
        UIBezierPath *path = [self pathWithSmallCircle:self.smalScirl bigCircle:self];
        //把路径转换成图形.
        self.shaplayer.path = path.CGPath;
        
        
    }
    
    if (distance > 60) {
        _smalScirl.hidden = YES;
        [self.shaplayer removeFromSuperlayer];
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        
        if (distance < 60) {
            [self.shaplayer removeFromSuperlayer];
            self.shaplayer = nil;
            self.center = self.smalScirl.center;
            self.smalScirl.hidden = NO;
            
        }else{
            //播放一个动画
            UIImageView *imageV = [[UIImageView alloc] initWithFrame:self.bounds];
            
            NSMutableArray *imageArray = [NSMutableArray array];
            
            for (int i = 0; i < 8; i++) {
                NSString *imageName  = [NSString stringWithFormat:@"%d.jpg",i+1];
                UIImage *image = [UIImage imageNamed:imageName];
                [imageArray addObject:image];
            }
            
            imageV.animationImages = imageArray;
            [imageV setAnimationDuration:1];
            [imageV startAnimating];
            [self addSubview:imageV];
            //消失
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self removeFromSuperview];
            });
        }
        
    }
    
   
}

/**
 *  路径曲线
 *
 *  @param smallCircle chuanru
 *  @param bigCircle   <#bigCircle description#>
 *
 *  @return <#return value description#>
 */
- (UIBezierPath *)pathWithSmallCircle:(UIView *)smallCircle bigCircle:(UIView *)bigCircle
{
    CGFloat x1 = smallCircle.center.x;
    CGFloat x2 = bigCircle.center.x;
    
    CGFloat y1 = smallCircle.center.y;
    CGFloat y2 = bigCircle.center.y;
    
    CGFloat d = [self distanceWithSmallCircle:smallCircle bigCircle:bigCircle];
    
    CGFloat  cosθ = (y2 - y1) / d;
    CGFloat  sinθ = (x2 - x1) / d;
    
    CGFloat r1 = smallCircle.bounds.size.width * 0.5;
    CGFloat r2 = bigCircle.bounds.size.width * 0.5;
    
    
    CGPoint pointA = CGPointMake(x1 - r1 * cosθ, y1 + r1 * sinθ);
    CGPoint pointB = CGPointMake(x1 + r1 * cosθ, y1 - r1 * sinθ);
    CGPoint pointC = CGPointMake(x2 + r2 * cosθ, y2 - r2 * sinθ);
    CGPoint pointD = CGPointMake(x2 - r2 * cosθ, y2 + r2 * sinθ);
    CGPoint pointO = CGPointMake(pointA.x + d * 0.5 * sinθ, pointA.y + d * 0.5 * cosθ);
    CGPoint pointP = CGPointMake(pointB.x + d * 0.5 * sinθ, pointB.y + d * 0.5 * cosθ);
    
    
    //描述路径
    UIBezierPath *path = [UIBezierPath bezierPath];
    //AB
    [path moveToPoint:pointA];
    [path addLineToPoint:pointB];
    //BC(曲线)
    [path addQuadCurveToPoint:pointC controlPoint:pointP];
    //CD
    [path addLineToPoint:pointD];
    //DA(曲线)
    [path addQuadCurveToPoint:pointA controlPoint:pointO];
    
    return path;
}

- (CGFloat)distanceWithSmallCircle:(UIView *)smallCircle bigCircle:(UIView *)bigCircle
{
    CGFloat offsetx = bigCircle.center.x - smallCircle.center.x;
    CGFloat offsetY = bigCircle.center.y - smallCircle.center.y;
    return sqrtf(offsetx * offsetx + offsetY * offsetY);
}

- (void)setHighlighted:(BOOL)highlighted
{
    
}
@end
