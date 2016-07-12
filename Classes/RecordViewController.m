//
//  RecordViewController.m
//  P2PCamera
//
//  Created by mac on 12-11-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RecordViewController.h"
#import "obj_common.h"
#import "RecordDateViewController.h"
#import "PicDirCell.h"
#import "defineutility.h"
#import "APICommon.h"
#import "obj_common.h"
#import "PPPPDefine.h"
#import "RemoteRecordFileListViewController.h"
#import "mytoast.h"

@interface RecordViewController ()

@end

@implementation RecordViewController

@synthesize navigationBar;
@synthesize segmentedControl;
@synthesize m_pCameraListMgt;
@synthesize m_tableView;
@synthesize m_pRecPathMgt;
@synthesize imageVideoDefault;
@synthesize imagePlay;
@synthesize m_pPPPPChannelMgt;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.image = [UIImage imageNamed:@"record30.png"];
        self.tabBarItem.title = NSLocalizedStringFromTable(@"Record", @STR_LOCALIZED_FILE_NAME, nil);
    }
    return self;
}

- (void) segmentedChanged: (id) sender
{
    UISegmentedControl *segment = (UISegmentedControl*)sender;
    
    switch (segment.selectedSegmentIndex) {
        case 0: //local
            m_bLocal = YES;
            self.m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            break;
        case 1: //remote
            m_bLocal = NO;
            self.m_tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            break;
            
        default:
            return;
    }
    
    [self.m_tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    m_bLocal = YES;
    
    UIImage *image = [UIImage imageNamed:@"top_bg_blue.png"];
    [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
//    UINavigationItem *navigationItem1 = [[UINavigationItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Record", @STR_LOCALIZED_FILE_NAME, nil)]; 
//    
//    NSArray *array = [NSArray arrayWithObjects:navigationItem1, nil];
//    [self.navigationBar setItems:array];
//    
//    [navigationItem1 release];
    
    self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    self.segmentedControl.tintColor = [UIColor colorWithRed:BTN_NORMAL_RED/255.0f green:BTN_NORMAL_GREEN/255.0f blue:BTN_NORMAL_BLUE/255.0f alpha:1.0f];

    [segmentedControl setTitle:NSLocalizedStringFromTable(@"Local", @STR_LOCALIZED_FILE_NAME, nil) forSegmentAtIndex:0];
    [segmentedControl setTitle:NSLocalizedStringFromTable(@"Remote", @STR_LOCALIZED_FILE_NAME, nil) forSegmentAtIndex:1];
    
    self.segmentedControl.selectedSegmentIndex = 0;
    
    [self.segmentedControl addTarget:self action:@selector(segmentedChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.imageVideoDefault = [UIImage imageNamed:@"videobk.png"];
    self.m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.imagePlay = [UIImage imageNamed:@"play_video.png"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) dealloc
{
    self.navigationBar = nil;
    self.segmentedControl = nil;
    self.m_pCameraListMgt = nil;
    self.m_tableView = nil;
    self.m_pRecPathMgt = nil;
    self.imageVideoDefault = nil;
    self.imagePlay = nil;
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark TableViewDelegate


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"numberOfRowsInSection");    
    int count = [m_pCameraListMgt GetCount];
    return count;  
    
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)anIndexPath
{
    //NSLog(@"cellForRowAtIndexPath");  
    
    NSInteger index = anIndexPath.row ;    
    
    //-----------------------------------------------------------------------------------
    NSDictionary *cameraDic = [m_pCameraListMgt GetCameraAtIndex:index];
    NSString *name = [cameraDic objectForKey:@STR_NAME];
    //UIImage *img = [cameraDic objectForKey:@STR_IMG];    
    NSNumber *nPPPPStatus = [cameraDic objectForKey:@STR_PPPP_STATUS];
    //NSNumber *nPPPPMode = [cameraDic objectForKey:@STR_PPPP_MODE];
    NSString *did = [cameraDic objectForKey:@STR_DID];
    
    NSString *cellIdentifier1 = @"RemoteRecordViewCell";
    if (m_bLocal == NO) {
        UITableViewCell *cell1 =  [aTableView dequeueReusableCellWithIdentifier:cellIdentifier1];
        if (cell1 == nil)
        {
            cell1 = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier1];
            [cell1 autorelease];
        }
        
        cell1.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell1.textLabel.text = name;
        
        NSString *strPPPPStatus = nil;
        int PPPPStatus = [nPPPPStatus intValue];
        switch (PPPPStatus) {
            case PPPP_STATUS_UNKNOWN:
                strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusUnknown", @STR_LOCALIZED_FILE_NAME, nil);
                break;
            case PPPP_STATUS_CONNECTING:
                strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusConnecting", @STR_LOCALIZED_FILE_NAME, nil);
                break;
            case PPPP_STATUS_INITIALING:
                strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusInitialing", @STR_LOCALIZED_FILE_NAME, nil);
                break;
            case PPPP_STATUS_CONNECT_FAILED:
                strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusConnectFailed", @STR_LOCALIZED_FILE_NAME, nil);
                break;
            case PPPP_STATUS_DISCONNECT:
                strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusDisconnected", @STR_LOCALIZED_FILE_NAME, nil);
                break;
            case PPPP_STATUS_INVALID_ID:
                strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusInvalidID", @STR_LOCALIZED_FILE_NAME, nil);
                break;
            case PPPP_STATUS_ON_LINE:
                strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusOnline", @STR_LOCALIZED_FILE_NAME, nil);
                break;
            case PPPP_STATUS_DEVICE_NOT_ON_LINE:
                strPPPPStatus = NSLocalizedStringFromTable(@"CameraIsNotOnline", @STR_LOCALIZED_FILE_NAME, nil);
                break;
            case PPPP_STATUS_CONNECT_TIMEOUT:
                strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusConnectTimeout", @STR_LOCALIZED_FILE_NAME, nil);
                break;
            default:
                strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusUnknown", @STR_LOCALIZED_FILE_NAME, nil);
                break;
        }
        
        cell1.detailTextLabel.text = strPPPPStatus;
        return cell1;
    }
    NSString *cellIdentifier = @"LocalRecordViewCell";       
    //当状态为显示当前的设备列表信息时
    PicDirCell *cell =  (PicDirCell*)[aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PicDirCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.labelName.text = [NSString stringWithFormat:@"%@(%d)", name, [m_pRecPathMgt GetTotalNumByID:did]];
    
    NSString *strFileName = [m_pRecPathMgt GetFirstPathByID:did];
    UIImage *image = [APICommon GetImageByName:did filename:strFileName];
    if (image != nil) {
        cell.imageView.image = image;
        
        int halfWidth = cell.imageView.frame.size.width / 2;
        int halfHeight = cell.imageView.frame.size.height / 2;
        
        int halfX = cell.imageView.frame.origin.x + halfWidth;
        int halfY = cell.imageView.frame.origin.y + halfHeight;
        
        int imageX = halfX - 20;
        int imageY = halfY - 20;
        
        //play image
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, imageY, 40, 40)];
        imageView.image = self.imagePlay;
        imageView.alpha = 0.6f;
        [cell addSubview:imageView];
        [imageView release];
    }else {
        cell.imageView.image = imageVideoDefault;
    }
    
    float cellHeight = cell.frame.size.height;
    float cellWidth = cell.frame.size.width;
    
    //NSLog(@"dddd cellHeight: %f, cellWidth: %f", cellHeight, cellWidth);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.origin.x, cellHeight - 2, cellWidth, 1)];
    label.backgroundColor = [UIColor colorWithRed:CELL_SEPERATOR_RED/255.0f green:CELL_SEPERATOR_GREEN/255.0f blue:CELL_SEPERATOR_BLUE/255.0f alpha:1.0];
    
    UIView *cellBgView = [[UIView alloc] initWithFrame:cell.frame];
    [cellBgView addSubview:label];
    [label release];
    
    cell.backgroundView = cellBgView;
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView*)tableview heightForRowAtIndexPath:(NSIndexPath*)indexpath
{
    if (m_bLocal) {
        return 60;
    }
    
    return 50;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)anIndexPath
{    
    [aTableView deselectRowAtIndexPath:anIndexPath animated:YES];
    
    NSDictionary *cameraDic = [m_pCameraListMgt GetCameraAtIndex:anIndexPath.row];
    NSString *name = [cameraDic objectForKey:@STR_NAME];
    NSString *did = [cameraDic objectForKey:@STR_DID];
    NSNumber *nPPPPStatus = [cameraDic objectForKey:@STR_PPPP_STATUS];
    
    if (m_bLocal) {
        RecordDateViewController *recDateViewController = [[RecordDateViewController alloc] init];
        recDateViewController.strName = name;
        recDateViewController.strDID = did;
        recDateViewController.m_pRecPathMgt = m_pRecPathMgt;
        recDateViewController.RecReloadDelegate = self;
        [self.navigationController pushViewController:recDateViewController animated:YES];
        [recDateViewController release];
    }else{
        
        int nStatus = [nPPPPStatus intValue];
        if (nStatus != PPPP_STATUS_ON_LINE) {
            [mytoast showWithText:NSLocalizedStringFromTable(@"CameraIsNotOnline", @STR_LOCALIZED_FILE_NAME, nil)];
            return;
        }
        RemoteRecordFileListViewController *remoteFileView = [[RemoteRecordFileListViewController alloc] init];
        remoteFileView.m_pPPPPChannelMgt = m_pPPPPChannelMgt;
        remoteFileView.m_strName = name;
        remoteFileView.m_strDID = did;
        
        [self.navigationController pushViewController:remoteFileView animated:YES];
        [remoteFileView release];
    }    
    
}

#pragma mark -
#pragma mark performOnMainThread

- (void) reloadTableView
{
    [m_tableView reloadData];
}

#pragma mark -
#pragma mark NotifyReloadData

- (void) NotifyReloadData
{
    [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:NO];
}

@end
