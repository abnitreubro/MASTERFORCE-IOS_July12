


//
//  PictureListViewController.m
//  P2PCamera
//
//  Created by mac on 12-11-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PictureListViewController.h"
#import "obj_common.h"
#import "PicListCell.h"
#import "PictureShowViewController.h"
#import "APICommon.h"
#import <QuartzCore/QuartzCore.h>

#import "PicListIpadCell.h"
#import "mytoast.h"
#import "AppDelegate.h"
@interface PictureListViewController ()

@end

@implementation PictureListViewController
@synthesize imageTag;
@synthesize navigationBar;
@synthesize strDate;
@synthesize m_pPicPathMgt;
@synthesize strDID;
@synthesize m_tableView;
@synthesize NotifyReloadDataDelegate;
@synthesize progressView;
@synthesize isP2P;
@synthesize m_Lock;
@synthesize alertView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    
    
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
        isIphone=YES;
        
    }else{
        isIphone=NO;
    }
    
    m_Lock=[[NSCondition alloc]init];
    
    memset(m_pSelectedStatus, 0, sizeof(m_pSelectedStatus));
    m_nTotalNum = 0;
    m_toolBar = nil;
    m_myImgDic=[[NSMutableDictionary alloc]init];
    m_bEditMode = NO;
    picPathArray = nil;
    picPathArray=[[NSMutableArray alloc]init];
    //[NSThread detachNewThreadSelector:@selector(loadPicPathArray) toTarget:self withObject:nil];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(loadPicPathArray) userInfo:nil repeats:NO];
    
    navigationBar.delegate = self;
    [self initNavigationBar];
    
    
    
    self.wantsFullScreenLayout = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    self.navigationBar.translucent = YES;
    
    CGRect navigationBarFrame = self.navigationBar.frame;
    navigationBarFrame.origin.y += 20;
    self.navigationBar.frame = navigationBarFrame;
    //self.navigationBar.alpha = 0.5f;
    
    
    
    
    CGRect tableViewFrame ;
    tableViewFrame.size.height = 480 - 20;
    tableViewFrame.size.width = 320;
    tableViewFrame.origin.x = 0;
    tableViewFrame.origin.y = 0;
    m_tableView .delegate=self;
    m_tableView.dataSource=self;
    m_tableView.frame = tableViewFrame;
    m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //m_tableView.hidden=YES;
    UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 44 + 20 + 4)];
    m_tableView.tableHeaderView = headerView;
    [headerView release];
    
    self.imageTag = [UIImage imageNamed:@"del_hook.png"];
    
    [self initProgressView];
    
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

-(void)initProgressView{
    alertView=[[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"initPicPrompt", @STR_LOCALIZED_FILE_NAME, nil) message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [alertView show];
    //alertView.frame=CGRectMake(10.0f, 100.0f, 240.0f, 200.0f);
    
    UIActivityIndicatorView *activeView=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activeView.center=CGPointMake(alertView.bounds.size.width/2, alertView.bounds.size.height-40);
    [activeView startAnimating];
    [alertView addSubview:activeView];
    [activeView release];
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(dismissProgressView) userInfo:nil repeats:NO];
}
-(void)dismissProgressView{
    [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
}

-(void)loadPicPathArray{
    
    //[progressView removeFromSuperview];
    if (picPathArray!=nil) {
        [picPathArray removeAllObjects];
        NSMutableArray *tempArray= [m_pPicPathMgt GetTotalPathArray:strDID date:strDate];
        for (NSString *pa in tempArray) {
            [picPathArray addObject:pa];
        }
    }
    if (m_tableView!=nil) {
        [m_tableView reloadData];
    }
    
    
    [self performSelectorOnMainThread:@selector(initNavigationBarOnMainThread) withObject:nil waitUntilDone:NO];
    
}



-(void)initNavigationBar{
    if (!m_bEditMode) {
        UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:[NSString stringWithFormat:@"%@(%d)",strDate,m_nTotalNum]];
        UINavigationItem *back = [[UINavigationItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Back", @STR_LOCALIZED_FILE_NAME, nil)];
        UIBarButtonItem *rightButton=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedStringFromTable(@"Edit", @STR_LOCALIZED_FILE_NAME, nil) style:UIBarButtonItemStyleBordered target:self action:@selector(btnEdit)];
        item.rightBarButtonItem=rightButton;
        [rightButton release];
        
        NSArray *array = [NSArray arrayWithObjects:back, item, nil];
        [self.navigationBar setItems:array];
        [item release];
        [back release];
        
    }else{
        UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:[NSString stringWithFormat:@"%@(%d)",strDate,m_nTotalNum]];
        UINavigationItem *back = [[UINavigationItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Back", @STR_LOCALIZED_FILE_NAME, nil)];
        UIBarButtonItem *rightButton=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedStringFromTable(@"Done", @STR_LOCALIZED_FILE_NAME, nil) style:UIBarButtonItemStyleDone  target:self action:@selector(btnEdit)];
        item.rightBarButtonItem=rightButton;
        [rightButton release];
        
        NSArray *array = [NSArray arrayWithObjects:back, item, nil];
        [self.navigationBar setItems:array];
        [item release];
        [back release];
        
    }
}

-(void)btnEdit{
    int imgCount= [m_myImgDic count];
    int count = [picPathArray count];
    NSLog(@"imgCount=%d count=%d",imgCount,count);
    if (imgCount<count) {
        [mytoast showWithText:NSLocalizedStringFromTable(@"piclisteditprompt", @STR_LOCALIZED_FILE_NAME, nil)];
        return;
    }
    NSLog(@"_____________");
    
    m_bEditMode=!m_bEditMode;
    [self initNavigationBar];
    NSLog(@"_____________p0");
    [self showToolBar];
    NSLog(@"_____________11");
}
-(void)showToolBar{
    
    
    CGRect screenFrame=[[UIScreen mainScreen]applicationFrame];
    if (m_bEditMode) {
        int toolBarX=0;
        int toolBarY=screenFrame.size.height-44+20;
        int toolBarWidth=screenFrame.size.width;
        int toolBarHeight=44;
        m_toolBar=[[UIToolbar alloc]initWithFrame:CGRectMake(toolBarX, toolBarY, toolBarWidth, toolBarHeight)];
        m_toolBar.barStyle=UIBarStyleBlackOpaque;
        
        UIBarButtonItem *btnSelectAll=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedStringFromTable(@"selectAll",  @STR_LOCALIZED_FILE_NAME, nil) style:UIBarButtonItemStyleBordered target:self action:@selector(mySelectAll)];
        UIBarButtonItem *btnSpace1=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem*btnReserveSelect=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedStringFromTable(@"reserveSelect",  @STR_LOCALIZED_FILE_NAME, nil) style:UIBarButtonItemStyleBordered target:self action:@selector(myReserveSelect)];
        UIBarButtonItem *btnSpace2=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *btnDelete=[[UIBarButtonItem alloc]initWithTitle:NSLocalizedStringFromTable(@"Delete",  @STR_LOCALIZED_FILE_NAME, nil) style:UIBarButtonItemStyleBordered target:self action:@selector(myDelete)];
        NSArray *array=[NSArray arrayWithObjects:btnSpace1,btnSelectAll,btnReserveSelect,btnDelete,btnSpace2 ,nil];
        [m_toolBar setItems:array];
        [btnSelectAll release];
        [btnReserveSelect release];
        [btnDelete release];
        [btnSpace1 release];
        [btnSpace2 release];
        [self.view addSubview:m_toolBar];
        CGRect rectTableView=m_tableView.frame;
        rectTableView.size.height-=44;
        m_tableView.frame=rectTableView;
    }else{
        CGRect rectTableView = self.m_tableView.frame;
        rectTableView.size.height += 44 ;
        self.m_tableView.frame = rectTableView ;
        [m_toolBar removeFromSuperview];
        [m_toolBar release];
        m_toolBar=nil;
        int i;
        BOOL bReload=NO;
        for (i=0; i<m_nTotalNum; i++) {
            if (m_pSelectedStatus[i]==1) {
                bReload=YES;
            }
            m_pSelectedStatus[i]=0;
        }
        if (bReload) {
            [self.m_tableView reloadData];
        }
    }
}
-(void)mySelectAll{
    BOOL bReload=NO;
    for (int i=0; i<m_nTotalNum; i++) {
        if (m_pSelectedStatus[i]==0) {
            bReload=YES;
            m_pSelectedStatus[i]=1;
        }
    }
    if (bReload) {
        [self.m_tableView reloadData];
    }
}
-(void)myReserveSelect{
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
-(void)myDelete{
    BOOL bReload=NO;
    int i;
    
    for (i=0; i<m_nTotalNum; i++) {
        if (m_pSelectedStatus[i]==1) {
            bReload=YES;
            NSLog(@"删除index=%d",i);
            [m_pPicPathMgt RemovePicPath:strDID PicDate:strDate PicPath:[picPathArray objectAtIndex:i]];
            [m_myImgDic removeObjectForKey:[picPathArray objectAtIndex:i]];
        }
    }
    
    if (bReload) {
        memset(m_pSelectedStatus, 0, sizeof(m_pSelectedStatus));
        
        [self loadPicPathArray];
        [self.NotifyReloadDataDelegate NotifyReloadData];
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
-(void)removeTag:(UIView *)view{
    for (UIView  *v in [view subviews]) {
        [v removeFromSuperview];
    }
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
    if (m_Lock!=nil) {
        [m_Lock release];
        m_Lock=nil;
    }
    if (alertView!=nil) {
        [alertView release];
        alertView=nil;
    }
    self.navigationBar = nil;
    self.m_pPicPathMgt = nil;
    self.strDID = nil;
    self.strDate = nil;
    self.m_tableView = nil;
    self.NotifyReloadDataDelegate=nil;
    self.progressView=nil;
    [picPathArray release];
    picPathArray=nil;
    [m_myImgDic removeAllObjects];
    [m_myImgDic release];
    m_myImgDic=nil;
    [super dealloc];
}


- (void) singleTapHandle: (UITapGestureRecognizer*)sender
{
    UIImageView *imageView = (UIImageView*)[sender view];
    int tag = imageView.tag;
    
    //NSLog(@"singleTapHandle tag:%d", tag);
    if(!m_bEditMode){
       
        
        PictureShowViewController *picShowViewController = [[PictureShowViewController alloc] init];
        picShowViewController.strDID = strDID;
        picShowViewController.strDate = strDate;
        picShowViewController.m_pPicPathMgt = m_pPicPathMgt;
        picShowViewController.picPathArray = picPathArray;
        picShowViewController.NotifyReloadDataDelegate = self;
        picShowViewController.m_currPic = tag;
        [self.navigationController pushViewController:picShowViewController animated:YES];
        [picShowViewController release];
     
        return;
    }
    if (tag>=m_nTotalNum) {
        return;
    }
    if(m_pSelectedStatus[tag]==1){
        
        NSArray *views=[imageView subviews];
        if([views count]<1){
            m_pSelectedStatus[tag]=0;
            return;
        }
        UIView *tagView=[views objectAtIndex:0];
        [tagView removeFromSuperview];
        m_pSelectedStatus[tag]=0;
    }else{
        [self AddTag:imageView];
        m_pSelectedStatus[tag]=1;
    }
    
}

#pragma mark -
#pragma mark TableViewDelegate

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    
    
    int  count = [picPathArray count];
    m_nTotalNum=count;
    NSLog(@" numberOfRowsInSection...count=%d",count);
    if (count == 0) {
        
        return 0;
    }
    if (isIphone) {
        return (count % 4) > 0 ? (count / 4) + 1 : count / 4;
    }else{
        
        return (count % 9) > 0 ? (count / 9) + 1 : count / 9;
    }
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)anIndexPath
{
    //NSLog(@"cellForRowAtIndexPath");
    
    
    NSString *cellIdentifier = @"PicListCell";
	
    if (isIphone) {
        PicListCell *cell =  (PicListCell*)[aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            
            UINib *nib=[UINib nibWithNibName:@"PicListCell" bundle:nil];
            [aTableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
            cell=(PicListCell *)[aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
            //            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PicListCell" owner:self options:nil];
            //            cell = [nib objectAtIndex:0];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        int nTotalCount = [picPathArray count];
        
        
        
        int AtIndex = anIndexPath.row * 4 ;
        
        NSString *strPath = [picPathArray objectAtIndex:AtIndex];
        
        
        
        if (strPath==nil) {
            [self removeTag:cell.imageView1];
            cell.imageView1.image=nil;
            return cell;
        }
        //kaven
        UIImage *img=[m_myImgDic objectForKey:strPath];
        
        
        NSString *flag=[m_myImgDic objectForKey:[NSString stringWithFormat:@"flagk%@",strPath]];
        if (img==nil)
        {
            
            [m_myImgDic setObject:[NSString stringWithFormat:@"flag%@",strPath] forKey:[NSString stringWithFormat:@"flagk%@",strPath]];
            
            NSDictionary *mdic=[NSDictionary dictionaryWithObjectsAndKeys:strPath,@"path",anIndexPath,@"indexpath",[NSNumber numberWithInt:1],@"num", nil];
            
            [NSThread detachNewThreadSelector:@selector(startLoadLocalPic:) toTarget:self withObject:mdic];
        }
        //kaven

        
        if (img != nil) {
            cell.imageView1.image = img;
        }else{
            cell.imageView1.image=nil;
        }
        cell.imageView1.tag = AtIndex;
        
        cell.imageView1.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapHandle:)];
        singleTap.numberOfTapsRequired = 1;
        [cell.imageView1 addGestureRecognizer:singleTap];
        
        if (m_pSelectedStatus[AtIndex] == 1)
        {
            [self AddTag:cell.imageView1];
        }else{
            [self removeTag:cell.imageView1];
        }
        [singleTap release];
        
        
        //imageView2
        AtIndex += 1;
        if (AtIndex >= nTotalCount) {
            
            [self removeTag:cell.imageView2];
            cell.imageView2.image=nil;
            cell.imageView2.userInteractionEnabled = NO;
            [self removeTag:cell.imageView3];
            cell.imageView3.userInteractionEnabled = NO;
            cell.imageView3.image=nil;
            [self removeTag:cell.imageView4];
            cell.imageView4.userInteractionEnabled = NO;
            cell.imageView4.image=nil;
            return cell;
        }
        
        strPath = [picPathArray objectAtIndex:AtIndex];
        if (strPath == nil) {
            
            return cell;
        }
        img=[m_myImgDic objectForKey:strPath];
        flag=[m_myImgDic objectForKey:[NSString stringWithFormat:@"flagk%@",strPath]];
        if (img==nil) {
            [m_myImgDic setObject:[NSString stringWithFormat:@"flag%@",strPath] forKey:[NSString stringWithFormat:@"flagk%@",strPath]];
            NSDictionary *mdic=[NSDictionary dictionaryWithObjectsAndKeys:strPath,@"path",anIndexPath,@"indexpath",[NSNumber numberWithInt:2],@"num", nil];
            [NSThread detachNewThreadSelector:@selector(startLoadLocalPic:) toTarget:self withObject:mdic];
        }
        
        //image = [APICommon GetImageByNameFromImage:strDID filename:strPath];
        if (img != nil) {
            cell.imageView2.image = img;
        }else{
            cell.imageView2.image=nil;
        }
        cell.imageView2.tag = AtIndex;
        
        cell.imageView2.userInteractionEnabled = YES;
        singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapHandle:)];
        singleTap.numberOfTapsRequired = 1;
        [cell.imageView2 addGestureRecognizer:singleTap];
        if (m_pSelectedStatus[AtIndex] == 1)
        {
            [self AddTag:cell.imageView2];
        }else{
            [self removeTag:cell.imageView2];
        }
        [singleTap release];
        
        //imageView3
        AtIndex += 1;
        if (AtIndex >= nTotalCount) {
            [self removeTag:cell.imageView3];
            cell.imageView3.userInteractionEnabled = NO;
            cell.imageView3.image=nil;
            [self removeTag:cell.imageView4];
            cell.imageView4.userInteractionEnabled = NO;
            cell.imageView4.image=nil;
            return cell;
        }
        strPath = [picPathArray objectAtIndex:AtIndex];
        if (strPath == nil) {
            
            return cell;
        }
        img=[m_myImgDic objectForKey:strPath];
        flag=[m_myImgDic objectForKey:[NSString stringWithFormat:@"flagk%@",strPath]];
        if (img==nil) {
            [m_myImgDic setObject:[NSString stringWithFormat:@"flag%@",strPath] forKey:[NSString stringWithFormat:@"flagk%@",strPath]];
            NSDictionary *mdic=[NSDictionary dictionaryWithObjectsAndKeys:strPath,@"path",anIndexPath,@"indexpath",[NSNumber numberWithInt:3],@"num", nil];
            [NSThread detachNewThreadSelector:@selector(startLoadLocalPic:) toTarget:self withObject:mdic];
        }
        
        //image = [APICommon GetImageByNameFromImage:strDID filename:strPath];
        if (img != nil) {
            cell.imageView3.image = img;
        }else{
            cell.imageView3.image=nil;
        }
        cell.imageView3.tag = AtIndex;
        
        cell.imageView3.userInteractionEnabled = YES;
        singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapHandle:)];
        singleTap.numberOfTapsRequired = 1;
        [cell.imageView3 addGestureRecognizer:singleTap];
        if (m_pSelectedStatus[AtIndex] == 1)
        {
            [self AddTag:cell.imageView3];
        }else{
            [self removeTag:cell.imageView3];
        }
        [singleTap release];
        
        //imageView4
        AtIndex += 1;
        if (AtIndex >= nTotalCount) {
            [self removeTag:cell.imageView4];
            cell.imageView4.userInteractionEnabled = NO;
            cell.imageView4.image=nil;
            return cell;
        }
        strPath = [picPathArray objectAtIndex:AtIndex];
        if (strPath == nil) {
            
            
            return cell;
        }
        img=[m_myImgDic objectForKey:strPath];
        flag=[m_myImgDic objectForKey:[NSString stringWithFormat:@"flagk%@",strPath]];
        if (img==nil) {
            
            [m_myImgDic setObject:[NSString stringWithFormat:@"flag%@",strPath] forKey:[NSString stringWithFormat:@"flagk%@",strPath]];
            NSDictionary *mdic=[NSDictionary dictionaryWithObjectsAndKeys:strPath,@"path",anIndexPath,@"indexpath",[NSNumber numberWithInt:4],@"num", nil];
            [NSThread detachNewThreadSelector:@selector(startLoadLocalPic:) toTarget:self withObject:mdic];
        }
        
        //image = [APICommon GetImageByNameFromImage:strDID filename:strPath];
        if (img != nil) {
            
            cell.imageView4.image = img;
        }else{
            
            cell.imageView4.image=nil;
        }
        cell.imageView4.tag = AtIndex;
        
        cell.imageView4.userInteractionEnabled = YES;
        singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapHandle:)];
        singleTap.numberOfTapsRequired = 1;
        [cell.imageView4 addGestureRecognizer:singleTap];
        if (m_pSelectedStatus[AtIndex] == 1)
        {
            [self AddTag:cell.imageView4];
        }else{
            [self removeTag:cell.imageView4];
        }
        [singleTap release];
        
        
        return cell;
    }else{
        PicListIpadCell *cell=(PicListIpadCell *)[aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil)
        {
            
            UINib *nib=[UINib nibWithNibName:@"PicListIpadCell" bundle:nil];
            [aTableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
            cell=(PicListIpadCell *)[aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
            //                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PicListIpadCell" owner:self options:nil];
            //                  cell = [nib objectAtIndex:0];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        int nTotalCount = [picPathArray count];
        
        
        
        int AtIndex = anIndexPath.row * 9 ;
        
        NSString *strPath = [picPathArray objectAtIndex:AtIndex];
        if (strPath==nil) {
            [self removeTag:cell.imageView1];
            cell.imageView1.image=nil;
            [self removeTag:cell.imageView2];
            cell.imageView2.image=nil;
            cell.imageView2.userInteractionEnabled = NO;
            [self removeTag:cell.imageView3];
            cell.imageView3.userInteractionEnabled = NO;
            cell.imageView3.image=nil;
            [self removeTag:cell.imageView4];
            cell.imageView4.userInteractionEnabled = NO;
            cell.imageView4.image=nil;
            [self removeTag:cell.imageView5];
            cell.imageView5.userInteractionEnabled = NO;
            cell.imageView5.image=nil;
            [self removeTag:cell.imageView6];
            cell.imageView6.userInteractionEnabled = NO;
            cell.imageView6.image=nil;
            [self removeTag:cell.imageView7];
            cell.imageView7.userInteractionEnabled = NO;
            cell.imageView7.image=nil;
            [self removeTag:cell.imageView8];
            cell.imageView8.userInteractionEnabled = NO;
            cell.imageView8.image=nil;
            [self removeTag:cell.imageView9];
            cell.imageView9.userInteractionEnabled = NO;
            cell.imageView9.image=nil;
            
            return cell;
        }
        //kaven
        UIImage *img=[m_myImgDic objectForKey:strPath];
        //NSString *flag=[m_myImgDic objectForKey:[NSString stringWithFormat:@"flagk%@",strPath]];
        if (img==nil) {
            //[m_myImgDic setObject:[NSString stringWithFormat:@"flag%@",strPath] forKey:[NSString stringWithFormat:@"flagk%@",strPath]];
            NSDictionary *mdic=[NSDictionary dictionaryWithObjectsAndKeys:strPath,@"path",anIndexPath,@"indexpath",[NSNumber numberWithInt:1],@"num", nil];
            [NSThread detachNewThreadSelector:@selector(startLoadLocalPic:) toTarget:self withObject:mdic];
        }
        //kaven
        //UIImage *image = [APICommon GetImageByNameFromImage:strDID filename:strPath];
        
        if (img != nil) {
            // NSLog(@"img!=nil  index=%d",AtIndex);
            cell.imageView1.image = img;
        }else{
            cell.imageView1.image=nil;
        }
        cell.imageView1.tag = AtIndex;
        
        cell.imageView1.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapHandle:)];
        singleTap.numberOfTapsRequired = 1;
        [cell.imageView1 addGestureRecognizer:singleTap];
        if (m_pSelectedStatus[AtIndex] == 1)
        {
            [self AddTag:cell.imageView1];
        }else{
            [self removeTag:cell.imageView1];
        }
        [singleTap release];
        
        
        //imageView2
        AtIndex += 1;
        if (AtIndex >= nTotalCount) {
            [self removeTag:cell.imageView2];
            cell.imageView2.image=nil;
            cell.imageView2.userInteractionEnabled = NO;
            [self removeTag:cell.imageView3];
            cell.imageView3.userInteractionEnabled = NO;
            cell.imageView3.image=nil;
            [self removeTag:cell.imageView4];
            cell.imageView4.userInteractionEnabled = NO;
            cell.imageView4.image=nil;
            [self removeTag:cell.imageView5];
            cell.imageView5.userInteractionEnabled = NO;
            cell.imageView5.image=nil;
            [self removeTag:cell.imageView6];
            cell.imageView6.userInteractionEnabled = NO;
            cell.imageView6.image=nil;
            [self removeTag:cell.imageView7];
            cell.imageView7.userInteractionEnabled = NO;
            cell.imageView7.image=nil;
            [self removeTag:cell.imageView8];
            cell.imageView8.userInteractionEnabled = NO;
            cell.imageView8.image=nil;
            [self removeTag:cell.imageView9];
            cell.imageView9.userInteractionEnabled = NO;
            cell.imageView9.image=nil;
            return cell;
        }
        
        strPath = [picPathArray objectAtIndex:AtIndex];
        if (strPath == nil) {
            return cell;
        }
        img=[m_myImgDic objectForKey:strPath];
        //flag=[m_myImgDic objectForKey:[NSString stringWithFormat:@"flagk%@",strPath]];
        if (img==nil) {
            //[m_myImgDic setObject:[NSString stringWithFormat:@"flag%@",strPath] forKey:[NSString stringWithFormat:@"flagk%@",strPath]];
            NSDictionary *mdic=[NSDictionary dictionaryWithObjectsAndKeys:strPath,@"path",anIndexPath,@"indexpath",[NSNumber numberWithInt:2],@"num", nil];
            [NSThread detachNewThreadSelector:@selector(startLoadLocalPic:) toTarget:self withObject:mdic];
        }
        
        //image = [APICommon GetImageByNameFromImage:strDID filename:strPath];
        if (img != nil) {
            // NSLog(@"img!=nil  index=%d",AtIndex);
            cell.imageView2.image = img;
        }else{
            cell.imageView2.image=nil;
        }
        cell.imageView2.tag = AtIndex;
        
        cell.imageView2.userInteractionEnabled = YES;
        singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapHandle:)];
        singleTap.numberOfTapsRequired = 1;
        [cell.imageView2 addGestureRecognizer:singleTap];
        if (m_pSelectedStatus[AtIndex] == 1)
        {
            [self AddTag:cell.imageView2];
        }else{
            [self removeTag:cell.imageView2];
        }
        [singleTap release];
        
        //imageView3
        AtIndex += 1;
        if (AtIndex >= nTotalCount) {
            [self removeTag:cell.imageView3];
            cell.imageView3.userInteractionEnabled = NO;
            cell.imageView3.image=nil;
            
            [self removeTag:cell.imageView4];
            cell.imageView4.userInteractionEnabled = NO;
            cell.imageView4.image=nil;
            [self removeTag:cell.imageView5];
            cell.imageView5.userInteractionEnabled = NO;
            cell.imageView5.image=nil;
            [self removeTag:cell.imageView6];
            cell.imageView6.userInteractionEnabled = NO;
            cell.imageView6.image=nil;
            [self removeTag:cell.imageView7];
            cell.imageView7.userInteractionEnabled = NO;
            cell.imageView7.image=nil;
            [self removeTag:cell.imageView8];
            cell.imageView8.userInteractionEnabled = NO;
            cell.imageView8.image=nil;
            [self removeTag:cell.imageView9];
            cell.imageView9.userInteractionEnabled = NO;
            cell.imageView9.image=nil;
            return cell;
        }
        strPath = [picPathArray objectAtIndex:AtIndex];
        if (strPath == nil) {
            return cell;
        }
        img=[m_myImgDic objectForKey:strPath];
        //flag=[m_myImgDic objectForKey:[NSString stringWithFormat:@"flagk%@",strPath]];
        if (img==nil) {
            //[m_myImgDic setObject:[NSString stringWithFormat:@"flag%@",strPath] forKey:[NSString stringWithFormat:@"flagk%@",strPath]];
            NSDictionary *mdic=[NSDictionary dictionaryWithObjectsAndKeys:strPath,@"path",anIndexPath,@"indexpath",[NSNumber numberWithInt:3],@"num", nil];
            [NSThread detachNewThreadSelector:@selector(startLoadLocalPic:) toTarget:self withObject:mdic];
        }
        
        //image = [APICommon GetImageByNameFromImage:strDID filename:strPath];
        if (img != nil) {
            //NSLog(@"img!=nil  index=%d",AtIndex);
            cell.imageView3.image = img;
        }else{
            cell.imageView3.image=nil;
        }
        cell.imageView3.tag = AtIndex;
        
        cell.imageView3.userInteractionEnabled = YES;
        singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapHandle:)];
        singleTap.numberOfTapsRequired = 1;
        [cell.imageView3 addGestureRecognizer:singleTap];
        if (m_pSelectedStatus[AtIndex] == 1)
        {
            [self AddTag:cell.imageView3];
        }else{
            [self removeTag:cell.imageView3];
        }
        [singleTap release];
        
        //imageView4
        AtIndex += 1;
        if (AtIndex >= nTotalCount) {
            [self removeTag:cell.imageView4];
            cell.imageView4.userInteractionEnabled = NO;
            cell.imageView4.image=nil;
            [self removeTag:cell.imageView5];
            cell.imageView5.userInteractionEnabled = NO;
            cell.imageView5.image=nil;
            [self removeTag:cell.imageView6];
            cell.imageView6.userInteractionEnabled = NO;
            cell.imageView6.image=nil;
            [self removeTag:cell.imageView7];
            cell.imageView7.userInteractionEnabled = NO;
            cell.imageView7.image=nil;
            [self removeTag:cell.imageView8];
            cell.imageView8.userInteractionEnabled = NO;
            cell.imageView8.image=nil;
            [self removeTag:cell.imageView9];
            cell.imageView9.userInteractionEnabled = NO;
            cell.imageView9.image=nil;
            return cell;
        }
        strPath = [picPathArray objectAtIndex:AtIndex];
        if (strPath == nil) {
            return cell;
        }
        img=[m_myImgDic objectForKey:strPath];
        //flag=[m_myImgDic objectForKey:[NSString stringWithFormat:@"flagk%@",strPath]];
        if (img==nil) {
            //[m_myImgDic setObject:[NSString stringWithFormat:@"flag%@",strPath] forKey:[NSString stringWithFormat:@"flagk%@",strPath]];
            NSDictionary *mdic=[NSDictionary dictionaryWithObjectsAndKeys:strPath,@"path",anIndexPath,@"indexpath",[NSNumber numberWithInt:4],@"num", nil];
            [NSThread detachNewThreadSelector:@selector(startLoadLocalPic:) toTarget:self withObject:mdic];
        }
        
        
        if (img != nil) {
            cell.imageView4.image = img;
        }else{
            cell.imageView4.image=nil;
        }
        cell.imageView4.tag = AtIndex;
        
        cell.imageView4.userInteractionEnabled = YES;
        singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapHandle:)];
        singleTap.numberOfTapsRequired = 1;
        [cell.imageView4 addGestureRecognizer:singleTap];
        if (m_pSelectedStatus[AtIndex] == 1)
        {
            [self AddTag:cell.imageView4];
        }else{
            [self removeTag:cell.imageView4];
        }
        [singleTap release];
        
        
        
        //ImageVIew5
        AtIndex += 1;
        if (AtIndex >= nTotalCount) {
            [self removeTag:cell.imageView5];
            cell.imageView5.userInteractionEnabled = NO;
            cell.imageView5.image=nil;
            
            [self removeTag:cell.imageView6];
            cell.imageView6.userInteractionEnabled = NO;
            cell.imageView6.image=nil;
            [self removeTag:cell.imageView7];
            cell.imageView7.userInteractionEnabled = NO;
            cell.imageView7.image=nil;
            [self removeTag:cell.imageView8];
            cell.imageView8.userInteractionEnabled = NO;
            cell.imageView8.image=nil;
            [self removeTag:cell.imageView9];
            cell.imageView9.userInteractionEnabled = NO;
            cell.imageView9.image=nil;
            return cell;
        }
        strPath = [picPathArray objectAtIndex:AtIndex];
        if (strPath == nil) {
            return cell;
        }
        img=[m_myImgDic objectForKey:strPath];
        //flag=[m_myImgDic objectForKey:[NSString stringWithFormat:@"flagk%@",strPath]];
        if (img==nil) {
            // [m_myImgDic setObject:[NSString stringWithFormat:@"flag%@",strPath] forKey:[NSString stringWithFormat:@"flagk%@",strPath]];
            NSDictionary *mdic=[NSDictionary dictionaryWithObjectsAndKeys:strPath,@"path",anIndexPath,@"indexpath",[NSNumber numberWithInt:5],@"num", nil];
            [NSThread detachNewThreadSelector:@selector(startLoadLocalPic:) toTarget:self withObject:mdic];
        }
        
        
        if (img != nil) {
            cell.imageView5.image = img;
        }else{
            cell.imageView5.image=nil;
        }
        cell.imageView5.tag = AtIndex;
        
        cell.imageView5.userInteractionEnabled = YES;
        singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapHandle:)];
        singleTap.numberOfTapsRequired = 1;
        [cell.imageView5 addGestureRecognizer:singleTap];
        if (m_pSelectedStatus[AtIndex] == 1)
        {
            [self AddTag:cell.imageView5];
        }else{
            [self removeTag:cell.imageView5];
        }
        [singleTap release];
        
        
        //ImageVIew6
        AtIndex += 1;
        if (AtIndex >= nTotalCount) {
            [self removeTag:cell.imageView6];
            cell.imageView6.userInteractionEnabled = NO;
            cell.imageView6.image=nil;
            
            [self removeTag:cell.imageView7];
            cell.imageView7.userInteractionEnabled = NO;
            cell.imageView7.image=nil;
            [self removeTag:cell.imageView8];
            cell.imageView8.userInteractionEnabled = NO;
            cell.imageView8.image=nil;
            [self removeTag:cell.imageView9];
            cell.imageView9.userInteractionEnabled = NO;
            cell.imageView9.image=nil;
            return cell;
        }
        strPath = [picPathArray objectAtIndex:AtIndex];
        if (strPath == nil) {
            return cell;
        }
        img=[m_myImgDic objectForKey:strPath];
        //flag=[m_myImgDic objectForKey:[NSString stringWithFormat:@"flagk%@",strPath]];
        if (img==nil) {
            //            [m_myImgDic setObject:[NSString stringWithFormat:@"flag%@",strPath] forKey:[NSString stringWithFormat:@"flagk%@",strPath]];
            NSDictionary *mdic=[NSDictionary dictionaryWithObjectsAndKeys:strPath,@"path",anIndexPath,@"indexpath",[NSNumber numberWithInt:6],@"num", nil];
            [NSThread detachNewThreadSelector:@selector(startLoadLocalPic:) toTarget:self withObject:mdic];
        }
        
        
        if (img != nil) {
            cell.imageView6.image = img;
        }else{
            cell.imageView6.image=nil;
        }
        cell.imageView6.tag = AtIndex;
        
        cell.imageView6.userInteractionEnabled = YES;
        singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapHandle:)];
        singleTap.numberOfTapsRequired = 1;
        [cell.imageView6 addGestureRecognizer:singleTap];
        if (m_pSelectedStatus[AtIndex] == 1)
        {
            [self AddTag:cell.imageView6];
        }else{
            [self removeTag:cell.imageView6];
        }
        [singleTap release];
        
        
        //ImageVIew7
        AtIndex += 1;
        if (AtIndex >= nTotalCount) {
            [self removeTag:cell.imageView7];
            cell.imageView7.userInteractionEnabled = NO;
            cell.imageView7.image=nil;
            
            [self removeTag:cell.imageView8];
            cell.imageView8.userInteractionEnabled = NO;
            cell.imageView8.image=nil;
            [self removeTag:cell.imageView9];
            cell.imageView9.userInteractionEnabled = NO;
            cell.imageView9.image=nil;
            return cell;
        }
        strPath = [picPathArray objectAtIndex:AtIndex];
        if (strPath == nil) {
            return cell;
        }
        img=[m_myImgDic objectForKey:strPath];
        //        flag=[m_myImgDic objectForKey:[NSString stringWithFormat:@"flagk%@",strPath]];
        if (img==nil) {
            //            [m_myImgDic setObject:[NSString stringWithFormat:@"flag%@",strPath] forKey:[NSString stringWithFormat:@"flagk%@",strPath]];
            NSDictionary *mdic=[NSDictionary dictionaryWithObjectsAndKeys:strPath,@"path",anIndexPath,@"indexpath",[NSNumber numberWithInt:7],@"num", nil];
            [NSThread detachNewThreadSelector:@selector(startLoadLocalPic:) toTarget:self withObject:mdic];
        }
        
        
        if (img != nil) {
            cell.imageView7.image = img;
        }else{
            cell.imageView7.image=nil;
        }
        cell.imageView7.tag = AtIndex;
        
        cell.imageView7.userInteractionEnabled = YES;
        singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapHandle:)];
        singleTap.numberOfTapsRequired = 1;
        [cell.imageView7 addGestureRecognizer:singleTap];
        if (m_pSelectedStatus[AtIndex] == 1)
        {
            [self AddTag:cell.imageView7];
        }else{
            [self removeTag:cell.imageView7];
        }
        [singleTap release];
        
        
        
        //ImageVIew8
        AtIndex += 1;
        if (AtIndex >= nTotalCount) {
            [self removeTag:cell.imageView8];
            cell.imageView8.userInteractionEnabled = NO;
            cell.imageView8.image=nil;
            
            [self removeTag:cell.imageView9];
            cell.imageView9.userInteractionEnabled = NO;
            cell.imageView9.image=nil;
            return cell;
        }
        strPath = [picPathArray objectAtIndex:AtIndex];
        if (strPath == nil) {
            return cell;
        }
        img=[m_myImgDic objectForKey:strPath];
        //        flag=[m_myImgDic objectForKey:[NSString stringWithFormat:@"flagk%@",strPath]];
        if (img==nil) {
            //            [m_myImgDic setObject:[NSString stringWithFormat:@"flag%@",strPath] forKey:[NSString stringWithFormat:@"flagk%@",strPath]];
            NSDictionary *mdic=[NSDictionary dictionaryWithObjectsAndKeys:strPath,@"path",anIndexPath,@"indexpath",[NSNumber numberWithInt:8],@"num", nil];
            [NSThread detachNewThreadSelector:@selector(startLoadLocalPic:) toTarget:self withObject:mdic];
        }
        
        
        if (img != nil) {
            cell.imageView8.image = img;
        }else{
            cell.imageView8.image=nil;
        }
        cell.imageView8.tag = AtIndex;
        
        cell.imageView8.userInteractionEnabled = YES;
        singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapHandle:)];
        singleTap.numberOfTapsRequired = 1;
        [cell.imageView8 addGestureRecognizer:singleTap];
        if (m_pSelectedStatus[AtIndex] == 1)
        {
            [self AddTag:cell.imageView8];
        }else{
            [self removeTag:cell.imageView8];
        }
        [singleTap release];
        
        
        
        //ImageVIew9
        AtIndex += 1;
        if (AtIndex >= nTotalCount) {
            [self removeTag:cell.imageView9];
            cell.imageView9.userInteractionEnabled = NO;
            cell.imageView9.image=nil;
            return cell;
        }
        strPath = [picPathArray objectAtIndex:AtIndex];
        if (strPath == nil) {
            return cell;
        }
        img=[m_myImgDic objectForKey:strPath];
        //        flag=[m_myImgDic objectForKey:[NSString stringWithFormat:@"flagk%@",strPath]];
        if (img==nil) {
            //            [m_myImgDic setObject:[NSString stringWithFormat:@"flag%@",strPath] forKey:[NSString stringWithFormat:@"flagk%@",strPath]];
            NSDictionary *mdic=[NSDictionary dictionaryWithObjectsAndKeys:strPath,@"path",anIndexPath,@"indexpath",[NSNumber numberWithInt:9],@"num", nil];
            [NSThread detachNewThreadSelector:@selector(startLoadLocalPic:) toTarget:self withObject:mdic];
        }
        
        
        if (img != nil) {
            cell.imageView9.image = img;
        }else{
            cell.imageView9.image=nil;
        }
        cell.imageView9.tag = AtIndex;
        NSLog(@"imageView9.tag=%d",AtIndex);
        cell.imageView9.userInteractionEnabled = YES;
        singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapHandle:)];
        singleTap.numberOfTapsRequired = 1;
        [cell.imageView9 addGestureRecognizer:singleTap];
        if (m_pSelectedStatus[AtIndex] == 1)
        {
            [self AddTag:cell.imageView9];
        }else{
            [self removeTag:cell.imageView9];
        }
        [singleTap release];
        
        
        return cell;
    }
    
    
    
    // return nil;
    
}



-(void)startLoadLocalPic:(NSDictionary *)dic{
    usleep(10);
    [m_Lock lock];
    NSString *path=[dic objectForKey:@"path"];
    // NSIndexPath *indexPath=[dic objectForKey:@"indexpath"];
    UIImage *img=[APICommon GetImageByNameFromImage:strDID filename:path];
    if (img!=nil) {
        [m_myImgDic setObject:img forKey:path];
        [self performSelectorOnMainThread:@selector(refreshCellForIndexPath:) withObject:dic waitUntilDone:NO];
    }
    [m_Lock unlock];
    // NSDictionary *mdic=[NSDictionary dictionaryWithObjectsAndKeys:indexPath,@"indexpath",path,@"path", nil];
}




-(void)refreshCellForIndexPath:(NSDictionary *)dic{
    if (m_tableView==nil) {
        return;
    }
    
    NSIndexPath *indexpath=[dic objectForKey:@"indexpath"];
    NSString *path=[dic objectForKey:@"path"];
    UIImage *img=[m_myImgDic objectForKey:path];
    NSNumber *num=[dic objectForKey:@"num"];
    int position=[num intValue];
    
    if (isIphone) {
        PicListCell *cell =  (PicListCell*)[self.m_tableView cellForRowAtIndexPath:indexpath];
        switch (position) {
            case 1:
                cell.imageView1.image=img;
                break;
            case 2:
                cell.imageView2.image=img;
                break;
            case 3:
                cell.imageView3.image=img;
                break;
            case 4:
                cell.imageView4.image=img;
                break;
                
            default:
                break;
        }
    }else{
        PicListIpadCell *cell=(PicListIpadCell *)[self.m_tableView cellForRowAtIndexPath:indexpath];
        switch (position) {
            case 1:
                cell.imageView1.image=img;
                break;
            case 2:
                cell.imageView2.image=img;
                break;
            case 3:
                cell.imageView3.image=img;
                break;
            case 4:
                cell.imageView4.image=img;
                break;
            case 5:
                cell.imageView5.image=img;
                break;
            case 6:
                cell.imageView6.image=img;
                break;
            case 7:
                cell.imageView7.image=img;
                break;
            case 8:
                cell.imageView8.image=img;
                break;
            case 9:
                cell.imageView9.image=img;
                break;
            default:
                break;
        }
    }
    
    
    
}
- (CGFloat)tableView:(UITableView*)tableview heightForRowAtIndexPath:(NSIndexPath*)indexpath
{
    if (isIphone) {
        return 79;
    }
    return 83;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)anIndexPath
{
    
    
}


#pragma mark -
#pragma mark performInMainThread
-(void)initNavigationBarOnMainThread{
    [self initNavigationBar];
}
- (void)reloadTableViewData
{
    
    [self loadPicPathArray];
    
}

#pragma mark -
#pragma mark NotifyReloadData

- (void) NotifyReloadData
{
    if (NotifyReloadDataDelegate!=nil) {
        [self.NotifyReloadDataDelegate NotifyReloadData];
    }
    
    [self performSelectorOnMainThread:@selector(reloadTableViewData) withObject:nil waitUntilDone:NO];
}

#pragma mark -
#pragma mark navigationBardelegate

- (BOOL) navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    if ([picPathArray count]<=0) {
        [self.navigationController popViewControllerAnimated:YES];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
        return NO;
    }
    [self.navigationController popViewControllerAnimated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    return NO;
}


@end
