//
//  PlayViewController.h
//  IpCameraClient
//
//  Created by jiyonglong on 12-4-23.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPPPStatusProtocol.h"
#import "PPPPChannelManagement.h"
#import "ParamNotifyProtocol.h"
#import "ImageNotifyProtocol.h"
#import "PicPathManagement.h"
#import "CustomAVRecorder.h"
#import "RecPathManagement.h"
#import "NotifyEventProtocol.h"
#import "MyGLViewController.h"

#import "RunCarModeProtocol.h"
#import "MySetDialog.h"




// new

#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <AssetsLibrary/AssetsLibrary.h>





@interface PlayViewController : UIViewController <UINavigationBarDelegate, PPPPStatusProtocol, ParamNotifyProtocol,ImageNotifyProtocol,RunCarModeProtocol,MySetDialogDelegate,AVAudioRecorderDelegate>
{    
    IBOutlet UIImageView *imgView;
    IBOutlet UIActivityIndicatorView *progressView;
    IBOutlet UILabel *LblProgress;       
    IBOutlet UIToolbar *playToolBar;
    IBOutlet UIBarButtonItem *btnItemResolution;  
    IBOutlet UIBarButtonItem *btnTitle;
    IBOutlet UILabel *timeoutLabel;
    IBOutlet UIToolbar *toolBarTop;
    IBOutlet UIBarButtonItem *btnLeftRight;
    IBOutlet UIBarButtonItem *btnUpDownMirror;
    IBOutlet UIBarButtonItem *btnLeftRightMirror;
    IBOutlet UIBarButtonItem *btnAudioControl;
    IBOutlet UIBarButtonItem *btnTalkControl;    
    IBOutlet UIBarButtonItem *btnSwitchDisplayMode;
    
    
    
    //行车记录仪
    IBOutlet UIBarButtonItem *btnSetContrast;
    IBOutlet UIBarButtonItem *btnRecord;
    IBOutlet UIBarButtonItem *btnSetBrightness;
    IBOutlet UIBarButtonItem *btnUpDown;
    IBOutlet UIBarButtonItem *btnRemoteRecord;
    BOOL isSoSPressed;
    BOOL isResolutionVGA;
    
    int mType;
    
    NSTimer *timer;
    int timeNumber;
    IBOutlet UIBarButtonItem *btnUpdateTime;
     MySetDialog *setDialog;
    BOOL isSetDialogShow;
    
    
    
    
    IBOutlet UIImageView *imageUp;
    IBOutlet UIImageView *imageDown;
    IBOutlet UIImageView *imageLeft;
    IBOutlet UIImageView *imageRight;
    IBOutlet UIBarButtonItem *btnSnapshot;
    
    UILabel *labelContrast;
    UISlider *sliderContrast;
    UILabel *labelBrightness;
    UISlider *sliderBrightness; 
    UIImage *imgVGA;
    UIImage *imgQVGA;
    UIImage *img720P;
    UIImage *imgNormal;
    UIImage *imgEnlarge;
    UIImage *imgFullScreen;    
    UIImage *ImageBrightness;
    UIImage *ImageContrast;    
    NSString *cameraName;
    NSString *strDID;
    NSString *strUser;
    NSString *strPwd;
    UIImage *imageSnapshot;
    
    
    CGPoint beginPoint;    
    int m_Contrast;
    int m_Brightness;
    BOOL bGetVideoParams;
    BOOL bPlaying;    
    BOOL bManualStop;  
    CPPPPChannelManagement *m_pPPPPChannelMgt;    
    int nResolution;
    UILabel *OSDLabel;
    UILabel *TimeStampLabel;    
    NSInteger nUpdataImageCount;    
    NSTimer *timeoutTimer;
    BOOL m_bAudioStarted;
    BOOL m_bTalkStarted;    
    BOOL m_bGetStreamCodecType;
    int m_StreamCodecType;
    int m_nP2PMode;
    int m_nTimeoutSec;    
    BOOL m_bToolBarShow;
    BOOL m_bPtzIsUpDown;
    BOOL m_bPtzIsLeftRight;
    BOOL m_bUpDownMirror;
    BOOL m_bLeftRightMirror;
    int m_nFlip;
    BOOL m_bBrightnessShow;
    BOOL m_bContrastShow;
    
    int m_nDisplayMode;
    int m_nVideoWidth;
    int m_nVideoHeight;
    
    int m_nScreenWidth;
    int m_nScreenHeight;
    
    PicPathManagement *m_pPicPathMgt;
    RecPathManagement *m_pRecPathMgt;
    
    CCustomAVRecorder *m_pCustomRecorder;
    NSCondition *m_RecordLock;
    
    id<NotifyEventProtocol> PicNotifyDelegate;
    id<NotifyEventProtocol> RecNotifyDelegate;
    
    MyGLViewController *myGLViewController;
    
    int m_videoFormat;
    
    Byte *m_pYUVData;
    NSCondition *m_YUVDataLock;
    int m_nWidth;
    int m_nHeight;
    BOOL isRecoding;
    int recordNum;
    NSString *strMemory;
    IBOutlet UIBarButtonItem *btnMemory;
    
    
    //wifi cam
    
    IBOutlet UIBarButtonItem *btnGoStop;
    BOOL isGo;
    
    IBOutlet UILabel *labelRecording;
    BOOL isRecordStart;
    BOOL isDataComeback;
    BOOL isStop;
    
    IBOutlet UIBarButtonItem *btnStatusPrompt;
    int deviceStatus;
    
    
    IBOutlet UIView  *portraitView;
    int mainScreenWidth;
    int mainScreenHeight;
    int m_mainScreenWidth;
    int m_mainScreenHeight;
    BOOL isLandScap;
    
    BOOL isIOS7;
    int takepicNum;
    
    
    
    //// new
    BOOL isRecording,isProcessing;
    
    AVPlayer * liveVideoPlayer;
    
    AVPlayerItem *playerItem;
    
    NSMutableArray *numberOfScreenshots;
    
    CFAbsoluteTime      _timeOfFirstFrame;
    NSTimer*recordingTimerVideo;

    NSDate* startedAt;

    AVAudioRecorder *recorder;
    
    NSTimer*waitingTimer,*recordingTimer,*autometicStopTimer;
    int currentTimeInSeconds;


    IBOutlet UIView *headerView;
    
    NSMutableArray * tempDetailsArray, *p2pPathDetails;
    NSString * audioOrVideo;
    
    
}

@property (nonatomic,strong)NSString * savedImagePathTemp;

@property (nonatomic,strong)NSURL *AudioURlP2P, *VideoURLP2P;

@property (nonatomic,retain)UIView  *portraitView;
@property (nonatomic,retain) IBOutlet UILabel *labelRecording;
@property (nonatomic,copy)NSString *strMemory;
@property BOOL isRecoding;
@property (nonatomic, assign) CPPPPChannelManagement *m_pPPPPChannelMgt;
@property (nonatomic, retain) UIImageView *imgView;
@property (nonatomic, copy) NSString *cameraName;
@property (nonatomic, copy) NSString *strDID;
@property (nonatomic,copy)NSString *strPwd;
@property (nonatomic,copy)NSString *strUser;
@property (nonatomic, retain) UIActivityIndicatorView *progressView;
@property (nonatomic, retain) UILabel *LblProgress;
@property (nonatomic, retain) UIToolbar *playToolBar;
@property (nonatomic, retain) UIBarButtonItem *btnItemResolution;
@property (nonatomic, retain) UIBarButtonItem *btnTitle;
@property (nonatomic, retain) UILabel *timeoutLabel;
@property int m_nP2PMode;
@property (nonatomic, retain) UIToolbar *toolBarTop;
@property (nonatomic, retain) UIBarButtonItem *btnUpDown;
@property (nonatomic, retain) UIBarButtonItem *btnLeftDown;
@property (nonatomic, retain) UIBarButtonItem *btnUpDownMirror;
@property (nonatomic, retain) UIBarButtonItem *btnLeftRightMirror;
@property (nonatomic, retain) UIBarButtonItem *btnAudioControl;
@property (nonatomic, retain) UIBarButtonItem *btnTalkControl;
@property (nonatomic, retain) UIBarButtonItem *btnSetContrast;
@property (nonatomic, retain) UIBarButtonItem *btnSetBrightness;
@property (nonatomic, retain) UIBarButtonItem *btnGoStop;
@property (nonatomic, retain) UIBarButtonItem *btnStatusPrompt;


@property (nonatomic, retain) IBOutlet UIBarButtonItem *btnMemory;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *btnRemoteRecord;

@property (nonatomic,retain)IBOutlet UIBarButtonItem *btnUpdateTime;

@property (nonatomic, retain) UIImage *imgVGA;
@property (nonatomic, retain) UIImage *imgQVGA;
@property (nonatomic, retain) UIImage *img720P;
@property (nonatomic, retain) UIBarButtonItem *btnSwitchDisplayMode;
@property (nonatomic, retain) UIImage *imgNormal;
@property (nonatomic, retain) UIImage *imgEnlarge;
@property (nonatomic, retain) UIImage *imgFullScreen;
@property (nonatomic, retain) UIImage *imageSnapshot;
@property (nonatomic, assign) PicPathManagement *m_pPicPathMgt;
@property (nonatomic, retain) UIBarButtonItem *btnRecord;
@property (nonatomic, retain) UIImageView *imageUp;
@property (nonatomic, retain) UIImageView *imageDown;
@property (nonatomic, retain) UIImageView *imageLeft;
@property (nonatomic, retain) UIImageView *imageRight;
@property (nonatomic, assign) RecPathManagement *m_pRecPathMgt;
@property (nonatomic, assign) id<NotifyEventProtocol> PicNotifyDelegate;
@property (nonatomic, assign) id<NotifyEventProtocol> RecNotifyDelegate;
@property (nonatomic, retain) UIBarButtonItem *btnSnapshot;
@property (nonatomic,retain)MySetDialog *setDialog;

- (IBAction) btnItemResolutionPressed:(id)sender;
- (IBAction) btnItemDefaultVideoParamsPressed:(id)sender;
- (void)StopPlay: (int) bForce;
- (IBAction) btnAudioControl: (id) sender;
- (IBAction) btnTalkControl:(id)sender;
- (IBAction) btnStop:(id)sender;
- (IBAction) btnUpDown:(id)sender;
- (IBAction) btnLeftRight:(id)sender;
- (IBAction) btnUpDownMirror:(id)sender;
- (IBAction) btnLeftRightMirror:(id)sender;
- (IBAction) btnSetContrast:(id)sender;
- (IBAction) btnSetBrightness:(id)sender;
- (IBAction) btnSwitchDisplayMode:(id)sender;
- (IBAction) btnSnapshot:(id)sender;
- (IBAction) btnRecord:(id)sender;
- (IBAction) btnRemoteRecord:(id)sender;

- (IBAction) btnGoStop:(id)sender;
- (IBAction) btnStartPPPP:(id)sender;

#pragma mark- JS Products Method
- (IBAction)backButtonAction:(id)sender;
@end
