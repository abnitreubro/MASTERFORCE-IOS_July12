//
//  PictureViewController.h
//  P2PCamera
//
//  Created by mac on 12-11-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraListMgt.h"
#import "PicPathManagement.h"
#import "NotifyEventProtocol.h"

@interface PictureViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, NotifyEventProtocol>{
    IBOutlet UINavigationBar *navigationBar;
    IBOutlet UISegmentedControl *segmentedControl;
    IBOutlet UITableView *m_tableView;
    
    
   // CameraListMgt *m_pCameraListMgt;
    //PicPathManagement *m_pPicPathMgt;
    
    UIImage *imageBkDefault;
}

@property (nonatomic, retain) UINavigationBar *navigationBar;
@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@property (nonatomic, assign) CameraListMgt *m_pCameraListMgt;
@property (nonatomic, assign) PicPathManagement *m_pPicPathMgt;
@property (nonatomic, retain) UITableView *m_tableView;
@property (nonatomic, retain) UIImage *imageBkDefault;

@end
