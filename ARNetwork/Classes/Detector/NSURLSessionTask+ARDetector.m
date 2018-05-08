//
//  NSURLSessionTask+ARDetector.m
//  ARNetwork
//
//  Created by Daniel Lin on 2018/5/7.
//  Copyright (c) 2018 Daniel Lin. All rights reserved.

#import "NSURLSessionTask+ARDetector.h"
#import "_NSObject+ARProperty.h"

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

@dynamic ar_loadingDetective, ar_loadingSuperView;

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self _addBasicProperty:@"ar_loadingDetective" encodingType:@encode(BOOL)];
        [self _addObjectProperty:@"ar_loadingSuperView"];
    });
}

- (void)ar_detectLoading {
    [self ar_detectLoadingWithSuperView:nil];
}

- (void)ar_detectLoadingWithSuperView:(UIView *)superView {
    self.ar_loadingDetective = YES;
    self.ar_loadingSuperView = superView ?: [UIViewController ar_topWithinRootViewController].view;
}

@end


