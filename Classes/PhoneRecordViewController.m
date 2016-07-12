//
//  PhoneRecordViewController.m
//  P2PCamera
//
//  Created by Tsang on 13-1-26.
//
//
#define STR_RECORD_FILE_NAME "STR_RECORD_FILE_NAME"
#define STR_RECORD_FILE_SIZE "STR_RECORD_FILE_SIZE"
#define kHeaderViewTag 100
#import "PhoneRecordViewController.h"
#import "AppDelegate.h"
#import "MyHeaderView.h"
#import "SearchFileViewController.h"
#import "obj_common.h"
#import <MediaPlayer/MediaPlayer.h>
@interface PhoneRecordViewController ()

@end

@implementation PhoneRecordViewController
@synthesize alertView;
@synthesize tableView;
@synthesize navigationBar;
@synthesize dateArray;
@synthesize arrDic;
@synthesize did;
@synthesize m_CurAllDic;
@synthesize m_CurArray;
@synthesize statusDic;

@synthesize isEdit;
-(NSString *)getFilePath:(NSString *)fileName{
    //NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];
    NSString *strPath=[documentsDirectory stringByAppendingPathComponent:did];
    NSString *downPath=[strPath stringByAppendingPathComponent:@"LocalRecord"];
    NSString *filePath=[downPath stringByAppendingPathComponent:fileName];
    NSLog(@"filePath=%@",filePath);
    
    //[self playView:filePath];
    return filePath;
}

-(void)playView:(NSString *)filePath{
    NSURL *moUrl=[NSURL fileURLWithPath:filePath];
    MPMoviePlayerViewController *player=[[MPMoviePlayerViewController alloc]initWithContentURL:moUrl];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playVideoFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:[player moviePlayer]];
    player.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
    [player setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentViewController:player animated:YES completion:nil];
    MPMoviePlayerController *p=[player moviePlayer];
    [p play];
    
}
-(void)playVideoFinish:(NSNotification *)theNotification{
    MPMoviePlayerController *player=[theNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [player stop];
    [self dismissMoviePlayerViewControllerAnimated];
    
}

-(BOOL)shouldAutorotate{
    return NO;
}
-(NSUInteger)supportedInterfaceOrientations{
    return  UIInterfaceOrientationMaskPortrait;
}
-(void)dealloc{
    [tableView release];
    tableView=nil;
    [navigationBar release];
    navigationBar=nil;
    [dateArray release];
    dateArray=nil;
    [arrDic release];
    arrDic=nil;
    [statusDic release];
    statusDic=nil;
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        dateArray=[[NSMutableArray alloc]init];
        arrDic=[[NSMutableDictionary alloc]init];
        m_CurArray=[[NSMutableArray alloc]init];
        m_CurAllDic=[[NSMutableDictionary alloc]init];
        statusDic=[[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isEdit=NO;
    [dateArray removeAllObjects];
    [arrDic removeAllObjects];
    [m_CurArray removeAllObjects];
    [m_CurAllDic removeAllObjects];
    [statusDic removeAllObjects];
    UIImage *image=[UIImage imageNamed:@"top_bg_blue.png"];
    if (![AppDelegate is43Version]) {
        [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        
    }
    tableView.delegate=self;
    tableView.dataSource=self;
    self.navigationBar.delegate=self;
    self.navigationBar.tintColor=[UIColor colorWithRed:BTN_NORMAL_RED/255.0f green:BTN_NORMAL_GREEN/255.0f blue:BTN_NORMAL_BLUE/255.0f alpha:1];
    UINavigationItem *back=[[UINavigationItem alloc]initWithTitle:NSLocalizedStringFromTable(@"runcar_mode_uplate", @STR_LOCALIZED_FILE_NAME, nil)];
    UINavigationItem *item=[[UINavigationItem alloc]initWithTitle:NSLocalizedStringFromTable(@"runcar_phonerecord", @STR_LOCALIZED_FILE_NAME, nil)];
    UIBarButtonItem *refreshButton =
    [[UIBarButtonItem alloc]
     initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
     target:self
     action:@selector(refresh)];
    
    item.rightBarButtonItem = refreshButton;
    
    [self.navigationBar setItems:[NSArray arrayWithObjects:back,item, nil]];
    [back release];
    [item release];
    
    [self ShowEditButton];
    
    [self InitCameraProcess:NSLocalizedStringFromTable(@"runcar_loadingfile", @STR_LOCALIZED_FILE_NAME, nil)];
    [NSThread detachNewThreadSelector:@selector(getFiles) toTarget:self withObject:nil];
    
}
-(void)InitCameraProcess:(NSString *)title{
    alertView=[[UIAlertView alloc]initWithTitle:title message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [alertView show];
    //alertView.frame=CGRectMake(10.0f, 100.0f, 240.0f, 200.0f);
    
    UIActivityIndicatorView *activeView=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activeView.center=CGPointMake(alertView.bounds.size.width/2, alertView.bounds.size.height-40);
    [activeView startAnimating];
    [alertView addSubview:activeView];
    [activeView release];
    //    timer=[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(AlertDismiss) userInfo:nil repeats:NO];
    //    timer=nil;
}

-(void)refresh{
    SearchFileViewController *controller=[[SearchFileViewController alloc]init];
    controller.remoteProtocol=self;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
    return;
    
}

-(void)getFiles{
    NSLog(@"getFiles....999");
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];
    NSString *strPath=[documentsDirectory stringByAppendingPathComponent:did];
    NSArray *fileList=[[NSArray alloc]init];
    NSError *error=nil;
    NSString *downPath=[strPath stringByAppendingPathComponent:@"LocalRecord"];
    fileList=[fileManager contentsOfDirectoryAtPath:downPath error:&error];
    NSLog(@"fileList.count=%d",fileList.count);
    [dateArray removeAllObjects];
    [arrDic removeAllObjects];
    [m_CurArray removeAllObjects];
    [m_CurAllDic removeAllObjects];
    [statusDic removeAllObjects];
    for(int i=0;i<fileList.count;i++){
        NSString *f=[fileList objectAtIndex:i];
        NSLog(@"f=%@",f);
        NSString *dkey=[f substringWithRange:NSMakeRange(2, 8)];
        [statusDic setObject:@"0" forKey:f];
        // NSString *tKey=[f substringFromIndex:11];
        //NSString *str=[tKey stringByReplacingOccurrencesOfString:@"_" withString:@":"];
        
        if (![dateArray containsObject:dkey]) {//没有该日期
            [dateArray addObject:dkey];
            NSMutableArray   *arr=[[NSMutableArray alloc]init];
            [arr addObject:f];
            [arrDic setObject:arr forKey:dkey];
            [arr release];
        }else{
            NSMutableArray *arr=(NSMutableArray *)[arrDic objectForKey:dkey];
            [arr addObject:f];
        }
        
        if (![m_CurArray containsObject:dkey]) {
            [m_CurArray addObject:dkey];
            NSMutableArray   *arr=[[NSMutableArray alloc]init];
            [arr addObject:f];
            [m_CurAllDic setObject:arr forKey:dkey];
            [arr release];
        }else{
            NSMutableArray *arr=(NSMutableArray *)[m_CurAllDic objectForKey:dkey];
            [arr addObject:f];
        }
        //  NSLog(@"dateArray.count=%d",dateArray.count);
        
    }
    int count=m_CurArray.count;
    for (int i=0; i<count; i++) {
        NSString *dkey=[m_CurArray objectAtIndex:i];
        NSMutableArray *arr=(NSMutableArray *)[m_CurAllDic objectForKey:dkey];
        [arr sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *str1=obj1;
            NSString *str2=obj2;
            return [str2 compare:str1];
        }];
    }
    count=dateArray.count;
    for (int i=0; i<count; i++) {
        NSString *dkey=[dateArray objectAtIndex:i];
        NSMutableArray *arr=(NSMutableArray *)[arrDic objectForKey:dkey];
        [arr sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *str1=obj1;
            NSString *str2=obj2;
            return [str2 compare:str1];
        }];
    }
    [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
    [self performSelectorOnMainThread:@selector(ReloadTableView) withObject:nil waitUntilDone:NO];
}
- (void) ShowEditButton
{
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    BOOL m_bEditMode=YES;
    if (m_bEditMode) {
        int toolBarX = 0;
        int toolBarY = screenFrame.size.height - 44 ;
        int toolBarWidth = screenFrame.size.width ;
        int toolBarHeight = 44 ;
        m_toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(toolBarX, toolBarY, toolBarWidth, toolBarHeight)];
        m_toolBar.barStyle = UIBarStyleBlackOpaque ;
        btnEdit = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Edit", @STR_LOCALIZED_FILE_NAME, nil) style:UIBarButtonItemStyleBordered target:self action:@selector(btnEdit)];
        btnSelectAll = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"runcar_selectall", @STR_LOCALIZED_FILE_NAME, nil) style:UIBarButtonItemStyleBordered target:self action:@selector(btnSelectAll)];
        UIBarButtonItem *btnSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        btnSelectReverse = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"runcar_selectreverse", @STR_LOCALIZED_FILE_NAME, nil) style:UIBarButtonItemStyleBordered target:self action:@selector(btnSelectReverse)];
        
        UIBarButtonItem *btnSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        btnDelete = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Delete", @STR_LOCALIZED_FILE_NAME, nil) style:UIBarButtonItemStyleBordered target:self action:@selector(btnDelete)];
        NSArray *itemArray = [NSArray arrayWithObjects:btnSpace1 ,btnEdit,btnSelectAll, btnSelectReverse, btnDelete, btnSpace2, nil];
        [m_toolBar setItems:itemArray];
        btnSelectReverse.enabled=NO;
        btnSelectAll.enabled=NO;
        btnDelete.enabled=NO;
        //        [btnSelectAll release];
        //        [btnSelectReverse release];
        //        [btnDelete release];
        [btnSpace1 release];
        [btnSpace2 release];
        [self.view addSubview:m_toolBar];
        
        CGRect rectTableView = self.tableView.frame;
        rectTableView.size.height -= 44 ;
        self.tableView.frame = rectTableView ;
        
    }
    //    else {
    //        CGRect rectTableView = self.tableView.frame;
    //        rectTableView.size.height += 44 ;
    //        self.tableView.frame = rectTableView ;
    //        [m_toolBar removeFromSuperview];
    //        [m_toolBar release];
    //        m_toolBar = nil;
    //
    //        int i;
    //        BOOL bReloadData = NO;
    //        for (i = 0; i < m_nTotalNum; i++) {
    //            if (m_pSelectedStatus[i] == 1) {
    //                bReloadData = YES;
    //            }
    //            m_pSelectedStatus[i] = 0;
    //        }
    //        if (bReloadData == YES) {
    //            [self.m_tableView reloadData];
    //        }
    //
    //    }
}
-(void)btnEdit{
    if (isEdit) {
        btnSelectReverse.enabled=NO;
        btnSelectAll.enabled=NO;
        btnDelete.enabled=NO;
        int dateCount=m_CurArray.count;
        
        for (int i=0; i<dateCount; i++) {
            NSString *dkey=[m_CurArray objectAtIndex:i];
            NSMutableArray *arr=(NSMutableArray *)[m_CurAllDic objectForKey:dkey];
            int count=arr.count;
            for (int j=0; j<count; j++) {
                NSString *key=[arr objectAtIndex:j];
                NSString *status=[statusDic objectForKey:key];
                if ([@"1" isEqualToString:status]) {
                    [statusDic removeObjectForKey:key];
                    [statusDic setObject:@"0" forKey:key];
                    
                }
            }
        }
        [self ReloadTableView];
        
        
    }else{
        
        btnSelectReverse.enabled=YES;
        btnSelectAll.enabled=YES;
        btnDelete.enabled=YES;
    }
    isEdit=!isEdit;
}
-(void)btnSelectAll{
    int dateCount=m_CurArray.count;
    for (int i=0; i<dateCount; i++) {
        NSString *dkey=[m_CurArray objectAtIndex:i];
        NSMutableArray *arr=(NSMutableArray *)[m_CurAllDic objectForKey:dkey];
        int count=arr.count;
        for (int j=0; j<count; j++) {
            NSString *key=[arr objectAtIndex:j];
            NSString *status=[statusDic objectForKey:key];
            if ([@"0" isEqualToString:status]) {
                [statusDic removeObjectForKey:key];
                [statusDic setObject:@"1" forKey:key];
            }
        }
    }
    [self ReloadTableView];
}
-(void)btnSelectReverse{
    int dateCount=m_CurArray.count;
    
    for (int i=0; i<dateCount; i++) {
        NSString *dkey=[m_CurArray objectAtIndex:i];
        NSMutableArray *arr=(NSMutableArray *)[m_CurAllDic objectForKey:dkey];
        int count=arr.count;
        for (int j=0; j<count; j++) {
            NSString *key=[arr objectAtIndex:j];
            NSString *status=[statusDic objectForKey:key];
            if ([@"0" isEqualToString:status]) {
                [statusDic removeObjectForKey:key];
                [statusDic setObject:@"1" forKey:key];
                
            }else{
                [statusDic removeObjectForKey:key];
                [statusDic setObject:@"0" forKey:key];
                
            }
        }
    }
    [self ReloadTableView];
}
-(void)btnDelete{
    [self InitCameraProcess:NSLocalizedStringFromTable(@"runcar_loadingfile", @STR_LOCALIZED_FILE_NAME, nil)];
    int dateCount=m_CurArray.count;
    BOOL isDeleted=NO;
    for (int i=0; i<dateCount; i++) {
        NSString *dkey=[m_CurArray objectAtIndex:i];
        NSMutableArray *arr=(NSMutableArray *)[m_CurAllDic objectForKey:dkey];
        int count=arr.count;
        NSLog(@"count=%d",count);
        
        for (int j=0; j<count; j++) {
            NSString *key=[arr objectAtIndex:j];
            NSString *status=[statusDic objectForKey:key];
            if ([@"1" isEqualToString:status]) {
                [self deleteLocalFile:key];
                isDeleted=YES;
            }
        }
    }
    if (isDeleted) {
        [NSThread detachNewThreadSelector:@selector(getFiles) toTarget:self withObject:nil];
    }else{
        [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
    }
    
    
}
#pragma mark- TableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return  40;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *dkey=[m_CurArray objectAtIndex:indexPath.section];
    NSMutableArray *arr=(NSMutableArray *)[m_CurAllDic objectForKey:dkey];
    NSString *fileName=[arr objectAtIndex:indexPath.row];
    
    [self deleteLocalFile:fileName];
    [arr removeObjectAtIndex:indexPath.row];
    if (arr.count<=0) {
        [m_CurArray removeObjectAtIndex:indexPath.section];
    }
    [self reloadTableView];
}
-(void)reloadTableView{
    [tableView reloadData];
}
-(void)deleteLocalFile:(NSString *)fileName{
    @try {
        //创建文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];//去处需要的路径
        
        NSString *strPath=[documentsDirectory stringByAppendingPathComponent:did];
        NSString *downPath=[strPath stringByAppendingPathComponent:@"LocalRecord"];
        //更改到待操作的目录下
        [fileManager changeCurrentDirectoryPath: downPath];
        
        //删除
        [fileManager removeItemAtPath:fileName error:nil];
        NSLog(@"删除文件成功");
    }
    @catch (NSException *exception) {
        NSLog(@"删除文件失败");
    }
    @finally {
        
    }
    
}

-(UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section{
    MyHeaderView *headerView=(MyHeaderView *)[aTableView viewWithTag:kHeaderViewTag +section];
    if (headerView==nil) {
        headerView=[[MyHeaderView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
        headerView.tag=kHeaderViewTag+section;
        //响应点击事件
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headerTap:)];
        [headerView addGestureRecognizer:tapGesture];
        [tapGesture release];
    }
    NSString *name=[m_CurArray objectAtIndex:section];
    NSMutableArray *arr=(NSMutableArray *)[m_CurAllDic objectForKey:name];
    NSLog(@"viewForHeader  arr.count=%d",arr.count);
    NSString *title=[NSString stringWithFormat:@"%@(%d)",name,[arr count]];
    [headerView setStrName:title];
    [headerView setOpen:isOpen];
    return headerView;
    
}

-(void)headerTap:(UITapGestureRecognizer *)theTap{
    MyHeaderView *headerView=(MyHeaderView *)theTap.view;
    headerView.open=!headerView.open;
    isOpen=headerView.open;
    [headerView setOpen:headerView.open];
    NSInteger section=headerView.tag-kHeaderViewTag;
    NSString *key=[m_CurArray objectAtIndex:section];
    [m_CurAllDic setObject:[NSNumber numberWithBool:headerView.open] forKey:[NSString stringWithFormat:@"%@open",key]];
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSLog(@"m_CurArray.count=%d",m_CurArray.count);
    return m_CurArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString *dKey=[m_CurArray objectAtIndex:section];
    NSInteger numberOfRows=0;
    BOOL open=[[m_CurAllDic objectForKey:[NSString stringWithFormat:@"%@open",dKey]]boolValue];
    if (open) {
        NSMutableArray *arr=(NSMutableArray *)[m_CurAllDic objectForKey:dKey];
        numberOfRows=arr.count;
    }
    
    
    return numberOfRows;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [m_CurArray objectAtIndex:section];
}
-(UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[atableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    NSString *dkey=[m_CurArray objectAtIndex:indexPath.section];
    NSMutableArray *arr=(NSMutableArray *)[m_CurAllDic objectForKey:dkey];
    cell.textLabel.text=[arr objectAtIndex:indexPath.row];
    NSString *status=[statusDic objectForKey:[arr objectAtIndex:indexPath.row]];
    if ([status isEqualToString:@"1"]) {
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType=nil;
    }
    return cell;
}
-(void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [atableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell=[atableView cellForRowAtIndexPath:indexPath];
    
    if (isEdit) {
        NSString *dkey=[m_CurArray objectAtIndex:indexPath.section];
        NSMutableArray *arr=(NSMutableArray *)[m_CurAllDic objectForKey:dkey];
        cell.textLabel.text=[arr objectAtIndex:indexPath.row];
        NSString *key=[arr objectAtIndex:indexPath.row];
        NSString *status=[statusDic objectForKey:key];
        
        if ([status isEqualToString:@"1"]) {
            cell.accessoryType=nil;
            [statusDic removeObjectForKey:key];
            [statusDic setObject:@"0" forKey:key];
        }else{
            [statusDic removeObjectForKey:key];
            [statusDic setObject:@"1" forKey:key];
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
        }
    }else{
        NSString *dkey=[dateArray objectAtIndex:indexPath.section];
        NSMutableArray *arr=(NSMutableArray *)[arrDic objectForKey:dkey];
        NSLog(@"fileName=%@",[arr objectAtIndex:indexPath.row]);
        NSString *localfilePath=[self getFilePath:[arr objectAtIndex:indexPath.row]];
        
        
        PlaybackViewController *playbackViewController = [[PlaybackViewController alloc] init];
        
        playbackViewController.strDID = did;
        //playbackViewController.localfilePath=localfilePath;
        //[self.navigationController pushViewController:playbackViewController animated:YES];
        
        AppDelegate *IPCamDelegate = [[UIApplication sharedApplication] delegate];
        [IPCamDelegate switchPlaybackView:playbackViewController];
        
        [playbackViewController release];
    }
    
    
}
-(void)ReloadTableView{
    NSLog(@"reloadTableView....88888");
    [tableView reloadData];
}
#pragma mark -
#pragma mark navigationBardelegate
-(BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item{
    [self.navigationController popViewControllerAnimated:YES];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}
#pragma mark- SearchResult
-(void)searchResult:(BOOL)isAll StartTime:(NSString *)startTime EndTime:(NSString *)endTime{
    NSLog(@"startTime=%@  endTime=%@  isAll=%d",startTime,endTime,isAll);
    
    [self searchFile:isAll StartTime:startTime EndTime:endTime];
}
-(void)searchFile:(BOOL)isAll  StartTime:(NSString *)startTime EndTime:(NSString *)endTime{
    [m_CurArray removeAllObjects];
    [m_CurAllDic removeAllObjects];
    
    
    if (isAll) {
        for (int i=0; i<dateArray.count; i++) {
            NSString *strDate=[dateArray objectAtIndex:i];
            [m_CurArray addObject:strDate];
            NSMutableArray *arr=(NSMutableArray *)[arrDic objectForKey:strDate];
            NSLog(@"arr.count=%d",arr.count);
            NSMutableArray *arr2=[[NSMutableArray alloc]init];
            [arr2 addObjectsFromArray:arr];
            [m_CurAllDic setObject:arr2 forKey:strDate];
            [arr2 release];
        }
    }else{
        NSString *sDate=[startTime substringWithRange:NSMakeRange(0, 8)];
        NSString *eDate=[endTime substringWithRange:NSMakeRange(0, 8)];
        NSLog(@"sDate=%@  eDate=%@",sDate,eDate);
        for (int i=0; i<dateArray.count; i++) {
            NSString *strDate=[dateArray objectAtIndex:i] ;
            NSLog(@"strDate=%@",strDate);
            if (([strDate compare:sDate]==NSOrderedSame)||(([strDate compare:sDate]==NSOrderedDescending)&&([strDate compare:eDate]==NSOrderedAscending))||([strDate compare:eDate]==NSOrderedSame)) {
                NSLog(@"在搜索的日期范围内 ");
                //strDate=[dateArray objectAtIndex:i];
                [m_CurArray addObject:strDate];
                NSMutableArray *arr=(NSMutableArray *)[arrDic objectForKey:strDate];
                NSMutableArray *curArr=[[NSMutableArray alloc]init];
                NSLog(@"arr.count=%d",arr.count);
                for (int j=0; j<arr.count; j++) {
                    NSString *strF=[arr objectAtIndex:j];
                    //                    NSString *strF=[fileDic objectForKey:@STR_RECORD_FILE_NAME];
                    NSLog(@"strF=%@",strF);
                    NSString *fileName=[strF substringWithRange:NSMakeRange(2, 14)];
                    NSLog(@"fileName=%@",fileName);
                    startTime=[startTime stringByReplacingOccurrencesOfString:@"_" withString:@""];
                    endTime=[endTime stringByReplacingOccurrencesOfString:@"_" withString:@""];
                    if (([fileName compare:startTime]==NSOrderedSame)||(([fileName compare:startTime]==NSOrderedDescending)&&([fileName compare:endTime]==NSOrderedAscending))||([fileName compare:endTime]==NSOrderedSame)) {
                        NSLog(@"strF满足搜索要求");
                        [curArr addObject:strF];
                    }
                }
                [m_CurAllDic setObject:curArr forKey:strDate];
                [curArr release];
            }
        }
        
    }
    
    [self ReloadTableView];
}
@end
