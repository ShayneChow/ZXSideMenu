//
//  ZXsideMenu.h
//  ZXSideMenu
//
//  Created by Xiang on 15/11/9.
//  Copyright © 2015年 微加科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZXSideMenu : UIViewController

@property (nonatomic, readonly) UIViewController *contentController;
@property (nonatomic, readonly) UIViewController *menuController;

@property (nonatomic, assign) CGFloat menuWidth;
@property (nonatomic, assign) BOOL tapGestureEnabled;
@property (nonatomic, assign) BOOL panGestureEnabled;

- (id)initWithContentController:(UIViewController *)contentController
                 menuController:(UIViewController *)menuController;

- (void)setContentController:(UIViewController *)contentController
                     animted:(BOOL)animated;

// 菜单的显示和隐藏
- (void)showMenuAnimated:(BOOL)animated;
- (void)hideMenuAnimated:(BOOL)animated;
- (BOOL)isMenuVisible;

// 设置菜单界面背景图
- (void)setBackgroundImage:(UIImage *)image;

@end
