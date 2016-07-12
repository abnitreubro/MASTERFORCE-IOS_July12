//
//  RemoteRecordFileListViewController.m
//  P2PCamera
//
//  Created by Tsang on 12-12-14.
//
//
#import <QuartzCore/QuartzCore.h>
#import "RemoteRecordFileListViewController.h"
#import "obj_common.h"
#import "defineutility.h"
#import "RemotePlaybackViewController.h"
#import "AppDelegate.h"
#import "PhoneRecordViewController.h"
#import "SearchFileViewController.h"
#import "MyHeaderView.h"
#import "RemoteDownloadViewController.h"
#import "mytoast.h"
#import "PictrueDateViewController.h"

#define STR_RECORD_FILE_NAME "STR_RECORD_FILE_NAME"
#define STR_RECORD_FILE_SIZE "STR_RECORD_FILE_SIZE"
#define kHeaderViewTag 100
@interface RemoteRecordFileListViewController ()

@end

@implementation RemoteRecordFileListViewController
@synthesize navigationBar;
@synthesize mTableView;
@synthesize m_pPPPPChannelMgt;
@synthesize m_strDID;
@synthesize m_strName;
@synthesize indicatorView;
@synthesize mDownloadDic;
@synthesize label_progress;
@synthesize DownloadingFileName;
@synthesize m_pPicPathMgt;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) refresh:(id)param
{
    SearchFileViewController *controller=[[SearchFileViewController alloc]init];
    controller.remoteProtocol=self;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
    return;
    
    [m_RecordFileList removeAllObjects];
    [self showLoadingIndicator];
    m_timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:NO];
    [self ReloadTableView];
    m_pPPPPChannelMgt->PPPPGetSDCardRecordFileList((char*)[m_strDID UTF8String], 0, 0);
    
    m_bFinished = NO;
    
}
-(void)updateDatePicker:(id)sender{
    UIDatePicker *dPicker=(UIDatePicker *)sender;
    NSDateFormatter *formater=[[NSDateFormatter alloc]init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr=[formater stringFromDate:dPicker.date];
    NSLog(@"updateDatePicker()    dateStr=%@",dateStr);
    [formater release];
}
- (void)handleTimer:(id)param
{
    [self StopTimer];
    [self hideLoadingIndicator];
    m_bFinished = YES;
    //[self performSelectorOnMainThread:@selector(reloadTableView:) withObject:nil waitUntilDone:NO];
}

- (void) StopTimer
{
    //[m_timerLock lock];
    if (m_timer != nil) {
        [m_timer invalidate];
        m_timer = nil;
    }
    //[m_timerLock unlock];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    mTableView.dataSource=self;
    mTableView.delegate=self;
    isDownLoading=NO;
    selectRow=-1;
    selectSection=-1;
    mProgress=0;
    mDownloadDic=[[NSMutableDictionary alloc]init];
    [self getLocalDownloadFile];
    
    m_DateArray=[[NSMutableArray alloc]init];
    m_AllDic=[[NSMutableDictionary alloc]init];
    m_CurAllDic=[[NSMutableDictionary alloc]init];
    m_CurDateArray=[[NSMutableArray alloc]init];
    
    UIImage *image = [UIImage imageNamed:@"top_bg_blue.png"];
    
    if (![AppDelegate is43Version]) {
        [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    self.navigationBar.delegate = self;
    self.navigationBar.tintColor = [UIColor colorWithRed:BTN_NORMAL_RED/255.0f green:BTN_NORMAL_GREEN/255.0f blue:BTN_NORMAL_BLUE/255.0f alpha:1];
    
    //NSLog(@"WifiSettingViewController viewDidLoad");
    m_timerLock = [[NSCondition alloc] init];
    
    m_bFinished = NO;
    m_RecordFileList = [[NSMutableArray alloc] init];
    
    [self showLoadingIndicator];
    m_timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:NO];
    
    m_pPPPPChannelMgt->SetSDCardSearchDelegate((char*)[m_strDID UTF8String], self);
    m_pPPPPChannelMgt->PPPPGetSDCardRecordFileList((char*)[m_strDID UTF8String], 0, 0);

}
-(void)getLocalDownloadFile{
    NSLog(@"getLocalDownloadFile=====11111");
    [mDownloadDic removeAllObjects];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory=[paths objectAtIndex:0];
    NSString *strPath=[documentDirectory stringByAppendingPathComponent:m_strDID];
    NSString *downPath=[strPath stringByAppendingPathComponent:@"RemoteDownload"];
    NSArray *fileList=[[NSArray alloc]init];
    NSError *error=nil;
    fileList=[fileManager contentsOfDirectoryAtPath:downPath error:&error];
    NSLog(@"fileList.count=%d",fileList.count);
    for (NSString *f in fileList) {
         NSLog(@"fileName=%@",f);
        [mDownloadDic  setObject:f forKey:f];
    }
}
- (void) viewDidUnload
{
    
    [super viewDidUnload];
    
    if (m_RecordFileList != nil) {
        [m_RecordFileList release];
        m_RecordFileList = nil;
    }
    
    m_pPPPPChannelMgt->SetSDCardSearchDelegate((char*)[m_strDID UTF8String], nil);
}

- (void) viewWillDisappear:(BOOL)animated
{
   // [self StopTimer];
}

- (void)showLoadingIndicator
{
   // NSLog(@"strDID:%@",m_strDID);
    //NSString *strTitle = m_strName;
    UINavigationItem *back = [[UINavigationItem alloc] initWithTitle:NSLocalizedStringFromTable(@"runcar_mode_preview", @STR_LOCALIZED_FILE_NAME, nil)];
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:NSLocalizedStringFromTable(@"runcar_mode_uplate", @STR_LOCALIZED_FILE_NAME, nil)];
    
    //创建一个右边按钮
    UIActivityIndicatorView *indicator =
    [[[UIActivityIndicatorView alloc]
      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite]
     autorelease];
	indicator.frame = CGRectMake(0, 0, 24, 24);
	[indicator startAnimating];
	UIBarButtonItem *progress =
    [[[UIBarButtonItem alloc] initWithCustomView:indicator] autorelease];
    
    item.rightBarButtonItem = progress;
    
    NSArray *array = [NSArray arrayWithObjects:back, item, nil];
    [self.navigationBar setItems:array];
	
    [item release];
    [back release];
}

- (void)hideLoadingIndicator
{
    //NSString *strTitle = m_strName;
    UINavigationItem *back = [[UINavigationItem alloc] initWithTitle:NSLocalizedStringFromTable(@"runcar_mode_preview", @STR_LOCALIZED_FILE_NAME, nil)];
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:NSLocalizedStringFromTable(@"runcar_mode_uplate", @STR_LOCALIZED_FILE_NAME, nil)];
    
    //创建一个右边按钮
    
	UIBarButtonItem *refreshButton =
    [[UIBarButtonItem alloc]
     initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
     target:self
     action:@selector(refresh:)];
    
    item.rightBarButtonItem = refreshButton;
    
    NSArray *array = [NSArray arrayWithObjects:back, item, nil];
    [self.navigationBar setItems:array];
	
    [refreshButton release];
    [item release];
    [back release];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    m_pPPPPChannelMgt->SetSDCardSearchDelegate((char*)[m_strDID UTF8String], nil);
    self.navigationBar = nil;
    self.mTableView = nil;
    self.m_strDID = nil;
    self.m_strName = nil;
    if (m_RecordFileList != nil) {
        [m_RecordFileList release];
        m_RecordFileList = nil;
    }
    [m_strDID release];
    [m_strName release];
//    if (headerView!=nil) {
//        [headerView release];
//        headerView=nil;
//    }
    [mDownloadDic release];
    mDownloadDic=nil;
    if (selectIndexPath!=nil) {
        [selectIndexPath release];
        selectIndexPath=nil;
    }
    if (m_DateArray!=nil) {
        [m_DateArray removeAllObjects];
    }
    if (m_AllDic!=nil) {
        [m_AllDic removeAllObjects];
    }
    if (m_CurDateArray !=nil) {
        [m_CurDateArray removeAllObjects];
    }
    if (m_CurAllDic!=nil) {
        [m_CurAllDic removeAllObjects];
    }
    [m_DateArray release];
    [m_AllDic release];
    [m_CurAllDic release];
    [m_CurDateArray release];
    [super dealloc];
}

#pragma mark -
#pragma mark TableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 0;
    }
    return  40;
}
-(UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section{
    //NSLog(@"viewForHeaderInSection section=%d",section);
    if (section!=0) {
        MyHeaderView *headerView=(MyHeaderView *)[aTableView viewWithTag:kHeaderViewTag +section];
        
        if (headerView==nil) {
            headerView=[[MyHeaderView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
            headerView.tag=kHeaderViewTag+section;
            //响应点击事件
            UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headerTap:)];
            [headerView addGestureRecognizer:tapGesture];
            [tapGesture release];
        }
        
        NSString *name=[m_CurDateArray objectAtIndex:section-1];
        
        NSMutableArray *arr=(NSMutableArray *)[m_CurAllDic objectForKey:name];
       
        NSString *title=[NSString stringWithFormat:@"%@(%d)",name,[arr count]];
        
        [headerView setStrName:title];
        [headerView setOpen:isOpen];
        return headerView;
    }
   
    
    return nil;
    
}
-(void)headerTap:(UITapGestureRecognizer *)theTap{
   
    MyHeaderView *headerView=(MyHeaderView *)theTap.view;
    headerView.open=!headerView.open;
    isOpen=headerView.open;
    [headerView setOpen:headerView.open];
    NSInteger section=headerView.tag-kHeaderViewTag-1;
   
    NSString *key=[m_CurDateArray objectAtIndex:section];
   
    [m_CurAllDic setObject:[NSNumber numberWithBool:headerView.open] forKey:[NSString stringWithFormat:@"%@open",key]];
    
    [mTableView reloadSections:[NSIndexSet indexSetWithIndex:section+1] withRowAnimation:UITableViewRowAnimationFade];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
   
    return m_CurDateArray.count+1;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *title=@"";
    switch (section) {
        case 0:
       
            break;
        default:
            title=[m_CurDateArray objectAtIndex:section-1];
            break;
    }
    
    return title;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count=0;
    switch (section) {
        case 0:{
            count=2;
        }
            break;

        default:
            NSString *dKey=[m_CurDateArray objectAtIndex:section-1];
            
            BOOL open=[[m_CurAllDic objectForKey:[NSString stringWithFormat:@"%@open",dKey]]boolValue];
            if (open) {
                NSMutableArray *arr=(NSMutableArray *)[m_CurAllDic objectForKey:dKey];
                count=arr.count;
//                NSLog(@"section  count=%d",count);
            }
            
            break;
    }
   
    return count;
    
}

- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)anIndexPath
{
    
    
    NSString *cellIdentifier = @"RemoteRecordFileListCell";
    

    UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
         
    if (anIndexPath.section!=0) {
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    
    switch (anIndexPath.section) {
        case 0:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            switch (anIndexPath.row) {
                case 0:
                {
                cell.textLabel.text=NSLocalizedStringFromTable(@"runcar_phone_recordfile", @STR_LOCALIZED_FILE_NAME, nil);
                }
                    break;
                case 1:
                {
                cell.textLabel.text=NSLocalizedStringFromTable(@"runcar_remote_downloadfile", @STR_LOCALIZED_FILE_NAME, nil);
                }
                    break;
                case 2:
                    cell.textLabel.text=@"本地照片";
                    break;
                default:
                    break;
            }
        }
            break;
        default:
        {
            
            NSString *dkey=[m_CurDateArray objectAtIndex:anIndexPath.section-1];
            NSMutableArray *arr=(NSMutableArray *)[m_CurAllDic objectForKey:dkey];
            NSMutableDictionary *fileDic=[arr objectAtIndex:anIndexPath.row];
            NSString *fileName=[fileDic objectForKey:@STR_RECORD_FILE_NAME];
            NSString *fileSize=[fileDic objectForKey:@STR_RECORD_FILE_SIZE];

           
            NSString *downloadedName=[mDownloadDic objectForKey:fileName];//手机上下载的文件名
           
            if (anIndexPath.section==selectSection&&anIndexPath.row==selectRow) {//选中正在下载的行
                
                UIView *v=[cell viewWithTag:100];
                if (v!=nil) {
                    [v removeFromSuperview];
                }
                UIView *view=[[UIView alloc]initWithFrame:CGRectMake(10, 0,mProgress,44)];
                view.backgroundColor=[UIColor greenColor];
                view.tag=100;
                view.alpha=0.5;
                [cell addSubview:view];
                [view release];
                
                if (curdata>0) {
                    UILabel *progress=[[UILabel alloc]init];
                    progress.frame=CGRectMake(0, 0, 94, 42);
                    progress.text=[NSString stringWithFormat:@"%dk/%dk",curdata/1024,totaldata/1024];
                    progress.adjustsFontSizeToFitWidth=YES;
                    progress.textAlignment= UITextAlignmentRight;
                    progress.textColor=[UIColor redColor];
                    progress.backgroundColor=[UIColor clearColor];
                                       
                    cell.accessoryView=progress;
                    [progress release];
                }else{
                    indicatorView=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    indicatorView.frame=CGRectMake(0, 0, 20, 20);
                    [indicatorView startAnimating];
                    cell.accessoryView=indicatorView;
                    [indicatorView release];
                }
              
                
                

               
            }else if(downloadedName!=NULL){//手机已经下载了该文件
               
                UIView *v=[cell viewWithTag:100];
                if (v!=nil) {
                    [v removeFromSuperview];
                }
                UIView *view=[[UIView alloc]initWithFrame:CGRectMake(10, 0,300,44)];
                view.backgroundColor=[UIColor greenColor];
                view.alpha=0.5;
                view.tag=100;
                [cell addSubview:view];
                [view release];
                

                
                UILabel *progress=[[UILabel alloc]init];
                progress.frame=CGRectMake(0, 0, 54, 42);
                progress.text=NSLocalizedStringFromTable(@"runcar_loaded", @STR_LOCALIZED_FILE_NAME, nil);
                progress.adjustsFontSizeToFitWidth=YES;
                progress.textAlignment= UITextAlignmentRight;
                progress.textColor=[UIColor redColor];
                progress.backgroundColor=[UIColor clearColor];
                
                cell.accessoryView=progress;
                
                [progress release];

                
            }else{
                UIImage *img=[UIImage imageNamed:@"download.png"];
                UIImageView *btn=[[UIImageView alloc]init];
                btn.frame=CGRectMake(0, 9, 30, 30);
                [btn setImage:img];
                
                //cell.accessoryView=btn;
                [btn release];

            
            }
           
            cell.textLabel.text =[NSString stringWithFormat:@"%@-%@",fileName,fileSize] ;
        }
            break;
        
    }
    
    
    return cell;
    
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
    if (indexPath.section!=0) {
        NSString *dkey=[m_CurDateArray objectAtIndex:indexPath.section-1];
        NSMutableArray *arr=(NSMutableArray *)[m_CurAllDic objectForKey:dkey];
        NSMutableDictionary *fileDic=[arr objectAtIndex:indexPath.row];
        NSString *fileName=[fileDic objectForKey:@STR_RECORD_FILE_NAME];
        
        NSString *name=[mDownloadDic objectForKey:fileName];
        if (isDownLoading) {
            [mytoast showWithText:NSLocalizedStringFromTable(@"runcar_hasfileloading", @STR_LOCALIZED_FILE_NAME, nil)];
            //                NSLog(@"改文件正在下载或已经下载或有其他文件正在下载");
            return nil;
        }
        if(name!=nil){
            [mytoast showWithText:NSLocalizedStringFromTable(@"runcar_thefileloaded", @STR_LOCALIZED_FILE_NAME, nil)];
            return nil;
        }

    }

    return indexPath;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
  
    if (indexPath.section!=0) {
        NSString *dkey=[m_CurDateArray objectAtIndex:indexPath.section-1];
        NSMutableArray *arr=(NSMutableArray *)[m_CurAllDic objectForKey:dkey];
        NSDictionary *fileDic =[arr objectAtIndex:indexPath.row];
        NSString *strFileName = [fileDic objectForKey:@STR_RECORD_FILE_NAME];
        NSString *name=[mDownloadDic objectForKey:strFileName];

        if (isDownLoading&&indexPath.row==selectRow&&indexPath.section==selectSection) {
            return YES;
        }
        if(!isDownLoading&&name!=nil){
           
            return YES;
        }
    }
    return NO;
}
-(void)tableView:(UITableView *)atableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"accessoryButtonTappedForRowWithIndexPath");
}
-(void)tableView:(UITableView *)atableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *dkey=[m_CurDateArray objectAtIndex:indexPath.section-1];
    NSMutableArray *arr=(NSMutableArray *)[m_CurAllDic objectForKey:dkey];
    NSDictionary *fileDic =[arr objectAtIndex:indexPath.row];

    NSString *fileName=[fileDic objectForKey:@STR_RECORD_FILE_NAME];//设备上的文件名
    [mDownloadDic removeObjectForKey:fileName];
    //删除本地文件
    [self deleteLocalFile:fileName];
  
    UITableViewCell *cell=[atableView cellForRowAtIndexPath:indexPath];
    UIView *view=[cell viewWithTag:100];
    if (view!=nil) {
        [view removeFromSuperview];
    }
    UIImage *img=[UIImage imageNamed:@"download.png"];
    UIImageView *btn=[[UIImageView alloc]init];
    btn.frame=CGRectMake(0, 9, 30, 30);
    [btn setImage:img];
    cell.accessoryView=nil;
    [btn release];
    isDownLoading=NO;
    selectSection=-1;
    selectRow=-1;
    curdata=-1;
}

-(void)deleteLocalFile:(NSString *)fileName{
    @try {
        //创建文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];//去处需要的路径
        
        NSString *strPath=[documentsDirectory stringByAppendingPathComponent:m_strDID];
        NSString *downPath=[strPath stringByAppendingPathComponent:@"RemoteDownload"];
        //更改到待操作的目录下
        [fileManager changeCurrentDirectoryPath: downPath];
        
        //删除
        [fileManager removeItemAtPath:fileName error:nil];
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }

}
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)anIndexPath
{
    //NSLog(@"点击。。。");
    if (anIndexPath.section==0) {
        [aTableView deselectRowAtIndexPath:anIndexPath animated:YES];
    }
        switch (anIndexPath.section) {
        case 0:
            switch (anIndexPath.row) {
                case 0:{//手机录像
                PhoneRecordViewController *pViewController=[[PhoneRecordViewController alloc]init];
                    pViewController.did=m_strDID;
                    [self.navigationController pushViewController:pViewController animated:YES];
                    [pViewController release];
                }
                    
                    
                    break;
                case 1:{//远程下载文件
                    RemoteDownloadViewController *pViewController=[[RemoteDownloadViewController alloc]init];
                    pViewController.did=m_strDID;
                    pViewController.RecReloadDelegate=self;
                    [self.navigationController pushViewController:pViewController animated:YES];
                    [pViewController release];
   
                }
                    break;
                case 2:{//本地照片
                    PictrueDateViewController *pictureDateViewController = [[PictrueDateViewController alloc] init];
                    //pictureDateViewController.strName = name;
                    pictureDateViewController.strDID = m_strDID;
//                    pictureDateViewController.NotifyReloadDataDelegate=self;
                   pictureDateViewController.m_pPicPathMgt = m_pPicPathMgt;
                    [self.navigationController pushViewController:pictureDateViewController animated:YES];
                    [pictureDateViewController release];
                }
                    break;
                default:
                    break;
            }
            break;
        
        default:
            {
                
                
              BOOL flag=  [self isOutOfMemory];
                if (flag) {
                    [mytoast showWithText:NSLocalizedStringFromTable(@"runcar_outofmemory", @STR_LOCALIZED_FILE_NAME, nil)];
                    
                    return;
                }
                if (!isDownLoading) {
                    // NSLog(@"点击了下载");
                    isDownLoading=YES;
                    // NSDictionary *fileDic = [m_RecordFileList objectAtIndex:anIndexPath.row];
                    
                    NSString *dkey=[m_CurDateArray objectAtIndex:anIndexPath.section-1];
                    NSMutableArray *arr=(NSMutableArray *)[m_CurAllDic objectForKey:dkey];
                    NSDictionary *fileDic =[arr objectAtIndex:anIndexPath.row];
                    NSString *strFileName = [fileDic objectForKey:@STR_RECORD_FILE_NAME];
                    //NSString *strFileSize=[fileDic objectForKey:@STR_RECORD_FILE_SIZE];
                    //NSInteger fileSize=[strFileSize intValue];
                    NSString *strFilePath=[self getFilePath:strFileName];
                     DownloadingFileName=strFileName;
                    remoteDownload=new RemoteDownload(strFilePath);
                    
                    m_pPPPPChannelMgt->SetRunCarRemoteDownloadDelegate((char *)[m_strDID UTF8String], self);
                    
                    m_pPPPPChannelMgt->PPPPStartPlayback((char*)[m_strDID UTF8String],(char*)[strFileName UTF8String], 0);
                    
                    
                    
                    UITableViewCell *cell=[mTableView cellForRowAtIndexPath:anIndexPath];
                    indicatorView=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    indicatorView.frame=CGRectMake(0, 0, 20, 20);
                    [indicatorView startAnimating];
                    cell.accessoryView=indicatorView;
                    
                    selectRow=anIndexPath.row;
                    selectSection=anIndexPath.section;
                    selectIndexPath=[anIndexPath retain];
                    
                    //mTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateRow) userInfo:nil repeats:YES];
                }else{
                    // NSLog(@"正在下载。。。");
                }
                
            }

            break;
            
    }
    
       
}
-(void)updateRow:(int)length{
   
    NSLog(@"updateRow length=%d",length);
    
    
    
    NSString *str1=[NSString stringWithFormat:@"%d",curdata];
    NSDecimalNumber *dec1=[NSDecimalNumber decimalNumberWithString:str1];
    NSString *str2=[NSString stringWithFormat:@"%d",300];
    NSDecimalNumber *dec2=[NSDecimalNumber decimalNumberWithString:str2];
    NSString *str3=[NSString stringWithFormat:@"%d",totaldata];
    NSDecimalNumber *dec3=[NSDecimalNumber decimalNumberWithString:str3];
    
    NSDecimalNumber *dec4=[dec1 decimalNumberByMultiplyingBy:dec2];
    NSDecimalNumber *dec5=[dec4 decimalNumberByDividingBy:dec3];
    
    NSString *resultStr=[dec5 stringValue];
    mProgress=[resultStr floatValue];
        
    
    [self performSelectorOnMainThread:@selector(pp:) withObject:[NSNumber numberWithFloat:mProgress] waitUntilDone:NO];
}
-(void)pp:(NSNumber *)number{
    NSLog(@"ppp() 1");
    float width=[number floatValue];
    
//    NSIndexPath *d=[mTableView indexPathForSelectedRow];
    UITableViewCell *cell=[mTableView cellForRowAtIndexPath:selectIndexPath];
  
    UIView *v=[cell viewWithTag:100];
    if (v!=nil) {
        [v removeFromSuperview];
    }
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(10, 0,width,44)];
    view.backgroundColor=[UIColor greenColor];
    view.tag=100;
    view.alpha=0.5;
    view.layer.cornerRadius=5;
    [cell addSubview:view];
    [view release];
    
    
    UILabel *progress=[[UILabel alloc]init];
    progress.frame=CGRectMake(0, 0, 94, 42);
    progress.text=[NSString stringWithFormat:@"%dk/%dk",curdata/1024,totaldata/1024];
    progress.adjustsFontSizeToFitWidth=YES;
    progress.textAlignment= UITextAlignmentRight;
    progress.textColor=[UIColor redColor];
    progress.backgroundColor=[UIColor clearColor];
    
    cell.accessoryView=progress;
    [progress release];
    
    if (curdata>=totaldata) {
        [self overRefresh];
    }
    
}
-(void)overRefresh{
    NSLog(@"overRefresh");
    //NSDictionary *fileDic = [m_RecordFileList objectAtIndex:selectIndexPath.row];
    
    NSString *dkey=[m_CurDateArray objectAtIndex:selectIndexPath.section-1];
    NSMutableArray *arr=(NSMutableArray *)[m_CurAllDic objectForKey:dkey];
    NSDictionary *fileDic =[arr objectAtIndex:selectIndexPath.row]; 
    NSString *fileName=[fileDic objectForKey:@STR_RECORD_FILE_NAME];//设备上的文件名
    [mDownloadDic setObject:fileName forKey:fileName];
    
    UITableViewCell *cell=[mTableView cellForRowAtIndexPath:selectIndexPath];
    if (cell==nil) {
        NSLog(@"cell==nil");
    }else{
        NSLog(@"cell!=nil");
    }
    UILabel *progress=[[UILabel alloc]init];
    progress.frame=CGRectMake(0, 0, 54, 42);
    progress.text=NSLocalizedStringFromTable(@"runcar_loaded", @STR_LOCALIZED_FILE_NAME, nil);
    progress.adjustsFontSizeToFitWidth=YES;
    progress.textAlignment= UITextAlignmentRight;
    progress.textColor=[UIColor redColor];
    progress.backgroundColor=[UIColor clearColor];
    cell.accessoryView=progress;
    
    [progress release];
    UIView *v=[cell viewWithTag:100];
    if (v!=nil) {
        [v removeFromSuperview];
    }
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(10, 0,300,44)];
    view.backgroundColor=[UIColor greenColor];
    view.tag=100;
    view.alpha=0.5;
    view.layer.cornerRadius=5;
    [cell addSubview:view];
    [view release];
    //num=0;
    mProgress=0;
    //mTimer=nil;
    isDownLoading=NO;
    selectRow=-1;
    selectSection=-1;
    [selectIndexPath release];
}
#pragma mark -
#pragma mark performOnMainThread

- (void) ReloadTableView
{
    [self.mTableView reloadData];
}

-(NSString *)getFilePath:(NSString *)fileName{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory=[paths objectAtIndex:0];
    NSString *strPath=[documentDirectory stringByAppendingPathComponent:m_strDID];
    NSString *downPath=[strPath stringByAppendingPathComponent:@"RemoteDownload"];
    if (![fileManager fileExistsAtPath:downPath]) {
        [fileManager createDirectoryAtPath:downPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *strFilePath=[downPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
    return strFilePath;
}

#pragma mark -
#pragma mark navigationBarDelegate

- (BOOL) navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    //[self.navigationController popViewControllerAnimated:YES];
    m_bFinished=YES;
   m_pPPPPChannelMgt->SetRunCarRemoteDownloadDelegate((char *)[m_strDID UTF8String], self);
    if (isDownLoading) {
        isDownLoading=NO;
        remoteDownload->close();
        SAFE_DELETE(remoteDownload);
        [self deleteLocalFile:DownloadingFileName];
    }

    [self playPPPView];
    return NO;
    
}

#pragma mark -
#pragma mark sdcardfilelistresult

- (void) SDCardRecordFileSearchResult:(NSString *)strFileName fileSize:(NSInteger)fileSize bEnd:(BOOL)bEnd
{
    NSLog(@"strFileName: %@, fileSize: %d, bEnd: %d", strFileName, fileSize, bEnd);
    
   
    
    if (m_bFinished == YES) {
        return;
    }
    
   [self performSelectorOnMainThread:@selector(StopTimer) withObject:nil waitUntilDone:YES];
    NSString *fSize=@"";
    if (fileSize/1024/1024>0) {
        fileSize=fileSize/1024/1024;
        fSize=[NSString stringWithFormat:@"%dM", fileSize];
    }else{
        fileSize=fileSize/1024;
        fSize=[NSString stringWithFormat:@"%dK", fileSize];
    }
    NSDictionary *fileDic = [NSDictionary dictionaryWithObjectsAndKeys:strFileName, @STR_RECORD_FILE_NAME, fSize, @STR_RECORD_FILE_SIZE, nil];
    
    
    //[m_RecordFileList addObject:fileDic];
    
    
    NSString *strDate=[strFileName substringWithRange:NSMakeRange(2,8)];
    
    
    if (![m_DateArray containsObject:strDate]) {//如果没有该日期
        [m_DateArray addObject:strDate];
        NSMutableArray *arr=[[NSMutableArray alloc]init];
        [arr addObject:fileDic];
        [m_AllDic setObject:arr forKey:strDate];
        [arr release];
    }else{
        NSMutableArray *arr=(NSMutableArray *)[m_AllDic objectForKey:strDate];
        [arr addObject:fileDic];
    }
    
    if (![m_CurDateArray containsObject:strDate]) {//如果没有该日期
        [m_CurDateArray addObject:strDate];
        NSMutableArray *arr=[[NSMutableArray alloc]init];
        [arr addObject:fileDic];
        [m_CurAllDic setObject:arr forKey:strDate];
        [arr release];
    }else{
        NSMutableArray *arr=(NSMutableArray *)[m_CurAllDic objectForKey:strDate];
        [arr addObject:fileDic];
    }
    
    if (bEnd == 1) {
        int count=m_DateArray.count;
        for (int i=0; i<count; i++) {
            NSString *dkey=[m_DateArray objectAtIndex:i];
            NSMutableArray *arr=(NSMutableArray *)[m_AllDic objectForKey:dkey];
            [arr sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSDictionary *dic1=obj1;
                NSDictionary *dic2=obj2;
                NSString *str1=[dic1 objectForKey:@STR_RECORD_FILE_NAME];
                NSString *str2=[dic2 objectForKey:@STR_RECORD_FILE_NAME];
                return [str2 compare:str1];
            }];
        }
        count=m_CurDateArray.count;
        for (int i=0; i<count; i++) {
            NSString *dkey=[m_CurDateArray objectAtIndex:i];
            NSMutableArray *arr=(NSMutableArray *)[m_CurAllDic objectForKey:dkey];
            [arr sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSDictionary *dic1=obj1;
                NSDictionary *dic2=obj2;
                NSString *str1=[dic1 objectForKey:@STR_RECORD_FILE_NAME];
                NSString *str2=[dic2 objectForKey:@STR_RECORD_FILE_NAME];
                return [str2 compare:str1];
            }];
        }

        
        [self performSelectorOnMainThread:@selector(hideLoadingIndicator) withObject:nil waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(ReloadTableView) withObject:nil waitUntilDone:YES];
    }
}

#pragma mark- RemoteDownloadDataResult
-(void)PlaybackDownloadDataResult:(char *)pbuf Len:(int)length CurrData:(unsigned int)curData TotalData:(unsigned int)totalData{
   
    //NSLog(@"PlaybackDownloadDataResult   length=%d CurrData=%d  totalData=%d",length,curData,totalData);
    
    if (!isDownLoading) {
        NSLog(@"停止下载");
        return;
    }
    NSLog(@"PlaybackDownloadDataResult   length=%d CurrData=%d  totalData=%d",length,curData,totalData);
    
    curdata=curData+length;
    totaldata=totalData;
    
    remoteDownload->sendData(pbuf, length);
    
    [self updateRow:length];
    
    if ((curData+length)>=totalData) {
       NSLog(@"下载完成");
       isDownLoading=NO;
       remoteDownload->close();
        SAFE_DELETE(remoteDownload);  
    }  
}

-(void)playPPPView{
    AppDelegate *ipClientAppDlg=[[UIApplication sharedApplication]delegate];
    PlayViewController *playViewController = [[PlayViewController alloc] init];
    playViewController.m_pPPPPChannelMgt=m_pPPPPChannelMgt;
    playViewController.strDID = m_strDID;
    //    playViewController.strUser=user;
    //    playViewController.strPwd=pwd;
    
    playViewController.cameraName = @"IpCam";
    playViewController.m_nP2PMode = 1;
    [ipClientAppDlg switchPlayView:playViewController];
    [playViewController release];
    
}
#pragma mark-  RemoteSearchResultDelegate
-(void)searchResult:(BOOL)isAll  StartTime:(NSString *)startTime EndTime:(NSString *)endTime{
    NSLog(@"startTime=%@  endTime=%@  isAll=%d",startTime,endTime,isAll);
    
    [self searchFile:isAll StartTime:startTime EndTime:endTime];
}
-(void)searchFile:(BOOL)isAll  StartTime:(NSString *)startTime EndTime:(NSString *)endTime{
    [m_CurDateArray removeAllObjects];
    [m_CurAllDic removeAllObjects];
    
    
    if (isAll) {
        for (int i=0; i<m_DateArray.count; i++) {
            NSString *strDate=[m_DateArray objectAtIndex:i];
            [m_CurDateArray addObject:strDate];
            NSMutableArray *arr=(NSMutableArray *)[m_AllDic objectForKey:strDate];
            NSMutableArray *arr2=[[NSMutableArray alloc]init];
            [arr2 addObjectsFromArray:arr];
            [m_CurAllDic setObject:arr2 forKey:strDate];
            [arr2 release];
        }
    }else{
        NSString *sDate=[startTime substringWithRange:NSMakeRange(0, 8)];
        NSString *eDate=[endTime substringWithRange:NSMakeRange(0, 8)];
        NSLog(@"sDate=%@  eDate=%@",sDate,eDate);
        for (int i=0; i<m_DateArray.count; i++) {
         NSString *strDate=[m_DateArray objectAtIndex:i];
            NSLog(@"strDate=%@",strDate);
            if (([strDate compare:sDate]==NSOrderedSame)||(([strDate compare:sDate]==NSOrderedDescending)&&([strDate compare:eDate]==NSOrderedAscending))||([strDate compare:eDate]==NSOrderedSame)) {
                NSLog(@"在搜索的日期范围内");
                
                [m_CurDateArray addObject:strDate];
                NSMutableArray *arr=(NSMutableArray *)[m_AllDic objectForKey:strDate];
                NSMutableArray *curArr=[[NSMutableArray alloc]init];
                for (int j=0; j<arr.count; j++) {
                    NSMutableDictionary *fileDic=(NSMutableDictionary *)[arr objectAtIndex:j];
                    NSString *strF=[fileDic objectForKey:@STR_RECORD_FILE_NAME];
                    NSLog(@"strF=%@",strF);
                    NSString *fileName=[strF substringWithRange:NSMakeRange(2, 14)];
                    NSLog(@"fileName=%@",fileName);
                    startTime=[startTime stringByReplacingOccurrencesOfString:@"_" withString:@""];
                    endTime=[endTime stringByReplacingOccurrencesOfString:@"_" withString:@""];
                    if (([fileName compare:startTime]==NSOrderedSame)||(([fileName compare:startTime]==NSOrderedDescending)&&([fileName compare:endTime]==NSOrderedAscending))||([fileName compare:endTime]==NSOrderedSame)) {
                        NSLog(@"strF满足搜索要求");
                        [curArr addObject:fileDic];
                    }
                }
                [m_CurAllDic setObject:curArr forKey:strDate];
                [curArr release];
            }
        }
        
    }
    
    [self ReloadTableView];
}
#pragma mark-  NotifyEventDelegate
-(void)NotifyReloadData{
    NSLog(@"NotifyReloadData......99999");
    [self getLocalDownloadFile];
    [self ReloadTableView];
}

-(BOOL)isOutOfMemory {
    
    //    return NO;
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;
    NSFileManager* fileManager = [[NSFileManager alloc ]init];
    NSDictionary *fileSysAttributes = [fileManager attributesOfFileSystemForPath:path error:nil];
    NSNumber *freeSpace = [fileSysAttributes objectForKey:NSFileSystemFreeSize];
    NSNumber *totalSpace = [fileSysAttributes objectForKey:NSFileSystemSize];
    float free=([freeSpace longLongValue])/1024.0/1024.0/1024.0;
    float total=([totalSpace longLongValue])/1024.0/1024.0/1024.0;
    NSString *memory=@"";
    if (free>1.0) {
        memory=[NSString stringWithFormat:@"%0.1fG/%0.1fG",free,total];
        //strMemory=[[NSString alloc]initWithFormat:@"%0.1fG/%0.1fG",free,total];
    }else{
        free=([freeSpace longLongValue])/1024.0/1024.0;
        memory=[NSString stringWithFormat:@"%0.1fM/%0.1fG",free,total];
        if (free<100.0) {
            return YES;
        }
    }
    NSLog(@"memory=%@",memory);
    
    
    
    return NO;
}

@end
