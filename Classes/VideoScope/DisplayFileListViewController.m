//
//  DisplayFileListViewController.m
//  VideoScope
//
//  Created by JS Products on 15/03/16.
//  Copyright © 2016  JS Products. All rights reserved.
//

#import "DisplayFileListViewController.h"

@interface DisplayFileListViewController (){
    
    
    NSMutableArray *allContentInFolder;
    UIBarButtonItem*deleteBtn;
    UIBarButtonItem *editButton;
    UIBarButtonItem *doneButton;
    
    BOOL isEditing;
    
    NSMutableArray * arrayTodelete,*indexArrayTodelete, * datesArray;
    
    // for collection View animations
    NSTimer * collectionTimer;
    NSMutableArray * newArray,*animatedIndexPaths,*thumbnailToDelete;
    int counter; // Counter for contents in file
    
    
    // Storing the thumbnails
    NSMutableArray * storeThumbnails, * indexStore;
}

@end



@implementation DisplayFileListViewController

@synthesize isP2P;

static NSString * const reuseIdentifier = @"FileList";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editDoneButonAction:)] ;
    self.navigationItem.rightBarButtonItems = @[editButton];
    
    newArray = [[NSMutableArray alloc] init];
    animatedIndexPaths = [[NSMutableArray alloc] init];
    indexStore = [[NSMutableArray alloc] init];
    storeThumbnails = [[NSMutableArray alloc] init];
    
    // Setting Static Title for Both Camera in List
    
    if (isP2P)
    {
        self.title = @"MX1020 Masterforce Wi-Fi Inspection Camera/Video";
        picPathArray = [[NSMutableArray alloc] init];
        [self loadP2PCameraData];
    }
    else
    {
        self.title = @"MX1021 Masterforce Wi-Fi Inspection Camera/Video";
        [self loadIPCameraData];
    }
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}






#pragma mark- UIBarButtonItem Edit/Delete button Action

-(void)editDoneButonAction:(id)sender{
    
    if (isEditing) {
        
        editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editDoneButonAction:)] ;
        
        self.navigationItem.rightBarButtonItems = @[editButton];
        
        isEditing=NO;
        [arrayTodelete removeAllObjects];
        [thumbnailToDelete removeAllObjects];
        [indexArrayTodelete removeAllObjects];
        [self makeAllViewEditable:NO];
    }
    
    else{
        
        doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editDoneButonAction:)] ;
        
        deleteBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteButonAction:)] ;
        deleteBtn.enabled=NO;
        self.navigationItem.rightBarButtonItems = @[doneButton,deleteBtn];
        isEditing=YES;
        [self makeAllViewEditable:YES];
    }
}








-(void)deleteButonAction:(id)sender{
    
    UIActionSheet *actionSheet= [[UIActionSheet alloc]initWithTitle:@"Are you sure to delete?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Confirm" otherButtonTitles:nil, nil];
    
    [actionSheet showInView:self.view];
    
}






-(void)makeAllViewEditable:(BOOL)editable{
    
    NSUInteger count;
    if (editable) {
        if (isP2P)
            count = picPathArray.count;
        else
            count = allContentInFolder.count;
        
        for (int j=0; j<count; j++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:0];
            DisplayFileListCollectionViewCell *cell=[self.FileListCollectionView cellForItemAtIndexPath:indexPath];
            
            cell.ButtonSelected.hidden=NO;
            cell.ButtonSelected.image=[UIImage imageNamed:@"disSelect.png"];
            
        }
    }
    else{
        
        if (isP2P)
            count = picPathArray.count;
        else
            count = allContentInFolder.count;
        
        for (int j=0; j<count; j++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:0];
            DisplayFileListCollectionViewCell *cell=[self.FileListCollectionView cellForItemAtIndexPath:indexPath];
            
            cell.ButtonSelected.hidden=YES;
            cell.ButtonSelected.image=[UIImage imageNamed:@"disSelect.png"];
            
        }
    }
}






# pragma mark - take data from documents directory for the IP camera

-(void)loadIPCameraData
{
    NSError*error=nil;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"imageFolder1"]]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])//Check
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Will Create folder
    
    allContentInFolder=[[NSMutableArray alloc]init];
    arrayTodelete=[[NSMutableArray alloc]init];
    thumbnailToDelete = [NSMutableArray new];
    indexArrayTodelete=[[NSMutableArray alloc]init];
    
    [allContentInFolder addObjectsFromArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPath error:NULL]];
    
    NSLog(@"All Content in Selectted foleder is %@",allContentInFolder);
    
    if (allContentInFolder.count > 0)
    {
        [editButton setEnabled:YES];
        
        newArray = [[NSMutableArray alloc] init];
        animatedIndexPaths = [[NSMutableArray alloc] init];
        
        counter= 0;
        
        collectionTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(performCollectionUpdates) userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:counter],@"count", nil] repeats:YES];
        
    }
    else
        [editButton setEnabled:NO];
    
}






# pragma mark - take data from documents directory for the P2P camera
-(void)loadP2PCameraData{
    
    /////// From the Wifi videoscope - old code
    
    indexArrayTodelete=[[NSMutableArray alloc]init];
    datesArray = [[NSMutableArray alloc] init];
    arrayTodelete=[[NSMutableArray alloc]init];
    thumbnailToDelete = [NSMutableArray new];
    
    
    //[progressView removeFromSuperview];
    if (picPathArray!=nil) {
        [picPathArray removeAllObjects];
        
        m_pPicPathMgt = [[PicPathManagement alloc] init];
        
        NSMutableArray *tempArray= [m_pPicPathMgt GetTotalPathArray:@"" date:@""];
        
        
        picPathArray = [[NSMutableArray alloc] init];
        
        for(NSDictionary *idDic in tempArray)
        {
            NSMutableArray * dateArray = [idDic objectForKey:@"OBJ-002864-STBZD"];
            
            if (dateArray != nil) {
                
                for (NSDictionary *dateDic in dateArray)
                {
                    
                    for (NSArray * key in dateDic) {
                        
                        NSLog(@" the count is %lu",[[dateDic objectForKey:key] count]);
                        
                        
                        for (int j =0 ; j < [[dateDic objectForKey:key] count]; j++) {
                            
                            [picPathArray addObject:[[dateDic objectForKey:key] objectAtIndex:j]];
                            [datesArray addObject:key];
                            NSLog(@"the array is: %@", picPathArray);
                            NSLog(@" the Value is %@",[[dateDic objectForKey:key] objectAtIndex:j]);
                        }
                    }
                }
            }
        }
    }
    
    
    /// Check and select the videos
    
    m_pRecPathMgt  = [[RecPathManagement alloc] init];
    
    NSMutableArray *tempArray= [m_pRecPathMgt GetTotalPathArray:@"" date:@""];
    
    if (tempArray.count >0)
    {
        if (picPathArray == nil)
        {
            [picPathArray removeAllObjects];
            picPathArray = [[NSMutableArray alloc] init];
        }
        if (picPathArray!=nil)
        {
            for(NSDictionary *idDic in tempArray)
            {
                NSMutableArray * dateArray = [idDic objectForKey:@"OBJ-002864-STBZD"];
                
                if (dateArray != nil) {
                    
                    for (NSDictionary *dateDic in dateArray)
                    {
                        
                        for (NSArray * key in dateDic) {
                            
                            NSLog(@" the count is %lu",[[dateDic objectForKey:key] count]);
                            
                            
                            for (int j =0 ; j < [[dateDic objectForKey:key] count]; j++) {
                                
                                [picPathArray addObject:[[dateDic objectForKey:key] objectAtIndex:j]];
                                [datesArray addObject:key];
                                
                                NSLog(@"the array is: %@", picPathArray);
                                NSLog(@" the Value is %@",[[dateDic objectForKey:key] objectAtIndex:j]);
                                
                                
                            }
                        }
                    }
                }
            }
        }
    }
    if (picPathArray.count > 0)
    {
        [editButton setEnabled:YES];
        
        newArray = [[NSMutableArray alloc] init];
        animatedIndexPaths = [[NSMutableArray alloc] init];
        
        counter= 0;
        
        
        collectionTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(performCollectionUpdates) userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:counter],@"count", nil] repeats:YES];
        
    }
    else
        [editButton setEnabled:NO];
}



#pragma mark - For the collection view Animations

-(void)performCollectionUpdates
{
    //    NSIndexPath *ip=[NSIndexPath indexPathForRow:i inSection:0];
    
    [self.collectionView performBatchUpdates:^{
        int resultsSize = [newArray count]; //data is the previous array of data
        [newArray addObject:@"1"];
        NSMutableArray *arrayWithIndexPaths = [NSMutableArray array];
        
        for (int j = resultsSize; j < resultsSize + 1; j++) {
            [arrayWithIndexPaths addObject:[NSIndexPath indexPathForRow:j
                                                              inSection:0]];
        }
        [self.collectionView insertItemsAtIndexPaths:arrayWithIndexPaths];
    } completion:nil];
    
    NSInteger count;
    if (picPathArray != nil)
        count = picPathArray.count;
    else
        count = allContentInFolder.count;
    
    if(counter<count)
    {
        if(count-counter==1)
        {
            [collectionTimer invalidate];
            counter++;
        }
        else
            counter++;
    }
}








#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}





- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return newArray.count;
}





- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DisplayFileListCollectionViewCell *cell = [self.FileListCollectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Designing the cell
    
    cell.layer.borderWidth = 2;
    cell.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3].CGColor;
    cell.layer.cornerRadius = 5;
    
    
    cell.clipsToBounds = YES;
    cell.ThumbNailImageView.clipsToBounds = YES;
    
    
    
    if (isP2P)
    {
        /////// From the Wifi videoscope - old code
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *strPath = [documentsDirectory stringByAppendingPathComponent:@"OBJ-002864-STBZD"];
        
        NSLog(@"%@",[picPathArray objectAtIndex:indexPath.row]);
        
        strPath = [strPath stringByAppendingPathComponent:[picPathArray objectAtIndex:indexPath.row]];
        
        if ([strPath containsString:@".mov"]||[strPath containsString:@".mp4"]||[strPath containsString:@".rec"]) // take thumbnail for videos // to reduce loading time next time the table view is scrolled.
        {
            
            cell.imagePlayButton.hidden=NO;
            if (storeThumbnails.count <= newArray.count && ![indexStore containsObject:indexPath])
            {
                [indexStore addObject:indexPath];
                
                NSURL * url = [NSURL fileURLWithPath: strPath];
                AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:url options:nil];
                AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
                generate1.appliesPreferredTrackTransform = YES;
                NSError *err = NULL;
                CMTime time = CMTimeMakeWithSeconds(1,32);
                CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
                UIImage *one = [[UIImage alloc] initWithCGImage:oneRef];
                
                cell.ThumbNailImageView.image=one;
                NSData* pictureData = UIImageJPEGRepresentation(one, .1); //JPEG conversion
                
                
                [storeThumbnails addObject:pictureData];
                
            }
            else
            {
                cell.ThumbNailImageView.image=[UIImage imageWithData:[storeThumbnails objectAtIndex:indexPath.row]];
            }
            
            AVURLAsset *avUrl = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:strPath]];
            CMTime timeTemp = [avUrl duration];
            int seconds = ceil(timeTemp.value/timeTemp.timescale);
            
            cell.lblDurationSize.text=[self formattedTime:seconds];
            
            
        }
        else
        {
            cell.imagePlayButton.hidden=YES;
            
            if (storeThumbnails.count <= newArray.count && ![indexStore containsObject:indexPath])
            {
                [indexStore addObject:indexPath];
                cell.ThumbNailImageView.image=[UIImage imageWithData:[NSData dataWithContentsOfFile:strPath]];
                
                [storeThumbnails addObject:[NSData dataWithContentsOfFile:strPath]];
                
            }
            else
            {
                cell.ThumbNailImageView.image=[UIImage imageWithData:[storeThumbnails objectAtIndex:indexPath.row]];
            }
            
            unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:strPath error:nil] fileSize];
            float fileSizeKB = fileSize/1024;
            
            cell.lblDurationSize.text=[NSString stringWithFormat:@"%0.02f M",fileSizeKB/1024];
        }
        
        NSFileManager* fm = [NSFileManager defaultManager];
        NSDictionary* attrs = [fm attributesOfItemAtPath:strPath error:nil];
        
        if (attrs != nil)
        {
            NSDate *date = (NSDate*)[attrs objectForKey: NSFileCreationDate];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat: @"MMM dd, yyyy, hh:mm:ss a"];
            
            NSString *strDate = [formatter stringFromDate:date]; // Convert date to string
            cell.dateLable.text=strDate;
        }
        
        
        if ([arrayTodelete containsObject:[picPathArray objectAtIndex:indexPath.item]]) {
            
            cell.ButtonSelected.image=[UIImage imageNamed:@"tkContact_checkBox.png"];
        }
        else{
            cell.ButtonSelected.image=[UIImage imageNamed:@"disSelect.png"];
        }
    }
    
    
    
    
    
    else  // IP Camera
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"imageFolder1"]]];
        NSString *savedImagePath = [dataPath stringByAppendingPathComponent:[allContentInFolder objectAtIndex:indexPath.item]];
        
        NSString *filePathExtenstion = [savedImagePath pathExtension];
        
        // Check for Images
        if ([filePathExtenstion caseInsensitiveCompare:@"jpg"] == NSOrderedSame || [filePathExtenstion caseInsensitiveCompare:@"jpeg"] == NSOrderedSame|| [filePathExtenstion caseInsensitiveCompare:@"png"] == NSOrderedSame ||[filePathExtenstion caseInsensitiveCompare:@"gif"] == NSOrderedSame)
        {
            
            
            if (storeThumbnails.count <= newArray.count && ![indexStore containsObject:indexPath])
            {
                [indexStore addObject:indexPath];
                cell.ThumbNailImageView.image=[UIImage imageWithData:[NSData dataWithContentsOfFile:savedImagePath]];
                
                [storeThumbnails addObject:[NSData dataWithContentsOfFile:savedImagePath]];
                
            }
            else
            {
                cell.ThumbNailImageView.image=[UIImage imageWithData:[storeThumbnails objectAtIndex:indexPath.row]];
            }
            
            
            
            
            cell.imagePlayButton.hidden=YES;
            
            unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:savedImagePath error:nil] fileSize];
            float fileSizeKB = fileSize/1024;
            float fileSizeMB = fileSizeKB/1024;
            
            NSLog(@"Size %@",[NSString stringWithFormat:@"%0.02f M",fileSizeMB]);
            cell.lblDurationSize.text=[NSString stringWithFormat:@"%.02f M",fileSizeMB];
            NSLog(@"text %@",cell.lblDurationSize.text);

        }
        else    // For Videos // Convert Thumbnail
        {
            
            
            if (storeThumbnails.count <= newArray.count && ![indexStore containsObject:indexPath])
            {
                [indexStore addObject:indexPath];
                
                NSURL * url = [NSURL fileURLWithPath: savedImagePath];
                AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:url options:nil];
                AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
                generate1.appliesPreferredTrackTransform = YES;
                NSError *err = NULL;
                CMTime time = CMTimeMakeWithSeconds(1,32);
                CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
                UIImage *one = [[UIImage alloc] initWithCGImage:oneRef];
                
                cell.ThumbNailImageView.image=one;
                NSData* pictureData = UIImageJPEGRepresentation(one, .1); //JPEG conversion
                
                
                [storeThumbnails addObject:pictureData];
                
            }
            else
            {
                cell.ThumbNailImageView.image=[UIImage imageWithData:[storeThumbnails objectAtIndex:indexPath.row]];
            }
            
            cell.imagePlayButton.hidden=NO;
            
            AVURLAsset *avUrl = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:savedImagePath]];
            CMTime timeTemp = [avUrl duration];
            int seconds = ceil(timeTemp.value/timeTemp.timescale);
            
            cell.lblDurationSize.text=[self formattedTime:seconds];
        }
        
        NSFileManager* fm = [NSFileManager defaultManager];
        NSDictionary* attrs = [fm attributesOfItemAtPath:savedImagePath error:nil];
        
        if (attrs != nil)
        {
            NSDate *date = (NSDate*)[attrs objectForKey: NSFileCreationDate];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat: @"MMM dd, yyyy, hh:mm:ss a"];
            
            NSString *strDate = [formatter stringFromDate:date]; // Convert date to string
            cell.dateLable.text=strDate;
        }
        
        if ([arrayTodelete containsObject:[allContentInFolder objectAtIndex:indexPath.item]]) {
            
            cell.ButtonSelected.image=[UIImage imageNamed:@"tkContact_checkBox.png"];
        }
        else{
            cell.ButtonSelected.image=[UIImage imageNamed:@"disSelect.png"];
        }
    }
    
    
    
    
    
    if (isEditing)
        cell.ButtonSelected.hidden=NO;
    else
        cell.ButtonSelected.hidden=YES;
    
    // To make sure the animation appears only during the initial loading and not always which can be annoying.
    if (![animatedIndexPaths containsObject:indexPath])
    {
        [animatedIndexPaths addObject:indexPath];
        
        cell.transform = CGAffineTransformMakeTranslation(0.0f, 200);
        cell.backgroundColor = [UIColor whiteColor];
        cell.layer.shadowColor = [[UIColor blackColor]CGColor];
        cell.layer.shadowOffset = CGSizeMake(10, 10);
        cell.alpha = 0;
        
        //2. Define the final state (After the animation) and commit the animation
        [UIView animateWithDuration:.8 delay:0.0 usingSpringWithDamping:.85 initialSpringVelocity:.8 options:0 animations:^{
            
            cell.transform = CGAffineTransformMakeTranslation(0.f, 0);
            cell.alpha = 1;
            cell.layer.shadowOffset = CGSizeMake(0, 0);
        } completion:^(BOOL finished) {
            
        }];
    }
    
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    DisplayFileListCollectionViewCell *cell=[self.FileListCollectionView cellForItemAtIndexPath:indexPath];
    
    
    if (isP2P) {
        if (isEditing) // Has user selected edit button for deleting
        {
            if ([arrayTodelete containsObject:[picPathArray objectAtIndex:indexPath.row]]) {
                
                [indexArrayTodelete removeObject:indexPath];
                [thumbnailToDelete removeObjectAtIndex:indexPath.row];
                [arrayTodelete removeObject:[picPathArray objectAtIndex:indexPath.row]];
                cell.ButtonSelected.image=[UIImage imageNamed:@"disSelect.png"];
            }
            else{
                //tkContact_checkBox
                [indexArrayTodelete addObject:indexPath];
                [thumbnailToDelete addObject:[storeThumbnails objectAtIndex:indexPath.row]];
                [arrayTodelete addObject:[picPathArray objectAtIndex:indexPath.row]];
                cell.ButtonSelected.image=[UIImage imageNamed:@"tkContact_checkBox.png"];
            }
            
            if (arrayTodelete.count>0)
                deleteBtn.enabled=YES;
            
            else
                deleteBtn.enabled=NO;
        }
        else
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            NSString *strPath = [documentsDirectory stringByAppendingPathComponent:@"OBJ-002864-STBZD"];
            
            NSLog(@"%@",[picPathArray objectAtIndex:indexPath.row]);
            
            strPath = [strPath stringByAppendingPathComponent:[picPathArray objectAtIndex:indexPath.row]];
            
            NSString * filePathExtenstion = [strPath pathExtension];
            
            if ([filePathExtenstion caseInsensitiveCompare:@"jpg"] == NSOrderedSame || [filePathExtenstion caseInsensitiveCompare:@"jpeg"] == NSOrderedSame|| [filePathExtenstion caseInsensitiveCompare:@"png"] == NSOrderedSame ||[filePathExtenstion caseInsensitiveCompare:@"gif"] == NSOrderedSame)
            {
                UIStoryboard * storyVC = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                
                ShowImageViewController * showImageViewController = (ShowImageViewController *)[storyVC instantiateViewControllerWithIdentifier:@"ShowImageViewController"];
                showImageViewController.strImagePath=strPath;
                
                [self.navigationController pushViewController:showImageViewController animated:YES];
            }
            else
            {
                UIStoryboard * storyVC = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                
                VideoPlayer * playRecordedVideoViewController = (VideoPlayer *)[storyVC instantiateViewControllerWithIdentifier:@"VideoPlayer"];
                playRecordedVideoViewController.strVideoPath=strPath;
                [self.navigationController pushViewController:playRecordedVideoViewController animated:YES];
                
            }
        }
    }
    
    
    
    
    else
    {
        if (isEditing)
        {
            if ([arrayTodelete containsObject:[allContentInFolder objectAtIndex:indexPath.row]]) {
                
                [indexArrayTodelete removeObject:indexPath];
                [thumbnailToDelete removeObjectAtIndex:indexPath.row];
                [arrayTodelete removeObject:[allContentInFolder objectAtIndex:indexPath.row]];
                cell.ButtonSelected.image=[UIImage imageNamed:@"disSelect.png"];
            }
            else{
                //tkContact_checkBox
                [indexArrayTodelete addObject:indexPath];
                [thumbnailToDelete addObject:[storeThumbnails objectAtIndex:indexPath.row]];
                [arrayTodelete addObject:[allContentInFolder objectAtIndex:indexPath.row]];
                cell.ButtonSelected.image=[UIImage imageNamed:@"tkContact_checkBox.png"];
            }
            
            if (arrayTodelete.count>0)
                deleteBtn.enabled=YES;
            
            else
                deleteBtn.enabled=NO;
        }
        else
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
            NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"imageFolder1"]]];
            NSString *savedImagePath = [dataPath stringByAppendingPathComponent:[allContentInFolder objectAtIndex:indexPath.item]];
            
            NSString *filePathExtenstion = [savedImagePath pathExtension];
            
            if ([filePathExtenstion caseInsensitiveCompare:@"jpg"] == NSOrderedSame || [filePathExtenstion caseInsensitiveCompare:@"jpeg"] == NSOrderedSame|| [filePathExtenstion caseInsensitiveCompare:@"png"] == NSOrderedSame ||[filePathExtenstion caseInsensitiveCompare:@"gif"] == NSOrderedSame)
            {
                UIStoryboard * storyVC = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                
                ShowImageViewController * showImageViewController = (ShowImageViewController *)[storyVC instantiateViewControllerWithIdentifier:@"ShowImageViewController"];
                showImageViewController.strImagePath=savedImagePath;
                
                [self.navigationController pushViewController:showImageViewController animated:YES];
            }
            else
            {
                UIStoryboard * storyVC = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                
                VideoPlayer * playRecordedVideoViewController = (VideoPlayer *)[storyVC instantiateViewControllerWithIdentifier:@"VideoPlayer"];
                playRecordedVideoViewController.strVideoPath=savedImagePath;
                [self.navigationController pushViewController:playRecordedVideoViewController animated:YES];
            }
        }
    }
}




#pragma mark- UIActionSheetDelegate


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSLog(@"%ld",(long)buttonIndex);
    
    if (buttonIndex==0) {
        if (isP2P)
        {
            int count = 0;

            for (NSString *itemname in arrayTodelete) {
                

                [storeThumbnails removeObject:[thumbnailToDelete objectAtIndex:count]];

               // [storeThumbnails removeObjectAtIndex:[[indexArrayTodelete objectAtIndex:count] row]];

                [indexStore removeObject:[indexArrayTodelete objectAtIndex:count]];
                
               // NSLog(@"path: %@",itemname);
                
                if ([itemname containsString:@".mov"]||[itemname containsString:@".mp4"]||[itemname containsString:@".rec"])
                    [m_pRecPathMgt RemovePath:@"OBJ-002864-STBZD" Date:[datesArray objectAtIndex:[[indexArrayTodelete objectAtIndex:count] row]] Path:itemname] ;
                else
                    [m_pPicPathMgt RemovePicPath:@"OBJ-002864-STBZD" PicDate:[datesArray objectAtIndex:[[indexArrayTodelete objectAtIndex:count] row]] PicPath:itemname] ;
                count = count +1;
                
                [picPathArray removeObject:itemname];
                [newArray removeLastObject];
                [animatedIndexPaths removeLastObject];
            }
            [self.FileListCollectionView deleteItemsAtIndexPaths:indexArrayTodelete];
            
            [self editDoneButonAction:nil];
            
        }
        else
        {
            int count = 0;
            
            for (NSString *itemname in arrayTodelete) {
                
                NSError *error;
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
                NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"imageFolder1"]]];
                NSString *savedImagePath = [dataPath stringByAppendingPathComponent:itemname];
                
                
                [[NSFileManager defaultManager] removeItemAtPath:savedImagePath error:&error]; //Will delete file
                
                if (!error)
                {
                    [allContentInFolder removeObject:itemname];
                    [newArray removeLastObject];
                    [animatedIndexPaths removeLastObject];
                    NSLog(@"I am Count %d and ount2 %ld and idexArray count %lu",count,(long)[[indexArrayTodelete objectAtIndex:count] row],(unsigned long)storeThumbnails.count);
                    //[storeThumbnails removeObjectAtIndex:[[indexArrayTodelete objectAtIndex:count] row]];
                    [storeThumbnails removeObject:[thumbnailToDelete objectAtIndex:count]];

                    [indexStore removeObject:[indexArrayTodelete objectAtIndex:count]];
                    count = count +1;
                    
                }
                
                else{
                    
                    UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                    return;
                }
            }
            [self.FileListCollectionView deleteItemsAtIndexPaths:indexArrayTodelete];
            
            [self editDoneButonAction:nil];
        }
    }
}





#pragma mark- Time formatting

- (NSString *)formattedTime:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    if (hours==0)
        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    else
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}






@end
