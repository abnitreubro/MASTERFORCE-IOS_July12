//
//  MyDocumentView.m
//  P2PCamera
//
//  Created by Tsang on 13-8-13.
//
//

#import "MyDocumentView.h"
#import "PicDirCell.h"
#import "obj_common.h"
#import "APICommon.h"
#import "AppDelegate.h"
#import "RecordDateViewController.h"
#import "PictrueDateViewController.h"
@interface MyDocumentView ()

@end

@implementation MyDocumentView

@synthesize mTableView;
@synthesize navigationBar;
@synthesize m_pCameraListMgt;
@synthesize m_pPicPathMgt;
@synthesize m_pRecPathMgt;
@synthesize m_pPPPPChannelMgt;
@synthesize strDID;
@synthesize strPwd;
@synthesize strUser;
#pragma mark UIViewController System Method
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    navigationBar=nil;
    mTableView=nil;
    strDID=nil;
    strUser=nil;
    strPwd=nil;
    if (m_pRecPathMgt!=nil) {
        [m_pRecPathMgt release];
        m_pRecPathMgt=nil;
    }
    if (m_pPicPathMgt!=nil) {
        [m_pPicPathMgt release];
        m_pPicPathMgt=nil;
    }
    [super dealloc];
}

- (void) btnBack: (id) sender
{
    [self playPPPView];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    m_pPicPathMgt = [[PicPathManagement alloc] init];
    m_pRecPathMgt = [[RecPathManagement alloc] init];
    
    mTableView.delegate=self;
    mTableView.dataSource=self;
    
    
    UIImage *image = [UIImage imageNamed:@"top_bg_blue.png"];
    
    if (![AppDelegate is43Version]) {
        [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    //self.navigationBar.delegate = self;
    self.navigationBar.tintColor = [UIColor colorWithRed:BTN_NORMAL_RED/255.0f green:BTN_NORMAL_GREEN/255.0f blue:BTN_NORMAL_BLUE/255.0f alpha:1];
    
    if ([AppDelegate isIOS7Version]) {
        NSLog(@"is ios7");
        self.wantsFullScreenLayout = YES;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
        CGRect navigationBarFrame = self.navigationBar.frame;
        navigationBarFrame.origin.y += 20;
        self.navigationBar.frame = navigationBarFrame;
        [self.view bringSubviewToFront:self.navigationBar];
        
        CGRect tableFrm=mTableView.frame;
        tableFrm.origin.y+=20;
        mTableView.frame=tableFrm;
        self.view.backgroundColor=[UIColor blackColor];
    }else{
        NSLog(@"less ios7");
        
    }
    
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:NSLocalizedStringFromTable(@"runcar_mode_uplate", @STR_LOCALIZED_FILE_NAME, nil)];
    UILabel *titleLabel=[[UILabel alloc]init];
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.text=NSLocalizedStringFromTable(@"runcar_mode_uplate", @STR_LOCALIZED_FILE_NAME, nil);
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.frame=CGRectMake(0, 0, 100, 40);
    item.titleView=titleLabel;
    [titleLabel release];
    UIButton *btnLeft=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnLeft setBackgroundImage:[UIImage imageNamed:@"btn_back_normal.png"] forState:UIControlStateNormal];
    [btnLeft setBackgroundImage:[UIImage imageNamed:@"btn_back_pressed.png"] forState:UIControlStateHighlighted];
    btnLeft.titleLabel.font=[UIFont systemFontOfSize:12];
    [btnLeft setTitle:NSLocalizedStringFromTable(@"runcar_mode_preview", @STR_LOCALIZED_FILE_NAME, nil) forState:UIControlStateNormal];
    btnLeft.frame=CGRectMake(0,0,60,30);
    [btnLeft addTarget:self action:@selector(btnBack:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIBarButtonItem *leftButton=[[UIBarButtonItem alloc]initWithCustomView:btnLeft];
    item.leftBarButtonItem=leftButton;
    NSArray *array = [NSArray arrayWithObjects:item, nil];
    [self.navigationBar setItems:array];
    [leftButton release];
    [item release];
    //defaultImg=[UIImage imageNamed:@"folder.png"];
    
    
    
    
}



#pragma mark UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}
- (CGFloat)tableView:(UITableView*)tableview heightForRowAtIndexPath:(NSIndexPath*)indexpath
{
    return 60;
}
-(UITableViewCell*)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)anIndexPath{
    NSInteger index = anIndexPath.row ;
    
    NSString *cellIdentifier = @"CameraPictureListCell";
    PicDirCell *cell =  (PicDirCell*)[aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PicDirCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (index) {
        case 0://picture
        {
            int nPicCount = [m_pPicPathMgt GetTotalNumByID:strDID];
            NSString *strShowName = [NSString stringWithFormat:@"%@(%d)", NSLocalizedStringFromTable(@"LocalPic", @STR_LOCALIZED_FILE_NAME, nil),nPicCount];
            
            cell.labelName.text = strShowName;
            cell.imageView.image = [UIImage imageNamed:@"folder_picture.png"];
           
        }
            break;
        case 1://record
        {
            cell.labelName.text = [NSString stringWithFormat:@"%@(%d)", NSLocalizedStringFromTable(@"Record", @STR_LOCALIZED_FILE_NAME, nil), [m_pRecPathMgt GetTotalNumByID:strDID]];
            cell.imageView.image = [UIImage imageNamed:@"folder_video.png"];

        }
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            PictrueDateViewController *pictureDateViewController = [[PictrueDateViewController alloc] init];
            pictureDateViewController.strName = @"";
            pictureDateViewController.strDID = strDID;
            pictureDateViewController.NotifyReloadDataDelegate=self;
            pictureDateViewController.m_pPicPathMgt = m_pPicPathMgt;
            [self.navigationController pushViewController:pictureDateViewController animated:YES];
            [pictureDateViewController release];
        }
            break;
        case 1:
        {
            RecordDateViewController *recDateViewController = [[RecordDateViewController alloc] init];
            recDateViewController.strName = @"";
            recDateViewController.strDID = strDID;
            recDateViewController.m_pRecPathMgt = m_pRecPathMgt;
            recDateViewController.RecReloadDelegate = self;
            [self.navigationController pushViewController:recDateViewController animated:YES];
            [recDateViewController release];
        }
            break;
        default:
            break;
    }
}

#pragma  mark NavigationBarDelegate
-(BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item{

    [self playPPPView];
    return NO;
    
}
#pragma mark Back Preview
-(void)playPPPView{
    AppDelegate *ipClientAppDlg=[[UIApplication sharedApplication]delegate];
    PlayViewController *playViewController = [[PlayViewController alloc] init];
    playViewController.m_pPPPPChannelMgt=m_pPPPPChannelMgt;
    playViewController.strDID = strDID;
    playViewController.strUser=strUser;
    playViewController.strPwd=strPwd;
    
    playViewController.cameraName = @"";
    playViewController.m_nP2PMode = 1;
    [ipClientAppDlg switchPlayView:playViewController];
    [playViewController release];
    
}
-(void)reloadTableView{
    [mTableView reloadData];
}
#pragma mark NotifyEventDelegate
- (void) NotifyReloadData{
    [self reloadTableView];
}
@end
