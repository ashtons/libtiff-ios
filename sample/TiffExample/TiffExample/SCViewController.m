//
//  SCViewController.m
//  TiffExample
//
//  Created by Sean Ashton on 31/01/2014.
//  Copyright (c) 2014 Schimera Pty Ltd. All rights reserved.
//

#import "SCViewController.h"
#import "TiffUtils.h"

@interface SCViewController ()

@end

@implementation SCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSString *tifFilePath = [[NSBundle mainBundle] pathForResource:@"example" ofType:@"tif"];
    if (tifFilePath) {
        NSInteger frames = [TiffUtils numberOfFramesInFile:tifFilePath];
        NSLog(@"There are %ld frames in the file", (long)frames);
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
