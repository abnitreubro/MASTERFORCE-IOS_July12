//
//  CameraViewController.h
//  IpCameraClient
//
//  Created by jiyonglong on 12-4-23.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditCameraProtocol.h"
#import "CameraListMgt.h"
#import "PPPPChannelManagement.h"
#import "PPPPStatusProtocol.h"
#import "SnapshotProtocol.h"
#import "PicPathManagement.h"
#import "NotifyEventProtocol.h"
#import "RecPathManagement.h"

@interface CameraViewController : UIViewController  
<UITableViewDelegate, UITableViewDataSource, EditCameraProtocol, PPPPStatusProtocol, SnapshotProtocol>{   
    
    BOOL bEditMode;
    CameraListMgt *cameraListMgt;   
    PicPathManagement *m_pPicPathMgt;
    RecPathManagement *m_pRecPathMgt;
    CPPPPChannelManagement *pPPPPChannelMgt;
    NSCondition *ppppChannelMgntCondition;
    
    IBOutlet UITableView *cameraList;
    IBOutlet UINavigationBar *navigationBar;
    
    IBOutlet UIButton *btnAddCamera;
    
    id<NotifyEventProtocol> PicNotifyEventDelegate;
    id<NotifyEventProtocol> RecordNotifyEventDelegate;
 

}

@property (nonatomic, retain) UITableView *cameraList;
@property (nonatomic, retain) UINavigationBar *navigationBar;

@property (nonatomic, retain) UIButton *btnAddCamera;
@property (nonatomic, assign) CameraListMgt *cameraListMgt;
@property (nonatomic, assign) PicPathManagement *m_pPicPathMgt;
@property (nonatomic, assign) RecPathManagement *m_pRecPathMgt;
@property (nonatomic, assign) id<NotifyEventProtocol> PicNotifyEventDelegate;
@property (nonatomic, assign) id<NotifyEventProtocol> RecordNotifyEventDelegate;
@property (nonatomic, assign) CPPPPChannelManagement *pPPPPChannelMgt;

- (void) StopPPPP;
- (void) StartPPPPThread;

- (IBAction)btnAddCameraTouchDown:(id)sender;
- (IBAction)btnAddCameraTouchUp:(id)sender;


@end
