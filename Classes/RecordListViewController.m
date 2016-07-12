//
//  RecordListViewController.m
//  P2PCamera
//
//  Created by mac on 12-11-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RecordListViewController.h"
#import "obj_common.h"
#import "PicListCell.h"
#import "PlaybackViewController.h"
#import "AppDelegate.h"
#import "APICommon.h"
#import <QuartzCore/QuartzCore.h>
#import "SearchListCell.h"
@interface RecordListViewController ()

@end

@implementation RecordListViewController

@synthesize navigationBar;
@synthesize strDate;
@synthesize m_pRecPathMgt;
@synthesize strDID;
@synthesize m_tableView;
@synthesize imageDefault;
@synthesize imagePlay;
@synthesize imageTag;
@synthesize RecReloadDelegate;
@synthesize progressView;
@synthesize testArray;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) btnEdit: (id) sender
{
    m_bEditMode = !m_bEditMode;
    [self initNavigationBar];
    [self ShowEditButton];
}

- (void) btnSelectAll: (id) sender
{
    //NSLog(@"btnSelectAll...");
    
    BOOL bReloadData = NO;
    
    int i;
    for (i = 0; i < m_nTotalNum; i++) {
        if (m_pSelectedStatus[i] == 0) {
            bReloadData = YES;
            m_pSelectedStatus[i] = 1;
        }
            }
    
    if (bReloadData == YES) {
        [self.m_tableView reloadData];
    }
    
}

- (void) btnSelectReverse: (id) sender
{
    int i;
    for (i = 0; i < m_nTotalNum; i++) {
        if(m_pSelectedStatus[i] == 1){
            m_pSelectedStatus[i] = 0;
        }else {
            m_pSelectedStatus[i] = 1;
        }
    }
    
    [self.m_tableView reloadData];
}

- (void) btnDelete: (id) sender
{
    BOOL bReloadData = NO;
    int i;
    for (i = 0; i < m_nTotalNum; i++) {
       
        if (m_pSelectedStatus[i] == 1) {
            
            bReloadData = YES;
          
            [m_pRecPathMgt RemovePath:strDID Date:strDate Path:[picPathArray objectAtIndex:i]];
        }
    }
  
    if (bReloadData == YES) {
        memset(m_pSelectedStatus, 0, sizeof(m_pSelectedStatus));
        
        [self reloadPathArray];
        [RecReloadDelegate NotifyReloadData];
    }
    
    
}
-(void)refreshCellForIndexPath:(NSDictionary *)dic{
   NSIndexPath *indexpath=[dic objectForKey:@"indexpath"];
    NSString *strPath=[dic objectForKey:@"path"];
    SearchListCell *cell =  (SearchListCell*)[self.m_tableView cellForRowAtIndexPath:indexpath];
    cell.didLabel.text=[NSString stringWithFormat:@"%@%@",NSLocalizedStringFromTable(@"filesize", @STR_LOCALIZED_FILE_NAME, nil),[m_myImgDic objectForKey:strPath]];
}

-(NSString *) getFileMemory:(NSString *) strPath {
    if (strPath==nil||[strPath length]==0) {
        return @"0";
    }
   // NSLog(@"strPath=%@",strPath);
    // NSString *strPath=[dic objectForKey:@"path"];
     
    [m_Lock lock];
    
        FILE *m_pfile=fopen([strPath UTF8String], "rb");
        fseek(m_pfile,0,SEEK_END);
        int   fileLenK = ftell(m_pfile)/1024;
        NSLog(@"fileLenK=%d",fileLenK);
        NSString *result=nil;
        if (fileLenK>1024) {
            NSString *k=[NSString stringWithFormat:@"%d",fileLenK];
            NSDecimalNumber *dec1=[NSDecimalNumber decimalNumberWithString:k];
            NSDecimalNumber *dec2=[NSDecimalNumber decimalNumberWithString:@"1024"];
            NSDecimalNumber *dec3=[dec1 decimalNumberByDividingBy:dec2];
            result=[dec3 stringValue];
            NSLog(@"result=%@",result);
            if (result.length>3) {
                result=[result substringToIndex:3];
            }
            result=[NSString stringWithFormat:@"%@M",result];
            
        }
        
        else {
            result=[NSString stringWithFormat:@"%dKB",fileLenK];    
        }
        fclose(m_pfile);
//        [m_myImgDic setObject:result forKey:strPath];
//        [self performSelectorOnMainThread:@selector(refreshCellForIndexPath:) withObject:dic waitUntilDone:NO];
        [m_Lock unlock];
    return result;
}


- (NSString*) GetRecordPath: (NSString*)strFileName
{
    [m_Lock lock];
    //获取路径
    //参数NSDocumentDirectory要获取那种路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];//去处需要的路径
    
    NSString *strPath = [documentsDirectory stringByAppendingPathComponent:strDID];
    //NSLog(@"strPath: %@", strPath);
    
    
    strPath = [strPath stringByAppendingPathComponent:strFileName];
    //NSLog(@"strPath: %@", strPath);
    [m_Lock unlock];
    return strPath;
    
    
}
- (void) ShowEditButton
{
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    
    if (m_bEditMode) {
        int toolBarX = 0;
        int toolBarY = screenFrame.size.height - 44 + 20;
        int toolBarWidth = screenFrame.size.width ;
        int toolBarHeight = 44 ;
        m_toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(toolBarX, toolBarY, toolBarWidth, toolBarHeight)];
        m_toolBar.barStyle = UIBarStyleBlackOpaque ;
        
        UIBarButtonItem *btnSelectAll = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"selectAll",  @STR_LOCALIZED_FILE_NAME, nil) style:UIBarButtonItemStyleBordered target:self action:@selector(btnSelectAll:)];
        UIBarButtonItem *btnSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *btnSelectReverse = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"reserveSelect",  @STR_LOCALIZED_FILE_NAME, nil) style:UIBarButtonItemStyleBordered target:self action:@selector(btnSelectReverse:)];
        UIBarButtonItem *btnSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *btnDelete = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Delete",  @STR_LOCALIZED_FILE_NAME, nil) style:UIBarButtonItemStyleBordered target:self action:@selector(btnDelete:)];
        NSArray *itemArray = [NSArray arrayWithObjects:btnSpace1 ,btnSelectAll, btnSelectReverse, btnDelete, btnSpace2, nil];
        [m_toolBar setItems:itemArray];
        [btnSelectAll release];
        [btnSelectReverse release];
        [btnDelete release];
        [btnSpace1 release];
        [btnSpace2 release];
        [self.view addSubview:m_toolBar];

        CGRect rectTableView = self.m_tableView.frame;
        rectTableView.size.height -= 44 ;
        self.m_tableView.frame = rectTableView ;
            
    }else {
        CGRect rectTableView = self.m_tableView.frame;
        rectTableView.size.height += 44 ;
        self.m_tableView.frame = rectTableView ;
        [m_toolBar removeFromSuperview];
        [m_toolBar release];
        m_toolBar = nil;
        
        int i;
        BOOL bReloadData = NO;
        for (i = 0; i < m_nTotalNum; i++) {
            if (m_pSelectedStatus[i] == 1) {
                bReloadData = YES;
            }
            m_pSelectedStatus[i] = 0;
        }
        if (bReloadData == YES) {
            [self.m_tableView reloadData];
        }
        
    }
}

- (void) initNavigationBar
{
    if (!m_bEditMode) {
        UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:strDate];
        UINavigationItem *back = [[UINavigationItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Back", @STR_LOCALIZED_FILE_NAME, nil)];
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Edit", @STR_LOCALIZED_FILE_NAME, nil) style:UIBarButtonItemStyleBordered target:self action:@selector(btnEdit:)];
        item.rightBarButtonItem = rightButton;
        [rightButton release];
        
        NSArray *array = [NSArray arrayWithObjects:back, item, nil];
        [self.navigationBar setItems:array];
        [item release];
        [back release];
        
    }else {
        UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:strDate];
        UINavigationItem *back = [[UINavigationItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Back", @STR_LOCALIZED_FILE_NAME, nil)];
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Done", @STR_LOCALIZED_FILE_NAME, nil) style:UIBarButtonItemStyleDone target:self action:@selector(btnEdit:)];
        item.rightBarButtonItem = rightButton;
        [rightButton release];
        
        NSArray *array = [NSArray arrayWithObjects:back, item, nil];
        [self.navigationBar setItems:array];
        [item release];
        [back release];
    }
    
}
- (void) reloadPathArray
{
    [picPathArray removeAllObjects];
    NSMutableArray *tempArray = [m_pRecPathMgt GetTotalPathArray:strDID date:strDate];
    for (NSString *strPath in tempArray) {
        [picPathArray addObject:strPath];
    }
    [self reloadTableViewData];
  
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    mainScreen=[[UIScreen mainScreen]bounds];
    m_Lock=[[NSCondition alloc]init];
    // Do any additional setup after loading the view from its nib.
    m_myImgDic=[[NSMutableDictionary alloc]init];
    m_bEditMode = NO;
    //m_pSelectedStatus = NULL;
    memset(m_pSelectedStatus, 0, sizeof(m_pSelectedStatus));
    m_nTotalNum = 0;
    m_toolBar = nil;
    
    picPathArray = nil;
    picPathArray = [[NSMutableArray alloc] init];
       
    
   
    navigationBar.delegate = self;
    navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    [self initNavigationBar];
    
    self.wantsFullScreenLayout = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    self.navigationBar.translucent = YES;
    
    CGRect navigationBarFrame = self.navigationBar.frame;
    navigationBarFrame.origin.y += 20;
    self.navigationBar.frame = navigationBarFrame;
    //self.navigationBar.alpha = 0.5f;
    
    CGRect tableViewFrame ;
    if ([AppDelegate isIOS7Version]) {
         tableViewFrame.size.height = 480 ;
    }else{
     tableViewFrame.size.height = 480-20 ;
    }
   
    tableViewFrame.size.width = 320;
    tableViewFrame.origin.x = 0;
    tableViewFrame.origin.y = 0;
    
    m_tableView.frame = tableViewFrame;
    //m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 44 + 20 + 5)];
    m_tableView.tableHeaderView = headerView;
    [headerView release];
    
    self.imageDefault = [UIImage imageNamed:@"videodefault.png"];
    self.imagePlay = [UIImage imageNamed:@"play_video.png"];
    self.imageTag = [UIImage imageNamed:@"del_hook.png"];
    
    [self reloadPathArray];
    
    
    if ([AppDelegate isIOS7Version]) {
        NSLog(@"is ios7");
        
        
        CGRect tableFrm=m_tableView.frame;
        tableFrm.origin.y+=20;
        m_tableView.frame=tableFrm;
        self.view.backgroundColor=[UIColor blackColor];
    }else{
        NSLog(@"less ios7");
        
    }
    
//    UIImageView *imgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background.png"]];
//    imgView.frame=m_tableView.frame;
//    imgView.center=m_tableView.center;
//    m_tableView.backgroundView=imgView;
//    [imgView release];
}
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning");
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) dealloc
{
    NSLog(@"RecordListViewController dealloc");
    self.navigationBar = nil;
    self.m_pRecPathMgt = nil;
    self.strDID = nil;
    self.strDate = nil;
    self.m_tableView = nil;
    self.imageDefault = nil;
    self.imagePlay = nil;
    self.imageTag = nil;
    self.progressView=nil;
   
    if (picPathArray != nil) {
        [picPathArray removeAllObjects];
        [picPathArray release];
        picPathArray = nil;
    }
    if (m_myImgDic!=nil) {
        [m_myImgDic removeAllObjects];
        [m_myImgDic release];
        m_myImgDic=nil;
    }
    if (m_Lock!=nil) {
        [m_Lock release];
        m_Lock=nil;
    }
    [super dealloc];
}

- (void) singleTapHandle: (UITapGestureRecognizer*)sender
{
    UIImageView *imageView = (UIImageView*)[sender view];
    int tag = imageView.tag;
    
    //NSLog(@"singleTapHandle tag:%d", tag);
    
    if (!m_bEditMode) {
        PlaybackViewController *playbackViewController = [[PlaybackViewController alloc] init];
        playbackViewController.m_nSelectIndex = tag;
        playbackViewController.m_pRecPathMgt = m_pRecPathMgt;
        playbackViewController.strDID = strDID;
        playbackViewController.strDate = strDate;
        AppDelegate *IPCamDelegate = [[UIApplication sharedApplication] delegate];
        [IPCamDelegate switchPlaybackView:playbackViewController];
        [playbackViewController release];
        return ;
    }
    
    if (tag >= m_nTotalNum) {
        return;
    }
    
    if (m_pSelectedStatus[tag] == 1) {
        NSArray *viewArray = [imageView subviews];
        if ([viewArray count] < 1) {
            m_pSelectedStatus[tag] = 0;
            return ;
        }
        
        UIView *viewTag = [viewArray objectAtIndex:0];
        [viewTag removeFromSuperview];
        
        m_pSelectedStatus[tag] = 0;
    }else {
        [self AddTag:imageView];
        
        m_pSelectedStatus[tag] = 1;
    }
    
    
}

- (void) AddTag: (UIView*) view
{
    int imageX = view.frame.size.width - 5 - 30;
    int imageY = 5;
    
    UIImageView *imageViewTag = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, imageY, 30, 30)];
    imageViewTag.image = self.imageTag;
    [view addSubview:imageViewTag];
    [imageViewTag release];
}

#pragma mark -
#pragma mark TableViewDelegate

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{

    int  count = [picPathArray count];
    
    NSLog(@"picPathArray.count=%d",count);
    
    m_nTotalNum = count;
    return count;
    if (count == 0) {
        return 0;
    }
    
    return (count % 3) > 0 ? (count / 3) + 1 : count / 3;
    
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)anIndexPath
{
    //NSLog(@"cellForRowAtIndexPath");  
    NSString *cellIdentifier = @"RecListCell";
    UITableViewCell *cell1=[aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell1==nil) {
//        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"SearchListCell" owner:self options:nil];
//        cell1=[nib objectAtIndex:0];
        
        UINib *nib=[UINib nibWithNibName:@"SearchListCell" bundle:nil];
        [aTableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
        cell1=[aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        
    }
    SearchListCell *cell2=(SearchListCell *)cell1;
    NSString *path=[picPathArray objectAtIndex:anIndexPath.row];
    NSString *fileSize=[m_myImgDic objectForKey:path];
    if (fileSize==nil) {
        
        fileSize=[self getFileMemory:[self GetRecordPath:path]];
        
//         NSString *p=[self GetRecordPath:path];
//         NSDictionary *mdic=[NSDictionary dictionaryWithObjectsAndKeys:[self GetRecordPath:path],@"path",anIndexPath,@"indexpath",nil];
//        
//        [NSThread detachNewThreadSelector:@selector(getFileMemory:) toTarget:self withObject:mdic];
//        fileSize=@"Loading...";
        
        [m_myImgDic setObject:fileSize forKey:path];
    }
   

    NSRange r= [path rangeOfString:@"_"];
    path=[path substringFromIndex:r.location+1];
    
    NSString *strName=[NSString stringWithFormat:@"Local_%@",[[path stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@":" withString:@""]];
    
   // NSString *strName=[NSString stringWithFormat:@"Local_%@",[path stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    
    NSString *strTime=[[path stringByReplacingOccurrencesOfString:@"_" withString:@" "] stringByReplacingOccurrencesOfString:@".rec" withString:@""];
    
    cell2.nameLabel.text=[NSString stringWithFormat:@"%@%@",NSLocalizedStringFromTable(@"record_filename", @STR_LOCALIZED_FILE_NAME, nil),strName];
    cell2.addrLabel.text=[NSString stringWithFormat:@"%@%@",NSLocalizedStringFromTable(@"record_filetime", @STR_LOCALIZED_FILE_NAME, nil),strTime];
    cell2.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell2.didLabel.text=[NSString stringWithFormat:@"%@%@",NSLocalizedStringFromTable(@"filesize", @STR_LOCALIZED_FILE_NAME, nil),fileSize];
    //cell2.didLabel.hidden=YES;
    if (m_pSelectedStatus[anIndexPath.row] == 1) {
        UIImageView *imgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"del_hook"]];
        cell1.accessoryView=imgView;
        [imgView release];
    }else{
        cell1.accessoryView=nil;
    }
    
//    float cellHeight = cell1.frame.size.height;
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(cell1.frame.origin.x, cellHeight - 1, mainScreen.size.width, 1)];
//    label.backgroundColor = [UIColor colorWithRed:0 green:60/255.0f blue:0 alpha:1.0];
//    
//    UIView *cellBgView = [[UIView alloc] initWithFrame:cell1.frame];
//    [cellBgView addSubview:label];
//    [label release];
//    cell1.backgroundView = cellBgView;
//    [cellBgView release];
    
    return cell1;

}
- (CGFloat)tableView:(UITableView*)tableview heightForRowAtIndexPath:(NSIndexPath*)indexpath
{
    return 70;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)anIndexPath
{    
    
    if (m_bEditMode) {
        
        SearchListCell *cell=(SearchListCell *)[aTableView cellForRowAtIndexPath:anIndexPath];
        if (m_pSelectedStatus[anIndexPath.row] == 1) {
            m_pSelectedStatus[anIndexPath.row] =0;
            cell.accessoryView=nil;
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        }else{
           m_pSelectedStatus[anIndexPath.row] =1;
            UIImageView *imgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"del_hook"]];
            cell.accessoryView=imgView;
            [imgView release];
        }
        [aTableView deselectRowAtIndexPath:anIndexPath animated:YES];
        return;
    }
    NSString *path=[picPathArray objectAtIndex:anIndexPath.row];
    NSString *fileSize=[m_myImgDic objectForKey:path];
    float  size=[fileSize floatValue];
    [aTableView deselectRowAtIndexPath:anIndexPath animated:YES];
    if (size<=0) {
        return;
    }
    PlaybackViewController *playbackViewController = [[PlaybackViewController alloc] init];
    playbackViewController.m_nSelectIndex = anIndexPath.row;
    playbackViewController.m_pRecPathMgt = m_pRecPathMgt;
    playbackViewController.strDID = strDID;
    playbackViewController.strDate = strDate;
    AppDelegate *IPCamDelegate = [[UIApplication sharedApplication] delegate];
    [IPCamDelegate switchPlaybackView:playbackViewController];
    [playbackViewController release];
}

-(int)getTotalTime:(NSString *)strPath{
    //read the total time
    int m_nTotalTime;
    int m_nTotalKeyFrame;
    FILE *m_pfile=fopen([strPath UTF8String], "rb");
    fseek(m_pfile, 0, SEEK_END);
    long fileLen = ftell(m_pfile);
    NSLog(@"fileLen: %ld", fileLen);
    int nEndIndexLen = strlen("ENDINDEX");
    fseek(m_pfile, fileLen - nEndIndexLen, 0);
    //NSLog(@"aaaa: %ld", ftell(m_pfile));
    char tempBuf[1024];
    memset(tempBuf, 0, sizeof(tempBuf));
    if(nEndIndexLen != fread(tempBuf, 1, nEndIndexLen, m_pfile))
    {
       
        m_nTotalTime= 0;
        return m_nTotalTime;
    }
    
    //NSLog(@"tempBuf: %s", tempBuf);
    if (strcmp("ENDINDEX", tempBuf) != 0) {
       
        m_nTotalTime= 0;
        return m_nTotalTime;
    }
    
    fseek(m_pfile, fileLen - nEndIndexLen - 8, 0);
    
    if(4 != fread((char*)&m_nTotalKeyFrame, 1, 4, m_pfile))
    {
        m_nTotalKeyFrame = 0;
        m_nTotalTime= 0;
        return m_nTotalTime;
    }
    if (4 != fread((char*)&m_nTotalTime, 1, 4, m_pfile))
    {
        m_nTotalKeyFrame = 0;
        m_nTotalTime= 0;
        return m_nTotalTime;
    }
    
    return m_nTotalTime;
}


#pragma mark -
#pragma mark performInMainThread

- (void)reloadTableViewData
{
    [m_tableView reloadData];
}

#pragma mark -
#pragma mark NotifyReloadData

- (void) NotifyReloadData
{
    [self performSelectorOnMainThread:@selector(reloadTableViewData) withObject:nil waitUntilDone:NO];
}

#pragma mark -
#pragma mark navigationBardelegate

- (BOOL) navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    int  count = [picPathArray count];
    if (count<=0) {
        [self.navigationController popViewControllerAnimated:YES];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
        
        return NO;
    }
    [self.navigationController popViewControllerAnimated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    return NO;
}


@end
