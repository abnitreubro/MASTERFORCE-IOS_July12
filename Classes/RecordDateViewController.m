//
//  RecordDateViewController.m
//  P2PCamera
//
//  Created by mac on 12-11-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RecordDateViewController.h"
#import "obj_common.h"
#import "RecordListViewController.h"
#import "PicDirCell.h"
#import "defineutility.h"
#import "APICommon.h"
#import "AppDelegate.h"
@interface RecordDateViewController ()

@end

@implementation RecordDateViewController

@synthesize m_pRecPathMgt;
@synthesize strDID;
@synthesize strName;
@synthesize navigationBar;
@synthesize imagePlay;
@synthesize imageDefault;
@synthesize tableView;
@synthesize RecReloadDelegate;

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
    
    //NSLog(@"RecordDateViewController viewDidLoad....");
    recDataArray = nil;
    recDataArray = [m_pRecPathMgt GetTotalDataArray:strDID] ;
    CGRect mainScreen=[[UIScreen mainScreen]bounds];
    mainScreenWidth=mainScreen.size.width;
    
    UIImage *image = [UIImage imageNamed:@"top_bg_blue.png"];
    [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.delegate = self;
    self.navigationBar.tintColor = [UIColor colorWithRed:BTN_NORMAL_RED/255.0f green:BTN_NORMAL_GREEN/255.0f blue:BTN_NORMAL_BLUE/255.0f alpha:1];
    
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:strName];
    UILabel *titleLabel=[[UILabel alloc]init];
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.text=NSLocalizedStringFromTable(@"Record", @STR_LOCALIZED_FILE_NAME, nil);
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
    
    self.imagePlay = [UIImage imageNamed:@"play_video.png"];
    self.imageDefault = [UIImage imageNamed:@"videobk.png"];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
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
    self.m_pRecPathMgt = nil;
    self.strDID = nil;
    self.navigationBar = nil;
    self.strName = nil;
    self.imagePlay = nil;
    self.imageDefault = nil;
    self.tableView = nil;
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
    //NSLog(@"numberOfRowsInSection11111");
    
    if (recDataArray == nil) {
        return 0;
    }
    
    return [recDataArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)anIndexPath
{
    //NSLog(@"cellForRowAtIndexPath11111");  
    
    NSDictionary *datePicDic = [recDataArray objectAtIndex:anIndexPath.row];
    NSString *strDate = [[datePicDic allKeys] objectAtIndex:0];
    
    NSString *cellIdentifier = @"RecordDateListCell";       
    //当状态为显示当前的设备列表信息时
    PicDirCell *cell =  (PicDirCell*)[aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PicDirCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    cell.labelName.text = [NSString stringWithFormat:@"%@(%d)", strDate, [m_pRecPathMgt GetTotalNumByIDAndDate:strDID Date:strDate]];
    
    NSString *strFileName = [m_pRecPathMgt GetFirstPathByIDAndDate:strDID Date:strDate];
    UIImage *image = [APICommon GetImageByName:strDID filename:strFileName];
    if (image != nil) {
        cell.imageView.image = image;
        //play image
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
        cell.imageView.image = self.imageDefault;
    }
    
    float cellHeight = cell.frame.size.height;
    float cellWidth = cell.frame.size.width;
    
    //NSLog(@"dddd cellHeight: %f, cellWidth: %f", cellHeight, cellWidth);
    
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
    
    NSDictionary *datePicDic = [recDataArray objectAtIndex:anIndexPath.row];
    NSString *strDate = [[datePicDic allKeys] objectAtIndex:0];
    
    RecordListViewController *recListViewController = [[RecordListViewController alloc] init];
    recListViewController.strDID = strDID;
    recListViewController.strDate = strDate;
    recListViewController.m_pRecPathMgt = m_pRecPathMgt;
    recListViewController.RecReloadDelegate = self;
    [self.navigationController pushViewController:recListViewController animated:YES];
    [recListViewController release];
    
}

#pragma mark -
#pragma mark uinavigationbardelegate

- (BOOL) navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    [self.navigationController popViewControllerAnimated:YES];
    
    return NO;
}

#pragma mark -
#pragma mark performOnMainThread
- (void) ReloadTableViewData
{
    [self.tableView reloadData];
    [RecReloadDelegate NotifyReloadData];
}


#pragma mark -
#pragma mark NotifyReloadDelegate

- (void) NotifyReloadData
{
    [self performSelectorOnMainThread:@selector(ReloadTableViewData) withObject:nil waitUntilDone:NO];
}

@end
