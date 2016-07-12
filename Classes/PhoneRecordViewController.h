//
//  PhoneRecordViewController.h
//  P2PCamera
//
//  Created by Tsang on 13-1-26.
//
//

#import <UIKit/UIKit.h>

#import "RemoteFileSearchResultProtocol.h"
@interface PhoneRecordViewController : UIViewController<UINavigationBarDelegate,UITableViewDataSource,UITableViewDelegate,RemoteFileSearchResultProtocol>
{
    IBOutlet UINavigationBar *navigationBar;
    IBOutlet UITableView *tableView;
    NSMutableArray *dateArray;
    NSMutableDictionary *arrDic;
    NSString *did;
    BOOL isOpen;
    UIToolbar *m_toolBar;
    NSMutableArray *m_CurArray;
    NSMutableDictionary *m_CurAllDic;
    NSMutableDictionary *statusDic;
    
    IBOutlet UIAlertView *alertView;
    UIBarButtonItem *btnEdit;
    UIBarButtonItem *btnSelectAll;
    UIBarButtonItem *btnSelectReverse ;
    UIBarButtonItem *btnDelete ;
    BOOL isEdit;
}
@property BOOL isEdit;
@property (nonatomic,retain) IBOutlet UIAlertView *alertView;
@property(nonatomic,retain)NSMutableDictionary *statusDic;
@property(nonatomic,retain)NSMutableArray *m_CurArray;
@property(nonatomic,retain) NSMutableDictionary *m_CurAllDic;
@property(nonatomic,retain)IBOutlet UINavigationBar *navigationBar;
@property(nonatomic,retain)IBOutlet UITableView *tableView;
@property(nonatomic,retain)NSMutableArray *dateArray;
@property(nonatomic,retain) NSMutableDictionary *arrDic;
@property(nonatomic,copy)NSString *did;
@end
