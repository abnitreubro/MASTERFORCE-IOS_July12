//
//  FileListingViewController.m
//  VideoScope
//
//  Created by JS Products on 04/03/16.
//  Copyright © 2016  JS Products. All rights reserved.
//

#import "FileListingViewController.h"
#import "AppDelegate.h"
#import "DisplayFileListViewController.h"


@interface FileListingViewController (){
    
    NSMutableArray *H_allValueInDataBase;
}

@end

@implementation FileListingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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
    ListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileList" forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return 130;
    else
        return 100;
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    DisplayFileListViewController *displayFileListViewController=segue.destinationViewController;
    displayFileListViewController.hidesBottomBarWhenPushed=YES;
        
    if (self.tableView.indexPathForSelectedRow.row == 0)
        displayFileListViewController.isP2P = YES;

    else
        displayFileListViewController.isP2P = NO;
    
}


@end
