



//
//  PictureShowViewController.h
//  P2PCamera
//
//  Created by mac on 12-11-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLCycleScrollView.h"
#import "PicPathManagement.h"
#import "NotifyEventProtocol.h"

@interface PictureShowViewController : UIViewController<XLCycleScrollViewDelegate, XLCycleScrollViewDatasource, UIAlertViewDelegate, UINavigationBarDelegate>{
    NSMutableArray *picPathArray;
    NSString *strDID;
    NSString *strDate;
    int m_currPic;
    PicPathManagement *m_pPicPathMgt;
    
    XLCycleScrollView *cycleScrollView;
    UINavigationBar *navigationBar;
    UIToolbar *toolBar;
    
    id<NotifyEventProtocol> NotifyReloadDataDelegate;
    
    UINavigationItem *item;
}

@property (nonatomic, copy) NSString *strDID;
@property (nonatomic, copy) NSString *strDate;
@property (nonatomic, assign) NSMutableArray *picPathArray;
@property (nonatomic, assign) int m_currPic;
@property (nonatomic, assign) PicPathManagement *m_pPicPathMgt;
@property (nonatomic, assign) id<NotifyEventProtocol> NotifyReloadDataDelegate;
@property (nonatomic, retain)UINavigationItem *item;
@end

