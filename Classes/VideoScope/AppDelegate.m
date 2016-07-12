//
//  AppDelegate.m
//  VideoScope
//
//  Created by JS Products on 04/03/16.
//  Copyright © 2016  JS Products. All rights reserved.
//

#import "AppDelegate.h"
#import "Constant.h"

#import "obj_common.h"
#import "CameraViewController.h"
#include <sys/param.h>
#include <sys/mount.h>
#import "PlayViewController.h"


#import "RemoteRecordFileListViewController.h"

#import "MyDocumentView.h"





@interface AppDelegate ()

@end



@implementation AppDelegate
@synthesize navigationController;
@synthesize playViewController;
@synthesize playbackViewController;
@synthesize remotePlaybackViewController;
@synthesize appForegroudProtocol;
@synthesize myNavController;
@synthesize m_pCameraListMgt;
@synthesize m_pPicPathMgt;
@synthesize m_pPPPPChannelMgt;
@synthesize m_pRecPathMgt;
@synthesize picViewController;
@synthesize recViewController;



+(AppDelegate *)instance {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOption
{
    
    // Override point for customization after application launch.

    self.appStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];

    if (![[NSUserDefaults standardUserDefaults]objectForKey:ISRECORDAUDIO]) {
        
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:ISRECORDAUDIO];
        
    }
    
    if (![[NSUserDefaults standardUserDefaults]objectForKey:RECORDINGTIME]) {
        
        [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:RECORDINGTIME];

    }
    PPPP_Initialize((CHAR*)"EJTDHXEHIASQARSTEIPAPHATLKASPDEKPNLNLTAUHUHXSULVEESVSWAOEHPKLULXARSTPGSQPDLNPEPALRPFLKLOLQLP-$$");

    m_pCameraListMgt = [[CameraListMgt alloc] init];
    m_pPicPathMgt = [[PicPathManagement alloc] init];
    m_pRecPathMgt = [[RecPathManagement alloc] init];
    
    m_pPPPPChannelMgt = new CPPPPChannelManagement();
    
    [NSThread detachNewThreadSelector:@selector(StartThread:) toTarget:self withObject:nil];
    sleep(5);

    [self removeFileIfNotProperlySaved];
    
    return YES;
}


# pragma mark - IPCamera methods


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
    PlayViewController *playView = [[PlayViewController alloc] init];
    playView.m_pPPPPChannelMgt = m_pPPPPChannelMgt;
    playView.strDID = @"OBJ-002864-STBZD";//OBJ-002864-STBZD/OBJ-003816-JVTGK
    playView.strUser=@"admin";
    playView.strPwd=@"";
    playView.cameraName = @"";
    playView.m_nP2PMode =1;// [nPPPPMode intValue];
    [self switchPlayView:playView];
}

- (void) switchRemotePlaybackView: (RemotePlaybackViewController*)_remotePlaybackViewController;
{
    self.remotePlaybackViewController = _remotePlaybackViewController ;
}

- (void) switchPlaybackView: (PlaybackViewController*)_playbackViewController
{
    self.playbackViewController = _playbackViewController ;
}

- (void) switchPlayView:(PlayViewController *)_playViewController
{
    
    self.playViewController = _playViewController ;
    self.playViewController.m_pPicPathMgt = m_pPicPathMgt;
    self.playViewController.m_pRecPathMgt = m_pRecPathMgt;
    self.playViewController.PicNotifyDelegate = picViewController;
    self.playViewController.RecNotifyDelegate = recViewController;
    
}
- (void) switchBack
{
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    if (self.playViewController != nil) {
        self.playViewController = nil;
    }
    if (self.playbackViewController != nil) {
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
    
    
    if (type==100)
    {
        MyDocumentView *documController=[[MyDocumentView alloc]init];
        documController.strDID=did;
        documController.strUser=user;
        documController.strPwd=pwd;
        documController.m_pPPPPChannelMgt=m_pPPPPChannelMgt;
        [self.navigationController pushViewController:documController animated:YES];
    }
    else if(type==10)
    {
        NSLog(@"popToRootViewController");
    }
    else
    {
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

#pragma mark -
# pragma mark - IP cmera methods ends

#pragma mark- Application Lifecycle

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
}



-(void)removeFileIfNotProperlySaved
{
    NSLog(@"Recording: %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"recording"]);
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"recording"]!= nil)
    {
        if ([[[[NSUserDefaults standardUserDefaults] valueForKey:@"recording"] objectAtIndex:0] isEqualToString:@"Started"] )
        {
            if ([[[[NSUserDefaults standardUserDefaults] valueForKey:@"recording"] objectAtIndex:2] isEqualToString:@"p2p"]) {
                
                if ([[[[NSUserDefaults standardUserDefaults] valueForKey:@"recording"] objectAtIndex:2] isEqualToString:@"Audio"]) { //// starte, audio,p2p - So remove paths for audio and video from document directory.
                    
                    NSURL * AudioURlP2P = [NSURL fileURLWithPath:[[NSUserDefaults standardUserDefaults] valueForKey:@"audio"]];
                    NSURL * VideoURLP2P=[NSURL fileURLWithPath:[[NSUserDefaults standardUserDefaults] valueForKey:@"video"]];
                    
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    
                    if ([fileManager fileExistsAtPath:[AudioURlP2P path]]) {
                        
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        [fileManager removeItemAtPath:[AudioURlP2P path]  error:NULL];
                        
                    }
                    
                    if ([fileManager fileExistsAtPath:[VideoURLP2P path]]) {
                        
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        [fileManager removeItemAtPath:[VideoURLP2P path]  error:NULL];
                        
                    }
                    
                    
                }
                else // remove from recordVideoPath
                {
                    [m_pRecPathMgt RemovePath:[[[NSUserDefaults standardUserDefaults] valueForKey:@"p2pDetails"] objectAtIndex:0] Date:[[[NSUserDefaults standardUserDefaults] valueForKey:@"p2pDetails"] objectAtIndex:1] Path:[[[NSUserDefaults standardUserDefaults] valueForKey:@"p2pDetails"] objectAtIndex:2]] ;
                }
            }
            else // IP camera
            {
                if ([[[[NSUserDefaults standardUserDefaults] valueForKey:@"recording"] objectAtIndex:2] isEqualToString:@"Audio"]) { //// starte, audio,IP - So remove paths for audio and video from document directory.
                    
                    NSURL * AudioURl = [NSURL fileURLWithPath:[[NSUserDefaults standardUserDefaults] valueForKey:@"audio"]];
                    NSURL * VideoURL=[NSURL fileURLWithPath:[[NSUserDefaults standardUserDefaults] valueForKey:@"video"]];
                    
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    
                    if ([fileManager fileExistsAtPath:[AudioURl path]]) {
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        [fileManager removeItemAtPath:[AudioURl path]  error:NULL];
                    }
                    
                    if ([fileManager fileExistsAtPath:[VideoURL path]]) {
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        [fileManager removeItemAtPath:[VideoURL path]  error:NULL];
                    }
                    
                }
                else // remove from recordVideoPath
                {
                    
                    NSURL * VideoURL=[NSURL fileURLWithPath:[[NSUserDefaults standardUserDefaults] valueForKey:@"video"]];
                    
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    
                    if ([fileManager fileExistsAtPath:[VideoURL path]]) {
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        [fileManager removeItemAtPath:[VideoURL path]  error:NULL];
                    }
                    
                }
            }
            
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"recording"];
        }
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"p2pDetails"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"audio"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"video"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"recording"];
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"applicationWillEnterForeground====");
    
    PlayViewController *playView = [[PlayViewController alloc] init];
    playView.m_pPPPPChannelMgt = m_pPPPPChannelMgt;
    playView.strDID = @"OBJ-002864-STBZD";//OBJ-002864-STBZD
    playView.strUser=@"admin";
    playView.strPwd=@"";
    playView.cameraName = @"";
    playView.m_nP2PMode =1;// [nPPPPMode intValue];
    [self switchPlayView:playView];
    
    
    
    return;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.


}
#pragma mark-
#pragma end


@end
