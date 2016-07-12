//
//  SearchFileViewController.h
//  P2PCamera
//
//  Created by Tsang on 13-2-1.
//
//

#import <UIKit/UIKit.h>
#import "RemoteFileSearchResultProtocol.h"
@interface SearchFileViewController : UIViewController<UINavigationBarDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
   IBOutlet UINavigationBar *navigationBar;
    UIPickerView *fPickerView;
    UIPickerView *sPickerView;
    NSMutableArray *yearArray;
    NSMutableArray *monthArray;
    NSMutableArray *dateArray;
    NSMutableArray *hourArray;
    NSMutableArray *minuteArray;
    NSMutableArray *secondArray;
    IBOutlet UISwitch *allSwitch;
    int fYear;
    int fMonth;
    int fDate;
    int fHour;
    int fMinute;
    int fSecond;
    int sYear;
    int sMonth;
    int sDate;
    int sHour;
    int sMinute;
    int sSecond;
    BOOL isAll;
    id<RemoteFileSearchResultProtocol> remoteProtocol;
}
@property (nonatomic,retain)IBOutlet UINavigationBar *navigationBar;
@property (nonatomic,retain)UIPickerView *fPickerView;
@property (nonatomic,retain)UIPickerView *sPickerView;
@property (nonatomic,retain)NSMutableArray *yearArray;
@property (nonatomic,retain)NSMutableArray *monthArray;
@property (nonatomic,retain)NSMutableArray *dateArray;
@property (nonatomic,retain)NSMutableArray *hourArray;
@property (nonatomic,retain)NSMutableArray *minuteArray;
@property (nonatomic,retain)NSMutableArray *secondArray;
@property (nonatomic, retain) UISwitch *allSwitch;
@property (nonatomic,assign)id<RemoteFileSearchResultProtocol> remoteProtocol;
@end
