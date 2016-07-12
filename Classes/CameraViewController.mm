
//  CameraViewController.m
//  IpCameraClient
//
//  Created by jiyonglong on 12-4-23.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CameraViewController.h"
#import "CameraListCell.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "PPPPDefine.h"
#import "mytoast.h"
#include "MyAudioSession.h"
#import "AddCameraCell.h"


@implementation CameraViewController

@synthesize cameraList;
@synthesize navigationBar;

@synthesize btnAddCamera;
@synthesize cameraListMgt;
@synthesize m_pPicPathMgt;
@synthesize PicNotifyEventDelegate;
@synthesize RecordNotifyEventDelegate;
@synthesize m_pRecPathMgt;
@synthesize pPPPPChannelMgt;

#pragma mark -
#pragma mark button presss handle

- (void) StartPlayView: (NSInteger)index
{    
    NSDictionary *cameraDic = [cameraListMgt GetCameraAtIndex:index];
    if (cameraDic == nil) {
        return;
    }
    
    NSString *strDID = [cameraDic objectForKey:@STR_DID];
    NSString *strName = [cameraDic objectForKey:@STR_NAME];
    NSNumber *nPPPPMode = [cameraDic objectForKey:@STR_PPPP_MODE];
    //pPPPPChannelMgt->PPPPGetSDCardRecordFileList((char*)[strDID UTF8String], 0, 0);
    
    
    AppDelegate *IPCamDelegate =  [[UIApplication sharedApplication] delegate] ;
    PlayViewController *playViewController = [[PlayViewController alloc] init];
    playViewController.m_pPPPPChannelMgt = pPPPPChannelMgt;
    playViewController.strDID = strDID;
    playViewController.cameraName = strName;
    playViewController.m_nP2PMode =1;// [nPPPPMode intValue];
    [IPCamDelegate switchPlayView:playViewController];
    
    [playViewController release];

}


#define ADD_CAMERA_RED 200
#define ADD_CAMERA_GREED 200
#define ADD_CAMERA_BLUE 200

#define ADD_CAMERA_NORMAL_RED 230
#define ADD_CAMERA_NORMAL_GREEN 230
#define ADD_CAMERA_NORMAL_BLUE 230

- (IBAction)btnAddCameraTouchDown:(id)sender
{
    btnAddCamera.backgroundColor = [UIColor colorWithRed:ADD_CAMERA_RED/255.0f green:ADD_CAMERA_GREED/255.0f blue:ADD_CAMERA_BLUE/255.0f alpha:1.0];
}

- (IBAction)btnAddCameraTouchUp:(id)sender
{
    
    
   // [cameraListMgt AddCamera:@"aaaaa" DID:@"bbbbb" User:@"dsfsfs" Pwd:@"" Snapshot:nil];
}

- (void) btnEdit:(id)sender
{
    //NSLog(@"btnEdit");   
    
    if (!bEditMode) {
        [self.cameraList setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    }else {
        [self.cameraList setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    
//    if (!bEditMode) {
//        //将tableview放大
//        CGRect tableviewFrame = self.cameraList.frame;
//        tableviewFrame.origin.y -= 45;
//        tableviewFrame.size.height += 45;
//        
//        self.cameraList.frame = tableviewFrame;
//        
//    }
//    else {
//        CGRect tableviewFrame = self.cameraList.frame;
//        tableviewFrame.origin.y += 45;
//        tableviewFrame.size.height -= 45;
//        
//        self.cameraList.frame = tableviewFrame;
//    }
    
    bEditMode = ! bEditMode;
    [self setNavigationBarItem:bEditMode];
   
    [cameraList reloadData];
}

- (void) setNavigationBarItem: (BOOL) abEditMode
{
    NSString *strText;    
    UIBarButtonItem *btnEdit;
    if (!abEditMode) {
        strText = NSLocalizedStringFromTable(@"Edit", @STR_LOCALIZED_FILE_NAME, nil);
        btnEdit = [[UIBarButtonItem alloc] initWithTitle:strText  style:UIBarButtonItemStyleBordered target:self action:@selector(btnEdit:)];
        //btnEdit.tintColor = [UIColor colorWithRed:COLOR_BASE_RED/255 green:COLOR_BASE_GREEN/255 blue:COLOR_BASE_BLUE/255 alpha:0.5];
        
        btnEdit.tintColor = [UIColor colorWithRed:BTN_NORMAL_RED/255.0f green:BTN_NORMAL_GREEN/255.0f blue:BTN_NORMAL_BLUE/255.0f alpha:1.0];
    }else {
        strText = NSLocalizedStringFromTable(@"Done", @STR_LOCALIZED_FILE_NAME, nil);
        btnEdit = [[UIBarButtonItem alloc] initWithTitle:strText  style:UIBarButtonItemStyleBordered target:self action:@selector(btnEdit:)];
        
        btnEdit.tintColor = [UIColor colorWithRed:BTN_DONE_RED/255.0f green:BTN_DONE_GREEN/255.0f blue:BTN_DONE_BLUE/255.0f alpha:1.0];
    }
    
    UINavigationItem *naviItem = [[UINavigationItem alloc] initWithTitle:NSLocalizedStringFromTable(@"IPCamera", @STR_LOCALIZED_FILE_NAME, nil)];  

    naviItem.rightBarButtonItem = btnEdit;
    [btnEdit release];
    NSArray *array = [NSArray arrayWithObjects:naviItem, nil];
    [self.navigationBar setItems:array];
    [naviItem release];

}


#pragma mark -
#pragma mark TableViewDelegate

//删除设备的处理
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
    //NSLog(@"commitEditingStyle");
    
    NSDictionary *cameraDic = [cameraListMgt GetCameraAtIndex:indexPath.row];
    NSString *strDID = [cameraDic objectForKey:@STR_DID];    
    if(YES == [cameraListMgt RemoveCameraAtIndex:indexPath.row]){
        if ([cameraListMgt GetCount] > 0) {
            [cameraList deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }else {
            [cameraList deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        //停止P2P
        pPPPPChannelMgt->Stop([strDID UTF8String]);
        
        [m_pPicPathMgt RemovePicPathByID:strDID];
        [m_pRecPathMgt RemovePathByID:strDID];
        
        [PicNotifyEventDelegate NotifyReloadData];
        [RecordNotifyEventDelegate NotifyReloadData];
        
        if ([cameraListMgt GetCount] == 0) {
            [self btnEdit:nil];
        }
        
    }    
} 

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{  
    if (bEditMode == YES) {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone; 
} 

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)anIndexPath
{
    int index = anIndexPath.row - 1;
    NSDictionary *cameraDic = [cameraListMgt GetCameraAtIndex:index];
    if (cameraDic == nil) {
        return;
    }
    
    NSNumber *nPPPPStatus = [cameraDic objectForKey:@STR_PPPP_STATUS];        

    if ([nPPPPStatus intValue] != PPPP_STATUS_ON_LINE) {   
        [mytoast showWithText:NSLocalizedStringFromTable(@"CameraIsNotOnline", @STR_LOCALIZED_FILE_NAME, nil)];
        return;
    }

}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
    return  NSLocalizedStringFromTable(@"Delete", @STR_LOCALIZED_FILE_NAME, nil); 
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"numberOfRowsInSection");    
    int count = [cameraListMgt GetCount];
    
    if (bEditMode) {
        return count;
    }
   
    return count + 1;  
    
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)anIndexPath
{
    //NSLog(@"cellForRowAtIndexPath");  
    
    NSInteger index = anIndexPath.row ;    
    
    //-----------------------------------------------------------------------------------
    
    
    if (bEditMode) {
        NSDictionary *cameraDic = [cameraListMgt GetCameraAtIndex:index];
        NSString *name = [cameraDic objectForKey:@STR_NAME];
        NSString *did = [cameraDic objectForKey:@STR_DID];
        
        NSString *cellIdentifier = @"CameraListEditCell";       
        //当状态为显示当前的设备列表信息时
        UITableViewCell *cell =  [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            [cell autorelease];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.text = name;
        cell.detailTextLabel.text = did;
       
        return cell;
    }
    
    //index = 0显示添加摄像机
    if (index == 0) {
        NSString *cellIdentifier = @"AddCameraCell";       
        //当状态为显示当前的设备列表信息时
        AddCameraCell *cell =  (AddCameraCell*)[aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AddCameraCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.labelAddCamera.text = NSLocalizedStringFromTable(@"TouchAddCamera", @STR_LOCALIZED_FILE_NAME, nil);
        
        float cellHeight = cell.frame.size.height;
        float cellWidth = cell.frame.size.width;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.origin.x, 0, cellWidth, cellHeight - 1)];
        label.backgroundColor = [UIColor colorWithRed:CELL_SEPERATOR_RED/255.0f green:CELL_SEPERATOR_GREEN/255.0f blue:CELL_SEPERATOR_BLUE/255.0f alpha:1.0];
        
        UIView *cellBgView = [[UIView alloc] initWithFrame:cell.frame];
        [cellBgView addSubview:label];
        [label release];
        
        cell.backgroundView = cellBgView;
        
        return cell;
    }
    
    index -= 1;
    
    NSDictionary *cameraDic = [cameraListMgt GetCameraAtIndex:index];
    NSString *name = [cameraDic objectForKey:@STR_NAME];
    UIImage *img = [cameraDic objectForKey:@STR_IMG];    
    NSNumber *nPPPPStatus = [cameraDic objectForKey:@STR_PPPP_STATUS];
    //NSNumber *nPPPPMode = [cameraDic objectForKey:@STR_PPPP_MODE];
    NSString *did = [cameraDic objectForKey:@STR_DID];

    NSString *cellIdentifier = @"CameraListCell";       
    //当状态为显示当前的设备列表信息时
    CameraListCell *cell =  (CameraListCell*)[aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CameraListCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;   
    
    int PPPPStatus = [nPPPPStatus intValue];
    //int PPPPMode = [nPPPPMode intValue];
    //NSLog(@"name: %@, index: %d, PPPPStatus: %d, PPPPMode: %d", name, index, PPPPStatus, PPPPMode);
        
    if (img != nil) {
        cell.imageCamera.image = img;
    }
        
    cell.NameLable.text = name;
    cell.PPPPIDLable.text = did; 
    
    //NSLog(@"cell frame heigth: %f", cell.frame.size.height);
    
    float cellHeight = cell.frame.size.height;
    float cellWidth = cell.frame.size.width;
    
    //NSLog(@"dddd cellHeight: %f, cellWidth: %f", cellHeight, cellWidth);

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.origin.x, cellHeight - 2, cellWidth, 1)];
    label.backgroundColor = [UIColor colorWithRed:CELL_SEPERATOR_RED/255.0f green:CELL_SEPERATOR_GREEN/255.0f blue:CELL_SEPERATOR_BLUE/255.0f alpha:1.0];

    UIView *cellBgView = [[UIView alloc] initWithFrame:cell.frame];
    [cellBgView addSubview:label];
    [label release];
     
    cell.backgroundView = cellBgView;
    
//    NSString *strPPPPMode = nil;    
//    switch (PPPPMode) {
//        case PPPP_MODE_UNKNOWN:    
//            strPPPPMode = NSLocalizedStringFromTable(@"PPPPModeUnknown", @STR_LOCALIZED_FILE_NAME, nil);
//            break;
//        case PPPP_MODE_P2P:
//            strPPPPMode = NSLocalizedStringFromTable(@"PPPPModeP2P", @STR_LOCALIZED_FILE_NAME, nil);
//            break;
//        case PPPP_MODE_RELAY:
//            strPPPPMode = NSLocalizedStringFromTable(@"PPPPModeRelay", @STR_LOCALIZED_FILE_NAME, nil);
//            break;            
//        default:
//            strPPPPMode = NSLocalizedStringFromTable(@"PPPPModeUnknown", @STR_LOCALIZED_FILE_NAME, nil);
//            break;
//    }
    
    //cell.PPPPModeLable.text = strPPPPMode;   
        
    NSString *strPPPPStatus = nil;
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
    cell.PPPPStatusLable.text = strPPPPStatus;
         
   	return cell;
}

- (CGFloat)tableView:(UITableView*)tableview heightForRowAtIndexPath:(NSIndexPath*)indexpath
{
    if (bEditMode) {
        return 50;
    }
    
    if (indexpath.row == 0) {
        return 44;
    }
    
    return 74;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)anIndexPath
{    
    [aTableView deselectRowAtIndexPath:anIndexPath animated:YES];
    
    //NSLog(@"didSelectRowAtIndexPath");    
    if (bEditMode == YES) {
        [aTableView deselectRowAtIndexPath:anIndexPath animated:YES];
        
        NSDictionary *cameraDic = [cameraListMgt GetCameraAtIndex:anIndexPath.row];
        if (cameraDic == nil) {
            return;
        }
       

        return;
    }
    
    if (anIndexPath.row == 0) {
       
        return;
    }
    
    int index = anIndexPath.row;
    index -= 1;
    NSDictionary *cameraDic = [cameraListMgt GetCameraAtIndex:index];
    if (cameraDic == nil) {
        return;
    }
    
    NSNumber *nPPPPStatus = [cameraDic objectForKey:@STR_PPPP_STATUS];        
    if ([nPPPPStatus intValue] == PPPP_STATUS_INVALID_ID) {
        return;
    }
    
    if ([nPPPPStatus intValue] != PPPP_STATUS_ON_LINE) {
        NSString *strDID = [cameraDic objectForKey:@STR_DID];
        NSString *strUser = [cameraDic objectForKey:@STR_USER];
        NSString *strPwd = [cameraDic objectForKey:@STR_PWD];    
        pPPPPChannelMgt->Start([strDID UTF8String], [strUser UTF8String], [strPwd UTF8String]);
        //[mytoast showWithText:NSLocalizedStringFromTable(@"CameraIsNotOnline", @STR_LOCALIZED_FILE_NAME, nil)];
        return;
    }
    
    [self StartPlayView:index];

}

#pragma mark -
#pragma mark system

- (void) refresh: (id) sender
{
    [self UpdateCameraSnapshot];
}

- (void) UpdateCameraSnapshot
{   
    int count = [cameraListMgt GetCount];    
    if (count == 0) {
        [self hideLoadingIndicator];
        return;
    }   
    
    //NSLog(@"UpdateCameraSnapshot...count: %d", count);
    int i;
    for (i = 0; i < count; i++)
    {
        NSDictionary *cameraDic = [cameraListMgt GetCameraAtIndex:i];
        if (cameraDic == nil) {
            return ;
        }        
            
        NSNumber *nPPPPStatus = [cameraDic objectForKey:@STR_PPPP_STATUS];    
        if ([nPPPPStatus intValue] != PPPP_STATUS_ON_LINE) {
            continue;
        }
        
        NSString *did = [cameraDic objectForKey:@STR_DID];
        pPPPPChannelMgt->Snapshot([did UTF8String]);        
    }    
    
    [self showLoadingIndicator];    
    [self performSelector:@selector(hideLoadingIndicator) withObject:nil afterDelay:10.0];
    
}

- (void)showLoadingIndicator
{
	UIActivityIndicatorView *indicator =
    [[[UIActivityIndicatorView alloc]
      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite]
     autorelease];
	indicator.frame = CGRectMake(0, 0, 24, 24);
	[indicator startAnimating];
	UIBarButtonItem *progress =
    [[[UIBarButtonItem alloc] initWithCustomView:indicator] autorelease];
	[self.navigationItem setLeftBarButtonItem:progress animated:YES]; 
}


- (void)hideLoadingIndicator
{
	UIActivityIndicatorView *indicator =
    (UIActivityIndicatorView *)self.navigationItem.leftBarButtonItem;
	if ([indicator isKindOfClass:[UIActivityIndicatorView class]])
	{
		[indicator stopAnimating];
	}
	UIBarButtonItem *refreshButton =
    [[[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
      target:self
      action:@selector(refresh:)]
     autorelease];
	[self.navigationItem setLeftBarButtonItem:refreshButton animated:YES];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationMaskLandscape);
}
- (BOOL)shouldAutorotate
{
	return NO;
}
- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskLandscape;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
	return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void) StartPPPP:(id) param
{
    //usleep(100000);
    sleep(1);
    
    int count = [cameraListMgt GetCount];
    
    int i;
    for (i = 0; i < count; i++) {
        NSDictionary *cameraDic = [cameraListMgt GetCameraAtIndex:i];
        
        NSString *strDID = [cameraDic objectForKey:@STR_DID];
        NSString *strUser = [cameraDic objectForKey:@STR_USER];
        NSString *strPwd = [cameraDic objectForKey:@STR_PWD];
        NSNumber *nPPPPStatus = [cameraDic objectForKey:@STR_PPPP_STATUS];        
        if ([nPPPPStatus intValue] == PPPP_STATUS_INVALID_ID) {
            continue;
        }
        
        usleep(100000);
        pPPPPChannelMgt->Start([strDID UTF8String], [strUser UTF8String], [strPwd UTF8String]);
                
    }
}

- (void) StopPPPP
{
    [ppppChannelMgntCondition lock];
    if (pPPPPChannelMgt == NULL) {
        [ppppChannelMgntCondition unlock];
        return;
    }
    pPPPPChannelMgt->StopAll();
    [ppppChannelMgntCondition unlock];
}

- (id) init
{
    self = [super init];
    if (self != nil) {
        ppppChannelMgntCondition = [[NSCondition alloc] init];
        self.title = NSLocalizedStringFromTable(@"IPCamera", @STR_LOCALIZED_FILE_NAME, nil);
        self.tabBarItem.image = [UIImage imageNamed:@"ipc30.png"];
    }    
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    //NSLog(@"CameraViewController viewDidLoad");     
     
    //cameraListMgt = [[CameraListMgt alloc] init];    
    bEditMode = NO;
    
    UIImage *image = [UIImage imageNamed:@"top_bg_blue.png"];
    [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    

    [self setNavigationBarItem:bEditMode];

    [self.cameraList setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //[self.cameraList setSeparatorColor:[UIColor clearColor]];
    
    btnAddCamera.backgroundColor = [UIColor colorWithRed:ADD_CAMERA_NORMAL_RED/255.0f green:ADD_CAMERA_NORMAL_GREEN/255.0f blue:ADD_CAMERA_NORMAL_BLUE/255.0f alpha:1.0];
  
    //[ppppChannelMgntCondition lock];
    //pPPPPChannelMgt = new CPPPPChannelManagement();
    pPPPPChannelMgt->pCameraViewController = self;
    //[ppppChannelMgntCondition unlock];
    
    [self StartPPPPThread];
    
    InitAudioSession();
}

- (void) StartPPPPThread
{
    //NSLog(@"StartPPPPThread");
    [ppppChannelMgntCondition lock];
    if (pPPPPChannelMgt == NULL) {
        [ppppChannelMgntCondition unlock];
        return;
    }    
    [NSThread detachNewThreadSelector:@selector(StartPPPP:) toTarget:self withObject:nil];   
    [ppppChannelMgntCondition unlock];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    //[cameraListMgt release];
    //cameraListMgt = nil;
    SAFE_DELETE(pPPPPChannelMgt);    
}

- (void)dealloc {
    self.cameraList = nil;
    //[cameraListMgt release];
    //cameraListMgt = nil;
    SAFE_DELETE(pPPPPChannelMgt);
    [ppppChannelMgntCondition release];
    self.navigationBar = nil;
    self.cameraListMgt = nil;
    self.PicNotifyEventDelegate = nil;
    self.RecordNotifyEventDelegate = nil;
    self.m_pPicPathMgt = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark EditCameraProtocol

- (BOOL) EditP2PCameraInfo:(BOOL)bAdd Name:(NSString *)name DID:(NSString *)did User:(NSString *)user Pwd:(NSString *)pwd OldDID:(NSString *)olddid
{
    NSLog(@"EditP2PCameraInfo  bAdd: %d, name: %@, did: %@, user: %@, pwd: %@, olddid: %@", bAdd, name, did, user, pwd, olddid);
    
    BOOL bRet;
    
    if (bAdd == YES) {
        bRet = [cameraListMgt AddCamera:name DID:did User:user Pwd:pwd Snapshot:nil];
    }else {
        bRet = [cameraListMgt EditCamera:olddid Name:name DID:did User:user Pwd:pwd];
    }
    
    if (bRet == YES) {

        if (bAdd) {//添加成功，增加P2P连接
            pPPPPChannelMgt->Start([did UTF8String], [user UTF8String], [pwd UTF8String]);
        }else {//修改成功，重新启动P2P连接
            pPPPPChannelMgt->Stop([did UTF8String]);
            pPPPPChannelMgt->Start([did UTF8String], [user UTF8String], [pwd UTF8String]);
            [self btnEdit:nil];
        }
        
        if (bEditMode && [olddid caseInsensitiveCompare:did] != NSOrderedSame) {
            [m_pPicPathMgt RemovePicPathByID:olddid];
        }
        
        //添加或修改设备成功，重新加载设备列表
        [cameraList reloadData];
        
        [PicNotifyEventDelegate NotifyReloadData];
        [RecordNotifyEventDelegate NotifyReloadData];
        
        
    }
    
    NSLog(@"bRet: %d", bRet);
    
    return bRet;
}

#pragma mark -
#pragma mark  PPPPStatusProtocol
- (void) PPPPStatus:(NSString *)strDID statusType:(NSInteger)statusType status:(NSInteger)status
{
    //NSLog(@"PPPPStatus ..... strDID: %@, statusType: %d, status: %d", strDID, statusType, status);
    if (statusType == MSG_NOTIFY_TYPE_PPPP_MODE) {        
        NSInteger index = [cameraListMgt UpdatePPPPMode:strDID mode:status];
        if ( index >= 0){          
         //   [self performSelectorOnMainThread:@selector(ReloadRowDataAtIndex:) withObject:[NSNumber numberWithInt:index] waitUntilDone:NO];
        }
        return;
    }
    
    if (statusType == MSG_NOTIFY_TYPE_PPPP_STATUS) {
        NSInteger index = [cameraListMgt UpdatePPPPStatus:strDID status:status];
        if ( index >= 0){          
           // [self performSelectorOnMainThread:@selector(ReloadRowDataAtIndex:) withObject:[NSNumber numberWithInt:index] waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(ReloadCameraTableView) withObject:nil waitUntilDone:NO];
        }
        
        //如果是ID号无效，则停止该设备的P2P
        if (status == PPPP_STATUS_INVALID_ID 
            || status == PPPP_STATUS_CONNECT_TIMEOUT
            || status == PPPP_STATUS_DEVICE_NOT_ON_LINE
            || status == PPPP_STATUS_CONNECT_FAILED) {          
            [self performSelectorOnMainThread:@selector(StopPPPPByDID:) withObject:strDID waitUntilDone:NO];
        }
        
        [RecordNotifyEventDelegate NotifyReloadData];
        
        return;        
    }    
}

#pragma mark -
#pragma mark PerformInMainThread

- (void) ReloadCameraTableView
{
    [cameraList reloadData];  
}

- (void) ReloadRowDataAtIndex: (NSNumber*) indexNumber
{
    //NSLog(@"ReloadRowDataAtIndex %d", [indexNumber intValue]);
  
    NSInteger index = [indexNumber intValue];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UITableViewCell *cell = [cameraList cellForRowAtIndexPath:indexPath];
    if (cell != nil) {              
//        int row;   
//        index += 1;    
//        row = (index % 2 > 0) ? index / 2 + 1 : index / 2;
//        
        NSArray *array = [NSArray arrayWithObject:indexPath];
        [cameraList reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
    }
} 

- (void) StopPPPPByDID:(NSString*)did
{
    pPPPPChannelMgt->Stop([did UTF8String]);
}

- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    NSData *dataImg = UIImageJPEGRepresentation(newImage, 0.0001);
    UIImage *imgOK = [UIImage imageWithData:dataImg];
    
    // Return the new image.
    return imgOK;
}

- (void) saveSnapshot: (UIImage*) image DID: (NSString*) strDID
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //获取路径
    //参数NSDocumentDirectory要获取那种路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];//去处需要的路径
    
    NSString *strPath = [documentsDirectory stringByAppendingPathComponent:strDID];
    //NSLog(@"strPath: %@", strPath);
    
    [fileManager createDirectoryAtPath:strPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    //[fileManager createDirectoryAtPath:strPath attributes:nil];
    
    
    strPath = [strPath stringByAppendingPathComponent:@"snapshot.jpg"];
    //NSLog(@"strPath: %@", strPath);
    
    NSData *dataImage = UIImageJPEGRepresentation(image, 1.0);
    [dataImage writeToFile:strPath atomically:YES ];
    
    [pool release];
 
    
}

#pragma mark -
#pragma mark SnapshotNotify

- (void) SnapshotNotify:(NSString *)strDID data:(char *)data length:(int)length
{   
    //NSLog(@"CameraViewController SnapshotNotify... strDID: %@, length: %d", strDID, length);
    if (length < 20) {
        return;
    }
    
    //显示图片
    NSData *image = [[NSData alloc] initWithBytes:data length:length];
    if (image == nil) {
        //NSLog(@"SnapshotNotify image == nil");
        [image release];
        return;
    }
    
    UIImage *img = [[UIImage alloc] initWithData:image]; 
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    UIImage *imgScale = [self imageWithImage:img scaledToSize:CGSizeMake(160, 120)];

    NSInteger index = [cameraListMgt UpdateCamereaImage:strDID  Image:imgScale] ;
    if (index >= 0) {
        
        [self saveSnapshot:imgScale DID:strDID];
        
        //NSLog(@"UpdateCamereaImage success!");
        [self performSelectorOnMainThread:@selector(ReloadCameraTableView) withObject:nil waitUntilDone:NO];
       //[self performSelectorOnMainThread:@selector(ReloadRowDataAtIndex:) withObject:[NSNumber numberWithInt:index] waitUntilDone:NO];
    }  
    
    [pool release];
    
    [img release];        
    [image release];
    
}

@end
