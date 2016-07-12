//
//  ShowImageViewController.m
//  VideoScope
//
//  Created by JS Products on 15/03/16.
//  Copyright © 2016  JS Products. All rights reserved.
//

#import "ShowImageViewController.h"

@interface ShowImageViewController ()
{
    UIBarButtonItem *shareBtn;
}

@end

@implementation ShowImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // get Time and set title
    
    NSFileManager* fm = [NSFileManager defaultManager];
    NSDictionary* attrs = [fm attributesOfItemAtPath:_strImagePath error:nil];
    
    if (attrs != nil)
    {
        NSDate *date = (NSDate*)[attrs objectForKey: NSFileCreationDate];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat: @"MMM dd, yyyy, hh:mm:ss a"];
        
        NSString *strDate = [formatter stringFromDate:date]; // Convert date to string
        self.title=strDate;
    }
    
    // Set Background color
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setScrollView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideShowNavigation)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    
    shareBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButtonAction:)] ;
    
    self.navigationItem.rightBarButtonItems = @[shareBtn];
    
    
    interfaceImage.image=[UIImage imageWithData:[NSData dataWithContentsOfFile:self.strImagePath]];

}


#pragma mark - Hide/Unhide navigation Controller

- (void) hideShowNavigation
{
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
    
}



#pragma mark - Sharing

-(void)shareButtonAction:(id)sender{
    
    NSMutableArray *sharingItems = [NSMutableArray new];
    NSString *postText = [[NSString alloc] initWithFormat:@"%@ ",[self.strImagePath lastPathComponent] ];
    
    if (postText) {
        [sharingItems addObject:postText];
    }
    [sharingItems addObject:interfaceImage.image];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    
    activityViewController.popoverPresentationController.barButtonItem = shareBtn;
    
    [self presentViewController: activityViewController animated:YES completion:nil];
}



#pragma mark - Handling Image Zoom

-(void)setScrollView
{
    interFaceScrollView.delegate=self;
    
    interFaceScrollView.zoomScale=1.0f;
    interFaceScrollView.minimumZoomScale=1.0f;
    interFaceScrollView.maximumZoomScale=4.0f;
    interFaceScrollView.bounces=YES;
    interFaceScrollView.bouncesZoom=YES;
    interFaceScrollView.clipsToBounds = YES;
}



-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return interfaceImage;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}


- (void)centerScrollViewContents {
    // This method centers the scroll view contents also used on did zoom
    CGSize boundsSize = interFaceScrollView.bounds.size;
    CGRect contentsFrame = interfaceImage.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    interfaceImage.frame = contentsFrame;
}



#pragma mark - handling Device Orientation

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}







@end





