//
//  NSURLSessionTask+ARDetector.m
//  ARNetwork
//
//  Created by Daniel Lin on 2018/5/7.
//  Copyright (c) 2018 Daniel Lin. All rights reserved.

#import "NSURLSessionTask+ARDetector.h"
#import <objc/runtime.h>

@interface UIViewController (ARPrivate)
- (instancetype)ar_topViewController;
+ (nullable instancetype)ar_topWithinRootViewController;
@end

@implementation UIViewController (ARPrivate)

- (instancetype)ar_topViewController {
    UIViewController *topViewController = self;
    UIViewController *presentedViewController = self.presentedViewController;
    while (presentedViewController) {
        topViewController = presentedViewController;
        presentedViewController = topViewController.presentedViewController;
    }
    
    if ([topViewController isKindOfClass:UINavigationController.class]) {
        return ((UINavigationController *)topViewController).topViewController.ar_topViewController;
    }
    
    if ([topViewController isKindOfClass:UITabBarController.class]) {
        return ((UITabBarController *)topViewController).selectedViewController.ar_topViewController;
    }
    
    NSArray<UIViewController *> *children = topViewController.childViewControllers;
    if (children.count > 0) {
        return children[0].ar_topViewController;
    }
    
    return topViewController;
}

+ (instancetype)ar_topWithinRootViewController {
    return UIApplication.sharedApplication.keyWindow.rootViewController.ar_topViewController;
}

@end

@implementation NSURLSessionTask (ARDetector)

- (BOOL)ar_loadingDetective {
    return objc_getAssociatedObject(self, @selector(ar_loadingDetective));
}

- (void)setAr_loadingDetective:(BOOL)ar_loadingDetective {
    if (ar_loadingDetective != self.ar_loadingDetective) {
        SEL keySEL = @selector(ar_loadingDetective);
        NSString *key = NSStringFromSelector(keySEL);
        [self willChangeValueForKey:key];
        objc_setAssociatedObject(self, keySEL, @(ar_loadingDetective), OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:key];
    }
}

- (UIView *)ar_loadingSuperView {
    return objc_getAssociatedObject(self, @selector(ar_loadingSuperView));
}

- (void)setAr_loadingSuperView:(UIView *)ar_loadingSuperView {
    if (ar_loadingSuperView != self.ar_loadingSuperView) {
        SEL keySEL = @selector(ar_loadingSuperView);
        NSString *key = NSStringFromSelector(keySEL);
        [self willChangeValueForKey:key];
        objc_setAssociatedObject(self, keySEL, ar_loadingSuperView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self didChangeValueForKey:key];
    }
}

- (void)ar_detectLoading {
    [self ar_detectLoadingWithSuperView:nil];
}

- (void)ar_detectLoadingWithSuperView:(UIView *)superView {
    self.ar_loadingDetective = YES;
    self.ar_loadingSuperView = superView ?: [UIViewController ar_topWithinRootViewController].view;
}

@end


