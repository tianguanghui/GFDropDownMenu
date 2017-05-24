//
//  GFDropDownMenu.m
//  60fen
//
//  Created by TianGuanghui on 2017/5/23.
//  Copyright © 2017年 Xuelang Borui Education Technology (Beijing) Co., Ltd. All rights reserved.
//
#define IS_iPad         (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#import "GFDropDownMenu.h"

#import "GFDropDownCollectionViewCell.h"

#define kDropDownCollectionColumn           2
#define kDropDownCollectionMaxRow           5
#define kDropDownCollectionHeightIPad       88
#define kDropDownCollectionHeightIPhone     44
#define kDropDownCollectionMargin           5
#define kDropDownCollectionPadding          5
#define kGFDropDownTextFontSizeIPad         28
#define kGFDropDownTextFontSizeIPhone       14
#define kGFDropDownCollectionViewCellIdentifier @"GFDropDownCollectionViewCellIdentifier"

#pragma mark - menu implementation

@interface GFDropDownMenu ()
@property (nonatomic, assign) NSInteger currentSelectedMenudIndex;
@property (nonatomic, assign) BOOL show;
@property (nonatomic, assign) NSInteger numOfMenu;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, strong) UIView *backGroundView;
@property (nonatomic, strong) UICollectionView *collectionView;
//data source
@property (nonatomic, copy) NSArray *array;
//layers array
/**
 标题
 */
@property (nonatomic, copy) NSArray *titles;
/**
 箭头
 */
@property (nonatomic, copy) NSArray *indicators;
/**
 背景
 */
@property (nonatomic, copy) NSArray *bgLayers;
/**
 分割线
 */
@property (nonatomic, copy) NSArray *lineLayers;
@end


@implementation GFDropDownMenu

#pragma mark - getter
- (UIColor *)lineColor {
    if (!_lineColor) {
        _lineColor = [UIColor lightGrayColor];
    }
    return _lineColor;
}

- (UIColor *)indicatorColor {
    if (!_indicatorColor) {
        _indicatorColor = [UIColor blackColor];
    }
    return _indicatorColor;
}

- (UIColor *)textColor {
    if (!_textColor) {
        _textColor = [UIColor blackColor];
    }
    return _textColor;
}

- (UIColor *)separatorColor {
    if (!_separatorColor) {
        _separatorColor = [UIColor blackColor];
    }
    return _separatorColor;
}

- (NSString *)titleForRowAtIndexPath:(GFDDIndexPath *)indexPath {
    return [self.dataSource menu:self titleForRowAtIndexPath:indexPath];
}

#pragma mark - setter
- (void)setDataSource:(id<GFDropDownMenuDataSource>)dataSource {
    _dataSource = dataSource;
    
    //configure view
    if ([_dataSource respondsToSelector:@selector(numberOfColumnsInMenu:)]) {
        _numOfMenu = [_dataSource numberOfColumnsInMenu:self];
    } else {
        _numOfMenu = 1;
    }
    
    CGFloat textLayerInterval = self.frame.size.width / ( _numOfMenu * 2);
    CGFloat bgLayerInterval = self.frame.size.width / _numOfMenu;
    
    NSMutableArray *tempTitles = [[NSMutableArray alloc] initWithCapacity:_numOfMenu];
    NSMutableArray *tempIndicators = [[NSMutableArray alloc] initWithCapacity:_numOfMenu];
    NSMutableArray *tempBgLayers = [[NSMutableArray alloc] initWithCapacity:_numOfMenu];
    NSMutableArray *tempLineLayers = [[NSMutableArray alloc] initWithCapacity:_numOfMenu];
    
    for (int i = 0; i < _numOfMenu; i++) {
        //bgLayer
        CGPoint bgLayerPosition = CGPointMake((i+0.5)*bgLayerInterval, self.frame.size.height/2);
        CALayer *bgLayer = [self createBgLayerWithColor:[UIColor whiteColor] andPosition:bgLayerPosition];
        [self.layer addSublayer:bgLayer];
        [tempBgLayers addObject:bgLayer];
        //title
        CGPoint titlePosition = CGPointMake( (i * 2 + 1) * textLayerInterval , self.frame.size.height / 2);
        NSString *titleString = [_dataSource menu:self titleForRowAtIndexPath:[GFDDIndexPath indexPathWithCol:i row:0]];
        CATextLayer *title = [self createTextLayerWithNSString:titleString withColor:self.textColor andPosition:titlePosition];
        [self.layer addSublayer:title];
        [tempTitles addObject:title];
        //indicator
        CAShapeLayer *indicator = [self createIndicatorWithColor:self.indicatorColor andPosition:CGPointMake(titlePosition.x + title.bounds.size.width / 2 + 8, self.frame.size.height / 2)];
        [self.layer addSublayer:indicator];
        [tempIndicators addObject:indicator];
    }
    //添加竖直分割线
    for (int i = 0; i < _numOfMenu; i++) {
        if (i != _numOfMenu-1) {
            CGPoint lineLayerPosition = CGPointMake((i+1)*bgLayerInterval, self.frame.size.height/2);
            CAShapeLayer *lineLayer = [self createLineLayerWithColor:self.lineColor andPosition:lineLayerPosition];
            [self.layer addSublayer:lineLayer];
            [tempLineLayers addObject:lineLayer];
        }
    }
    
    _titles = [tempTitles copy];
    _indicators = [tempIndicators copy];
    _bgLayers = [tempBgLayers copy];
    _lineLayers = [tempLineLayers copy];
}

#pragma mark - init method
- (instancetype)initWithOrigin:(CGPoint)origin andHeight:(CGFloat)height {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self = [self initWithFrame:CGRectMake(origin.x, origin.y, screenSize.width, height)];
    if (self) {
        _origin = origin;
        _currentSelectedMenudIndex = -1;
        _show = NO;
        
        //tableView init
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0) collectionViewLayout:flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[GFDropDownCollectionViewCell class] forCellWithReuseIdentifier:kGFDropDownCollectionViewCellIdentifier];
        [_collectionView setBackgroundColor:[UIColor whiteColor]];
        
        //self tapped
        self.backgroundColor = [UIColor whiteColor];
        UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTapped:)];
        [self addGestureRecognizer:tapGesture];
        
        //background init and tapped
        _backGroundView = [[UIView alloc] initWithFrame:CGRectMake(origin.x, origin.y, screenSize.width, screenSize.height)];
        _backGroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        _backGroundView.opaque = NO;
        UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
        [_backGroundView addGestureRecognizer:gesture];
        
        //add bottom shadow
        UIView *bottomShadow = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-0.5, screenSize.width, 0.5)];
        bottomShadow.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:bottomShadow];
    }
    return self;
}

#pragma mark - init support
/**
 创建color颜色的以position为中心点的图层

 @param color 颜色
 @param position 中心点
 @return 创建的图层
 */
- (CALayer *)createBgLayerWithColor:(UIColor *)color andPosition:(CGPoint)position {
    CALayer *layer = [CALayer layer];
    layer.position = position;
    layer.bounds = CGRectMake(0, 0, self.frame.size.width/self.numOfMenu, self.frame.size.height-1);
    layer.backgroundColor = color.CGColor;
    NSLog(@"bglayer bounds:%@",NSStringFromCGRect(layer.bounds));
    NSLog(@"bglayer position:%@", NSStringFromCGPoint(position));
    
    return layer;
}

- (CAShapeLayer *)createLineLayerWithColor:(UIColor *)color andPosition:(CGPoint)position {
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(0, 5)];
    [path addLineToPoint:CGPointMake(0, self.frame.size.height-5)];
    
    layer.path = path.CGPath;
    layer.lineWidth = 1.0;
    layer.strokeColor = color.CGColor;
    layer.fillColor = nil;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    CGPathRelease(bound);
    
    layer.position = position;
    
    return layer;
}

- (CAShapeLayer *)createIndicatorWithColor:(UIColor *)color andPosition:(CGPoint)position {
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    //绘制下三角
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(5, 5)];
    [path addLineToPoint:CGPointMake(10, 0)];
    layer.path = path.CGPath;
    layer.lineWidth = 1.0;
    layer.strokeColor = color.CGColor;
    layer.fillColor = nil;
    
    //绘制三角形
//    [path moveToPoint:CGPointMake(0, 0)];
//    [path addLineToPoint:CGPointMake(8, 0)];
//    [path addLineToPoint:CGPointMake(4, 5)];
//    [path closePath];
//    layer.path = path.CGPath;
//    layer.lineWidth = 1.0;
//    layer.strokeColor = color.CGColor;
//    layer.fillColor = color.CGColor;
    
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    CGPathRelease(bound);
    
    layer.position = position;
    
    return layer;
}

- (CATextLayer *)createTextLayerWithNSString:(NSString *)string withColor:(UIColor *)color andPosition:(CGPoint)position {
    
    CGSize size = [self calculateTitleSizeWithString:string];
    
    CATextLayer *layer = [CATextLayer new];
    CGFloat sizeWidth = (size.width < (self.frame.size.width / _numOfMenu) - 25) ? size.width : self.frame.size.width / _numOfMenu - 25;
    layer.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    layer.string = string;
    if (IS_iPad) {
        layer.fontSize = kGFDropDownTextFontSizeIPad;
    }
    else {
        layer.fontSize = kGFDropDownTextFontSizeIPhone;
    }
    layer.alignmentMode = kCAAlignmentCenter;
    layer.foregroundColor = color.CGColor;
    
    layer.contentsScale = [[UIScreen mainScreen] scale];
    
    layer.position = position;
    
    return layer;
}

- (CGSize)calculateTitleSizeWithString:(NSString *)string
{
    CGFloat fontSize = 0;
    if (IS_iPad) {
        fontSize = kGFDropDownTextFontSizeIPad;
    }
    else {
        fontSize = kGFDropDownTextFontSizeIPhone;
    }
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    CGSize size = [string boundingRectWithSize:CGSizeMake(280, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return size;
}

#pragma mark - gesture handle
- (void)menuTapped:(UITapGestureRecognizer *)paramSender {
    CGPoint touchPoint = [paramSender locationInView:self];
    //calculate index
    NSInteger tapIndex = touchPoint.x / (self.frame.size.width / _numOfMenu);
    
    for (int i = 0; i < _numOfMenu; i++) {
        if (i != tapIndex) {
            [self animateIndicator:_indicators[i] Forward:NO complete:^{
                [self animateTitle:_titles[i] show:NO complete:^{
                    
                }];
            }];
            [(CALayer *)self.bgLayers[i] setBackgroundColor:[UIColor whiteColor].CGColor];
        }
    }
    
    if (tapIndex == _currentSelectedMenudIndex && _show) {
        [self animateIdicator:_indicators[_currentSelectedMenudIndex] background:_backGroundView collectionView:_collectionView title:_titles[_currentSelectedMenudIndex] forward:NO complecte:^{
            _currentSelectedMenudIndex = tapIndex;
            _show = NO;
        }];
        [(CALayer *)self.bgLayers[tapIndex] setBackgroundColor:[UIColor whiteColor].CGColor];
    } else {
        _currentSelectedMenudIndex = tapIndex;
        [_collectionView reloadData];
        [self animateIdicator:_indicators[tapIndex] background:_backGroundView collectionView:_collectionView title:_titles[tapIndex] forward:YES complecte:^{
            _show = YES;
        }];
        [(CALayer *)self.bgLayers[tapIndex] setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1.0].CGColor];
    }
}

- (void)backgroundTapped:(UITapGestureRecognizer *)paramSender
{
    [self animateIdicator:_indicators[_currentSelectedMenudIndex] background:_backGroundView collectionView:_collectionView title:_titles[_currentSelectedMenudIndex] forward:NO complecte:^{
        _show = NO;
    }];
    [(CALayer *)self.bgLayers[_currentSelectedMenudIndex] setBackgroundColor:[UIColor whiteColor].CGColor];
}

#pragma mark - animation method
- (void)animateIndicator:(CAShapeLayer *)indicator Forward:(BOOL)forward complete:(void(^)())complete {
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.25];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.4 :0.0 :0.2 :1.0]];
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    anim.values = forward ? @[ @0, @(M_PI) ] : @[ @(M_PI), @0 ];
    
    if (!anim.removedOnCompletion) {
        [indicator addAnimation:anim forKey:anim.keyPath];
    } else {
        [indicator addAnimation:anim forKey:anim.keyPath];
        [indicator setValue:anim.values.lastObject forKeyPath:anim.keyPath];
    }
    
    [CATransaction commit];
    
    complete();
}

- (void)animateBackGroundView:(UIView *)view show:(BOOL)show complete:(void(^)())complete {
    if (show) {
        [self.superview addSubview:view];
        [view.superview addSubview:self];
        
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    }
    complete();
}

- (void)animateCollectionView:(UICollectionView *)collectionView show:(BOOL)show complete:(void(^)())complete {
    if (show) {
        collectionView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0);
        [self.superview addSubview:collectionView];
        
        CGFloat extraHeight = (kDropDownCollectionMargin*2)+kDropDownCollectionPadding*(ceilf([collectionView numberOfItemsInSection:0]*1.0/kDropDownCollectionColumn-1));
        NSInteger minRows = MIN(ceilf([collectionView numberOfItemsInSection:0]*1.0/kDropDownCollectionColumn), kDropDownCollectionMaxRow);
        
        CGFloat collectionViewHeight = (IS_iPad?kDropDownCollectionHeightIPad:kDropDownCollectionHeightIPhone)*minRows+extraHeight;
        
        [UIView animateWithDuration:0.2 animations:^{
            _collectionView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, collectionViewHeight);
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            _collectionView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0);
        } completion:^(BOOL finished) {
            [collectionView removeFromSuperview];
        }];
    }
    complete();
}

- (void)animateTitle:(CATextLayer *)title show:(BOOL)show complete:(void(^)())complete {
    CGSize size = [self calculateTitleSizeWithString:title.string];
    CGFloat sizeWidth = (size.width < (self.frame.size.width / _numOfMenu) - 25) ? size.width : self.frame.size.width / _numOfMenu - 25;
    title.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    complete();
}

- (void)animateIdicator:(CAShapeLayer *)indicator background:(UIView *)background collectionView:(UICollectionView *)collectionView title:(CATextLayer *)title forward:(BOOL)forward complecte:(void(^)())complete{
    
    [self animateIndicator:indicator Forward:forward complete:^{
        [self animateTitle:title show:forward complete:^{
            [self animateBackGroundView:background show:forward complete:^{
                [self animateCollectionView:collectionView show:forward complete:^{
                }];
            }];
        }];
    }];
    
    complete();
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSAssert(self.dataSource != nil, @"menu's dataSource shouldn't be nil");
    if ([self.dataSource respondsToSelector:@selector(menu:numberOfRowsInColumn:)]) {
        return [self.dataSource menu:self numberOfRowsInColumn:self.currentSelectedMenudIndex];
    } else {
        NSAssert(0 == 1, @"required method of dataSource protocol should be implemented");
        return 0;
    }
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(self.dataSource != nil, @"menu's dataSource shouldn't be nil");
    GFDropDownCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kGFDropDownCollectionViewCellIdentifier forIndexPath:indexPath];
    NSAssert(self.dataSource != nil, @"menu's datasource shouldn't be nil");
    if ([self.dataSource respondsToSelector:@selector(menu:titleForRowAtIndexPath:)]) {
        cell.textLabel.text = [self.dataSource menu:self titleForRowAtIndexPath:[GFDDIndexPath indexPathWithCol:self.currentSelectedMenudIndex row:indexPath.row]];
    } else {
        NSAssert(0 == 1, @"dataSource method needs to be implemented");
    }
    cell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    if ([cell.textLabel.text isEqualToString: [(CATextLayer *)[_titles objectAtIndex:_currentSelectedMenudIndex] string]]) {
        cell.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    }
    
    cell.layer.cornerRadius = (IS_iPad?kDropDownCollectionHeightIPad:kDropDownCollectionHeightIPhone)*1.0/2;
    [cell setClipsToBounds:YES];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self confiMenuWithSelectRow:indexPath.row];
    if (self.delegate || [self.delegate respondsToSelector:@selector(menu:didSelectRowAtIndexPath:)]) {
        [self.delegate menu:self didSelectRowAtIndexPath:[GFDDIndexPath indexPathWithCol:self.currentSelectedMenudIndex row:indexPath.row]];
    }
}

- (void)confiMenuWithSelectRow:(NSInteger)row {
    CATextLayer *title = (CATextLayer *)_titles[_currentSelectedMenudIndex];
    title.string = [self.dataSource menu:self titleForRowAtIndexPath:[GFDDIndexPath indexPathWithCol:self.currentSelectedMenudIndex row:row]];
    
    [self animateIdicator:_indicators[_currentSelectedMenudIndex] background:_backGroundView collectionView:_collectionView title:_titles[_currentSelectedMenudIndex] forward:NO complecte:^{
        _show = NO;
    }];
    [(CALayer *)self.bgLayers[_currentSelectedMenudIndex] setBackgroundColor:[UIColor whiteColor].CGColor];
    
    CAShapeLayer *indicator = (CAShapeLayer *)_indicators[_currentSelectedMenudIndex];
    indicator.position = CGPointMake(title.position.x + title.frame.size.width / 2 + 8, indicator.position.y);
}

- (void)dismiss {
    [self backgroundTapped:nil];
}

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component {
    _currentSelectedMenudIndex = component;
    [self confiMenuWithSelectRow: row];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(floor((self.frame.size.width-kDropDownCollectionMargin*2-kDropDownCollectionPadding*(kDropDownCollectionColumn-1))*1.0/kDropDownCollectionColumn), (IS_iPad?kDropDownCollectionHeightIPad:kDropDownCollectionHeightIPhone));
}

//定义每个UICollectionView 的 margin
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(kDropDownCollectionMargin, kDropDownCollectionMargin, kDropDownCollectionMargin, kDropDownCollectionMargin);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kDropDownCollectionMargin;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kDropDownCollectionMargin;
}

@end
