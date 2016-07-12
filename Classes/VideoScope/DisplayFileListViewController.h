//
//  DisplayFileListViewController.h
//  VideoScope
//
//  Created by JS Products on 15/03/16.
//  Copyright © 2016  JS Products. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DisplayFileListCollectionViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import "ShowImageViewController.h"
#import "PicPathManagement.h"
#import "RecPathManagement.h"
#import "APICommon.h"

#import "AppDelegate.h"
#import "VideoPlayer.h"

@interface DisplayFileListViewController : UICollectionViewController<UIActionSheetDelegate>
{
    NSMutableArray *picPathArray;
    PicPathManagement *m_pPicPathMgt;
    NSString *strDID;
    RecPathManagement *m_pRecPathMgt;
}


@property (strong, nonatomic) IBOutlet UICollectionView *FileListCollectionView;
@property UIImageView *imgvwThumb;

@property BOOL isP2P;

@end
