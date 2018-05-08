//
//  ARViewController.m
//  ARNetwork
//
//  Created by Daniel on 12/12/2016.
//  Copyright (c) 2016 Daniel. All rights reserved.
//

#import "ARViewController.h"
#import "ARExampleResultModel.h"

#import "ARNetwork_Example-Swift.h"

@import ARNetwork;

@interface ARViewController ()

@end

@implementation ARViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    NSString *urlString = @"http://httpbin.org/get";
    
    NSURLSessionDataTask *task_1 = [[ARHTTPManager sharedInstance] getURL:urlString params:nil success:^(id data, NSString *msg) {

    } failure:^(NSInteger code, NSString *msg) {

    }];
    [task_1 ar_detectLoadingWithSuperView:self.view];
    
//    [ARHTTPMock getRequestURL:urlString responseByMainBundleJSONFile:@"ARExampleResultModel"];
    [ARExampleResultModel getURL:urlString params:nil dataCache:ARCacheTypeLoadAndUpdate success:^(ARExampleResultModel *data, NSString *msg, BOOL isCached) {
        SwiftExample *example = [[SwiftExample alloc] init];
        example.result = data;
    } failure:^(NSInteger code, NSString *msg) {

    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
