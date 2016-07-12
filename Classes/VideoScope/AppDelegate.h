//
//  AppDelegate.h
//  VideoScope
//
//  Created by JS Products on 04/03/16.
//  Copyright © 2016  JS Products. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

// IP Camera
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
#import "MyNavgationController.h"
// IP Camera




@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    // IP CAMERA Variable declaration
    UINavigationController *navigationController;
    PlayViewController *playViewController;
    CameraViewController *cameraViewController;
    PlaybackViewController *playbackViewController;
    RemotePlaybackViewController *remotePlaybackViewController;
    
    id<AppEnterForegroundProtocol> appForegroudProtocol;
    
    MyNavgationController *myNavController;
    BOOL isEnterForeground;
// IP CAMERA
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) UIStoryboard *appStoryboard;
@property CameraListMgt *m_pCameraListMgt;
@property PicPathManagement *m_pPicPathMgt;
@property RecPathManagement *m_pRecPathMgt;
@property CPPPPChannelManagement *m_pPPPPChannelMgt ;
@property PictureViewController *picViewController;
@property RecordViewController *recViewController;


+(AppDelegate *)instance;








// IP CAMERA Prperties declaration
@property (nonatomic,retain)MyNavgationController *myNavController;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) PlayViewController *playViewController;
@property (nonatomic, retain) PlaybackViewController *playbackViewController;
@property (nonatomic, retain) RemotePlaybackViewController *remotePlaybackViewController;

//@property (nonatomic,retain) LoginController *loginController;


@property (nonatomic,retain)id<AppEnterForegroundProtocol> appForegroudProtocol;
- (void) switchPlayView: (PlayViewController *)playViewController;
- (void) switchPlaybackView: (PlaybackViewController*)_playbackViewController;
- (void) switchRemotePlaybackView: (RemotePlaybackViewController*)_remotePlaybackViewController;
- (void) switchBack:(NSString*)did User:(NSString*)user Pwd:(NSString*)pwd Type:(NSInteger)type;
- (void) switchView: (id) param;
+(BOOL)is43Version;
+(BOOL)isIOS7Version;

+(void)setEnterBackground:(BOOL)flag;
+(BOOL)getEnterBackground;

@end

