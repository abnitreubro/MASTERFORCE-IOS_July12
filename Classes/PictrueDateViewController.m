//
//  PictrueDateViewController.m
//  P2PCamera
//
//  Created by mac on 12-11-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PictrueDateViewController.h"
#import "obj_common.h"
#import "PictureListViewController.h"
#import "PicDirCell.h"
#import "APICommon.h" 
#import "AppDelegate.h"
@interface PictrueDateViewController ()

@end

@implementation PictrueDateViewController

@synthesize m_pPicPathMgt;
@synthesize strDID;
@synthesize strName;
@synthesize navigationBar;
@synthesize tableView;
@synthesize imageBkDefault;
@synthesize NotifyReloadDataDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) btnBack: (id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect mainScreen=[[UIScreen mainScreen]bounds];
    mainScreenWidth=mainScreen.size.width;
    
    picDataArray = nil;
    picDataArray = [m_pPicPathMgt GetTotalPicDataArray:strDID] ;
    
    UIImage *image = [UIImage imageNamed:@"top_bg_blue.png"];
    [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.delegate = self;
    self.navigationBar.tintColor = [UIColor colorWithRed:BTN_NORMAL_RED/255.0f green:BTN_NORMAL_GREEN/255.0f blue:BTN_NORMAL_BLUE/255.0f alpha:1];
    
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ %@",strName,NSLocalizedStringFromTable(@"Picture", @STR_LOCALIZED_FILE_NAME, nil)]];
    
    UILabel *titleLabel=[[UILabel alloc]init];
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.text=NSLocalizedStringFromTable(@"Picture", @STR_LOCALIZED_FILE_NAME, nil);
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.frame=CGRectMake(0, 0, 100, 40);
    item.titleView=titleLabel;
    [titleLabel release];
    UIButton *btnLeft=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnLeft setBackgroundImage:[UIImage imageNamed:@"btn_back_normal.png"] forState:UIControlStateNormal];
    [btnLeft setBackgroundImage:[UIImage imageNamed:@"btn_back_pressed.png"] forState:UIControlStateHighlighted];
    btnLeft.titleLabel.font=[UIFont systemFontOfSize:12];
    [btnLeft setTitle:NSLocalizedStringFromTable(@"Back", @STR_LOCALIZED_FILE_NAME, nil) forState:UIControlStateNormal];
    btnLeft.frame=CGRectMake(0,0,60,30);
    [btnLeft addTarget:self action:@selector(btnBack:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIBarButtonItem *leftButton=[[UIBarButtonItem alloc]initWithCustomView:btnLeft];
    item.leftBarButtonItem=leftButton;
    
    NSArray *array = [NSArray arrayWithObjects: item, nil];
    [self.navigationBar setItems:array];
    
    [item release];
    [leftButton release];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.imageBkDefault = [UIImage imageNamed:@"picbk.png"];
    
    
    if ([AppDelegate isIOS7Version]) {
        NSLog(@"is ios7");
        self.wantsFullScreenLayout = YES;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
        CGRect navigationBarFrame = self.navigationBar.frame;
        navigationBarFrame.origin.y += 20;
        self.navigationBar.frame = navigationBarFrame;
        [self.view bringSubviewToFront:self.navigationBar];
        
        CGRect tableFrm=tableView.frame;
        tableFrm.origin.y+=20;
        tableView.frame=tableFrm;
        self.view.backgroundColor=[UIColor blackColor];
    }else{
        NSLog(@"less ios7");
        
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) dealloc
{
    self.m_pPicPathMgt = nil;
    self.strDID = nil;
    self.navigationBar = nil;
    self.strName = nil;
    self.tableView = nil;
    self.imageBkDefault = nil;
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
    
    if (picDataArray == nil) {
        return 0;
    }
    
    return [picDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)anIndexPath
{
    //NSLog(@"cellForRowAtIndexPath");  
    
    NSDictionary *datePicDic = [picDataArray objectAtIndex:anIndexPath.row];
    NSString *strDate = [[datePicDic allKeys] objectAtIndex:0];
    
    NSString *cellIdentifier = @"PictureDateListCell";       
    //当状态为显示当前的设备列表信息时
    PicDirCell *cell =  (PicDirCell*)[aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PicDirCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    int nPicCount = [m_pPicPathMgt GetTotalNumByIDAndDate:strDID Date:strDate];
    NSString *strShowName = [NSString stringWithFormat:@"%@(%d)", strDate, nPicCount];
    
    NSString *strPath = [m_pPicPathMgt GetFirstPathByIDAndDate:strDID Date:strDate];
    UIImage *image = [APICommon GetImageByNameFromImage:strDID filename:strPath];
    
    cell.labelName.text = strShowName;
    cell.labelName.text = strShowName;
    
    if (image != nil) {
        cell.imageView.image = image;
    }else {
        cell.imageView.image = imageBkDefault;
    }
    
    float cellHeight = cell.frame.size.height;
    float cellWidth = cell.frame.size.width;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.origin.x, cellHeight - 2, mainScreenWidth, 1)];
    label.backgroundColor = [UIColor colorWithRed:CELL_SEPERATOR_RED/255.0f green:CELL_SEPERATOR_GREEN/255.0f blue:CELL_SEPERATOR_BLUE/255.0f alpha:1.0];
    
    UIView *cellBgView = [[UIView alloc] initWithFrame:cell.frame];
    [cellBgView addSubview:label];
    [label release];
    
    cell.backgroundView = cellBgView;
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView*)tableview heightForRowAtIndexPath:(NSIndexPath*)indexpath
{
    return 60;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)anIndexPath
{    
    [aTableView deselectRowAtIndexPath:anIndexPath animated:YES];
    
    NSDictionary *datePicDic = [picDataArray objectAtIndex:anIndexPath.row];
    NSString *strDate = [[datePicDic allKeys] objectAtIndex:0];
    
    PictureListViewController *picListViewController = [[PictureListViewController alloc] init];
    picListViewController.strDID = strDID;
    picListViewController.strDate = strDate;
    picListViewController.m_pPicPathMgt = m_pPicPathMgt;
    picListViewController.NotifyReloadDataDelegate=self;
    [self.navigationController pushViewController:picListViewController animated:YES];
    [picListViewController release];
}



#pragma mark-
#pragma mark perfortInMainThread
-(void)reloadTableViewData{
    [self.tableView reloadData];
}


#pragma mark-
#pragma mark NotifyReloadData
-(void)NotifyReloadData{
    if(self.NotifyReloadDataDelegate!=nil){
        [self.NotifyReloadDataDelegate NotifyReloadData];
    }
    
    picDataArray = [m_pPicPathMgt GetTotalPicDataArray:strDID] ;
   
    [self performSelectorOnMainThread:@selector(reloadTableViewData) withObject:nil waitUntilDone:NO];
}

#pragma mark -
#pragma mark uinavigationbardelegate

- (BOOL) navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    [self.navigationController popViewControllerAnimated:YES];

    return NO;
}

@end
