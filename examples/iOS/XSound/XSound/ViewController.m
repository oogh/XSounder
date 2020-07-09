//
//  ViewController.m
//  XSound
//
//  Created by Andy on 2020/7/6.
//  Copyright © 2020 oogh. All rights reserved.
//

#import "ViewController.h"
#import "XIosSounder.h"

@interface ViewController () {
    XIosSounder* _sounder;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)onOncePressClick:(UIButton *)sender {
    NSString* filename = [[NSBundle mainBundle] pathForResource:@"jieqian" ofType:@"pcm"];
    _sounder = [[XIosSounder alloc] init];
    [_sounder setInput:filename];
    [_sounder start];
}

@end
