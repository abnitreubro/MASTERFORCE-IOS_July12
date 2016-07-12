//
//  MyDocumentView.h
//  P2PCamera
//
//  Created by Tsang on 13-8-13.
//
//

#import <UIKit/UIKit.h>
#import "CameraListMgt.h"
#import "PicPathManagement.h"
#import "RecPathManagement.h"
#import "PPPPChannelManagement.h"
#import "NotifyEventProtocol.h"
@interface MyDocumentView : UIViewController<UITableViewDelegate,UITableViewDataSource,NotifyEventProtocol>
{
    IBOutlet UITableView *mTableView;
    IBOutlet UINavigationBar *navigationBar;
    CameraListMgt *m_pCameraListMgt;
    PicPathManagement *m_pPicPathMgt;
    RecPathManagement *m_pRecPathMgt;
    CPPPPChannelManagement *m_pPPPPChannelMgt;
    NSString *strDID;
    NSString *strUser;
    NSString *strPwd;
    UIImage *defaultImg;
}
@property (nonatomic,copy) NSString *strDID;
@property (nonatomic,copy) NSString *strUser;
@property (nonatomic,copy) NSString *strPwd;
@property (nonatomic, assign) CameraListMgt *m_pCameraListMgt;
@property (nonatomic, assign) PicPathManagement *m_pPicPathMgt;
@property (nonatomic, assign) RecPathManagement *m_pRecPathMgt;
@property (nonatomic, assign) CPPPPChannelManagement *m_pPPPPChannelMgt;
@property (nonatomic, retain) UINavigationBar *navigationBar;
@property (nonatomic, retain) UITableView *mTableView;
@end
