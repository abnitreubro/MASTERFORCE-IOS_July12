    //
//  PlayViewController.m
//  IpCameraClient
//
//  Created by jiyonglong on 12-4-23.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayViewController.h"
#include "AppDelegate.h"

#import "obj_common.h"
#import "PPPPDefine.h"
#import "mytoast.h"
#import "cmdhead.h"
#import "moto.h"
#import "CustomToast.h"
#import <sys/time.h>
#import "APICommon.h"
#import "avilib.h"
#import <QuartzCore/QuartzCore.h>
#import  <AVFoundation/AVFoundation.h>
#import "MySetDialog.h"
@implementation PlayViewController


@synthesize m_pPPPPChannelMgt;
@synthesize imgView;
@synthesize cameraName;
@synthesize strDID;
@synthesize strPwd;
@synthesize strUser;
@synthesize progressView;
@synthesize LblProgress;
@synthesize playToolBar;
@synthesize btnItemResolution;
@synthesize btnTitle;
@synthesize timeoutLabel;
@synthesize m_nP2PMode;
@synthesize toolBarTop;
@synthesize btnUpDown;
@synthesize btnLeftDown;
@synthesize btnUpDownMirror;
@synthesize btnLeftRightMirror;
@synthesize btnTalkControl;
@synthesize btnAudioControl;
@synthesize btnSetContrast;
@synthesize btnSetBrightness;
@synthesize imgVGA;
@synthesize img720P;
@synthesize imgQVGA;
@synthesize btnSwitchDisplayMode;
@synthesize imgNormal;
@synthesize imgEnlarge;
@synthesize imgFullScreen;
@synthesize imageSnapshot;
@synthesize m_pPicPathMgt;
@synthesize btnRecord;
@synthesize imageUp;
@synthesize imageDown;
@synthesize imageLeft;
@synthesize imageRight;
@synthesize m_pRecPathMgt;
@synthesize PicNotifyDelegate;
@synthesize RecNotifyDelegate;
@synthesize btnSnapshot;
@synthesize btnUpdateTime;
@synthesize isRecoding;
@synthesize btnRemoteRecord;
@synthesize btnMemory;
@synthesize strMemory;

@synthesize setDialog;
@synthesize labelRecording;
@synthesize btnGoStop;
@synthesize btnStatusPrompt;

@synthesize portraitView;

@synthesize AudioURlP2P,VideoURLP2P;


#pragma mark -
#pragma mark others

- (void) StartAudio
{
    m_pPPPPChannelMgt->StartPPPPAudio([strDID UTF8String]);
}

- (void) StopAudio
{
    m_pPPPPChannelMgt->StopPPPPAudio([strDID UTF8String]);
}

- (void) StartTalk
{
    m_pPPPPChannelMgt->StartPPPPTalk([strDID UTF8String]);
}

- (void) StopTalk
{
    m_pPPPPChannelMgt->StopPPPPTalk([strDID UTF8String]);
}



- (IBAction)btnStop:(id)sender
{
    if (isRecordStart) {
        
        [CustomToast showWithText:NSLocalizedStringFromTable(@"play_stop_record_p", @STR_LOCALIZED_FILE_NAME, nil)
                        superView:self.view
                        bLandScap:YES];
        return;
    }
    
    bManualStop = YES;    
    [self StopPlay: 0]; 
}



- (IBAction)btnAudioControl:(id)sender
{
    if (m_bAudioStarted) {
        [self StopAudio];  
        btnAudioControl.style = UIBarButtonItemStyleBordered;
    }else {
        [self StartAudio];
        btnAudioControl.style = UIBarButtonItemStyleDone;
    }
    
    m_bAudioStarted = !m_bAudioStarted;
    
    if (m_bAudioStarted) {
        btnTalkControl.enabled = NO;
    }else {
        btnTalkControl.enabled = YES;
    }
}

- (IBAction)btnTalkControl:(id)sender
{
    
    if (m_bTalkStarted) {
        //[self StopTalk];
        m_pPPPPChannelMgt->CameraControl([strDID UTF8String], 31, 31);
        btnTalkControl.style = UIBarButtonItemStyleBordered;
    }else {
        //[self StartTalk];
        m_pPPPPChannelMgt->CameraControl([strDID UTF8String], 30, 30);
        btnTalkControl.style = UIBarButtonItemStyleDone;
    }
    m_bTalkStarted = !m_bTalkStarted;
    
//    if (m_bTalkStarted) {
//        btnAudioControl.enabled = NO;
//    }else {
//        btnAudioControl.enabled = YES;
//    }
}

- (IBAction) btnItemDefaultVideoParamsPressed:(id)sender
{
    sliderBrightness.value = 1;
    sliderContrast.value = 128;
    m_pPPPPChannelMgt->CameraControl([strDID UTF8String], 1, 1);
    m_pPPPPChannelMgt->CameraControl([strDID UTF8String], 2, 128);
    
    [CustomToast showWithText:NSLocalizedStringFromTable(@"DefaultVideoParams", @STR_LOCALIZED_FILE_NAME, nil)
                    superView:self.view 
                    bLandScap:YES];
}

- (IBAction) btnUpDown:(id)sender
{
    NSLog(@"btnUpDown=======");

    if (isRecordStart) {
        if (isLandScap) {
            [CustomToast showWithText:NSLocalizedStringFromTable(@"play_stop_record_p", @STR_LOCALIZED_FILE_NAME, nil)
                            superView:self.view
                            bLandScap:YES];
        }else{
            [mytoast showWithText:NSLocalizedStringFromTable(@"play_stop_record_p", @STR_LOCALIZED_FILE_NAME, nil)];
        }
        
        return;
    }
    
    if (isLandScap) {
        
        [CustomToast showWithText:NSLocalizedStringFromTable(@"play_gomydocument", @STR_LOCALIZED_FILE_NAME, nil)
                        superView:self.view
                        bLandScap:YES];
        return;
    }
   
    [self StopPlay:100];
    return;
    
    
    if (m_bPtzIsUpDown) {
        m_pPPPPChannelMgt->PTZ_Control([strDID UTF8String], CMD_PTZ_UP_DOWN_STOP);
        btnUpDown.style = UIBarButtonItemStyleBordered;
        
    }else {
        m_pPPPPChannelMgt->PTZ_Control([strDID UTF8String], CMD_PTZ_UP_DOWN);
        btnUpDown.style = UIBarButtonItemStyleDone;
    }
    m_bPtzIsUpDown = !m_bPtzIsUpDown;
        
}





- (NSString*) GetRecordFileName
{
    
    NSDate* date = [NSDate date];    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];    
    [formatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss"];
    NSString* strDateTime = [formatter stringFromDate:date];
    
    NSString *strFileName = [NSString stringWithFormat:@"%@_%@.mov",strDID , strDateTime];
    
    [formatter release];
    
    return strFileName;
}




- (NSString*) GetRecordPath: (NSString*)strFileName
{
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //获取路径
    //参数NSDocumentDirectory要获取那种路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];//去处需要的路径
    
    NSString *strPath =nil;
    
    strPath = [documentsDirectory stringByAppendingPathComponent:strDID];
   
    
    [fileManager createDirectoryAtPath:strPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    
    
    strPath = [strPath stringByAppendingPathComponent:strFileName];
    
        
    return strPath;
}




- (void) stopRecord
{
    [m_RecordLock lock];
    SAFE_DELETE(m_pCustomRecorder);
    [RecNotifyDelegate NotifyReloadData];
    [m_RecordLock  unlock];
}




-(IBAction)btnRemoteRecord:(id)sender{
    if (isRecoding) {
        btnRemoteRecord.style = UIBarButtonItemStyleBordered;
        m_pPPPPChannelMgt->SetSDcardRecordParams((char *)[strDID UTF8String], (char *)[strUser UTF8String],  (char *)[strPwd UTF8String], 0);
    }else{
        btnRemoteRecord.style = UIBarButtonItemStyleDone;
        m_pPPPPChannelMgt->SetSDcardRecordParams((char *)[strDID UTF8String], (char *)[strUser UTF8String],  (char *)[strPwd UTF8String], 1);
    }
    isRecoding=!isRecoding;
    NSLog(@"");
    return;
}

- (IBAction) btnGoStop:(id)sender{
    if (isGo) {
        [btnGoStop setImage:[UIImage imageNamed:@"play_stop.png"]];
    }else{
        [btnGoStop setImage:[UIImage imageNamed:@"play_start.png"]];
    }
    isGo=!isGo;
}



- (IBAction) btnRecord:(id)sender
{
    
    [self recordVideo:sender];
//    
//    [m_RecordLock lock];
//    
//    if (m_pCustomRecorder == NULL) {
//        BOOL flag=[self isOutOfMemory];
//        
//        if (flag) {
//            
//            [CustomToast showWithText:NSLocalizedStringFromTable(@"runcar_outofmemory", @STR_LOCALIZED_FILE_NAME, nil)
//                            superView:self.view
//                            bLandScap:YES];
//            [m_RecordLock unlock];
//            return;
//        }
//        labelRecording.hidden=NO;
//        m_pCustomRecorder = new CCustomAVRecorder();
//        NSString *strFileName = [self GetRecordFileName];
//        NSString *strPath = [self GetRecordPath: strFileName];
//        
//        if(m_pCustomRecorder->StartRecord((char*)[strPath UTF8String], m_videoFormat, (char*)[strDID UTF8String]))
//        {
//            NSDate* date = [NSDate date];    
//            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];    
//            [formatter setDateFormat:@"yyyy-MM-dd"];
//            NSString* strDate = [formatter stringFromDate:date];
//            [m_pRecPathMgt InsertPath:strDID Date:strDate Path:strFileName];
//            [formatter release];
//        }
//         timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateRecordTime) userInfo:nil repeats:YES];
//        //打开锁
//        //[self.btnSetContrast setEnabled:YES];
//       
//        btnRecord.style = UIBarButtonItemStyleDone;
//        isRecordStart=YES;
//    }else {
//        //关闭锁
//        timeNumber=0;
//        isRecordStart=NO;
//        labelRecording.hidden=YES;
//        labelRecording.text=[NSString stringWithFormat:@"%@%@",NSLocalizedStringFromTable(@"play_recording", @STR_LOCALIZED_FILE_NAME, nil),@"00:00:00"];
//        [timer invalidate];
//        timer=nil;
//        
//        SAFE_DELETE(m_pCustomRecorder);
//        [RecNotifyDelegate NotifyReloadData];
//        btnRecord.style = UIBarButtonItemStyleBordered;
//    }
//    [m_RecordLock unlock];
    
}


-(NSString *)getRecordTime:(int)secTime{
    int hour = secTime / 60 / 60;
    int minute = (secTime - hour * 3600 ) / 60;
    int sec = (secTime - hour * 3600 - minute * 60) ;
    NSString *strTime = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, sec];
    return strTime;
}



-(void)updateRecordTime{
    
    timeNumber++;
    NSString *strTime=[self getRecordTime:timeNumber];
    NSLog(@"%@",strTime);
    labelRecording.text=[NSString stringWithFormat:@"%@%@",NSLocalizedStringFromTable(@"play_recording", @STR_LOCALIZED_FILE_NAME, nil),strTime];
//    return;
    btnUpdateTime.title=[NSString stringWithFormat:@"Recording...%d",timeNumber];
    
    NSLog(@"startRecordTime  timeNumber=%d",timeNumber);
    
    NSLog(@"set Time%ld",[[[NSUserDefaults standardUserDefaults] valueForKey:@"recordingTime"] integerValue]);
    if (timeNumber==([[[NSUserDefaults standardUserDefaults] valueForKey:@"recordingTime"] integerValue])*60) {
//        timeNumber=0;
//        SAFE_DELETE(m_pCustomRecorder);
//        [RecNotifyDelegate NotifyReloadData];
//        BOOL flag=[self isOutOfMemory];
//        
//        if (flag) {
//            
//            [CustomToast showWithText:NSLocalizedStringFromTable(@"runcar_outofmemory", @STR_LOCALIZED_FILE_NAME, nil)
//                            superView:self.view
//                            bLandScap:YES];
//            [m_RecordLock unlock];
//            return;
//        }
//        labelRecording.hidden=NO;
//        m_pCustomRecorder = new CCustomAVRecorder();
//        NSString *strFileName = [self GetRecordFileName];
//        NSString *strPath = [self GetRecordPath: strFileName];
//        if(m_pCustomRecorder->StartRecord((char*)[strPath UTF8String], m_videoFormat, (char*)[strDID UTF8String]))
//        {
//            NSDate* date = [NSDate date];
//            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
//            [formatter setDateFormat:@"yyyy-MM-dd"];
//            NSString* strDate = [formatter stringFromDate:date];
//            [m_pRecPathMgt InsertPath:strDID Date:strDate Path:strFileName];
//            [formatter release];
//        }
        
        timeNumber=0;
        isRecordStart=NO;
        labelRecording.hidden=YES;
        labelRecording.text=[NSString stringWithFormat:@"%@%@",NSLocalizedStringFromTable(@"play_recording", @STR_LOCALIZED_FILE_NAME, nil),@"00:00:00"];
        [timer invalidate];
        timer=nil;
        
        SAFE_DELETE(m_pCustomRecorder);
        [RecNotifyDelegate NotifyReloadData];
        btnRecord.style = UIBarButtonItemStyleBordered;
        [m_RecordLock unlock];
    }
    
//    if (timeNumber==5) {
//        timeNumber=0;
//        
//        [aviRecorder stopRecord];
//       [aviRecorder release];
//        aviRecorder=nil;
//        
//        NSString *strFileName = [self GetRecordFileName];
//        NSString *filePath = [self GetRecordPath: strFileName];
//       aviRecorder=[[CustomAViRecorder alloc]init];
//        [aviRecorder startRecord:m_nWidth Height:m_nHeight Type:mType FilePath:filePath];
//    }
}

- (IBAction) btnLeftRight:(id)sender
{
    if (m_bPtzIsLeftRight) {
        m_pPPPPChannelMgt->PTZ_Control([strDID UTF8String], CMD_PTZ_LEFT_RIGHT_STOP);
        btnLeftRight.style = UIBarButtonItemStyleBordered;
        
    }else {
        m_pPPPPChannelMgt->PTZ_Control([strDID UTF8String], CMD_PTZ_LEFT_RIGHT);
        btnLeftRight.style = UIBarButtonItemStyleDone;
    }
    m_bPtzIsLeftRight = !m_bPtzIsLeftRight;
}

- (IBAction) btnUpDownMirror:(id)sender
{
    int value;
    
    if (m_bUpDownMirror) {
        btnUpDownMirror.style = UIBarButtonItemStyleBordered;
        
        if (m_bLeftRightMirror) {
            value = 2;
        }else {
            value = 0;
        }
    }else {
        btnUpDownMirror.style = UIBarButtonItemStyleDone;
        if (m_bLeftRightMirror) {
            value = 3;
        }else {
            value = 1;
        }
    }
    
    m_pPPPPChannelMgt->CameraControl([strDID UTF8String], 5, value);    
    
    m_bUpDownMirror = !m_bUpDownMirror;
}

- (IBAction) btnLeftRightMirror:(id)sender
{
    int value;
    
    if (m_bLeftRightMirror) {
        btnLeftRightMirror.style = UIBarButtonItemStyleBordered;
        
        if (m_bUpDownMirror) {
            value = 1;
        }else {
            value = 0;
        }
    }else {
        
        btnLeftRightMirror.style = UIBarButtonItemStyleDone;
        
        if (m_bUpDownMirror) {
            value = 3;
        }else {
            value = 2;
        }
    }
    
    m_pPPPPChannelMgt->CameraControl([strDID UTF8String], 5, value);    
    
    m_bLeftRightMirror = !m_bLeftRightMirror;
}

- (void) showContrastSlider: (BOOL) bShow
{
    [labelContrast setHidden:!bShow];
    [sliderContrast setHidden:!bShow];
    
    if (bShow) {
        btnSetContrast.style = UIBarButtonItemStyleDone;
    }else {
        btnSetContrast.style = UIBarButtonItemStyleBordered; 
    }
}

- (void) showBrightnessSlider: (BOOL) bShow
{
    [labelBrightness setHidden:!bShow];
    [sliderBrightness setHidden:!bShow];
    
    if (bShow) {
        btnSetBrightness.style = UIBarButtonItemStyleDone;
    }else {
        btnSetBrightness.style = UIBarButtonItemStyleBordered; 
    }
}

- (IBAction) btnSetContrast:(id)sender
{
 
    if (m_bContrastShow) {
        [self showContrastSlider:NO];
    }else {
        [self showContrastSlider:YES];
    }    
    m_bContrastShow = !m_bContrastShow;
}
-(void)sosDelayed{
    NSLog(@"sosDelayed");
    isSoSPressed=NO;
    btnSetContrast.style=UIBarButtonItemStyleBordered;
}

- (IBAction) btnSetBrightness:(id)sender
{
    
  
    if (m_bBrightnessShow) {
        [self showBrightnessSlider:NO];
    }else {
        [self showBrightnessSlider:YES];
    }
    
    m_bBrightnessShow = !m_bBrightnessShow;
}

- (void) setResolutionSize:(NSInteger) resolution
{
    
    
    switch (resolution) {
        case 0:
            m_nVideoWidth = 640;
            m_nVideoHeight = 480;
            break;
        case 1:
            m_nVideoWidth = 320;
            m_nVideoHeight = 240;
            break;
        case 3:
            m_nVideoWidth = 1280;
            m_nVideoHeight = 720;
            break;
            
        default:
            break;
    }
    
    [self setDisplayMode];
}
-(void)hiddenVersionText{
   timeoutLabel.hidden=YES;
}
- (IBAction) btnItemResolutionPressed:(id)sender
{
    timeoutLabel.hidden=NO;
    timeoutLabel.text=[NSString stringWithFormat:@"Version:%@",@STR_VERSION_NO] ;
    [self performSelector:@selector(hiddenVersionText) withObject:nil afterDelay:2];
    
    
    //[self PlayMusic];
    
//    MyPlaySound *sound = [[MyPlaySound alloc]initForPlayingSystemSoundEffectWith:@"Tock" ofType:@"aiff"]; 
//    
//    [sound play];
    
    return;
    NSLog(@"btnItemResolutionPressed...");
    [self showSetDialog:isSetDialogShow];
    isSetDialogShow=!isSetDialogShow;
    return;
    
//    if (bGetVideoParams == NO || m_bGetStreamCodecType == NO) {
//        return ;
//    }
//    
//    if (isResolutionVGA) {
//        m_pPPPPChannelMgt->CameraControl([strDID UTF8String], 37, 37);
//        isResolutionVGA=NO;
//        nResolution=1;
//        [self updateVideoResolution];
//    }else{
//        nResolution=0;
//        [self updateVideoResolution];
//        isResolutionVGA=YES;
//        m_pPPPPChannelMgt->CameraControl([strDID UTF8String], 36, 36);
//    }
//    
//    
//    return;
//    
    
    
    int resolution = 0;
    
    if (m_StreamCodecType == STREAM_CODEC_TYPE_JPEG) {
        if (nResolution == 0) {
            resolution = 1; 
            
        }else {
            resolution = 0;
        }
    }else {
        switch (nResolution) {
            case 0:
                resolution = 3;
                break;
            case 1:
                resolution = 3;
                break;
            case 3:
                resolution = 1;
                break;
            default:
                return;
        }
    }
    
   // [self setResolutionSize:resolution];
    
    nResolution = resolution;
    [self updateVideoResolution];    
    NSLog(@"btnItemResolutionPressed...nResolution=%d",nResolution);
    m_pPPPPChannelMgt->CameraControl([strDID UTF8String], 0, resolution);   
      
    nUpdataImageCount = 0;
    [self performSelector:@selector(getCameraParams) withObject:nil afterDelay:3.0];
}


-(void)PlayMusic{
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"autumn" ofType:@"mp3"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:musicPath];
    
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
   
    // 创建播放器
    
    [url release];
    
    
    [player prepareToPlay];
    [player setVolume:1];
    player.numberOfLoops = -1; //设置音乐播放次数  -1为一直循环
     //播放
    if (player.playing) {
        [player pause];
        [player stop];
    }else{
        [player play];
    }
}
- (IBAction) btnSwitchDisplayMode:(id)sender
{
    switch (m_nDisplayMode) {
        case 0:
            m_nDisplayMode = 1;
            break;
        case 1:
            m_nDisplayMode = 2;
            break;
        case 2:
            m_nDisplayMode = 0;
            break;            
        default:
            m_nDisplayMode = 0;
            break;
    }
    
    [self setDisplayMode];
}

- (void) image: (UIImage*)image didFinishSavingWithError: (NSError*) error contextInfo: (void*)contextInfo
{
    //NSLog(@"save result");
    
    if (error != nil) {
        //show error message
        NSLog(@"take picture failed");
    }else {
        //show message image successfully saved
        //NSLog(@"save success");
        [CustomToast showWithText:NSLocalizedStringFromTable(@"TakePictureSuccess", @STR_LOCALIZED_FILE_NAME, nil)
                superView:self.view 
                bLandScap:isLandScap];
    }
    
}

- (IBAction) btnSnapshot:(id)sender
{
    
    UIImage *image = nil;
    if(m_videoFormat != 0 && m_videoFormat != 2) //MJPEG && H264
    {
        return ;
    }
    
    if (m_videoFormat == 0) {//MJPEG
        if (imageSnapshot == nil || m_pPicPathMgt == nil) {
            return;
        }
        
        image = imageSnapshot;
    }else{//H264
        [m_YUVDataLock lock];
        if (m_YUVDataLock == NULL) {
            [m_YUVDataLock unlock];
            return;
        }
        
        //yuv->image
        image = [APICommon YUV420ToImage:m_pYUVData width:m_nWidth height:m_nHeight];
        
        [m_YUVDataLock unlock];
    }
    
    
    //------save image--------
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //获取路径
    //参数NSDocumentDirectory要获取那种路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];//去处需要的路径
    
    NSString *strPath = [documentsDirectory stringByAppendingPathComponent:strDID];
    //NSLog(@"strPath: %@", strPath);
    
    [fileManager createDirectoryAtPath:strPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    //[fileManager createDirectoryAtPath:strPath attributes:nil];
    
    NSDate* date = [NSDate date];    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];    
    [formatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss"];
    NSString* strDateTime = [formatter stringFromDate:date];
     strDateTime=[NSString stringWithFormat:@"%@_%d",strDateTime,takepicNum];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString* strDate = [formatter stringFromDate:date];
    
    NSString *strFileName = [NSString stringWithFormat:@"%@_%@.jpg", strDID, strDateTime];
    
    strPath = [strPath stringByAppendingPathComponent:strFileName];
    //NSLog(@"strPath: %@", strPath);
    
    //NSData *dataImage = UIImageJPEGRepresentation(imageSnapshot, 1.0);
    NSData *dataImage = UIImageJPEGRepresentation(image, 1.0);
    if([dataImage writeToFile:strPath atomically:YES ])
    {
        [m_pPicPathMgt InsertPicPath:strDID PicDate:strDate PicPath:strFileName];
    }
       
    [pool release];

    [formatter release];
    
    [CustomToast showWithText:NSLocalizedStringFromTable(@"TakePictureSuccess", @STR_LOCALIZED_FILE_NAME, nil)
                    superView:self.view 
                    bLandScap:isLandScap];
    
    [PicNotifyDelegate NotifyReloadData];
  
}

- (void) showOSD
{    
    //[OSDLabel setHidden:NO];
    if (bPlaying == YES) {
        //[TimeStampLabel setHidden:NO];
    }     
}

- (void) showPtzImage: (BOOL) bShow
{
    [imageUp setHidden:!bShow];
    [imageDown setHidden:!bShow];
    [imageLeft setHidden:!bShow];
    [imageRight setHidden:!bShow];
}

- (void) animationStop
{
    //NSLog(@"animation stop");
    if (!m_bToolBarShow) {
        [self showOSD];
        
        //[self showPtzImage:m_bToolBarShow];
    }
}

- (void) ShowToolBar: (BOOL) bShow
{
    //开始动画    
    [UIView beginAnimations:nil context:nil];  
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationStop)];
    
    //设定动画持续时间    
    [UIView setAnimationDuration:0.4];
    
    //动画的内容        
    CGRect frame = headerView.frame;
    if (bShow == YES) {
        
            frame.origin.y += frame.size.height;
        
        
    }else {
        
            frame.origin.y -= frame.size.height;
        
        
    }       
    [headerView setFrame:frame];
    
    CGRect frame2 = playToolBar.frame;
    CGRect frame3 = timeoutLabel.frame;
    
    if (bShow == YES) {
        frame3.origin.y -= frame2.size.height;
    }else {
        frame3.origin.y += frame2.size.height;
    }    
    [timeoutLabel setFrame:frame3];
    
    if (bShow == YES) {
        frame2.origin.y -= frame2.size.height;
    }else {
        frame2.origin.y += frame2.size.height;
    }    
    [playToolBar setFrame:frame2]; 
    
    
    //动画结束    
    [UIView commitAnimations];
}

//停止播放，并返回到设备列表界面
- (void) StopPlay:(int)bForce
{    
    NSLog(@"StopPlay....");
    isDataComeback=NO;
    isStop=YES;
    if (m_pCustomRecorder != nil) {
        isRecordStart=NO;
        SAFE_DELETE(m_pCustomRecorder);
        [RecNotifyDelegate NotifyReloadData];
    }
    if (m_pPPPPChannelMgt != NULL) {
        m_pPPPPChannelMgt->StopPPPPLivestream([strDID UTF8String]);
        m_pPPPPChannelMgt->StopPPPPAudio([strDID UTF8String]);
        m_pPPPPChannelMgt->StopPPPPTalk([strDID UTF8String]);
        m_pPPPPChannelMgt->Stop([strDID UTF8String]);
    } 
    
    if (timeoutTimer != nil) {
        [timeoutTimer invalidate];
        timeoutTimer = nil;
    }
    
       
    if (bForce==100) {//100表示进入U盘
        AppDelegate *IPCAMDelegate = [[UIApplication sharedApplication] delegate];
        [IPCAMDelegate switchBack:strDID User:strUser Pwd:strPwd Type:bForce];
    } 
    
    if (bForce != 1&&bForce!=100 && bManualStop == NO) {
       // [mytoast showWithText:NSLocalizedStringFromTable(@"PPPPStatusDisconnected", @STR_LOCALIZED_FILE_NAME, nil)];
        
        [CustomToast showWithText:NSLocalizedStringFromTable(@"PPPPStatusDisconnected", @STR_LOCALIZED_FILE_NAME, nil)
                        superView:self.view
                        bLandScap:YES];
    }    
    
}

- (void) hideProgress:(id)param
{    
    [self.progressView setHidden:YES];
    [self.LblProgress setHidden:YES];  
    
    if (NO == [OSDLabel isHidden]) {
        //[TimeStampLabel setHidden:NO];
    }
    
    if (m_nP2PMode == PPPP_MODE_RELAY) {
        //[timeoutLabel  setHidden:NO];
        timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES]; 
    }
    
   // [self getCameraParams];
}

- (void)enableButton
{
    [self.btnRecord setEnabled:YES];
    [self.btnSnapshot setEnabled:YES];
}


//handler the start timer
- (void)handleTimer:(NSTimer *)timer
{
    //NSLog(@"handleTimer");
    if(m_nTimeoutSec <= 0){
        //[timeoutTimer invalidate];
        //[self performSelectorOnMainThread:@selector(StopPlay:) withObject:nil waitUntilDone:NO];
        [self StopPlay:1];
        return;
    }
    
    //[self performSelectorOnMainThread:@selector(updateTimeout:) withObject:nil waitUntilDone:NO];
    NSString *strTimeout = [NSString stringWithFormat:@"%@ %d %@", NSLocalizedStringFromTable(@"RelayModeTimeout", @STR_LOCALIZED_FILE_NAME, nil),m_nTimeoutSec,NSLocalizedStringFromTable(@"StrSeconds", @STR_LOCALIZED_FILE_NAME, nil)];
    timeoutLabel.text = strTimeout;
    m_nTimeoutSec = m_nTimeoutSec - 1;
    
    //timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTimer:) //userInfo:nil repeats:NO];
    
}

- (void) updateTimeout:(id)data{
    NSString *strTimeout = [NSString stringWithFormat:@"%@ %d %@", NSLocalizedStringFromTable(@"RelayModeTimeout", @STR_LOCALIZED_FILE_NAME, nil),m_nTimeoutSec,NSLocalizedStringFromTable(@"StrSeconds", @STR_LOCALIZED_FILE_NAME, nil)];
    timeoutLabel.text = strTimeout;
    m_nTimeoutSec = m_nTimeoutSec - 1;
    //NSLog(@"m_nTimeoutSec: %d", m_nTimeoutSec);
}

- (void) updateImage:(id)data
{
    //NSLog(@"updateImage");
    UIImage *img = (UIImage*)data;    
    
    self.imageSnapshot = img;
    //UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (!isLandScap) {
//        imgView.frame=CGRectMake(0, (mainScreenHeight-mainScreenWidth*3/4)/2, mainScreenWidth, mainScreenWidth*3/4);
    }else{
        NSLog(@" 横评。。。");
        NSLog(@"mainScreenWidth=%d mainScreenHeight*3/4=%d",mainScreenWidth,mainScreenHeight*3/4);
//        imgView.frame=CGRectMake((mainScreenHeight-mainScreenWidth*4/3)/2,0 , mainScreenWidth*4/3, mainScreenWidth);
    }
    imgView.image = img;
    [img release];
    
    //show timestamp
    [self updateTimestamp];

}

- (void) updateTimestamp
{
    //show timestamp
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* str = [formatter stringFromDate:date];
    TimeStampLabel.text = str;
    [formatter release];
}

- (void) getCameraParams
{
    return;
    NSLog(@"getCameraParams...");
    m_pPPPPChannelMgt->GetCGI([strDID UTF8String], CGI_IEGET_CAM_PARAMS);  
}

- (void) updateVideoResolution
{
    return;
    NSLog(@"updateVideoResolution nResolution: %d", nResolution);
    [self setResolutionSize:nResolution];
    switch (nResolution) {
        case 0:
            //btnItemResolution.title = @"640*480";
            //btnItemResolution.image = imgVGA;
            btnItemResolution.image = imgQVGA;
            break;
        case 1:
            //btnItemResolution.title = @"320*240";
            btnItemResolution.image = imgQVGA;
            break;
        case 2:
            //btnItemResolution.title = @"160*120";
            break;
        case 3:
            //btnItemResolution.title = @"1280*720";
            btnItemResolution.image = img720P;
            break;
        case 4:
            //btnItemResolution.title = @"640*360";
            break;
        case 5:
            //btnItemResolution.title = @"1280*960";
            break;            
        default:
            break;
    }
}

- (void) UpdateVieoDisplay
{
    //[self updateVideoResolution];
    
    //NSLog(@"m_nFlip: %d", m_nFlip);
    
    switch (m_nFlip) {
        case 0: // normal
            m_bUpDownMirror = NO;
            m_bLeftRightMirror = NO;
            btnUpDownMirror.style = UIBarButtonItemStyleBordered;
            btnLeftRightMirror.style = UIBarButtonItemStyleBordered;
            break;
        case 1: //up down mirror
            m_bUpDownMirror = YES;
            m_bLeftRightMirror = NO;
            btnUpDownMirror.style = UIBarButtonItemStyleDone;
            btnLeftRightMirror.style = UIBarButtonItemStyleBordered;
            break;
        case 2: // left right mirror
            m_bUpDownMirror = NO;
            m_bLeftRightMirror = YES;
            btnUpDownMirror.style = UIBarButtonItemStyleBordered;
            btnLeftRightMirror.style = UIBarButtonItemStyleDone;
            break;
        case 3: //all mirror
            m_bUpDownMirror = YES;
            m_bLeftRightMirror = YES;
            btnUpDownMirror.style = UIBarButtonItemStyleDone;
            btnLeftRightMirror.style = UIBarButtonItemStyleDone;
            break;            
        default:
            break;
    }
    
    sliderContrast.value = m_Contrast;
    sliderBrightness.value = m_Brightness;
}


- (void) ptzImageTouched: (UITapGestureRecognizer*)sender
{
    UIImageView *imageView = (UIImageView*)[sender view];
    
   // NSLog(@"ptzImageTouched... tag: %d", imageView.tag);
    int command = 0;
    switch (imageView.tag) {
        case 0: //up
            command = CMD_PTZ_UP;
            break;
        case 1: //down
            command = CMD_PTZ_DOWN;
            break;
        case 2: //left
            command = CMD_PTZ_LEFT;
            break;
        case 3: //right
            command = CMD_PTZ_RIGHT;
            break;
            
        default:
            return;
    }
    
    m_pPPPPChannelMgt->PTZ_Control([strDID UTF8String], command);
}

- (void) playViewTouch: (id) param
{
    //NSLog(@"touch...."); 
    m_bToolBarShow = !m_bToolBarShow;
    [self ShowToolBar:m_bToolBarShow];
    if (isSetDialogShow) {
        [self showSetDialog:isSetDialogShow];
        isSetDialogShow=!isSetDialogShow;
    }
    
    
    if (m_bToolBarShow) {
        [OSDLabel setHidden:YES];
        [TimeStampLabel setHidden:YES];
        //[self showPtzImage:YES];
    }else {
        m_bContrastShow = NO;
        m_bBrightnessShow = NO;
        [self showBrightnessSlider:NO];
        [self showContrastSlider:NO];
      
    }
}

#pragma mark -
#pragma mark TouchEvent
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"touchesBegan");
    beginPoint = [[touches anyObject] locationInView:imgView];    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"touchesMoved");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    return;
    //NSLog(@"touchesEnded");    
    if (bPlaying == NO)
    {
        return;
    }
    
    CGPoint currPoint = [[touches anyObject] locationInView:imgView];
    const int EVENT_PTZ = 1;    
    int curr_event = EVENT_PTZ;
    
    int x1 = beginPoint.x;
    int y1 = beginPoint.y;
    int x2 = currPoint.x;
    int y2 = currPoint.y;
    
    int view_width = imgView.frame.size.width;
    int _width1 = 0;
    int _width2 = view_width  ;
    
    if(x1 >= _width1 && x1 <= _width2)
    {
        curr_event = EVENT_PTZ;
    }
    else 
    {
        return;
    }
    
    const int MIN_X_LEN = 60;
    const int MIN_Y_LEN = 60;
    
    int len = (x1 > x2) ? (x1 - x2) : (x2 - x1) ;    
    BOOL b_x_ok = (len >= MIN_X_LEN ) ? YES : NO ;
    len = (y1 > y2) ? (y1 - y2) : (y2 - y1) ;
    BOOL b_y_ok = (len > MIN_Y_LEN) ? YES : NO;
    
    BOOL bUp = NO;
    BOOL bDown = NO;
    BOOL bLeft = NO;
    BOOL bRight = NO;      
    
    bDown = (y1 > y2) ? NO : YES;
    bUp = !bDown;
    bRight = (x1 > x2) ? NO : YES;
    bLeft = !bRight;
    
    int command = 0;
    
    switch (curr_event)
    {
        case EVENT_PTZ:        
        {           
            
            if (b_x_ok == YES)
            {
                if (bLeft == YES)
                {
                    NSLog(@"left");                           
                    //command = CMD_PTZ_LEFT;
                    command = CMD_PTZ_RIGHT;
                }
                else 
                {
                    NSLog(@"right");
                    //command = CMD_PTZ_RIGHT;
                    command = CMD_PTZ_LEFT;
                }        
                
                m_pPPPPChannelMgt->PTZ_Control([strDID UTF8String], command);
          
            }
                        
            if (b_y_ok == YES) 
            {
                
                if (bUp == YES)
                {
                    NSLog(@"up");
                    //command = CMD_PTZ_UP;
                    command = CMD_PTZ_DOWN;
                }
                else
                {
                    NSLog(@"down");
                    //command = CMD_PTZ_DOWN;
                    command = CMD_PTZ_UP;
                }
                
                m_pPPPPChannelMgt->PTZ_Control([strDID UTF8String], command);
             
            }            
        }
            break;

        default:
            return ;
    }
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"touchesCancelled");
}

#pragma mark -
#pragma mark system



-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
   CGRect mainS=[[UIScreen mainScreen]bounds];
    NSLog(@"mainScreenWidth=%d mainScreenHeight=%d",mainScreenWidth,mainScreenHeight);

}



- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];

    if (deviceStatus!=PPPP_STATUS_ON_LINE) {
        NSLog(@"btnStartPPPP.....connecting...");
        m_pPPPPChannelMgt->pCameraViewController = self;
        m_pPPPPChannelMgt->Start([strDID UTF8String], [strUser UTF8String], [strPwd UTF8String]);
        [self hiddenProgresssLabel:NO];
        imgView.image = nil;
    }
}






- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(EnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(EnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
}





- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    
    if (deviceStatus != PPPP_STATUS_ON_LINE)
        [self StopPlay:1];
    else
    {
        if (isRecording) {
            [self recordVideo:nil];

        }
        if (isRecording || isProcessing)
        {
            tempDetailsArray = [[NSMutableArray alloc] initWithObjects:@"Started",audioOrVideo,@"p2p", nil];
            [[NSUserDefaults standardUserDefaults] setValue:tempDetailsArray forKey:@"recording"];
        }
    }

    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}





- (void)EnterBackground{
    if (isLandScap)
        [AppDelegate setEnterBackground:YES];
    
//    [self recordVideo:nil];
    
//    if (isRecording || isProcessing)
//    {
//        tempDetailsArray = [[NSMutableArray alloc] initWithObjects:@"Started",audioOrVideo,@"p2p", nil];
//        [[NSUserDefaults standardUserDefaults] setValue:tempDetailsArray forKey:@"recording"];
//    }
    
    
    [self.navigationController popViewControllerAnimated:NO];
}




- (void)EnterForeground{
    NSLog(@"EnterForeground");
//    if (deviceStatus!=PPPP_STATUS_ON_LINE) {
//        NSLog(@"btnStartPPPP.....connecting...");
//        m_pPPPPChannelMgt->pCameraViewController = self;
//        m_pPPPPChannelMgt->Start([strDID UTF8String], [strUser UTF8String], [strPwd UTF8String]);
//        [self hiddenProgresssLabel:NO];
//    }
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) updateContrast: (id) sender
{
    float f = sliderContrast.value;
    m_pPPPPChannelMgt->CameraControl([strDID UTF8String], 2, f);
}

- (void) updateBrightness: (id) sender
{
    float f = sliderBrightness.value;
    m_pPPPPChannelMgt->CameraControl([strDID UTF8String], 1, f);
}

- (void) setDisplayModeImage
{
    m_nDisplayMode=1;
    switch (m_nDisplayMode) {
        case 0: //normal
            btnSwitchDisplayMode.image = imgEnlarge;
            break;
        case 1: //enlarge
            btnSwitchDisplayMode.image = imgFullScreen;
            break;
        case 2: //full screen
            btnSwitchDisplayMode.image = imgNormal;
            break;
            
        default:
            break;
    }
}

- (void) setDisplayMode
{
    //NSLog(@"setDisplayMode...m_nVideoWidth: %d, m_nVideoHeight: %d, m_nDisplayMode: %d", m_nVideoWidth, m_nVideoHeight, m_nDisplayMode);
    
    if (m_nVideoWidth == 0 || m_nVideoHeight == 0) 
    {
        return;
    }
    
    int nDisplayWidth = 0;
    int nDisplayHeight = 0;
    
    m_nDisplayMode=2;//全屏
    switch (m_nDisplayMode) 
    {
        case 0:
        {
            if (m_nVideoWidth > m_nScreenWidth || m_nVideoHeight > m_nScreenHeight) {
                nDisplayHeight = m_nScreenHeight;
                nDisplayWidth = m_nVideoWidth * m_nScreenHeight / m_nVideoHeight ;
                if (nDisplayWidth > m_nScreenWidth) {
                    nDisplayWidth = m_nScreenWidth;
                    nDisplayHeight = m_nVideoHeight * m_nScreenWidth / m_nVideoWidth;
                }
            }else {
                nDisplayWidth = m_nVideoWidth;
                nDisplayHeight = m_nVideoHeight;
            }
        }
            break;
        case 1:
        {
            nDisplayHeight = m_nScreenHeight;
            nDisplayWidth = m_nVideoWidth * m_nScreenHeight / m_nVideoHeight ;
            if (nDisplayWidth > m_nScreenWidth) {
                nDisplayWidth = m_nScreenWidth;
                nDisplayHeight = m_nVideoHeight * m_nScreenWidth / m_nVideoWidth;
            }
        }
            break;
        case 2:
        {
            nDisplayWidth = m_nScreenWidth;
            nDisplayHeight = m_nScreenHeight;
        }
            break;            
        default:
            break;
    }
    
    //NSLog(@"nDisplayWidth: %d, nDisplayHeight: %d", nDisplayWidth, nDisplayHeight);
    
    int nCenterX = m_nScreenWidth / 2;
    int nCenterY = m_nScreenHeight / 2;
    
    //NSLog(@"nCenterX:%d, nCenterY: %d", nCenterX, nCenterY);
    
    int halfWidth = nDisplayWidth / 2;
    int halfHeight = nDisplayHeight / 2;
    
    int nDisplayX = nCenterX - halfWidth;
    int nDisplayY = nCenterY - halfHeight;
    
    //NSLog(@"halfWdith: %d, halfHeight: %d, nDisplayX: %d, nDisplayY: %d", 
    //      halfWidth, halfHeight, nDisplayX, nDisplayY);
    
    CGRect imgViewFrame ;
    imgViewFrame.origin.x = nDisplayX;
    imgViewFrame.origin.y = nDisplayY;
    imgViewFrame.size.width = nDisplayWidth;
    imgViewFrame.size.height = nDisplayHeight;
//    imgView.frame = imgViewFrame;
    
    //----for yuv------
    //CGRect GLViewRect ;
    //GLViewRect.origin.x = nDisplayX;
    //GLViewRect.origin.y = nDisplayY;
    ////GLViewRect.size.width = nDisplayWidth;
    //GLViewRect.size.height = nDisplayHeight;
    myGLViewController.view.frame = imgViewFrame;
    
   // NSLog(@"nDisplayWidth: %d, nDisplayHeight: %d", nDisplayWidth, nDisplayHeight);
    
    
    [self setDisplayModeImage];
    
}
-(void)updateRecordStatus:(NSNumber *)num{
    int status=[num intValue];
    switch (status) {
        case 0:
            isRecoding=NO;
            btnRemoteRecord.style = UIBarButtonItemStyleBordered;

            break;
        case 1:
            isRecoding=YES;
            btnRemoteRecord.style = UIBarButtonItemStyleDone;
            
            
            break;

        default:
            break;
    }
}
- (void) CreateGLView
{
    myGLViewController = [[MyGLViewController alloc] init];
   
    myGLViewController.view.frame = CGRectMake(0, 0, m_nScreenWidth, m_nScreenHeight);
    [self.view addSubview:myGLViewController.view];
    [self.view bringSubviewToFront:OSDLabel];
    [self.view bringSubviewToFront:TimeStampLabel];
    [self.view bringSubviewToFront:toolBarTop];
    [self.view bringSubviewToFront:playToolBar];
    [self.view bringSubviewToFront:labelBrightness];
    [self.view bringSubviewToFront:labelContrast];
    [self.view bringSubviewToFront:sliderBrightness];
    [self.view bringSubviewToFront:sliderContrast];
    [self.view bringSubviewToFront:timeoutLabel];
    [self.view bringSubviewToFront:setDialog];
    [self.view bringSubviewToFront:labelRecording];
}

-(void)mySetDialogOnClick:(int)tag {//预置位和红外灯
    
    switch (tag) {
        case 0://qvga
            NSLog(@"mySetDialogOnClick tag=%d  resolution=1",tag);
            m_pPPPPChannelMgt->CameraControl([strDID UTF8String], 0, 1);
            break;
        case 1://720p
            NSLog(@"mySetDialogOnClick tag=%d  resolution=3",tag);
            m_pPPPPChannelMgt->CameraControl([strDID UTF8String], 0, 3);
            break;
    }
    [self showSetDialog:isSetDialogShow];
    isSetDialogShow=!isSetDialogShow;
}

-(void)showSetDialog:(BOOL)bShow{
    NSLog(@"showSetDialog..");
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    //设定动画持续时间
    [UIView setAnimationDuration:0.3];
    CGRect frame=setDialog.frame;
    if (bShow) {
        frame.origin.x-=120;
    }else{
        frame.origin.x+=120;
    }
    setDialog.frame=frame;
    
    //动画结束
    [UIView commitAnimations];
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [super viewDidLoad];
    self.view.autoresizesSubviews=YES;
   takepicNum=0;
    CGRect mainScreen=[[UIScreen mainScreen]bounds];
    mainScreenWidth=mainScreen.size.width;
    mainScreenHeight=mainScreen.size.height;
    if ([AppDelegate getEnterBackground]==YES) {
        if ([[UIDevice currentDevice] userInterfaceIdiom ]==UIUserInterfaceIdiomPhone) {
            if (mainScreenWidth<mainScreenHeight) {
                mainScreenWidth=mainScreen.size.width;
                mainScreenHeight=mainScreen.size.height;
                
            }else{
                mainScreenWidth=mainScreen.size.width;
                mainScreenHeight=mainScreen.size.height;
            }
            isLandScap=NO;
        }else{
            mainScreenWidth=mainScreen.size.height;
            mainScreenHeight=mainScreen.size.width;
        }
        
        [AppDelegate setEnterBackground:NO];
    }
    isLandScap=NO;
    
    NSLog(@"mainScreenWidth=%d mainScreenHeight=%d",mainScreenWidth,mainScreenHeight);
    deviceStatus=PPPP_STATUS_UNKNOWN;
    //test
    isGo=YES;
    isStop=NO;
    labelRecording.text=[NSString stringWithFormat:@"%@%@",NSLocalizedStringFromTable(@"play_recording", @STR_LOCALIZED_FILE_NAME, nil),@"00:00:00"];
    setDialog=[[MySetDialog alloc]initWithFrame:CGRectMake(-100, 50, 100, 100) Btn:2];
   // [self.view addSubview:setDialog];
    setDialog.diaDelegate=self;
    setDialog.backgroundColor=[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.8];
    [setDialog setBtnTitle:@"QVGA" Index:0];
    [setDialog setBtnTitle:@"720P" Index:1];
    
    
    [btnStatusPrompt setTitle:NSLocalizedStringFromTable(@"PPPPStatusConnecting", @STR_LOCALIZED_FILE_NAME, nil)];
    //[playToolBar setHidden:YES];
    timeNumber=0;
    isSoSPressed=NO;
    isResolutionVGA=YES;
    isRecoding=NO;
    isRecordStart=NO;
    
    m_videoFormat = -1;
    nUpdataImageCount = 0;    
    m_bTalkStarted = NO;
    m_bAudioStarted = NO;    
    m_bPtzIsUpDown = NO;
    m_bPtzIsLeftRight = NO;
    m_nDisplayMode = 2;
    m_nVideoWidth = 0;
    m_nVideoHeight = 0;
    m_pCustomRecorder = NULL;
    m_pYUVData = NULL;
    m_nWidth = 0;
    m_nHeight = 0;
    m_YUVDataLock = [[NSCondition alloc] init];
    m_RecordLock = [[NSCondition alloc] init];
    
    
    [self showPtzImage:NO];
    [self.btnRecord setEnabled:NO];
    [self.btnSnapshot setEnabled:NO];
//    [self.btnSetContrast setEnabled:NO];
//    [self.btnUpdateTime setEnabled:NO];
    
    
    
    
    
    CGRect getFrame = [[UIScreen mainScreen]applicationFrame];    
    m_nScreenHeight = getFrame.size.width;
    m_nScreenWidth = getFrame.size.height;
    //m_nScreenHeight = getFrame.size.height;
    //m_nScreenWidth = getFrame.size.width;
    //NSLog(@"screen width: %d height: %d", m_nScreenWidth, m_nScreenHeight);
    
    //create yuv displayController
    myGLViewController = nil;
    
    imageUp.tag = 0;
    imageDown.tag = 1;
    imageLeft.tag = 2;
    imageRight.tag = 3;
    imageUp.userInteractionEnabled = YES;
    UITapGestureRecognizer *ptzImageGR=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ptzImageTouched:)];
    [ptzImageGR setNumberOfTapsRequired:1];
    [imageUp addGestureRecognizer:ptzImageGR];
    [ptzImageGR release];
    
    imageDown.userInteractionEnabled = YES;
    ptzImageGR=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ptzImageTouched:)];
    [ptzImageGR setNumberOfTapsRequired:1];
    [imageDown addGestureRecognizer:ptzImageGR];
    [ptzImageGR release];
    
    imageLeft.userInteractionEnabled = YES;
    ptzImageGR=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ptzImageTouched:)];
    [ptzImageGR setNumberOfTapsRequired:1];
    [imageLeft addGestureRecognizer:ptzImageGR];
    [ptzImageGR release];
    
    imageRight.userInteractionEnabled = YES;
    ptzImageGR=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ptzImageTouched:)];
    [ptzImageGR setNumberOfTapsRequired:1];
    [imageRight addGestureRecognizer:ptzImageGR];
    [ptzImageGR release];

    
    
    UIImageView *imageBg;
    imageBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, mainScreenWidth, mainScreenHeight)];
    imageBg.backgroundColor = [UIColor colorWithRed:100.0/255 green:100.0/255 blue:100.0/255 alpha:0.5];
    imageBg.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGes1=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playViewTouch:)];
    [tapGes1 setNumberOfTapsRequired:1];
    imgView.userInteractionEnabled=YES;
    [imgView addGestureRecognizer:tapGes1];
    [tapGes1 release];
    
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageBg];
    [self.view sendSubviewToBack:imageBg];    
    [imageBg release];    
    
    self.imgVGA = [UIImage imageNamed:@"resolution_vga_pressed"];
    self.imgQVGA = [UIImage imageNamed:@"resolution_qvga"];
    self.img720P = [UIImage imageNamed:@"resolution_720p_pressed"];
    
    
    self.imgNormal = [UIImage imageNamed:@"ptz_playmode_standard"];
    self.imgEnlarge = [UIImage imageNamed:@"ptz_playmode_enlarge"];
    self.imgFullScreen = [UIImage imageNamed:@"ptz_playmode_fullscreen"];
    
    //==========================================================
    labelContrast  = [[UILabel alloc] initWithFrame:CGRectMake(20, 65, 30, 170)];
    UIColor *labelColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.5f];
    labelContrast.backgroundColor = labelColor;
    labelContrast.layer.masksToBounds = YES;
    labelContrast.layer.cornerRadius = 5.0;
    [self.view addSubview:labelContrast];
    [labelContrast setHidden:YES];
    
    sliderContrast = [[UISlider alloc] init];
    [sliderContrast setMaximumValue:255.0];
    [sliderContrast setMinimumValue:1.0];
    CGAffineTransform rotation = CGAffineTransformMakeRotation(-1.57079633);
    sliderContrast.transform = rotation;
    [sliderContrast setFrame:CGRectMake(20, 70, 30, 160)];
    [self.view addSubview:sliderContrast];
    [sliderContrast setHidden:YES];
    [sliderContrast addTarget:self action:@selector(updateContrast:) forControlEvents:UIControlEventTouchUpInside];
    
    m_bContrastShow = NO;
    //==========================================================
    
    //==========================================================
    labelBrightness  = [[UILabel alloc] initWithFrame:CGRectMake(480 - 50, 65, 30, 170)];    
    labelBrightness.backgroundColor = labelColor;
    labelContrast.layer.masksToBounds = YES;
    labelBrightness.layer.cornerRadius = 5.0;
    [self.view addSubview:labelBrightness];
    [labelBrightness setHidden:YES];
    
    sliderBrightness = [[UISlider alloc] init];
    [sliderBrightness setMaximumValue:255.0];
    [sliderBrightness setMinimumValue:1.0];
    sliderBrightness.transform = rotation;
    [sliderBrightness setFrame:CGRectMake(480 - 50, 70, 30, 160)];
    [self.view addSubview:sliderBrightness];
    [sliderBrightness setHidden:YES];
    [sliderBrightness addTarget:self action:@selector(updateBrightness:) forControlEvents:UIControlEventTouchUpInside];
    
    m_bBrightnessShow = NO;
    //==========================================================
    
    m_bToolBarShow = YES;
    
    self.btnTitle.title = cameraName;
    

    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 4.9) {
        
        //iOS 5
        UIImage *toolBarIMG = [UIImage imageNamed: @"barbk.png"];  
        if ([toolBarTop respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)]) { 
            [toolBarTop setBackgroundImage:toolBarIMG forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault]; 
        }
        if ([playToolBar respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)]) { 
            [playToolBar setBackgroundImage:toolBarIMG forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault]; 
        }
        
    } else {
        
        //iOS 4
        [toolBarTop insertSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"barbk.png"]] autorelease] atIndex:0]; 
        [playToolBar insertSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"barbk.png"]] autorelease] atIndex:0]; 
    }     
    
    
    UIColor *osdColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.3f];
    
    ///////////////////////////////////////////////////////////////////
    OSDLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)]; 
    [OSDLabel setNumberOfLines:0];    
    UIFont *font = [UIFont fontWithName:@"Arial" size:18];
    CGSize size = CGSizeMake(170,100); 
    OSDLabel.lineBreakMode = UILineBreakModeWordWrap; 
    NSString *s = cameraName;
    CGSize labelsize = [s sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    [OSDLabel setFrame: CGRectMake(10, 10, labelsize.width, labelsize.height)];
    OSDLabel.text = cameraName;
    OSDLabel.font = font;
    OSDLabel.layer.masksToBounds = YES;
    OSDLabel.layer.cornerRadius = 2.0;
    OSDLabel.backgroundColor = osdColor;  
    [self.view addSubview:OSDLabel];
    [OSDLabel setHidden:YES];
    ///////////////////////////////////////////////////////////////////
    
    ///////////////////////////////////////////////////////////////////
    TimeStampLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)]; 
    [TimeStampLabel setNumberOfLines:0];    
    //font = [UIFont fontWithName:@"Arial" size:18];
    //size = CGSizeMake(170,100); 
    TimeStampLabel.lineBreakMode = UILineBreakModeWordWrap; 
    s = @"2012-07-04 08:05:30";
    labelsize = [s sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    [TimeStampLabel setFrame: CGRectMake(480 - 10 - labelsize.width, 10, labelsize.width, labelsize.height)];
    TimeStampLabel.font = font;
    TimeStampLabel.layer.masksToBounds = YES;
    TimeStampLabel.layer.cornerRadius = 2.0;
    TimeStampLabel.backgroundColor = osdColor;   
    [self.view addSubview:TimeStampLabel];
    [TimeStampLabel setHidden:YES];
    ///////////////////////////////////////////////////////////////////
    
    [timeoutLabel setHidden:YES];
    //timeoutLabel.backgroundColor = osdColor;
    m_nTimeoutSec = 180;
    timeoutTimer = nil;
    
    //imgView.userInteractionEnabled = YES;
    bGetVideoParams = NO;
    bManualStop = NO;
    m_bGetStreamCodecType = NO;
    
    self.LblProgress.text = NSLocalizedStringFromTable(@"Connecting", @STR_LOCALIZED_FILE_NAME,nil);
  
    [self.progressView setHidden:NO];
    [self.progressView startAnimating];
    
        CGRect topFrame=toolBarTop.frame;
        topFrame.size.width=mainScreenHeight;
        toolBarTop.frame=topFrame;
    
   
    //连接设备
    if (m_pPPPPChannelMgt!=nil) {
        
         m_pPPPPChannelMgt->pCameraViewController = self;
        m_pPPPPChannelMgt->Start([strDID UTF8String], [strUser UTF8String], [strPwd UTF8String]);
    }
     
    
    [self performSelector:@selector(playViewTouch:) withObject:nil afterDelay:1];
    
    [self isOutOfMemory];
    [NSThread detachNewThreadSelector:@selector(switchActionlocal) toTarget:self withObject:nil];
}




- (void)switchActionlocal{
    //设置时间
    NSTimeZone *zone = [NSTimeZone localTimeZone];//获得当前应用程序默认的时区
    //NSInteger interval = [zone secondsFromGMTForDate:[NSDate date]];//以秒为单位返回当前应用程序与世界标准时间（格林威尼时间）的时差
    NSInteger interval = -[zone secondsFromGMT];
    NSDate *date=[NSDate date];
    NSTimeInterval now=[date timeIntervalSince1970];
    //        time(0)/1000
    NSLog(@"interval=%d",interval);
    
    m_pPPPPChannelMgt->SetDateTime((char*)[strDID UTF8String], now, interval, 0, (char*)[@"" UTF8String]);
    
    m_pPPPPChannelMgt->CameraControl([strDID UTF8String], 40, 40);
}
- (void)viewDidUnload {
    
    [super viewDidUnload];
}

- (void)dealloc {
    NSLog(@"PlayViewController dealloc");
    m_pPPPPChannelMgt->SetRunCarDelegate((char *)[strDID UTF8String], nil);
    if (OSDLabel != nil) {
        [OSDLabel release];
        OSDLabel = nil;
    }
    if (TimeStampLabel != nil) {
        [TimeStampLabel release];
        TimeStampLabel = nil;
    }
    self.labelRecording=nil;
    self.imgView = nil;
    self.cameraName = nil;
    self.strDID = nil;
    self.playToolBar = nil;
    self.btnItemResolution = nil;
    self.btnTitle = nil;
    self.toolBarTop = nil;
    self.btnUpDown = nil;
    self.btnLeftDown = nil;
    self.btnUpDownMirror = nil;
    self.btnLeftRightMirror = nil;
    self.btnTalkControl = nil;
    self.btnAudioControl = nil;
    self.btnMemory=nil;
    [sliderContrast release];
    [labelContrast release];
    self.btnSetContrast = nil;
    self.btnSetBrightness = nil;   
    [sliderBrightness release];
    [labelBrightness release];
    self.imgVGA = nil;
    self.imgQVGA = nil;
    self.img720P = nil;
    self.btnSwitchDisplayMode = nil;
    self.imgEnlarge = nil;
    self.imgFullScreen = nil;
    self.imgNormal = nil;
    self.imageSnapshot = nil;
    //self.m_pPicPathMgt = nil;
    self.btnRecord = nil;
    if (m_RecordLock != nil) {
        [m_RecordLock release];
        m_RecordLock = nil;
        
    }
    self.imageLeft = nil;
    self.imageUp = nil;
    self.imageDown = nil;
    self.imageRight = nil;
    //self.m_pRecPathMgt = nil;
    self.PicNotifyDelegate = nil;
    if (myGLViewController != nil) {
        [myGLViewController release];
        myGLViewController = nil;
    }
    if (m_YUVDataLock != nil) {
        [m_YUVDataLock release];
        m_YUVDataLock = nil;
    }
    SAFE_DELETE(m_pYUVData);
    [super dealloc];
    
}

#pragma mark -
#pragma mark PPPPStatusDelegate

- (void) PPPPStatus:(NSString *)astrDID statusType:(NSInteger)statusType status:(NSInteger)status
{
    NSLog(@"PlayViewController strDID: %@, statusType: %d, status: %d", astrDID, statusType, status);
    //处理PPP的事件通知
    
    if (bManualStop == YES) {
        return;
    }
    
    //这个一般情况下是不会发生的
    if ([astrDID isEqualToString:strDID] == NO) {
        return;
    }
    
    
    NSString *strPPPPStatus = nil;
    if (statusType == MSG_NOTIFY_TYPE_PPPP_STATUS) {
        
    deviceStatus=status;
    switch (status) {
        case PPPP_STATUS_UNKNOWN:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusUnknown", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_CONNECTING:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusConnecting", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_INITIALING:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusInitialing", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_CONNECT_FAILED:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusConnectFailed", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_DISCONNECT:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusDisconnected", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_INVALID_ID:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusInvalidID", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_ON_LINE:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusOnline", @STR_LOCALIZED_FILE_NAME, nil);
            
            [self performSelectorOnMainThread:@selector(getLivestream) withObject:nil waitUntilDone:NO];
            break;
        case PPPP_STATUS_DEVICE_NOT_ON_LINE:
            strPPPPStatus = NSLocalizedStringFromTable(@"CameraIsNotOnline", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_CONNECT_TIMEOUT:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusConnectTimeout", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        default:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusUnknown", @STR_LOCALIZED_FILE_NAME, nil);
            break;
    }
    
        [self performSelectorOnMainThread:@selector(updateDeviceStatus:) withObject:strPPPPStatus waitUntilDone:NO];
        
        if (status == PPPP_STATUS_INVALID_ID
            || status == PPPP_STATUS_CONNECT_TIMEOUT
            || status == PPPP_STATUS_DEVICE_NOT_ON_LINE
            || status == PPPP_STATUS_CONNECT_FAILED||statusType==PPPP_STATUS_INVALID_USER_PWD) {
            [self performSelectorOnMainThread:@selector(StopPPPPByDID:) withObject:strDID waitUntilDone:NO];
        }
}
    
}

- (void) StopPPPPByDID:(NSString*)did
{
    m_pPPPPChannelMgt->Stop([did UTF8String]);
}



- (IBAction) btnStartPPPP:(id)sender{
    if (deviceStatus!=PPPP_STATUS_ON_LINE) {
        NSLog(@"btnStartPPPP.....connecting...");
         m_pPPPPChannelMgt->pCameraViewController = self;
         m_pPPPPChannelMgt->Start([strDID UTF8String], [strUser UTF8String], [strPwd UTF8String]);
        [self hiddenProgresssLabel:NO];
    }
}




-(void)updateDeviceStatus:(NSString*)strStatus{
    if (deviceStatus!=PPPP_STATUS_CONNECTING) {
        [self hiddenProgresssLabel:YES];
    }
    if (deviceStatus==PPPP_STATUS_CONNECTING) {
        self.LblProgress.text = NSLocalizedStringFromTable(@"Connecting", @STR_LOCALIZED_FILE_NAME,nil);
        self.LblProgress.hidden = NO;
        [self.progressView setHidden:NO];
        [self.progressView startAnimating];
    }

    if (deviceStatus==PPPP_STATUS_CONNECT_TIMEOUT)
    {
        [self timeOutAlertMessagePopOut];
    }
    
    [btnStatusPrompt setTitle:strStatus];
}




-(void)hiddenProgresssLabel:(BOOL)bShow{
    [self.progressView setHidden:bShow];
    [self.LblProgress setHidden:bShow];
}



-(void)getLivestream{
    NSLog(@"PlayViewController...getLivestream...============");
    if (m_pPPPPChannelMgt != NULL) {

        [self hiddenProgresssLabel:NO];
        self.LblProgress.text=NSLocalizedStringFromTable(@"play_getvideo", @STR_LOCALIZED_FILE_NAME, nil);
        
        if( m_pPPPPChannelMgt->StartPPPPLivestream([strDID UTF8String], 10, self) == 0 ){
            NSLog(@"获取视频失败...");
            [self updateDeviceStatus:NSLocalizedStringFromTable(@"play_getvideofailed", @STR_LOCALIZED_FILE_NAME, nil)];

            return;
        }
        
        
        m_pPPPPChannelMgt->SetRunCarDelegate((char *)[strDID UTF8String], self);
        m_pPPPPChannelMgt->PPPPSetSystemParams((char *)[strDID UTF8String], MSG_TYPE_GET_STATUS, NULL, 0);
    }
}
-(void)onMainThread{
    [self performSelector:@selector(reConnectLivestream) withObject:nil afterDelay:5];
}
-(void)reConnectLivestream{
    NSLog(@"reConnectLivestream...");
    if( m_pPPPPChannelMgt->StartPPPPLivestream([strDID UTF8String], 10, self) == 0 ){
        [self performSelectorOnMainThread:@selector(StopPlay:) withObject:nil waitUntilDone:NO];
        
        return;
    }
    
    [NSTimer  scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkReconnectOk) userInfo:nil repeats:NO];
}
-(void)checkReconnectOk{
    NSLog(@"checkReconnectOk...isDataComeback=%d",isDataComeback);
    if (!isDataComeback) {
        
        [self performSelectorOnMainThread:@selector(StopPlay:) withObject:nil waitUntilDone:NO];
    }
}
#pragma mark -
#pragma mark ParamNotify

- (void) ParamNotify:(int)paramType params:(void *)params
{
    //NSLog(@"PlayViewController ParamNotify");
    
    if (paramType == CGI_IEGET_CAM_PARAMS) {
        PSTRU_CAMERA_PARAM pCameraParam = (PSTRU_CAMERA_PARAM)params;
        m_Contrast = pCameraParam->contrast;
        m_Brightness = pCameraParam->bright;  
        nResolution = pCameraParam->resolution;     
        m_nFlip = pCameraParam->flip;
        bGetVideoParams = YES;
        NSLog(@"resolution:%d",nResolution);
        //[self performSelectorOnMainThread:@selector(UpdateVieoDisplay) withObject:nil waitUntilDone:NO];
        return;
    }
    
    if (paramType == STREAM_CODEC_TYPE) { 
        //NSLog(@"STREAM_CODEC_TYPE notify");
        m_StreamCodecType = *((int*)params);
        m_bGetStreamCodecType = YES;
        //[self performSelectorOnMainThread:@selector(DisplayVideoCodec) withObject:nil waitUntilDone:NO];
    }
    
}

#pragma mark -
#pragma mark ImageNotify
-(void)stopRecordForMemoryOver{
    
    
    if (isRecoding||isRecording) {
        recordNum=0;
        btnUpdateTime.title=@"Recording...0";
        btnRecord.style = UIBarButtonItemStyleBordered;
        [btnUpdateTime setEnabled:NO];
        [timer invalidate];
        timer=nil;
        timeNumber=0;
      //  SAFE_DELETE(m_pCustomRecorder);
        [self recordVideo:nil];  // new

    }

    
    [CustomToast showWithText:NSLocalizedStringFromTable(@"runcar_outofmemory", @STR_LOCALIZED_FILE_NAME, nil)
                    superView:self.view
                    bLandScap:YES];
    
    
}
- (void) H264Data:(Byte *)h264Frame length:(int)length type:(int)type timestamp:(NSInteger) timestamp
{
    if(isStop){
        return;
    }
    if (m_videoFormat == -1) {
        m_videoFormat = 2;
        [self performSelectorOnMainThread:@selector(enableButton) withObject:nil waitUntilDone:NO];
    }
    
   
    [m_RecordLock lock];
    if (isRecordStart) {
        if (m_pCustomRecorder != nil) {
            recordNum++;
            NSLog(@"recordNum=%d",recordNum);
            if (recordNum==100) {
                recordNum=0;
                BOOL flag=[self isOutOfMemory];
                if (flag) {
                    [self performSelectorOnMainThread:@selector(stopRecordForMemoryOver) withObject:self waitUntilDone:NO];
                }
            }
            
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            unsigned int unTimestamp = 0;
            struct timeval tv;
            struct timezone tz;
            gettimeofday(&tv, &tz);
            unTimestamp = tv.tv_usec / 1000 + tv.tv_sec * 1000 ;
            //NSLog(@"unTimestamp: %d", unTimestamp);
            
            m_pCustomRecorder->SendOneFrame((char*)h264Frame, length, unTimestamp, type);
            [pool release];
        }
    }
    // NSLog(@"H264Data... length: %d, type: %d", length, type);
    [m_RecordLock unlock];
}

- (void) YUVNotify:(Byte *)yuv length:(int)length width:(int)width height:(int)height timestamp:(unsigned int)timestamp StreamID:(int)streamID
{
    
   
    mType=1;
    if (streamID==63) {
        //NSLog(@"YUVNotify.... streamID:%d",streamID);
    }
    
    isDataComeback=YES;
    if (!isGo) {
        return;
    }
    if(isStop){
        return;
    }
    if ([AppDelegate is43Version]) {//4.3.3版本
        
        UIImage *image=[APICommon YUV420ToImage:yuv width:width height:height];
        if (bPlaying==NO) {
            bPlaying = YES;
            [self updateResolution:image];
            
            [self performSelectorOnMainThread:@selector(hideProgress:) withObject:nil waitUntilDone:NO];
            
        }
        
        [self performSelectorOnMainThread:@selector(updateTimestamp) withObject:nil waitUntilDone:NO];
        if (image != nil) {
            [image retain];
            [self performSelectorOnMainThread:@selector(updateImage:) withObject:image waitUntilDone:NO];
        }
        
        [m_YUVDataLock lock];
        SAFE_DELETE(m_pYUVData);
        int yuvlength = width * height * 3 / 2;
        m_pYUVData = new Byte[yuvlength];
        memcpy(m_pYUVData, yuv, yuvlength);
        m_nWidth = width;
        m_nHeight = height;
        [m_YUVDataLock unlock];
        if (streamID==63) {
            takepicNum++;
            NSLog(@"yuv.. streamid=%d", streamID);
            [self performSelectorOnMainThread:@selector(btnSnapshot:) withObject:@"" waitUntilDone:NO];
        }
        return;
    }

    
    if (bPlaying == NO)
    {
        
        [self performSelectorOnMainThread:@selector(CreateGLView) withObject:nil waitUntilDone:YES];
        [self updataResolution:width height:height];
        [self performSelectorOnMainThread:@selector(hideProgress:) withObject:nil waitUntilDone:NO];
        bPlaying = YES;
    }
     
    [self performSelectorOnMainThread:@selector(updateTimestamp) withObject:nil waitUntilDone:NO];
    
    [myGLViewController WriteYUVFrame:yuv Len:length width:width height:height];
//
    [m_YUVDataLock lock];
    SAFE_DELETE(m_pYUVData);
    int yuvlength = width * height * 3 / 2;
    m_pYUVData = new Byte[yuvlength];
    memcpy(m_pYUVData, yuv, yuvlength);
    m_nWidth = width;
    m_nHeight = height;
    [m_YUVDataLock unlock];
    
    if (streamID==63) {
        takepicNum++;
        NSLog(@"yuv.. streamid=%d", streamID);
        [self performSelectorOnMainThread:@selector(btnSnapshot:) withObject:@"" waitUntilDone:NO];
    }
}

- (void) ImageNotify:(UIImage *)image timestamp:(NSInteger)timestamp StreamID:(int)streamID
{
   // NSLog(@"ImageNotify.....StreamID=%d",streamID);
   
    isDataComeback=YES;
    if (!isGo) {
        return;
    }
    if(isStop){
        return;
    }
    mType=0;
    m_nWidth=image.size.width;
    m_nHeight=image.size.height;
    
    if (m_videoFormat == -1) {
        m_videoFormat = 0;
        [self performSelectorOnMainThread:@selector(enableButton) withObject:nil waitUntilDone:NO];
    }
    
    if (bPlaying == NO)
    {
        bPlaying = YES;
        [self updateResolution:image];
        
        [self performSelectorOnMainThread:@selector(hideProgress:) withObject:nil waitUntilDone:NO]; 
    }
    
    if (image != nil) {
        [image retain];
        [self performSelectorOnMainThread:@selector(updateImage:) withObject:image waitUntilDone:NO];
    }
    
    [m_RecordLock lock];
    if (isRecordStart) {
        if (m_pCustomRecorder != nil) {
            recordNum++;
            NSLog(@"recordNum=%d",recordNum);
            if (recordNum==100) {
                recordNum=0;
                BOOL flag=[self isOutOfMemory];
                if (flag) {
                    [self performSelectorOnMainThread:@selector(stopRecordForMemoryOver) withObject:self waitUntilDone:NO];
                }
            }
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            NSData *data = UIImageJPEGRepresentation(image, 1.0);
            unsigned int unTimestamp = 0;
            struct timeval tv;
            struct timezone tz;
            gettimeofday(&tv, &tz);
            unTimestamp = tv.tv_usec / 1000 + tv.tv_sec * 1000 ;
            //NSLog(@"unTimestamp: %d", unTimestamp);
            m_pCustomRecorder->SendOneFrame((char*)[data bytes], [data length], unTimestamp, 0);
            [pool release];
        }
    }
    
    
    [m_RecordLock unlock];
    if (streamID==63) {
        NSLog(@"ImageNotify.. streamid=%d", streamID);
        [self performSelectorOnMainThread:@selector(btnSnapshot:) withObject:@"" waitUntilDone:NO];
    }
}

- (void) updataResolution: (int) width height:(int)height
{
    m_nVideoWidth = width;
    m_nVideoHeight = height;
    
    if(m_nVideoWidth == 1280 && m_nVideoHeight == 720){
        nResolution = 3;
        [self performSelectorOnMainThread:@selector(updateVideoResolution) withObject:nil waitUntilDone:NO];
    }else if(m_nVideoWidth == 640 && m_nVideoHeight == 480){
        nResolution = 0;
        [self performSelectorOnMainThread:@selector(updateVideoResolution) withObject:nil waitUntilDone:NO];
    }else if(m_nVideoWidth == 320 && m_nVideoHeight == 240){
        nResolution = 1;
        [self performSelectorOnMainThread:@selector(updateVideoResolution) withObject:nil waitUntilDone:NO];
    }else {
        
    }
    
    [self performSelectorOnMainThread:@selector(setDisplayMode) withObject:nil waitUntilDone:NO];

}

- (void) updateResolution:(UIImage*)image
{
    
    //NSLog(@"updateResolution");
    m_nVideoWidth = image.size.width;
    m_nVideoHeight = image.size.height;
    
    //NSLog(@"m_nVideoWidth: %d, m_nVideoHeight: %d", m_nVideoWidth, m_nVideoHeight);
  
    if(m_nVideoWidth == 1280 && m_nVideoHeight == 720){
        nResolution = 3;
        [self performSelectorOnMainThread:@selector(updateVideoResolution) withObject:nil waitUntilDone:NO];
    }else if(m_nVideoWidth == 640 && m_nVideoHeight == 480){
        nResolution = 0;
        [self performSelectorOnMainThread:@selector(updateVideoResolution) withObject:nil waitUntilDone:NO];
    }else if(m_nVideoWidth == 320 && m_nVideoHeight == 240){
        nResolution = 1;
        [self performSelectorOnMainThread:@selector(updateVideoResolution) withObject:nil waitUntilDone:NO];
    }else {
        
    }
    
    [self performSelectorOnMainThread:@selector(setDisplayMode) withObject:nil waitUntilDone:NO];
}

#pragma mark- RuncarModeProtocol
-(void)runcarStatusResult:(NSString *)did Sysver:(NSString *)sysver DevName:(NSString *)devname Devid:(NSString *)devid AlarmStatus:(int)alarmstatus SdCardStatus:(int)sdstatus SdcardTotalSize:(int)totalsize SdcardRemainSize:(int)remainsize Mac:(NSString *)mac WifiMac:(NSString *)wifimac DNSstatus:(int)dns_status UPNPstatus:(int)upnp_status{
    NSLog(@"sysver=%@ devname=%@ Devid=%@ alarmstatus=%d sdstatus=%d totalsize=%d remainsize=%d ",sysver,devname,devid,alarmstatus,sdstatus,totalsize,remainsize);
    
    // 从右到左，第一字节代表sd卡是否插入（1为SD卡插入），
    // 第二字节代表是否正在录像（1为正在录像），
    // 第三字节表示录像模式（1为本地模式，0为行车模式）
    
    // sixB = Integer.toHexString(statu);
    // int d = Integer.parseInt(sixB);
    Byte b1 = (Byte) (sdstatus & 0xFF);// sd卡是否插入（1为SD卡插入）
    Byte b2 = (Byte) ((sdstatus & 0xFF00) >> 8);// 是否正在录像（1为正在录像），
    Byte b3 = (Byte) ((sdstatus & 0xFF0000) >> 16);// 表示录像模式（1为本地模式，0为行车模式）
    NSLog(@"b1=%d b2=%d b3=%d",b1,b2,b3);
    [self performSelectorOnMainThread:@selector(updateRecordStatus:) withObject:[NSNumber numberWithInt:b2] waitUntilDone:NO];
}
-(BOOL)isOutOfMemory {
    
    //    return NO;
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;
    NSFileManager* fileManager = [[NSFileManager alloc ]init];
    NSDictionary *fileSysAttributes = [fileManager attributesOfFileSystemForPath:path error:nil];
    NSNumber *freeSpace = [fileSysAttributes objectForKey:NSFileSystemFreeSize];
    NSNumber *totalSpace = [fileSysAttributes objectForKey:NSFileSystemSize];
    float free=([freeSpace longLongValue])/1024.0/1024.0/1024.0;
    float total=([totalSpace longLongValue])/1024.0/1024.0/1024.0;
    NSString *memory=@"";
    if (free>1.0) {
        memory=[NSString stringWithFormat:@"%0.1fG/%0.1fG",free,total];
        //strMemory=[[NSString alloc]initWithFormat:@"%0.1fG/%0.1fG",free,total];
    }else{
        free=([freeSpace longLongValue])/1024.0/1024.0;
        memory=[NSString stringWithFormat:@"%0.1fM/%0.1fG",free,total];
        if (free<100.0) {
            [self performSelectorOnMainThread:@selector(showMemory:) withObject:memory waitUntilDone:NO];
            return YES;
        }
    }
    NSLog(@"memory=%@",memory);
    
    [self performSelectorOnMainThread:@selector(showMemory:) withObject:memory waitUntilDone:NO];
    
    return NO;
}
-(void)showMemory:(NSString *)memory{
    
    btnMemory.title=memory;
}






//////////////////////////______________________________________________////////////////////////
//////////////////////////______________________________________________////////////////////////
//////////////////////////______________________________________________////////////////////////
//////////////////////////______________________________________________////////////////////////
//////////////////////////______________________________________________////////////////////////
//////////////////////////______________________________________________////////////////////////
//////////////////////////______________________________________________////////////////////////



#pragma mark- New Methods to capture video
# pragma mark
#pragma mark
#pragma mark



- (IBAction)backButtonAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
}



// Button Action to record video for curent event from live streaming

-(void)recordVideo :(id)sender{
    
    BOOL flag=[self isOutOfMemory];
    
    if (flag) {
        
        [CustomToast showWithText:@"No enough storage. Please clean up and try again."
                        superView:self.view
                        bLandScap:NO];
        
        
        return;
    }
    
    if (isProcessing && !isRecording) {
        return;
    }
    if (isRecording) {
        [recorder stop];
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        recorder=nil;
        
        isRecording=NO;
        startedAt=nil;

        [recordingTimerVideo invalidate];
        recordingTimerVideo=nil;
        
        NSLog(@"numberOfScreenshots is %@",numberOfScreenshots);
        
        isRecording=NO;
        
        isProcessing=YES;
        
        if(numberOfScreenshots.count > 0)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                labelRecording.text = @"Saving...";
            }];
            [NSThread detachNewThreadSelector:@selector(createWriter) toTarget:self withObject:nil];

        }

        [recordingTimer invalidate];
        recordingTimer=nil;
        [autometicStopTimer invalidate];
        autometicStopTimer=nil;
        self.labelRecording.hidden=YES;
        // Working For Audio Recording For Merging with Video
        
        
    }
    else{

        
        if ([[btnStatusPrompt title] isEqualToString:NSLocalizedStringFromTable(@"PPPPStatusOnline", @STR_LOCALIZED_FILE_NAME, nil)])
        {
            startedAt = [NSDate date];
            
            isRecording=YES;
            
            NSLog(@"Audio Recording status is %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"isRecordAudio"]);
            
            if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"isRecordAudio"]integerValue]==1) {
                [self initializeAudioRecorder];
                AVAudioSession *session = [AVAudioSession sharedInstance];
                [session setActive:YES error:nil];
                
                audioOrVideo = @"Audio";
                // Start recording
                [recorder record];
                
            }
            else
                audioOrVideo = @"Video";
            
            currentTimeInSeconds = 0;
            
            self.labelRecording.text = [self formattedTime:currentTimeInSeconds];
            self.labelRecording.hidden=NO;
            // [screenCaptureView startRecording];
            
            // Working For Audio Recording For Merging with Video
            
            numberOfScreenshots=[[NSMutableArray alloc]init];
            
            recordingTimerVideo =[NSTimer scheduledTimerWithTimeInterval:0.25
                                                                  target:self
                                                                selector:@selector(timerMethodExecute:)
                                                                userInfo:nil
                                                                 repeats:YES];
            
            
            
            
            if (!currentTimeInSeconds) {
                currentTimeInSeconds = 0 ;
            }
            
            if (!recordingTimer) {
                recordingTimer = [self createTimer:1.0:YES];
            }
            
            if (!autometicStopTimer) {
                
                autometicStopTimer=[self createTimer:[[[NSUserDefaults standardUserDefaults]objectForKey:@"recordingTime"]floatValue]*60:NO];
            }
            
            

        }
        else
        {
            [CustomToast showWithText:btnStatusPrompt.title
                            superView:self.view
                            bLandScap:NO];
        }
    }
}

#pragma mark- Screen Capture Functionality

-(void)timerMethodExecute:(id)info{
    
    if ([self isOutOfMemory]) {
        
        [self stopRecordForMemoryOver];
        
        return;
    }
    [self takeScreenshots];
}


-(void)takeScreenshots{
    
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]){
        
        
        NSData *tempData = UIImageJPEGRepresentation(self.imgView.image, 0.01);
        
        UIImage *image = [UIImage imageWithData:tempData];
        
        [numberOfScreenshots addObject:image];
        
    }
    else{
        
        UIGraphicsBeginImageContext(self.imgView.bounds.size);
        
        UIGraphicsBeginImageContextWithOptions(self.imgView.bounds.size,self.imgView.opaque, 0.0);
        [self.imgView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        [numberOfScreenshots addObject:image];
        
    }
    return;
    
    
}


#pragma end

#pragma mark- Generating Video From Screenshots

-(void)createWriter{
    
    NSError*error=nil;
    
    NSString *savedImagePath;
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"isRecordAudio"]integerValue]==1) {

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat: @"yyyyMMddHHmmss"];
        NSString *strDate = [formatter stringFromDate:[NSDate date]]; // Convert date to string
        
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",@""]];
        
        
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])//Check
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Will Create folder
        
        savedImagePath = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",strDate]];
        
        
        
    }
    else
    {
        NSString *strFileName = [self GetRecordFileName];
        savedImagePath = [self GetRecordPath: strFileName];
      
        NSDate * date = [NSDate date];
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString * strDate = [formatter stringFromDate:date];
        
        [m_pRecPathMgt InsertPath:strDID Date:strDate Path:strFileName];

        p2pPathDetails = [[NSMutableArray alloc] initWithObjects:strDID,strDate,strFileName, nil];
        
        [[NSUserDefaults standardUserDefaults] setValue:p2pPathDetails forKey:@"p2pDetails"];
        
    }
    
   
    
    
    
    NSURL *videoTempURL = [NSURL fileURLWithPath:savedImagePath];
    
    
    VideoURLP2P=[NSURL fileURLWithPath:savedImagePath];
    
    [[NSUserDefaults standardUserDefaults] setObject:savedImagePath forKey:@"video"];
    
    // WARNING: AVAssetWriter does not overwrite files for us, so remove the destination file if it already exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[videoTempURL path]  error:NULL];
    
    int height = 480;
    
    int width = 640;
    
    
    [self writeImageAsMovie:numberOfScreenshots toPath:savedImagePath size:CGSizeMake(width, height)];
    numberOfScreenshots=nil;
}

-(void)writeImageAsMovie:(NSArray *)array toPath:(NSString*)path size:(CGSize)size

{
    NSError *error = nil;
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:path]
                                  
                                                           fileType:AVFileTypeQuickTimeMovie
                                  
                                                              error:&error];
    
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey,
                                   
                                   nil];
    
    
    AVAssetWriterInput* writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                       
                                                                         outputSettings:videoSettings];
    
    
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:nil];
    
    
    NSParameterAssert(writerInput);
    
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    
    [videoWriter addInput:writerInput];
    
    //Start a SESSION of writing.
    
    // After you start a session, you will keep adding image frames
    
    // until you are complete - then you will tell it you are done.
    
    [videoWriter startWriting];
    
    // This starts your video at time = 0
    
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    
    CVPixelBufferRef buffer = NULL;
    
    
    // This was just our utility class to get screen sizes etc.
    
    
    int i = 0;
    _timeOfFirstFrame = CFAbsoluteTimeGetCurrent();

    
    while (1)
        
    {
        
        // Check if the writer is ready for more data, if not, just wait
        
        if(writerInput.readyForMoreMediaData){
            
            
            CFAbsoluteTime current  = CFAbsoluteTimeGetCurrent();
            CFTimeInterval elapse   = current - _timeOfFirstFrame;
            CMTime present          = CMTimeMake( i * 150, 600);
            
            NSLog(@"%d",present);
            
            
            if (i >= [array count])
                
            {
                buffer = NULL;
            }
            
            else
                
            {
                // This command grabs the next UIImage and converts it to a CGImage
                buffer = [self pixelBufferFromCGImage:[[array objectAtIndex:i] CGImage]];
            }
            
            if (buffer)
                
            {
                // Give the CGImage to the AVAssetWriter to add to your video
                [adaptor appendPixelBuffer:buffer withPresentationTime:present];
                
                CVPixelBufferPoolRef bufferPool = adaptor.pixelBufferPool;
                NSParameterAssert(bufferPool != NULL);
                CVPixelBufferRelease(buffer);
                i++;
            }
            
            else
                
            {
                //Finish the session:
                // This is important to be done exactly in this order
                [writerInput markAsFinished];
                
                // WARNING: finishWriting in the solution above is deprecated.
                
                // You now need to give a completion handler.
                
                [videoWriter finishWritingWithCompletionHandler:^{
                    
                    NSLog(@"Finished writing...checking completion status...");
                    
                    if (videoWriter.status != AVAssetWriterStatusFailed && videoWriter.status == AVAssetWriterStatusCompleted)
                    {
                        isProcessing=NO;
                        NSLog(@"Video writing succeeded.");
                        // Move video to camera roll
                        
                        // NOTE: You cannot write directly to the camera roll.
                        
                        // You must first write to an iOS directory then move it!
                        
                        //    NSURL *videoTempURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@", path]];
                        
                        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"isRecordAudio"]integerValue]==1)
                        {
                            [self mergeAndSave];
                        }
                        else{
                            [self performSelectorOnMainThread:@selector(showVideoSuccessMessage) withObject:nil waitUntilDone:NO];
                        }
                    } else
                        
                    {
                        NSLog(@"Video writing failed: %@", videoWriter.error);
                    }
                    
                }]; // end videoWriter finishWriting Block
                
                CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
                
                NSLog (@"Done");
                
                adaptor=nil;
                videoWriter=nil;
                writerInput=nil;
                array=nil;
                buffer=NULL;
                
                break;
                
            }
        }
    }
}


-(void)showVideoSuccessMessage{
    
    tempDetailsArray = [[NSMutableArray alloc] initWithObjects:@"Success",audioOrVideo,@"p2p", nil];
    [[NSUserDefaults standardUserDefaults] setValue:tempDetailsArray forKey:@"recording"];
    
    
    
    NSLog(@"%@", self.navigationController.viewControllers);
    if ([self.navigationController.viewControllers containsObject:self]) {
        
        [CustomToast showWithText:@"Video saved successfully"
                        superView:self.view
                        bLandScap:NO];
    }
}

-(CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image

{
    // This again was just our utility class for the height & width of the
    // incoming video (640 height x 480 width)
    
    int height = 1080;
    int width = 720;
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             
                             nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, width,
                                          
                                          height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          
                                          &pxbuffer);
    
    
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata, width,
                                                 
                                                 height, 8, 4*width, rgbColorSpace,
                                                 
                                                 kCGImageAlphaNoneSkipFirst);
    
    NSParameterAssert(context);
    
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    
    CGContextDrawImage(context, CGRectMake(0, 0, width,
                                           
                                           height), image);
    
    CGColorSpaceRelease(rgbColorSpace);
    
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}



#pragma mark- end

#pragma mark- Audio Capture Functionality


-(void)initializeAudioRecorder{
    
    NSError*error=nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyyMMddHHmmss"];
    NSString *strDate = [formatter stringFromDate:[NSDate date]]; // Convert date to string
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",@""]];
    
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])//Check
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Will Create folder
    }
    
    NSString *savedImagePath = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a",strDate]];

    
    [[NSUserDefaults standardUserDefaults] setObject:savedImagePath forKey:@"audio"];
    
    NSURL *outputFileURL = [NSURL fileURLWithPath:savedImagePath];
    AudioURlP2P=[NSURL fileURLWithPath:savedImagePath];
    
    NSLog(@"Audio Path is %@",AudioURlP2P);
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryRecord error:&error];
    
    if (error) {
        NSLog(@"Erro! %@", error.debugDescription);
    }
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    
    
}

#pragma mark- end


#pragma mark- Mixing Audio and Video


-(void)mergeAndSave
{
    //Create AVMutableComposition Object which will hold our multiple AVMutableCompositionTrack or we can say it will hold our video and audio files.
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    //Now first load your audio file using AVURLAsset. Make sure you give the correct path of your videos.
    //  NSURL *audio_url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Asteroid_Sound" ofType:@"mp3"]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // [fileManager removeItemAtPath:[AudioURl path]  error:NULL];
    
    NSLog(@"savedImagePathTemp is %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"audio"]);

    AudioURlP2P=[NSURL fileURLWithPath:[[NSUserDefaults standardUserDefaults] valueForKey:@"audio"]];
    
    NSLog(@"AudioURlP2P is %@",AudioURlP2P);

    AVURLAsset  *audioAsset = [[AVURLAsset alloc]initWithURL:AudioURlP2P options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    
    //Now we are creating the first AVMutableCompositionTrack containing our audio and add it to our AVMutableComposition object.
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    if([[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject]==NULL)
    {
        NSLog(@"Sound is not Present");
    }
    else
    {
        NSLog(@"Sound is Present");
        //You will initalise all things
    }

    
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    //Now we will load video file.
    // NSURL *video_url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Asteroid_Video" ofType:@"m4v"]];
    
    VideoURLP2P=[NSURL fileURLWithPath:[[NSUserDefaults standardUserDefaults] valueForKey:@"video"]];

    
    AVURLAsset  *videoAsset = [[AVURLAsset alloc]initWithURL:VideoURLP2P options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    
    //Now we are creating the second AVMutableCompositionTrack containing our video and add it to our AVMutableComposition object.
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    
    NSError*error=nil;
    
    
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);

    CMTime vdioDuration = videoAsset.duration;
    float vdioDurationSeconds = CMTimeGetSeconds(vdioDuration);

    
    NSLog(@"audio time: %f, video time: %f",audioDurationSeconds,vdioDurationSeconds);
    
    NSString *strFileName = [self GetRecordFileName];
    NSString *strPath = [self GetRecordPath: strFileName];
    
    NSURL *outputFileUrl = [NSURL fileURLWithPath:strPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:strPath])
        [[NSFileManager defaultManager] removeItemAtPath:strPath error:nil];
    
    
    
    //Now create an AVAssetExportSession object that will save your final video at specified path.
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    _assetExport.outputFileType = @"com.apple.quicktime-movie";
    _assetExport.outputURL = outputFileUrl;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             // [self exportDidFinish:_assetExport];
            NSDate * date = [NSDate date];
            NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSString * strDate = [formatter stringFromDate:date];

             [m_pRecPathMgt InsertPath:strDID Date:strDate Path:strFileName];
             
             NSLog(@"File merged sucessfully");
             if ([fileManager fileExistsAtPath:[AudioURlP2P path]]) {
                 
                 NSFileManager *fileManager = [NSFileManager defaultManager];
                 [fileManager removeItemAtPath:[AudioURlP2P path]  error:NULL];
                 
             }
             
             if ([fileManager fileExistsAtPath:[AudioURlP2P path]]) {
                 NSLog(@"File Available");
             }
             else{
                 NSLog(@"File not available");
             }
             
             
             if ([fileManager fileExistsAtPath:[VideoURLP2P path]]) {
                 
                 NSFileManager *fileManager = [NSFileManager defaultManager];
                 [fileManager removeItemAtPath:[VideoURLP2P path]  error:NULL];
                 
             }
             
             [self performSelectorOnMainThread:@selector(showVideoSuccessMessage) withObject:nil waitUntilDone:NO];
             
         });
     }
     ];
}



#pragma mark- Timer Functionality Implementation

- (NSTimer *)createTimer :(float)interval :(BOOL)shouldRepeat{
    return [NSTimer scheduledTimerWithTimeInterval:interval
                                            target:self
                                          selector:@selector(timerTicked:)
                                          userInfo:nil
                                           repeats:shouldRepeat];
}

- (void)timerTicked:(NSTimer *)timer1 {
    if (timer1==recordingTimer) {
        currentTimeInSeconds++;
        self.labelRecording.text = [self formattedTime:currentTimeInSeconds];
        
    }
    
    if (timer1== autometicStopTimer) {
        
        [self recordVideo:nil];
        
    }
}

- (NSString *)formattedTime:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}


-(void)timeOutAlertMessagePopOut
{
    imgView.image = nil;
    UIView *alertView = [[UIView alloc]initWithFrame:CGRectMake(20, 50, 250, 100)];
    
    alertView.center=CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2+80);
    alertView.backgroundColor=[UIColor clearColor];
    
    UIImageView*errorImage =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"error"]];
    errorImage.frame=CGRectMake(0, 5, errorImage.frame.size.width, errorImage.frame.size.height);
    errorImage.center=CGPointMake(alertView.frame.size.width/2, errorImage.center.y);
    [alertView addSubview:errorImage];
    
    UILabel *errorLbl = [[UILabel alloc]initWithFrame:CGRectMake(10, errorImage.frame.origin.y+errorImage.frame.size.height/2, alertView.frame.size.width-20, 100)];
    errorLbl.numberOfLines=0;
    errorLbl.text=@"Connect Time Out, Please check if device is connected.";
    errorLbl.textAlignment=NSTextAlignmentCenter;
    errorLbl.font=[UIFont boldSystemFontOfSize:16];
    errorLbl.textColor=[UIColor whiteColor];
    [alertView addSubview:errorLbl];
    
    [self.view addSubview:alertView];
    
    
    [UIView animateWithDuration:3 animations:^{
        
        alertView.frame = CGRectMake(alertView.frame.origin.x, alertView.frame.origin.y, 0, 0);
        
        alertView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [alertView removeFromSuperview];
        [self.navigationController popViewControllerAnimated:YES];
        
    }];

}





@end
