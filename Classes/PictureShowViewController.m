

#import "PictureShowViewController.h"
#import "obj_common.h"
#import "CustomToast.h"
#import "AppDelegate.h"
@interface PictureShowViewController ()

@end

@implementation PictureShowViewController

@synthesize strDID;
@synthesize picPathArray;
@synthesize m_currPic;
@synthesize strDate;
@synthesize m_pPicPathMgt;
@synthesize NotifyReloadDataDelegate;
@synthesize item;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) image: (UIImage*)image didFinishSavingWithError: (NSError*) error contextInfo: (void*)contextInfo
{
    //NSLog(@"save result");
    
    if (error != nil) {
        //show error message
        NSLog(@"take picture failed");
    }else {
        //show message image successfully saved
        //NSLog(@"save success");
        [CustomToast showWithText:NSLocalizedStringFromTable(@"SavePictureSuccess", @STR_LOCALIZED_FILE_NAME, nil)
                        superView:self.view
                        bLandScap:NO];
    }
    
}

- (void) btnAction: (id) sender
{
    NSLog(@"btnAction...9999");
    int count=[picPathArray count];
    if (m_currPic>=count||count<=0) {
        return;
    }
    UIImage *image = [self GetImageByName:strDID filename:[picPathArray objectAtIndex:m_currPic]];
    if (image == nil) {
        
        return;
    }
    
    
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
}

- (void) btnDelete: (id) sender
{
    int count=[picPathArray count];
    if (count<=0) {
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Message", @STR_LOCALIZED_FILE_NAME, nil) message:NSLocalizedStringFromTable(@"DeletePicture", @STR_LOCALIZED_FILE_NAME, nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @STR_LOCALIZED_FILE_NAME, nil) otherButtonTitles:NSLocalizedStringFromTable(@"OK", @STR_LOCALIZED_FILE_NAME, nil), nil];
    
    
    [alert show];
    [alert release];
    
    
    
}

-(void) btnPreviousPage{
    [cycleScrollView previousPage];
}
-(void) btnNextPage{
    [cycleScrollView nextPage];
}
- (void) btnBack: (id) sender
{
    if ([picPathArray count]<=0) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
   
    
    self.wantsFullScreenLayout = YES;
    CGRect mainScreen=[[UIScreen mainScreen]bounds];
    CGRect viewFrame = self.view.frame;
    viewFrame.size.height += 20;
    self.view.frame = viewFrame;
    
    cycleScrollView = [[XLCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, mainScreen.size.width, mainScreen.size.height)];
       cycleScrollView.currentPage = m_currPic;
       cycleScrollView.delegate = self;
        cycleScrollView.datasource = self;
       [self.view addSubview:cycleScrollView];
    
    
    
    navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, mainScreen.size.width, 44)];
        navigationBar.barStyle = UIBarStyleBlackTranslucent;
       navigationBar.delegate = self;
    
        UINavigationItem *back = [[UINavigationItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Back", @STR_LOCALIZED_FILE_NAME, nil)];
    
         item = [[UINavigationItem alloc] initWithTitle:[NSString stringWithFormat:@"%d of %d",m_currPic+1,[picPathArray count]]];
    
        NSArray *array = [NSArray arrayWithObjects:back, item, nil];
        [navigationBar setItems:array];
        
       [back release];
    
       [self.view addSubview:navigationBar];

    //UIImage *image = [UIImage imageNamed:@"top_bg_blue.png"];
    toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,  mainScreen.size.height - 65, mainScreen.size.width, 49)];
    toolBar.barStyle = UIBarStyleBlackTranslucent;
//    if (![IpCameraClientAppDelegate is43Version]) {
//        [toolBar setBackgroundImage:image forToolbarPosition:0 barMetrics:UIBarMetricsDefault];
//    }
    
   // toolBar.tintColor=[UIColor colorWithRed:235/255.0f green:202/255.0f blue:86/255.0f alpha:1];
    
    
    
    //UIBarButtonItem *ActionItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(btnAction:)];
    
    UIBarButtonItem *ActionItem=[[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(btnAction:)];
    [ActionItem setBackgroundImage:[UIImage imageNamed:@"action.png"] forState:UIControlStateNormal barMetrics:nil];
    
    
    UIBarButtonItem *FlexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *previousItem=[[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(btnPreviousPage)];
    [previousItem setBackgroundImage:[UIImage imageNamed:@"previous.png"] forState:UIControlStateNormal barMetrics:nil];
    
    UIBarButtonItem *nextItem=[[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(btnNextPage)];
    [nextItem setBackgroundImage:[UIImage imageNamed:@"next.png"] forState:UIControlStateNormal barMetrics:nil];
    
    //UIBarButtonItem *DeleteItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(btnDelete:)];
    UIBarButtonItem *DeleteItem=[[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(btnDelete:)];
    [DeleteItem setBackgroundImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal barMetrics:nil];
    
    NSArray *toolBarItems = [[NSArray alloc] initWithObjects:ActionItem, FlexItem,previousItem,FlexItem, nextItem,FlexItem,DeleteItem, nil];
    
    [toolBar setItems:toolBarItems animated:YES];
    
    [self.view addSubview:toolBar];
    [ActionItem release];
    [FlexItem release];
    [DeleteItem release];
    [toolBarItems release];
    [previousItem release];
    [nextItem release];
    //self.view.backgroundColor=[UIColor whiteColor];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) dealloc
{
    self.strDID = nil;
    self.picPathArray = nil;
    self.m_currPic = nil;
    if (navigationBar != nil) {
        [navigationBar release];
        navigationBar = nil;
    }
    if (toolBar != nil) {
        [toolBar release];
        toolBar = nil;
    }
    self.strDate = nil;
    self.m_pPicPathMgt = nil;
    if (cycleScrollView != nil) {
        [cycleScrollView release];
        cycleScrollView = nil;
    }
    self.NotifyReloadDataDelegate = nil;
    [item release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIImage*) GetImageByName: (NSString*)did filename:(NSString*)filename
{
    //参数NSDocumentDirectory要获取那种路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];//去处需要的路径
    
    NSString *strPath = [documentsDirectory stringByAppendingPathComponent:did];
    strPath = [strPath stringByAppendingPathComponent:filename];
    //NSLog(@"strPath: %@", strPath);
    
    UIImage *image = [UIImage imageWithContentsOfFile:strPath];
    
    return image;
}

- (UIImageView*) GetImageViewRectByImage: (UIImage*) image
{
    if (image == nil) {
        return nil;
    }
    
    //NSLog(@"GetImageViewRectByImageSize  width: %d, height: %d", width, height);
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    //NSLog(@"width %f, height: %f", screenRect.size.width, screenRect.size.height);
    
    CGRect imageViewFrame;
    float imageWidth = image.size.width;
    float imageHeight = image.size.height;
    
    // NSLog(@"imageWidth: %f, imageHeight: %f", imageWidth, imageHeight);
    
    float screenWidth = screenRect.size.width;
    float screenHeight = screenRect.size.height;
    
    // NSLog(@"screenWidth: %f, screenHeight: %f", screenWidth, screenHeight);
    
    float imageScreenWidth = 0;
    float imageScreenHeight = screenWidth * imageHeight / imageWidth ;
    if (imageScreenHeight > screenHeight) {
        imageScreenHeight = screenHeight;
        imageScreenWidth = imageWidth * screenHeight / imageHeight ;
    }else {
        imageScreenWidth = screenWidth;
    }
    
    // NSLog(@"imageScreenWidth: %f, imageScreenHeight: %f", imageScreenWidth, imageScreenHeight);
    
    float centerX = screenWidth / 2;
    float centerY = screenHeight / 2;
    
    imageViewFrame.origin.x = centerX - imageScreenWidth / 2;
    imageViewFrame.origin.y = centerY - imageScreenHeight / 2;
    imageViewFrame.size.width = imageScreenWidth;
    imageViewFrame.size.height = imageScreenHeight;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
    imageView.image = image;
    [imageView autorelease];
    
    return imageView;
}

#pragma mark -
#pragma mark XLCycleScrollViewDelegate

- (NSInteger)numberOfPages
{
    return [picPathArray count];
}

- (UILabel*) newLable
{
    return [[[UILabel alloc] init] autorelease];
}

//不能返回nil
- (UIView *)pageAtIndex:(NSInteger)index
{
    if (index >= [picPathArray count]) {
        return [self newLable];
    }
    
    UIImage *image = [self GetImageByName:strDID filename:[picPathArray objectAtIndex:index]];
    
    UIImageView * imageView = [self GetImageViewRectByImage:image];
    if (imageView == nil) {
        return [self newLable];
    }
    
    return imageView;
}

- (void)didClickPage:(XLCycleScrollView *)csView atIndex:(NSInteger)index
{
    
    if(navigationBar.isHidden)
    {
        [navigationBar setHidden:NO];
        [toolBar setHidden:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    else {
        [navigationBar setHidden:YES];
        [toolBar setHidden:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
}

- (void) currentPage:(NSInteger)index
{
    if (index<0||index>[picPathArray count]) {
        return;
    }
    if ([picPathArray count]==0) {
        index-=1;
    }
    item.title=[NSString stringWithFormat:@"%d of %d",index+1,[picPathArray count]];
    
    m_currPic = index;
    NSLog(@"m_currPic=%d",m_currPic);
    //NSLog(@"m_currPic: %d", m_currPic);
}

#pragma mark -
#pragma mark AlertViewDelete

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    ///NSLog(@"buttonIndex: %d", buttonIndex);
    
    if (buttonIndex == 1) {
        if(m_currPic >= [picPathArray count])
            return ;
        
        NSString *fileName = [picPathArray objectAtIndex:m_currPic];
        if (fileName == nil) {
            return ;
        }
        if([m_pPicPathMgt RemovePicPath:strDID PicDate:strDate PicPath:fileName]){
            [NotifyReloadDataDelegate NotifyReloadData];
            [picPathArray removeObjectAtIndex:m_currPic];
            
            [cycleScrollView delLoadData];
            //[cycleScrollView nextPage];
        }
    }
    
}

#pragma mark -
#pragma mark navigationBardelegate

- (BOOL) navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    if ([picPathArray count]<=0) {
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    }
    [self.navigationController popViewControllerAnimated:YES];
    
    return NO;
}

@end

