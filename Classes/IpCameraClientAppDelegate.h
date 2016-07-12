//
//  IpCameraClientAppDelegate.h
//  IpCameraClient
//
//  Created by jiyonglong on 12-4-23.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StartViewController.h"
#import "PlayViewController.h"
#import "CameraViewController.h"
#import "CameraListMgt.h"
#import "PicPathManagement.h"
#import "RecPathManagement.h"
#import "PlaybackViewController.h"
#import "PictureViewController.h"
#import "RecordViewController.h"
#import "PPPPChannelManagement.h"
#import "RemotePlaybackViewController.h"

#import "AppEnterForegroundProtocol.h"


//#import "LoginController.h"
#import "MyNavgationController.h"
@interface IpCameraClientAppDelegate : NSObject <UIApplicationDelegate> {
    
    IBOutlet UIWindow *window;    
    UINavigationController *navigationController;
    StartViewController *startViewController;    
    PlayViewController *playViewController;
    CameraViewController *cameraViewController;
    PlaybackViewController *playbackViewController;
    PictureViewController *picViewController;
    RecordViewController *recViewController;
    RemotePlaybackViewController *remotePlaybackViewController;
    
    CameraListMgt *m_pCameraListMgt;
    PicPathManagement *m_pPicPathMgt;
    RecPathManagement *m_pRecPathMgt;
    
    CPPPPChannelManagement *m_pPPPPChannelMgt ;
    
  //  LoginController *loginController;
    
    id<AppEnterForegroundProtocol> appForegroudProtocol;
    
    MyNavgationController *myNavController;
    BOOL isEnterForeground;
}

@property (nonatomic, retain) UIStoryboard *appStoryboard;



@property (nonatomic,retain)MyNavgationController *myNavController;
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) StartViewController *startViewController;
@property (nonatomic, retain) PlayViewController *playViewController;
@property (nonatomic, retain) PlaybackViewController *playbackViewController;
@property (nonatomic, retain) RemotePlaybackViewController *remotePlaybackViewController;

//@property (nonatomic,retain) LoginController *loginController;


@property (nonatomic,retain)id<AppEnterForegroundProtocol> appForegroudProtocol;
- (void) switchPlayView: (PlayViewController *)playViewController;
- (void) switchPlaybackView: (PlaybackViewController*)_playbackViewController;
- (void) switchRemotePlaybackView: (RemotePlaybackViewController*)_remotePlaybackViewController;
- (void) switchBack:(NSString*)did User:(NSString*)user Pwd:(NSString*)pwd Type:(NSInteger)type;

+(BOOL)is43Version;
+(BOOL)isIOS7Version;

+(void)setEnterBackground:(BOOL)flag;
+(BOOL)getEnterBackground;

@end

