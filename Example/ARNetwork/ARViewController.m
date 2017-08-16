//
//  ARViewController.m
//  ARNetwork
//
//  Created by Daniel on 12/12/2016.
//  Copyright (c) 2016 Daniel. All rights reserved.
//

#import "ARViewController.h"
@import ARNetwork;

@interface ARViewController ()

@end

@implementation ARViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[ARHTTPManager sharedInstance] getURL:@"http://httpbin.org/get" params:nil success:^(id data, NSString *msg) {
        
    } failure:^(NSInteger code, NSString *msg) {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
