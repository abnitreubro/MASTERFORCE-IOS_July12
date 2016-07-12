//
//  CameraListingViewController.m
//  VideoScope
//
//  Created by JS Products on 04/03/16.
//  Copyright © 2016  JS Products. All rights reserved.
//

#import "CameraListingViewController.h"
#import "AppDelegate.h"
#import "Constant.h"
#import "CameraPreviewViewController.h"
@interface CameraListingViewController (){
    
    NSMutableArray *H_allValueInDataBase;
    
}

@end

@implementation CameraListingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tabBarController.tabBar setTintColor:[UIColor colorWithRed:0.2968 green:0.84765625 blue:0.390625 alpha:1]];

}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CameraList" forIndexPath:indexPath];
    // Settng Two Static Camera name and Image for same
    if (indexPath.row==0)
    {
        cell.cameraName.text= @"MX1020 Masterforce Wi-Fi Inspection Camera/Video";
        cell.cameraImage.image = [UIImage imageNamed:@"MX1020-200"];
    }
    else
    {
        cell.cameraName.text=@"MX1021 Masterforce Wi-Fi Inspection Camera/Video";
        cell.cameraImage.image = [UIImage imageNamed:@"MX1021-200"];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row==1)
    {
        // Setting stream URL for IP Camera
        
        CameraPreviewViewController *cameraPreviewViewController = [[AppDelegate instance].appStoryboard instantiateViewControllerWithIdentifier:@"CameraPreviewViewController"];
        cameraPreviewViewController.hidesBottomBarWhenPushed=YES;
        cameraPreviewViewController.cameraName=@"Steelman PRO Video Scope";
        cameraPreviewViewController.cameraURL=@"http://192.168.1.1:8080/?action=stream";
        cameraPreviewViewController.folderName=[[NSUserDefaults standardUserDefaults]objectForKey:@"folderName1"];
        [self.navigationController pushViewController:cameraPreviewViewController animated:YES];
    }
    else  // Implemented as per the OLD code.
    {
        
        // P2P Camera settingon selection
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        
        PlayViewController *playViewController = appDelegate.playViewController;
        
        playViewController.m_pPPPPChannelMgt = appDelegate.m_pPPPPChannelMgt;
        playViewController.strDID = @"OBJ-002864-STBZD";//OBJ-002864-STBZD/OBJ-003816-JVTGK
        playViewController.strUser=@"admin";
        playViewController.strPwd=@"";
        playViewController.cameraName = @"";
        playViewController.m_nP2PMode =1;// [nPPPPMode intValue];
        
        playViewController.m_pPicPathMgt = appDelegate.m_pPicPathMgt;
        playViewController.m_pRecPathMgt = appDelegate.m_pRecPathMgt;
        playViewController.PicNotifyDelegate = appDelegate.picViewController;
        playViewController.RecNotifyDelegate = appDelegate.recViewController;
        
        playViewController.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:playViewController animated:YES];
    }
}






-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return 130;
    else
        return 100;
}

@end
