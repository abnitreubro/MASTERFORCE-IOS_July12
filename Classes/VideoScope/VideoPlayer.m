//
//  VideoPlayer.m
//  P2PCamera
//
//  Created by JS Products on 20/04/16.
//
//

#import "VideoPlayer.h"

@implementation VideoPlayer

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    shareBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButtonAction:)] ;
    
    self.navigationItem.rightBarButtonItems = @[shareBtn];
    
    [self.view layoutIfNeeded];

    
    // Fetch thumbnail to display
    
    NSURL * url = [NSURL fileURLWithPath: _strVideoPath];
    AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
    generate1.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMakeWithSeconds(1,32);
    CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
    UIImage *one = [[UIImage alloc] initWithCGImage:oneRef];
    
    videoImage.image=one;
    videoImage.contentMode = UIViewContentModeScaleAspectFit;
    
    if (one.size.height > 1)
    {
        imageHeightConstraint.constant = (videoImage.frame.size.width/one.size.width)*one.size.height;
        
        if (imageHeightConstraint.constant > self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height)
        {
            imageHeightConstraint.constant = self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 20 - 20; // status bar + 10 + 10 view spacing
        }
    }
    
    AVURLAsset *avUrl = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:_strVideoPath]];
    CMTime timeTemp = [avUrl duration];
    int seconds = ceil(timeTemp.value/timeTemp.timescale);
    
    
    
    
    // set the title
    
    NSFileManager* fm = [NSFileManager defaultManager];
    NSDictionary* attrs = [fm attributesOfItemAtPath:_strVideoPath error:nil];
    
    if (attrs != nil)
    {
        NSDate *date = (NSDate*)[attrs objectForKey: NSFileCreationDate];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat: @"MMM dd, yyyy, hh:mm:ss a"];
        
        NSString *strDate = [formatter stringFromDate:date]; // Convert date to string
        self.title=strDate;
    }
    
    
    
    // add the tap gesture recognizer
    UITapGestureRecognizer *tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnce:)];
    
    [self.view addGestureRecognizer:tapOnce];
    
    // Setup audio session
    NSError *error;
    
    AVAudioSession * session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    
  //  UInt32 doChangeDefaultRoute = 1;
  //  AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
    
    // AVPLAYER
    
    asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:_strVideoPath]];
    playerItem = [[AVPlayerItem alloc]initWithAsset:asset];
    _player = [[AVPlayer alloc]initWithPlayerItem:playerItem];
    _player.volume = 1.0;

    playerLayer =[AVPlayerLayer playerLayerWithPlayer:_player];
   
    [playerLayer setFrame:imageContainingView.bounds];
    
    [imageContainingView.layer addSublayer:playerLayer];

    [_player seekToTime:kCMTimeZero];
    [_player play];
    
    
    
    
    // set the time for labels
    labelStopTime.text = [self formattedTime:seconds];
    labelStartTime.text = [self getStringFromCMTime:_player.currentTime];
    
    // Set the slider values
    CMTime interval = CMTimeMake(33, 1000);
    __weak __typeof(self) weakself = self;
    playbackObserver = [weakself.player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock: ^(CMTime time) {
        CMTime endTime = CMTimeConvertScale (weakself.player.currentItem.asset.duration, weakself.player.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
        if (CMTimeCompare(endTime, kCMTimeZero) != 0) {
            double normalizedTime = (double) weakself.player.currentTime.value / (double) endTime.value;
            movieSlider.value = normalizedTime;
        }
        labelStartTime.text = [weakself getStringFromCMTime:weakself.player.currentTime];
    }];
    
    isPlaying = YES;
    
    // for knowing when finished
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerFinishedPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];

    [movieSlider addTarget:self action:@selector(progressBarChanged:) forControlEvents:UIControlEventValueChanged];
    

    transparentControlView.layer.cornerRadius = 2;
    transparentControlView.backgroundColor = [UIColor darkGrayColor];
    transparentControlView.opaque = NO;

}



-(void)viewWillAppear:(BOOL)animated
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (!self.navigationController.navigationBarHidden)
        {
            [UIView  animateWithDuration:.5 animations:^{
                [[self navigationController] setNavigationBarHidden:YES animated:YES];
                controlsView.alpha = 0;
            }];
        }
    });
}



#pragma mark - Hide/Unhide views

- (void)tapOnce:(UIGestureRecognizer *)gesture
{
    if (!self.navigationController.navigationBarHidden)
    {
        [UIView  animateWithDuration:.5 animations:^{
            [[self navigationController] setNavigationBarHidden:YES animated:YES];
            controlsView.alpha = 0;
        }];
    }
    else
    {
        [UIView animateWithDuration:.5 animations:^{
            [[self navigationController] setNavigationBarHidden:NO animated:YES];
            controlsView.alpha = 1;
        }];
    }
}




-(void)hideViews
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        
        [UIView  animateWithDuration:.5 animations:^{
            [[self navigationController] setNavigationBarHidden:YES animated:YES];
            controlsView.alpha = 0;
            
        }];
    });
}




#pragma mark - Sharing

// Universal Social Share functionality

-(void)shareButtonAction:(id)sender
{
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    NSString *postText = [[NSString alloc] initWithFormat:@"%@ ",[_strVideoPath lastPathComponent] ];
    
    if (postText) {
        [sharingItems addObject:postText];
    }
    NSURL *url=[NSURL fileURLWithPath:_strVideoPath];
    
    [sharingItems addObject:url];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    
    activityViewController.popoverPresentationController.barButtonItem = shareBtn;
    
    [self presentViewController: activityViewController animated:YES completion:nil];
}



#pragma mark - Video Player Controls

-(void)playerFinishedPlaying
{
    [self.player pause];
    [self.player seekToTime:kCMTimeZero];
    [playStopButton setSelected:NO];
    isPlaying = NO;

    [playStopButton setImage:[UIImage imageNamed:@"playbottone.png"] forState:UIControlStateNormal];
}




-(void)progressBarChanged:(UISlider*)sender
{
    if (isPlaying) {
        [self.player pause];
        [playStopButton setImage:[UIImage imageNamed:@"playbottone.png"] forState:UIControlStateNormal];

    }
    
    NSLog(@"%f",sender.value);
    
    CMTime seekTime = CMTimeMakeWithSeconds(sender.value * (double)self.player.currentItem.asset.duration.value/(double)self.player.currentItem.asset.duration.timescale,1000);
    [self.player seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    labelStartTime.text = [self getStringFromCMTime:seekTime];;
}




- (IBAction)movieSliderAction:(id)sender
{
    if (isPlaying) {
        [self.player play];
        [playStopButton setImage:[UIImage imageNamed:@"pause_green.png"] forState:UIControlStateNormal];
    }
}




- (IBAction)playStopButton:(id)sender {
    if (isPlaying)
        [self pause];
    
    else
        [self play];
}




-(void)play
{
    [self.player play];
    isPlaying = YES;
    [playStopButton setSelected:YES];
    
    [playStopButton setImage:[UIImage imageNamed:@"pause_green.png"] forState:UIControlStateNormal];
}




-(void)pause
{
    [self.player pause];
    isPlaying = NO;
    [playStopButton setSelected:NO];
    
    [playStopButton setImage:[UIImage imageNamed:@"playbottone.png"] forState:UIControlStateNormal];
}




#pragma mark - Time Formatting

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


-(NSString*)getStringFromCMTime:(CMTime)time
{
    Float64 currentSeconds = CMTimeGetSeconds(time);
    int mins = currentSeconds/60.0;
    int secs = fmodf(currentSeconds, 60.0);
    NSString *minsString = mins < 10 ? [NSString stringWithFormat:@"0%d", mins] : [NSString stringWithFormat:@"%d", mins];
    NSString *secsString = secs < 10 ? [NSString stringWithFormat:@"0%d", secs] : [NSString stringWithFormat:@"%d", secs];
    return [NSString stringWithFormat:@"%@:%@", minsString, secsString];
}


#pragma mark - Device Rotation

- (BOOL)shouldAutorotate{
    if([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft ||[[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeRight || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait)
        return YES;
    else
        return NO;
}

// Handling the player on rotation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation ]== UIDeviceOrientationLandscapeRight || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait)
    {
        [playerLayer setFrame:CGRectMake(0, 0, imageContainingView.frame.size.height, imageContainingView.frame.size.width)];
    }
}





#pragma mark - remove playbackObserver

-(void)dealloc
{
    
    // Release observer
    
    [self.player removeTimeObserver:playbackObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    [self playerFinishedPlaying];

}



@end
