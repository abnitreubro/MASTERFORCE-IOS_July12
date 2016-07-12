//
//  IpCameraClientAppDelegate.m
//  IpCameraClient
//
//  Created by jiyonglong on 12-4-23.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "IpCameraClientAppDelegate.h"
#import "obj_common.h"
#import "CameraViewController.h"
#include <sys/param.h>
#include <sys/mount.h>

#import "RemoteRecordFileListViewController.h"

#import "MyDocumentView.h"
@implementation IpCameraClientAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize startViewController;
@synthesize playViewController;
@synthesize playbackViewController;
@synthesize remotePlaybackViewController;

@synthesize appForegroudProtocol;
//@synthesize loginController;

@synthesize myNavController;
#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    PPPP_Initialize((CHAR*)"EJTDHXEHIASQARSTEIPAPHATLKASPDEKPNLNLTAUHUHXSULVEESVSWAOEHPKLULXARSTPGSQPDLNPEPALRPFLKLOLQLP-$$");
    //hide the status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    
    startViewController = [[StartViewController alloc] init];
    
    m_pCameraListMgt = [[CameraListMgt alloc] init];
    m_pPicPathMgt = [[PicPathManagement alloc] init];
    m_pRecPathMgt = [[RecPathManagement alloc] init];

    m_pPPPPChannelMgt = new CPPPPChannelManagement();
    
//    loginController=[[LoginController alloc] init];
//    loginController.pChannelMgt=m_pPPPPChannelMgt;
//    loginController.m_pPicPathMgt=m_pPicPathMgt;
//    loginController.m_pRecPathMgt=m_pRecPathMgt;
//    loginController.m_pCameraListMgt=m_pCameraListMgt;
//    navigationController = [[UINavigationController alloc] initWithRootViewController:loginController];
//   [navigationController setNavigationBarHidden:YES];
    
    
    self.appStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];

    
//    [self.window addSubview:startViewController.view];
//    self.window.rootViewController=startViewController;
//    [self.window makeKeyAndVisible];
//    [NSThread detachNewThreadSelector:@selector(StartThread:) toTarget:self withObject:nil];
    return YES;
    
}


 -(void)usedSpaceAndfreeSpace{
         NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;
         NSFileManager* fileManager = [[NSFileManager alloc ]init];
         NSDictionary *fileSysAttributes = [fileManager attributesOfFileSystemForPath:path error:nil];
        NSNumber *freeSpace = [fileSysAttributes objectForKey:NSFileSystemFreeSize];
        NSNumber *totalSpace = [fileSysAttributes objectForKey:NSFileSystemSize];

     NSLog(@"剩余%0.0fM/总%0.0fM",[freeSpace longLongValue]/1024.0/1024.0,[totalSpace longLongValue]/1024.0/1024.0);
}



- (void) StartThread: (id) param
{
   
    st_PPPP_NetInfo NetInfo;
    PPPP_NetworkDetect(&NetInfo, 0);    
    usleep(1000000);
    [self performSelectorOnMainThread:@selector(switchView:) withObject:nil waitUntilDone:NO];
}

- (void) switchView: (id) param
{
    [self.startViewController.view removeFromSuperview];
    
    PlayViewController *playView = [[PlayViewController alloc] init];
    playView.m_pPPPPChannelMgt = m_pPPPPChannelMgt;
    playView.strDID = @"OBJ-002864-STBZD";//OBJ-002864-STBZD/OBJ-003816-JVTGK
    playView.strUser=@"admin";
    playView.strPwd=@"";
    playView.cameraName = @"";
    playView.m_nP2PMode =1;// [nPPPPMode intValue];
    [self switchPlayView:playView];
    [playView release];
}

- (void) switchRemotePlaybackView: (RemotePlaybackViewController*)_remotePlaybackViewController;
{
    for (UIView *view in [self.window subviews])
    {
        [view removeFromSuperview];
    }
    
    self.remotePlaybackViewController = _remotePlaybackViewController ;

    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.window addSubview:remotePlaybackViewController.view];
}

- (void) switchPlaybackView: (PlaybackViewController*)_playbackViewController
{
    for (UIView *view in [self.window subviews]) {
        [view removeFromSuperview];
    }
    
    self.playbackViewController = _playbackViewController ;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [self.window addSubview:playbackViewController.view];
}

- (void) switchPlayView:(PlayViewController *)_playViewController
{
    for (UIView *view in [self.window subviews]) {
        [view removeFromSuperview];
    }
    
    self.playViewController = _playViewController ;
    self.playViewController.m_pPicPathMgt = m_pPicPathMgt;
    self.playViewController.m_pRecPathMgt = m_pRecPathMgt;
    self.playViewController.PicNotifyDelegate = picViewController;
    self.playViewController.RecNotifyDelegate = recViewController;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    if (navigationController !=nil) {
        [navigationController release];
        navigationController = nil;
    }
    navigationController = [[UINavigationController alloc] initWithRootViewController:_playViewController];
    [navigationController setNavigationBarHidden:YES];
    //[self.window addSubview:_playViewController.view];
    self.window.rootViewController=navigationController;
}
- (void) switchBack
{
    for (UIView *view in [self.window subviews]) {
        [view removeFromSuperview];
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [self.window addSubview:navigationController.view];
    if (self.playViewController != nil) {
        self.playViewController = nil;
    }
    if (self.playbackViewController != nil) {
        self.playbackViewController = nil;
    }
    
    if (self.remotePlaybackViewController != nil) {
        self.remotePlaybackViewController = nil;
    }
}
- (void) switchBack:(NSString*)did User:(NSString*)user Pwd:(NSString*)pwd Type:(NSInteger)type
{
    for (UIView *view in [self.window subviews]){
        [view removeFromSuperview];
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [self.window addSubview:navigationController.view];
    
    if (type==100)
    {
        MyDocumentView *documController=[[MyDocumentView alloc]init];
        documController.strDID=did;
        documController.strUser=user;
        documController.strPwd=pwd;
        documController.m_pPPPPChannelMgt=m_pPPPPChannelMgt;
        [self.navigationController pushViewController:documController animated:YES];
        [documController release];
    }else if(type==10){
        NSLog(@"popToRootViewController");
       // [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        NSLog(@"popToRootViewController _______");
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    
    if (self.playViewController != nil) {
        self.playViewController = nil;
    } 
    if (self.playbackViewController != nil) {
        self.playbackViewController = nil;
    }

    if (self.remotePlaybackViewController != nil) {
        self.remotePlaybackViewController = nil;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    //NSLog(@"applicationWillResignActive");
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    if (playViewController != nil) {
        [playViewController StopPlay:1];
    }
    
    if (playbackViewController != nil) {
        [playbackViewController StopPlayback];
    }
    
    if (remotePlaybackViewController != nil) {
        [remotePlaybackViewController StopPlayback];
    }

    //[cameraViewController StopPPPP];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
//    NSLog(@"applicationWillEnterForeground");

    //[cameraViewController StartPPPPThread];
    
    
    NSLog(@"applicationWillEnterForeground====");
    
    PlayViewController *playView = [[PlayViewController alloc] init];
    playView.m_pPPPPChannelMgt = m_pPPPPChannelMgt;
    playView.strDID = @"OBJ-002864-STBZD";//OBJ-002864-STBZD
    playView.strUser=@"admin";
    playView.strPwd=@"";
    playView.cameraName = @"";
    playView.m_nP2PMode =1;// [nPPPPMode intValue];
    [self switchPlayView:playView];
    [playView release];
    
    return;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    //NSLog(@"applicationDidBecomeActive");    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    //NSLog(@"applicationWillTerminate");
    
}




#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
    //NSLog(@"applicationDidReceiveMemoryWarning");
}

- (void)dealloc 
{
    //NSLog(@"IpCameraClientAppDelegate dealloc");
    self.window = nil;
    self.startViewController = nil;
    self.navigationController = nil;
    self.playViewController = nil;
    self.remotePlaybackViewController = nil;
    self.playbackViewController = nil;
    
   // self.loginController=nil;
    if (cameraViewController != nil) {
        [cameraViewController release];
        cameraViewController = nil;
    }
    PPPP_DeInitialize();
    if(m_pCameraListMgt != nil){
        [m_pCameraListMgt release];
        m_pCameraListMgt = nil;
    }
    if (picViewController != nil) {
        [picViewController release];
        picViewController = nil;
    }
    if (recViewController != nil) {
        [recViewController release];
        recViewController = nil;
    }
    [IpCameraClientAppDelegate setEnterBackground:NO];
    SAFE_DELETE(m_pPPPPChannelMgt);
    [super dealloc];
}

+(BOOL)is43Version{
    int version=[[[UIDevice currentDevice]systemVersion] integerValue];
    //NSLog(@"version=%d",version);
    BOOL b=NO;
    if (version<4.5) {
        b=YES;
    }
    return b;
}

+(BOOL)isIOS7Version{
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    // NSLog(@"version=%f",version);
    BOOL b=NO;
    if (version>6.9) {
        
        b=YES;
    }
    return b;
}
+(void)setEnterBackground:(BOOL)flag{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:flag] forKey:@"setEnterBackground"];
}
+(BOOL)getEnterBackground{
    return  [[[NSUserDefaults standardUserDefaults] objectForKey:@"setEnterBackground"] boolValue];
}

@end
