////
////  PictureListViewController.h
////  P2PCamera
////
////  Created by mac on 12-11-14.
////  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
////
//
//#import <UIKit/UIKit.h>
//#import "PicPathManagement.h"
//#import "NotifyEventProtocol.h"
//
//@interface PictureListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, NotifyEventProtocol, UINavigationBarDelegate>{
//    IBOutlet UINavigationBar *navigationBar;
//    IBOutlet UITableView *m_tableView;
//    
//    NSMutableArray *picPathArray;
//    BOOL m_bEditMode;
//    UIToolbar *m_toolBar;
//    char m_pSelectedStatus[1024];
//    int m_nTotalNum;
//    UIImage *imageTag;
//    NSString *strDate;
//    NSString *strDID;
//    PicPathManagement *m_pPicPathMgt;
//    id<NotifyEventProtocol> NotifyReloadDataDelegate;
//    NSMutableDictionary *m_myImgDic;
//    IBOutlet UIView *progressView;
//    BOOL isSecond;
//    NSCondition *mLock;
//}
//
//@property (nonatomic, retain) UITableView *m_tableView;
//@property (nonatomic, retain) UINavigationBar *navigationBar;
//@property (nonatomic, copy) NSString *strDID;
//@property (nonatomic, copy) NSString *strDate;
//@property (nonatomic, assign) PicPathManagement *m_pPicPathMgt;
//@property (nonatomic,retain) id<NotifyEventProtocol> NotifyReloadDataDelegate;
//@property (nonatomic, retain) UIImage *imageTag;
//@property (nonatomic ,retain) IBOutlet UIView *progressView;
//@end

//
//  PictureListViewController.h
//  P2PCamera
//
//  Created by mac on 12-11-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicPathManagement.h"
#import "NotifyEventProtocol.h"

@interface PictureListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, NotifyEventProtocol, UINavigationBarDelegate>{
    IBOutlet UINavigationBar *navigationBar;
    IBOutlet UITableView *m_tableView;
    
    NSMutableArray *picPathArray;
    BOOL m_bEditMode;
    UIToolbar *m_toolBar;
    char m_pSelectedStatus[1024];
    int m_nTotalNum;
    UIImage *imageTag;
    NSString *strDate;
    NSString *strDID;
    PicPathManagement *m_pPicPathMgt;
    id<NotifyEventProtocol> NotifyReloadDataDelegate;
    NSMutableDictionary *m_myImgDic;
    IBOutlet UIView *progressView;
    
    BOOL isP2P;
    NSCondition *m_Lock;
    
    BOOL isIphone;
    
    UIAlertView *alertView;
}
@property BOOL isP2P;
@property (nonatomic, retain)NSCondition *m_Lock;
@property (nonatomic, retain) UITableView *m_tableView;
@property (nonatomic, retain) UINavigationBar *navigationBar;
@property (nonatomic, copy) NSString *strDID;
@property (nonatomic, copy) NSString *strDate;
@property (nonatomic, assign) PicPathManagement *m_pPicPathMgt;
@property (nonatomic,retain) id<NotifyEventProtocol> NotifyReloadDataDelegate;
@property (nonatomic, retain) UIImage *imageTag;
@property (nonatomic ,retain) IBOutlet UIView *progressView;
@property (nonatomic, retain)UIAlertView *alertView;
@end

