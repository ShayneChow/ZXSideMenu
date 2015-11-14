//
//  ZXsideMenu.m
//  ZXSideMenu
//
//  Created by Xiang on 15/11/9.
//  Copyright © 2015年 微加科技. All rights reserved.
//

#import "ZXSideMenu.h"

// constants
const CGFloat ZXSideMenuMinimumRelativePanDistanceToOpen = 0.33;
const CGFloat ZXSideMenuDefaultMenuWidth = 260.0;
const CGFloat ZXSideMenuDefaultDamping = 0.5;

// 动画持续时间
const CGFloat ZXSideMenuDefaultOpenAnimationTime = 1.2;
const CGFloat ZXSideMenuDefaultCloseAnimationTime = 0.4;

@interface ZXSideMenu ()
/** 菜单背景图 */
@property (nonatomic, strong) UIImageView *bgImageView;
/** 菜单视图 */
@property (nonatomic, strong) UIView *containerView;
/** 点击手势 */
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
/** 拖动手势 */
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;

@end

@implementation ZXSideMenu

#pragma mark - init

- (id)initWithContentController:(UIViewController *)contentController
                 menuController:(UIViewController *)menuController {
    return self;
}

#pragma mark - ViewController Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubviews];
    
    [self setupGesture];
}

// 设置菜单界面背景图
- (void)setBackgroundImage:(UIImage *)image {
    if (!self.bgImageView && image) {
        self.bgImageView = [[UIImageView alloc] initWithImage:image];
        self.bgImageView.frame = self.view.bounds;
        self.bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view insertSubview:self.bgImageView atIndex:0];
    } else if (image == nil) {
        [self.bgImageView removeFromSuperview];
        self.bgImageView = nil;
    } else {
        self.bgImageView.image = image;
    }
}

- (void)setupSubviews {
    // add childcontroller
    [self addChildViewController:self.menuController];
    [self.menuController didMoveToParentViewController:self];
    [self addChildViewController:self.contentController];
    [self.contentController didMoveToParentViewController:self];
    
    // add subviews
    _containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    [self.containerView addSubview:self.contentController.view];
    self.contentController.view.frame = self.containerView.bounds;
    self.contentController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_containerView];
}

- (void)setupGesture {
    // 此处添加手势操作方法
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognized:)];
    [self.containerView addGestureRecognizer:self.tapRecognizer];
    [self.containerView addGestureRecognizer:self.panRecognizer];
}

#pragma mark - 手势方法

- (void)tapRecognized:(UITapGestureRecognizer*)recognizer
{
    if (!self.tapGestureEnabled) return;
    
    if (![self isMenuVisible]) {
        [self showMenuAnimated:YES];
    } else {
        [self hideMenuAnimated:YES];
    }
}

- (void)panRecognized:(UIPanGestureRecognizer*)recognizer
{
    if (!self.panGestureEnabled) return;
    
    CGPoint translation = [recognizer translationInView:recognizer.view];
    CGPoint velocity = [recognizer velocityInView:recognizer.view];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            [self addMenuControllerView];
            [recognizer setTranslation:CGPointMake(recognizer.view.frame.origin.x, 0) inView:recognizer.view];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            [recognizer.view setTransform:CGAffineTransformMakeTranslation(MAX(0,translation.x), 0)];
//            [self statusBarView].transform = recognizer.view.transform;
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (velocity.x > 5.0 || (velocity.x >= -1.0 && translation.x > ZXSideMenuMinimumRelativePanDistanceToOpen*self.menuWidth)) {
                CGFloat transformedVelocity = velocity.x/ABS(self.menuWidth - translation.x);
                CGFloat duration = ZXSideMenuDefaultOpenAnimationTime * 0.66;
                [self showMenuAnimated:YES duration:duration initalVelocity:transformedVelocity];
            } else {
                [self hideMenuAnimated:YES];
            }
        }
        default:
            break;
    }
}

- (BOOL)isMenuVisible {
    return !CGAffineTransformEqualToTransform(self.containerView.transform,
                                              CGAffineTransformIdentity);
}

#pragma mark - 切换视图控制器

- (void)setContentController:(UIViewController *)contentController
                     animted:(BOOL)animated {
    if (contentController == nil) return;
    UIViewController *previousController = self.contentController;
    _contentController = contentController;
    
    // 添加子控制器
    [self addChildViewController:self.contentController];
    
    // 添加子视图
    self.contentController.view.frame = self.containerView.bounds;
    self.contentController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // 加载动画
    __weak typeof(self) weakSelf = self;    // 避免在block中使用self造成循环引用
    CGFloat offset = ZXSideMenuDefaultMenuWidth + (self.view.frame.size.width-ZXSideMenuDefaultMenuWidth)/2.0;
    [UIView animateWithDuration:ZXSideMenuDefaultCloseAnimationTime/2.0 animations:^{
        weakSelf.containerView.transform = CGAffineTransformMakeTranslation(offset, 0);
//        [weakSelf statusBarView].transform = weakSelf.containerView.transform;
    } completion:^(BOOL finished) {
        // move to container view
        [weakSelf.containerView addSubview:self.contentController.view];
        [weakSelf.contentController didMoveToParentViewController:weakSelf];
        
        // remove old controller
        [previousController willMoveToParentViewController:nil];
        [previousController removeFromParentViewController];
        [previousController.view removeFromSuperview];
        
        [weakSelf hideMenuAnimated:YES];
    }];
}

#pragma mark - 菜单的显示和隐藏
// 菜单的显示
- (void)showMenuAnimated:(BOOL)animated {
    [self showMenuAnimated:animated duration:ZXSideMenuDefaultOpenAnimationTime initalVelocity:1.0];
}

- (void)showMenuAnimated:(BOOL)animated duration:(CGFloat)duration initalVelocity:(CGFloat)velocity {
    // 添加菜单控制器
    [self addMenuControllerView];
    
    // 添加动画
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:animated ? duration : 0 delay:0 usingSpringWithDamping:ZXSideMenuDefaultDamping initialSpringVelocity:velocity options:UIViewAnimationOptionAllowUserInteraction animations:^{
        weakSelf.containerView.transform = CGAffineTransformMakeTranslation(self.menuWidth, 0);
    } completion:nil];
    
}

- (void)addMenuControllerView {
    NSLog(@"加载菜单控制器");
    if (self.menuController.view.superview == nil) {
        CGRect menuFrame, restFrame;
        CGRectDivide(self.view.bounds, &menuFrame, &restFrame, self.menuWidth, CGRectMinXEdge);
        self.menuController.view.frame = menuFrame;
        self.menuController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        self.view.backgroundColor = self.menuController.view.backgroundColor;
        if (self.bgImageView) [self.view insertSubview:self.menuController.view aboveSubview:self.bgImageView];
        else [self.view insertSubview:self.menuController.view atIndex:0];
    }
}

// 菜单的隐藏
- (void)hideMenuAnimated:(BOOL)animated {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:ZXSideMenuDefaultCloseAnimationTime animations:^{
        weakSelf.containerView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [weakSelf.menuController.view removeFromSuperview];
    }];
}

@end
