//
//  PictrueDateViewController.h
//  P2PCamera
//
//  Created by mac on 12-11-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicPathManagement.h"
#import "NotifyEventProtocol.h"

@interface PictrueDateViewController : UIViewController<UITableViewDelegate,NotifyEventProtocol, UITableViewDataSource, UINavigationBarDelegate>{
    PicPathManagement *m_pPicPathMgt;
    NSString *strDID;
    NSString *strName;
    
    NSMutableArray *picDataArray;
    
    IBOutlet UINavigationBar *navigationBar;
    IBOutlet UITableView *tableView;
    
    UIImage *imageBkDefault;
    id<NotifyEventProtocol> NotifyReloadDataDelegate;

    int mainScreenWidth;
}

@property (nonatomic, assign) PicPathManagement *m_pPicPathMgt;
@property (nonatomic, copy) NSString *strDID;
@property (nonatomic, copy) NSString *strName;
@property (nonatomic, retain) UINavigationBar *navigationBar;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIImage *imageBkDefault;
@property (nonatomic,retain) id<NotifyEventProtocol> NotifyReloadDataDelegate;

@end
