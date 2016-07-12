//
//  PlaybackViewController.m
//  P2PCamera
//
//  Created by mac on 12-11-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RemotePlaybackViewController.h"
#import "obj_common.h"
#import "AppDelegate.h"

@interface RemotePlaybackViewController ()

@end

@implementation RemotePlaybackViewController

@synthesize navigationBar;
@synthesize imageView;
@synthesize strDID;
@synthesize m_strFileName;
@synthesize m_pPPPPMgnt;
@synthesize m_strName;
@synthesize progressView;
@synthesize LblProgress;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void) StopPlayback
{
    [m_playbackstoplock lock];
    
    m_pPPPPMgnt->PPPPStopPlayback((char*)[strDID UTF8String]);
    m_pPPPPMgnt->SetPlaybackDelegate((char*)[strDID UTF8String], nil);
    
    AppDelegate *IPCamDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [IPCamDelegate switchBack];
    
    [m_playbackstoplock unlock];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    m_bPlayPause = NO;
    m_bHideToolBar = NO;
    myGLViewController = nil;
    
    self.imageView.backgroundColor = [UIColor grayColor];
    
    m_playbackstoplock = [[NSCondition alloc] init];
    
    
    CGRect getFrame = [[UIScreen mainScreen]applicationFrame];
    m_nScreenHeight = getFrame.size.width;
    m_nScreenWidth = getFrame.size.height;
    
    navigationBar.barStyle = UIBarStyleBlackTranslucent;
    navigationBar.delegate = self;
    
    UIImage *image = [UIImage imageNamed:@"navbk.png"];
    [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.alpha = 0.6f;
    
    UINavigationItem *back = [[UINavigationItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Back", @STR_LOCALIZED_FILE_NAME, nil)];
    
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:m_strName];
    
    NSArray *array = [NSArray arrayWithObjects:back, item, nil];
    [navigationBar setItems:array];
    
    [item release];
    [back release];
    
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *imageGR=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTouched:)];
    [imageGR setNumberOfTapsRequired:1];
    [imageView addGestureRecognizer:imageGR];
    [imageGR release];
    
    
    //-------------bottomView--------------------------------------
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame] ;
    float bottomViewHeight = 60 ;
    float bottomViewX = 0;
    float bottomViewY = screenRect.size.width - bottomViewHeight ;
    float bottomViewWidth = screenRect.size.height;
    
    //NSLog(@"bottomViewX: %f, bottomViewY: %f, bottomViewWidth: %f, bottomViewHeight: %f", bottomViewX, bottomViewY, bottomViewWidth, bottomViewHeight);
    
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(bottomViewX, bottomViewY, bottomViewWidth, bottomViewHeight)];
    bottomView.backgroundColor = [UIColor colorWithRed:80/255.0f green:80/255.0f blue:80/255.0f alpha:1.0f];
    bottomView.alpha = 0.6f ;
    
    CGRect rectLabel = bottomView.bounds;
    
    UILabel *fileNameLabel = [[UILabel alloc] initWithFrame:rectLabel];
    fileNameLabel.textAlignment = UITextAlignmentCenter;
    fileNameLabel.text = m_strFileName;
    fileNameLabel.backgroundColor = [UIColor colorWithRed:80/255.0f green:80/255.0f blue:80/255.0f alpha:1.0f];
    fileNameLabel.textColor = [UIColor whiteColor];
    [bottomView addSubview:fileNameLabel];
    [fileNameLabel release];
    
    [self.view addSubview:bottomView];
    
    self.LblProgress.text = NSLocalizedStringFromTable(@"Connecting", @STR_LOCALIZED_FILE_NAME,nil);
    self.LblProgress.textColor = [UIColor whiteColor];
    [self.progressView startAnimating];
    
    //=====================================================================
    
    m_pPPPPMgnt->SetPlaybackDelegate((char*)[strDID UTF8String], self);
    if (!m_pPPPPMgnt->PPPPStartPlayback((char*)[strDID UTF8String],(char*)[m_strFileName UTF8String], 0)) {
        [self performSelectorOnMainThread:@selector(StopPlayback) withObject:nil waitUntilDone:NO];
    }
    
}

- (void) imageTouched: (UITapGestureRecognizer*)sender
{
    m_bHideToolBar = !m_bHideToolBar ;
    
    [navigationBar setHidden:m_bHideToolBar];
    [bottomView setHidden:m_bHideToolBar];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 6.0) {//ios6
        [self.view setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
        
        CGRect rectScreen = [[UIScreen mainScreen] applicationFrame];
        
        self.view.frame = rectScreen;//CGRectMake(0,0,480,320);
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    if (bottomView != nil) {
        [bottomView release];
        bottomView = nil;
    }
    if (playButton != nil) {
        [playButton release];
        playButton = nil;
    }
}

- (void) CreateGLView
{
    if (myGLViewController != nil) {
        return;
    }
    
    myGLViewController = [[MyGLViewController alloc] init];
    myGLViewController.view.frame = CGRectMake(0, 0, m_nScreenWidth, m_nScreenHeight);
    [self.view addSubview:myGLViewController.view];
    [self.view bringSubviewToFront:navigationBar];
    [self.view bringSubviewToFront:bottomView];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void) dealloc
{
    self.navigationBar = nil;
    self.imageView = nil;
    self.strDID = nil;
    self.m_strFileName = nil;
    self.m_strName = nil;
    self.progressView = nil;
    self.LblProgress = nil;
    
    if (bottomView != nil) {
        [bottomView release];
        bottomView = nil;
    }
        
    if (myGLViewController != nil) {
        [myGLViewController release];
        myGLViewController = nil;
    }
    
    if (m_playbackstoplock != nil) {
        [m_playbackstoplock release];
        m_playbackstoplock = nil;
    }
    [super dealloc];
}

#pragma mark -
#pragma mark performOnMainThread
- (void) updateImage: (UIImage*) image
{
    imageView.image = image;
     [image release];
}

- (void) hideView
{
    [self.progressView setHidden:YES];
    [self.LblProgress setHidden:YES];
}

#pragma mark -
#pragma mark navigationBarDelegate

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    [self StopPlayback];
    return NO;
}

#pragma mark -
- (void)YUVNotify:(Byte *)yuv length:(int)length width:(int)width height:(int)height timestamp:(unsigned int)timestamp
{
    [self performSelectorOnMainThread:@selector(hideView) withObject:nil waitUntilDone:NO];
    
    [self performSelectorOnMainThread:@selector(CreateGLView) withObject:nil waitUntilDone:NO];
    [myGLViewController WriteYUVFrame:yuv Len:length width:width height:height];
}

- (void)ImageNotify:(UIImage *)image timestamp:(NSInteger)timestamp
{
    [self performSelectorOnMainThread:@selector(hideView) withObject:nil waitUntilDone:NO];
    
    [self performSelectorOnMainThread:@selector(updateImage:) withObject:image waitUntilDone:NO];
}

- (void)H264Data:(Byte *)h264Frame length:(int)length type:(int)type timestamp:(NSInteger)timestamp
{
    
}


@end
