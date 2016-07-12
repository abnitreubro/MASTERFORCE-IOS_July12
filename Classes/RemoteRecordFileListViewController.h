//
//  RemoteRecordFileListViewController.h
//  P2PCamera
//
//  Created by Tsang on 12-12-14.
//
//

#import <UIKit/UIKit.h>

#import "PPPPChannelManagement.h"
#import "SDCardRecordFileSearchProtocol.h"
#import "MyHeaderView.h"
#import "RunCarDownloadRemoteFileProtocol.h"
#import "RemoteDownloadFiles.h"
#import "RemoteFileSearchResultProtocol.h"
#import "NotifyEventProtocol.h"
#import "PicPathManagement.h"
@interface RemoteRecordFileListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate, UINavigationBarDelegate, SDCardRecordFileSearchProtocol,RunCarDownloadRemoteFileProtocol,RemoteFileSearchResultProtocol,NotifyEventProtocol>
{
    IBOutlet UINavigationBar *navigationBar;
    IBOutlet UITableView *mTableView;
    
    NSCondition *m_timerLock;
    NSTimer *m_timer;
    BOOL m_bFinished;
    
    CPPPPChannelManagement *m_pPPPPChannelMgt;
    PicPathManagement *m_pPicPathMgt;
    NSString *m_strDID;
    NSString *m_strName;
    
    NSMutableArray *m_RecordFileList;
    
    NSMutableArray *m_DateArray;
    NSMutableDictionary *m_AllDic;
    NSMutableArray *m_CurDateArray;
    NSMutableDictionary *m_CurAllDic;
    //MyHeaderView *headerView;
    
    BOOL isDownLoading;
    
    RemoteDownload *remoteDownload;
    
    int selectRow;//选择的下载行
    int selectSection;//选择下载的section
    float mProgress;//下载的进度
    NSMutableDictionary *mDownloadDic;//下载过的文件
    UIActivityIndicatorView *indicatorView;
    UILabel *label_progress;
    NSIndexPath *selectIndexPath;
    UIPickerView *fPickerView;
    UIPickerView *sPickerView;
    //test
    NSTimer *mTimer;
    int num;
    int totaldata;
    int curdata;
    BOOL isOpen;
    NSString *DownloadingFileName;
}
@property (nonatomic,copy)NSString *DownloadingFileName;
@property (nonatomic, retain) UINavigationBar *navigationBar;
@property (nonatomic, retain) UITableView *mTableView;
@property (nonatomic, assign) CPPPPChannelManagement *m_pPPPPChannelMgt;
@property (nonatomic, assign) PicPathManagement *m_pPicPathMgt;
@property (nonatomic, copy) NSString *m_strDID;
@property (nonatomic, copy) NSString *m_strName;
@property (nonatomic,retain)NSMutableDictionary *mDownloadDic;
@property (nonatomic,retain)UIActivityIndicatorView *indicatorView;
@property (nonatomic, retain)UILabel *label_progress;
@end
