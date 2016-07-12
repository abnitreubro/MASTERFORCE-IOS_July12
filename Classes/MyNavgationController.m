//
//  MyNavgationController.m
//  P2PCamera
//
//  Created by Tsang on 13-3-19.
//
//

#import "MyNavgationController.h"

@interface MyNavgationController ()

@end

@implementation MyNavgationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
-(BOOL)shouldAutorotate{
    NSLog(@"shouldAutorotate");
    return NO;
}
//-(NSUInteger)supportedInterfaceOrientations{
//    return UIInterfaceOrientationPortrait;
//}
//-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
//    return toInterfaceOrientation==UIInterfaceOrientationMaskPortrait;
//}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
