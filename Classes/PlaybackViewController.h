//
//  PlaybackViewController.h
//  P2PCamera
//
//  Created by mac on 12-11-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecPathManagement.h"
#import "LocalPlayback.h"
#import "PlaybackProtocol.h"
#import "MyGLViewController.h"

@interface PlaybackViewController : UIViewController<UINavigationBarDelegate, PlaybackProtocol>{
    IBOutlet UIImageView *imageView;
    IBOutlet UINavigationBar *navigationBar;
    
    RecPathManagement *m_pRecPathMgt;
    int m_nSelectIndex;
    
    CLocalPlayback *m_pLocalPlayback;
    
    NSString *strDID;
    NSString *strDate;
    
    UIView *bottomView;
    UIButton *playButton;
    UILabel *startLabel;
    UILabel *endLabel;
    UISlider *slider;
    
    UIImage *imagePlayNormal;
    UIImage *imagePlayPressed;
    UIImage *imagePauseNormal;
    UIImage *imagePausePressed;
    
    int m_nTotalTime;
    
    BOOL m_bPlayPause;
    BOOL m_bHideToolBar;
    
    MyGLViewController *myGLViewController;
    int m_nScreenHeight;
    int m_nScreenWidth;
    
    NSCondition *m_playbackstoplock;
    UILabel *TimeStampLabel;
    BOOL isP2P;
}

@property (nonatomic, retain) UINavigationBar *navigationBar;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, assign) int m_nSelectIndex;
@property (nonatomic, assign) RecPathManagement *m_pRecPathMgt;
@property (nonatomic, copy) NSString *strDID;
@property (nonatomic, copy) NSString *strDate;
@property (nonatomic, retain) UIImage *imagePlayNormal;
@property (nonatomic, retain) UIImage *imagePlayPressed;
@property (nonatomic, retain) UIImage *imagePauseNormal;
@property (nonatomic, retain) UIImage *imagePausePressed;

@property (nonatomic,retain) NSString * videoFilePath;

- (void) StopPlayback;


@end
