//
//  CameraPreviewViewController.m
//  VideoScope
//
//  Created by JS Products on 07/03/16.
//  Copyright © 2016  JS Products. All rights reserved.
//



// The class is used for streaming, displaying, recording the video

#import "CameraPreviewViewController.h"
#import "Constant.h"
#define END_MARKER_BYTES { 0xFF, 0xD9 }

@interface CameraPreviewViewController (){
    NSURLConnection* connection;
    NSTimer*waitingTimer,*recordingTimer,*autometicStopTimer;
    UIBarButtonItem *videoRecorderBtn;
    int currentTimeInSeconds;
    CGFloat scaleValue;
    UIImage *  imageCropped;

}

@end

@implementation CameraPreviewViewController

@synthesize interfaceScrollView,interfaceImage;

static NSData *_endMarkerData = nil;

#pragma mark- Viewcontroller Methods

- (void)viewDidLoad {
    startedAt=nil;
    scaleValue = 1;

    [super viewDidLoad];
    
    [self.view layoutIfNeeded];
    
    self.navigationItem.title=@"MX1021 Masterforce Wi-Fi Inspection Camera/Video";
    [self.activityIndicatorView startAnimating];
    
    
    // Setting Timer for 1 min if user won't receive any responce then go back to root view controller
    
    waitingTimer = [NSTimer scheduledTimerWithTimeInterval:60.0
                                     target:self
                                   selector:@selector(timeOut:)
                                   userInfo:nil
                                    repeats:NO];
    if (_endMarkerData == nil) {
        uint8_t endMarker[2] = END_MARKER_BYTES;
        _endMarkerData = [[NSData alloc] initWithBytes:endMarker length:2];
    }
    NSLog(@"Camera Detal is %@",self.folderName);
    
    UIBarButtonItem *cameraBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takeImageButtonAction:)] ;

    UIImage *recorderImage = [UIImage imageNamed:@"wifiCamera"];
    UIButton *recButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [recButton addTarget:self action:@selector(recordVideo:) forControlEvents:UIControlEventTouchUpInside];
    recButton.bounds = CGRectMake( 0, 0, recorderImage.size.width/1.7, recorderImage.size.height/1.7 );
    [recButton setImage:recorderImage forState:UIControlStateNormal];
    
    videoRecorderBtn = [[UIBarButtonItem alloc] initWithCustomView:recButton];
    videoRecorderBtn.enabled=NO;
    
    self.navigationItem.rightBarButtonItems = @[cameraBtn,videoRecorderBtn];
    
    [self setUpScrolling];
    
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnce:)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveImage:)];
    [self.view addGestureRecognizer:pan];
    
    [self.view bringSubviewToFront:self.bottomButtonView];
}



#pragma mark - hide/unhide views

-(void)viewWillAppear:(BOOL)animated
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (!self.navigationController.navigationBarHidden)
        {
            [UIView  animateWithDuration:.5 animations:^{
                [[self navigationController] setNavigationBarHidden:YES animated:YES];
                _bottomButtonView.alpha = 0;
            }];
        }
    });
}



-(void)viewDidAppear:(BOOL)animated{
    [self playVideo];
    
}



- (void)tapOnce:(UIGestureRecognizer *)gesture
{
    if (!self.navigationController.navigationBarHidden)
    {
        [UIView  animateWithDuration:.5 animations:^{
            [[self navigationController] setNavigationBarHidden:YES animated:YES];
            _bottomButtonView.alpha = 0;
            
        }];
    }
    else
    {
        [UIView animateWithDuration:.5 animations:^{
            [[self navigationController] setNavigationBarHidden:NO animated:YES];
            _bottomButtonView.alpha = 1;
            
        }];
    }
}



#pragma mark- end
#pragma mark - Custom methods


-(void)playVideo{
    

    NSURL *videoURL= [NSURL URLWithString:[self urlencode:self.cameraURL]];

    NSLog(@"Video URl IS %@",videoURL);
    
    connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:videoURL] delegate:self];
    [connection start];
}



-(void)timeOut:(NSTimer*)timer{
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
}

#pragma mark- end

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // Checking if getting any response
    self.receivedData = [[NSMutableData alloc] init];
    
}



- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    // Perform action once get usefull data here
    
    [self.receivedData appendData:data];

    NSRange endRange = [_receivedData rangeOfData:_endMarkerData
                                          options:0
                                            range:NSMakeRange(0, _receivedData.length)];
    
    long long endLocation = endRange.location + endRange.length;
    if (_receivedData.length >= endLocation) {
        NSData *imageData = [_receivedData subdataWithRange:NSMakeRange(0, endLocation)];
        UIImage *receivedImage = [UIImage imageWithData:imageData];
        if (receivedImage) {
            interfaceImage.image = receivedImage;
            
            videoRecorderBtn.enabled=YES;

            [waitingTimer invalidate];
            waitingTimer=nil;
            
            [self.activityIndicatorView stopAnimating];
        }
    }
}



- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    // Perform if loading finished
    NSLog(@"nothing");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    
    // Dismiss viewcontroller if any error occurs while streaming
    
    [self.activityIndicatorView stopAnimating];

    NSLog(@"Connection Error %@",error);
    
    UIView *alertView = [[UIView alloc]initWithFrame:CGRectMake(20, 50, 250, 100)];
    
    alertView.center=CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    alertView.backgroundColor=[UIColor clearColor];
    
    UIImageView*errorImage =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"error"]];
    errorImage.frame=CGRectMake(0, 5, errorImage.frame.size.width, errorImage.frame.size.height);
    errorImage.center=CGPointMake(alertView.frame.size.width/2, errorImage.center.y);
    [alertView addSubview:errorImage];
    
    UILabel *errorLbl = [[UILabel alloc]initWithFrame:CGRectMake(10, errorImage.frame.origin.y+errorImage.frame.size.height/2, alertView.frame.size.width-20, 100)];
    errorLbl.numberOfLines=0;
    errorLbl.text=error.localizedDescription;
    errorLbl.textAlignment=NSTextAlignmentCenter;
    errorLbl.font=[UIFont boldSystemFontOfSize:16];
    errorLbl.textColor=[UIColor whiteColor];
    [alertView addSubview:errorLbl];
    
    [self.view addSubview:alertView];
    
    NSTimeInterval animationDuration = 2.0;/* determine length of animation */;
    //CGRect newFrameSize = /* determine what the frame size should be */;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    [UIView commitAnimations];
    
    [UIView animateWithDuration:1 animations:^{
        
        alertView.frame = CGRectMake(alertView.frame.origin.x, alertView.frame.origin.y, 0, 0);

        alertView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [alertView removeFromSuperview];
        [self.navigationController popViewControllerAnimated:YES];

    }];
    
}

#pragma mark- end


#pragma mark- encode URL

// Formate URLin prpoper formate
-(NSString *)urlencode:(NSString *)str
{
    NSString *encodeString=(NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)str, NULL, (CFStringRef)@"", kCFStringEncodingUTF8));
    return encodeString;
}

#pragma mark- end



#pragma mark- end
#pragma mark- Take screenshots
// Capture Image
-(void)captureImage
{
    NSError*error=nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyyMMddHHmmss"];
    
    NSString *strDate = [formatter stringFromDate:[NSDate date]]; // Convert date to string

    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]){

        
        
        //// For the aspect fit
 
        
        CGFloat aspect = interfaceImage.image.size.width / interfaceImage.image.size.height;
        if (interfaceImage.image.size.width / aspect <= interfaceImage.image.size.height)
        {
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(interfaceImage.image.size.width, interfaceImage.image.size.width / aspect), NO, 0.0f);
            
            //draw
            [interfaceImage.image drawInRect:CGRectMake(0.0f, 0.0f, CGSizeMake(interfaceImage.image.size.width, interfaceImage.image.size.width / aspect).width, CGSizeMake(interfaceImage.image.size.width, interfaceImage.image.size.width / aspect).height)];
            
            //capture resultant image
            imageCropped = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        else
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(interfaceImage.image.size.height * aspect, interfaceImage.image.size.height), NO, 0.0f);
            
            //draw
            [interfaceImage.image drawInRect:CGRectMake(0.0f, 0.0f, CGSizeMake(interfaceImage.image.size.height * aspect, interfaceImage.image.size.height).width, CGSizeMake(interfaceImage.image.size.height * aspect, interfaceImage.image.size.height).height)];
            
            //capture resultant image
            imageCropped = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            
        }
//// For the aspect fit

        
        NSData * imageData = UIImageJPEGRepresentation(imageCropped, 0.05); //UIImagePNGRepresentation(image);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",self.folderName]];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])//Check
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Will Create folder

        NSString *savedImagePath = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",strDate]];
        [imageData writeToFile:savedImagePath atomically:NO];
    }
    else
    {
        
        UIGraphicsBeginImageContext(interfaceImage.bounds.size);
        
        //// For the aspect fit
        
        
        CGFloat aspect = interfaceImage.image.size.width / interfaceImage.image.size.height;
        if (interfaceImage.image.size.width / aspect <= interfaceImage.image.size.height)
        {
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(interfaceImage.image.size.width, interfaceImage.image.size.width / aspect), NO, 0.0f);
            
            //draw
            [interfaceImage.image drawInRect:CGRectMake(0.0f, 0.0f, CGSizeMake(interfaceImage.image.size.width, interfaceImage.image.size.width / aspect).width, CGSizeMake(interfaceImage.image.size.width, interfaceImage.image.size.width / aspect).height)];
            
            //capture resultant image
            imageCropped = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        else
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(interfaceImage.image.size.height * aspect, interfaceImage.image.size.height), NO, 0.0f);
            
            //draw
            [interfaceImage.image drawInRect:CGRectMake(0.0f, 0.0f, CGSizeMake(interfaceImage.image.size.height * aspect, interfaceImage.image.size.height).width, CGSizeMake(interfaceImage.image.size.height * aspect, interfaceImage.image.size.height).height)];
            
            //capture resultant image
            imageCropped = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            
        }
        //// For the aspect fit
        
        NSData * imageData = UIImageJPEGRepresentation(imageCropped, 0.01);//UIImagePNGRepresentation(image);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",self.folderName]];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])//Check
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Will Create folder
        
        NSString *savedImagePath = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",strDate]];
        [imageData writeToFile:savedImagePath atomically:NO];
        
        
    }

    [CustomToast showWithText:@"Snapshot saved successfully"
                    superView:self.view
                    bLandScap:NO];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mark- Timer Functionality Implementation

- (NSTimer *)createTimer :(float)interval :(BOOL)shouldRepeat{
    return [NSTimer scheduledTimerWithTimeInterval:interval
                                            target:self
                                          selector:@selector(timerTicked:)
                                          userInfo:nil
                                           repeats:shouldRepeat];
}

- (void)timerTicked:(NSTimer *)timer {
    if (timer==recordingTimer) {
        currentTimeInSeconds++;
        self.lblRecordingTime.text = [self formattedTime:currentTimeInSeconds];

    }

    if (timer== autometicStopTimer) {
        
        [self recordVideo:nil];
    }
}

- (NSString *)formattedTime:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}


#pragma mark- Button Action
// Button Action to take photo for curent event from live streaming

-(void)takeImageButtonAction :(id)sender{
    
    
    if (![self.activityIndicatorView isAnimating]) {
        
        BOOL flag=[self isOutOfMemory];

        if (flag) {
            
            [CustomToast showWithText:@"No enough storage. Please clean up and try again."
                            superView:self.view
                            bLandScap:NO];
            return;
        }
        [self captureImage];
    }
}

// Button Action to record video for curent event from live streaming

-(void)recordVideo :(id)sender{
    
    BOOL flag=[self isOutOfMemory];

    if (flag) {
        
        [CustomToast showWithText:@"No enough storage. Please clean up and try again."
                        superView:self.view
                        bLandScap:NO];

        
        return;
    }

    if (isProcessing && !isRecording) {
        return;
    }
    if (isRecording) {
        [recorder stop];
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];

        recorder=nil;

        isRecording=NO;
        startedAt=nil;
        
        UIButton *button= (UIButton*)videoRecorderBtn.customView;
        
        [recordingTimerVideo invalidate];
        recordingTimerVideo=nil;
        
        NSLog(@"numberOfScreenshots is %@",numberOfScreenshots);
        
        isRecording=NO;
        
        isProcessing=YES;
        
        //[self createWriter];
        if (numberOfScreenshots.count > 0)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _lblRecordingTime.text = @"Saving...";
            }];

            [NSThread detachNewThreadSelector:@selector(createWriter) toTarget:self withObject:nil];
        }
        
        UIImage *recorderImage = [UIImage imageNamed:@"wifiCamera"];
        [button setImage:recorderImage forState:UIControlStateNormal];

        
        [recordingTimer invalidate];
        recordingTimer=nil;
        [autometicStopTimer invalidate];
        autometicStopTimer=nil;
        self.viewRecordingTime.hidden=YES;
        // Working For Audio Recording For Merging with Video


    }
    else{
        UIButton *button= (UIButton*)videoRecorderBtn.customView;

        //[self setUpWriter];
        UIImage *recorderImage = [UIImage imageNamed:@"wifiCamera_act"];
        [button setImage:recorderImage forState:UIControlStateNormal];
        
        startedAt = [NSDate date];

        isRecording=YES;
        
        NSLog(@"Audio Recording status is %@",[[NSUserDefaults standardUserDefaults]objectForKey:ISRECORDAUDIO]);
        
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:ISRECORDAUDIO]integerValue]==1) {
            [self initializeAudioRecorder];
            AVAudioSession *session = [AVAudioSession sharedInstance];
            [session setActive:YES error:nil];
            
            // Start recording
            [recorder record];
            
        }
        currentTimeInSeconds = 0;
        
        self.lblRecordingTime.text = [self formattedTime:currentTimeInSeconds];
        self.viewRecordingTime.hidden=NO;
       // [screenCaptureView startRecording];

        // Working For Audio Recording For Merging with Video

        numberOfScreenshots=[[NSMutableArray alloc]init];
        
        recordingTimerVideo =[NSTimer scheduledTimerWithTimeInterval:0.25
                                                         target:self
                                                       selector:@selector(timerMethodExecute:)
                                                       userInfo:nil
                                                        repeats:YES];
        
        
        
        
        if (!currentTimeInSeconds) {
            currentTimeInSeconds = 0 ;
        }
        
        if (!recordingTimer) {
            recordingTimer = [self createTimer:1.0:YES];
        }
        
        if (!autometicStopTimer) {
            
            autometicStopTimer=[self createTimer:[[[NSUserDefaults standardUserDefaults]objectForKey:RECORDINGTIME]floatValue]*60:NO];
            
        }
        
    }
}

#pragma mark- Screen Capture Functionality

-(void)timerMethodExecute:(id)info{
    
    if ([self isOutOfMemory]) {
        
        [self stopRecordForMemoryOver];
        
        return;
        
    }
    
    [self takeScreenshots];
}


-(void)takeScreenshots{
    
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]){
        
        NSData *tempData = UIImageJPEGRepresentation(interfaceImage.image, 0.01);
        
        UIImage *image = [UIImage imageWithData:tempData];
        
        [numberOfScreenshots addObject:image];
        
    }
    else{
        
        UIGraphicsBeginImageContext(interfaceImage.bounds.size);
        
        UIGraphicsBeginImageContextWithOptions(interfaceImage.bounds.size,interfaceImage.opaque, 0.0);
        [interfaceImage.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        [numberOfScreenshots addObject:image];
        
    }
    return;
}


#pragma end

#pragma mark- Generating Video From Screenshots

-(void)createWriter{
    
    NSError*error=nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyyMMddHHmmss"];
    NSString *strDate = [formatter stringFromDate:[NSDate date]]; // Convert date to string
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath;
    
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:ISRECORDAUDIO]integerValue]==1) {
        dataPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",@"temp"]];

    }
    else
    {
        dataPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",self.folderName]];

    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])//Check
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Will Create folder
    
    NSString *savedImagePath = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",strDate]];
    

    
    NSURL *videoTempURL = [NSURL fileURLWithPath:savedImagePath];
    
    
    VideoURL=[NSURL fileURLWithPath:savedImagePath];
    
    // WARNING: AVAssetWriter does not overwrite files for us, so remove the destination file if it already exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[videoTempURL path]  error:NULL];
    
    int height = 480;
    
    int width = 640;
    
    
    [self writeImageAsMovie:numberOfScreenshots toPath:savedImagePath size:CGSizeMake(width, height)];
    numberOfScreenshots=nil;
}

-(void)writeImageAsMovie:(NSArray *)array toPath:(NSString*)path size:(CGSize)size

{
    NSError *error = nil;
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:path]
                                  
                                                           fileType:AVFileTypeQuickTimeMovie
                                  
                                                              error:&error];
    
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey,
                                   
                                   nil];
    
    
    AVAssetWriterInput* writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                       
                                                                         outputSettings:videoSettings];
    
    
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:nil];
    _timeOfFirstFrame = CFAbsoluteTimeGetCurrent();
    
    
    NSParameterAssert(writerInput);
    
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    
    [videoWriter addInput:writerInput];
    
    //Start a SESSION of writing.
    
    // After you start a session, you will keep adding image frames
    
    // until you are complete - then you will tell it you are done.
    
    [videoWriter startWriting];
    
    // This starts your video at time = 0
    
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    
    CVPixelBufferRef buffer = NULL;
    
    
    // This was just our utility class to get screen sizes etc.
    
    
    int i = 0;
    
    while (1)
        
    {
        
        // Check if the writer is ready for more data, if not, just wait
        
        if(writerInput.readyForMoreMediaData){
            
            
            CFAbsoluteTime current  = CFAbsoluteTimeGetCurrent();
            CFTimeInterval elapse   = current - _timeOfFirstFrame;
            CMTime present          = CMTimeMake(i * 150, 600);
            
            
            if (i >= [array count])
                
            {
                buffer = NULL;
            }
            
            else
                
            {
                // This command grabs the next UIImage and converts it to a CGImage
                buffer = [self pixelBufferFromCGImage:[[array objectAtIndex:i] CGImage]];
            }
            
            if (buffer)
                
            {
                // Give the CGImage to the AVAssetWriter to add to your video
                [adaptor appendPixelBuffer:buffer withPresentationTime:present];
                
                CVPixelBufferPoolRef bufferPool = adaptor.pixelBufferPool;
                NSParameterAssert(bufferPool != NULL);
                CVPixelBufferRelease(buffer);
                i++;
            }
            
            else
                
            {
                //Finish the session:
                // This is important to be done exactly in this order
                [writerInput markAsFinished];
                
                // WARNING: finishWriting in the solution above is deprecated.
                
                // You now need to give a completion handler.
                
                [videoWriter finishWritingWithCompletionHandler:^{
                    
                    NSLog(@"Finished writing...checking completion status...");
                    
                    if (videoWriter.status != AVAssetWriterStatusFailed && videoWriter.status == AVAssetWriterStatusCompleted)
                    {
                        isProcessing=NO;
                        NSLog(@"Video writing succeeded.");
                        // Move video to camera roll
                        
                        // NOTE: You cannot write directly to the camera roll.
                        
                        // You must first write to an iOS directory then move it!
                        
                    //    NSURL *videoTempURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@", path]];
                        
                        if ([[[NSUserDefaults standardUserDefaults]objectForKey:ISRECORDAUDIO]integerValue]==1) {
                            [self mergeAndSave];
                        }
                        else{
                            
                            [self performSelectorOnMainThread:@selector(showVideoSuccessMessage) withObject:nil waitUntilDone:NO];
                        }
                    } else
                        
                    {
                        NSLog(@"Video writing failed: %@", videoWriter.error);
                    }
                    
                }]; // end videoWriter finishWriting Block

                CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
                
                NSLog (@"Done");
                
                adaptor=nil;
                videoWriter=nil;
                writerInput=nil;
                array=nil;
                buffer=NULL;
                
                break;
                
            }
        }
    }
}


-(void)showVideoSuccessMessage{
    
    NSLog(@"%@", self.navigationController.viewControllers);
    if ([self.navigationController.viewControllers containsObject:self]) {
        
        [CustomToast showWithText:@"Video saved successfully"
                        superView:self.view
                        bLandScap:NO];
    }
}

-(CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image

{
    // This again was just our utility class for the height & width of the
    // incoming video (640 height x 480 width)
    
    int height = 1080;
    int width = 720;
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             
                             nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, width,
                                          
                                          height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          
                                          &pxbuffer);
    
    
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata, width,
                                                 
                                                 height, 8, 4*width, rgbColorSpace,
                                                 
                                                 kCGImageAlphaNoneSkipFirst);
    
    NSParameterAssert(context);
    
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    
    CGContextDrawImage(context, CGRectMake(0, 0, width,
                                           
                                           height), image);
    
    CGColorSpaceRelease(rgbColorSpace);
    
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);

    return pxbuffer;
}




#pragma mark- Audio Capture Functionality


-(void)initializeAudioRecorder{
    
    NSError*error=nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyyMMddHHmmss"];
    NSString *strDate = [formatter stringFromDate:[NSDate date]]; // Convert date to string
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",@"temp"]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])//Check
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Will Create folder
    
    NSString *savedImagePath = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a",strDate]];
    
    
    NSURL *outputFileURL = [NSURL fileURLWithPath:savedImagePath];
    AudioURl=[NSURL fileURLWithPath:savedImagePath];
    
    NSLog(@"Audio Path is %@",outputFileURL);
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryRecord error:&error];
    
    if (error) {
        NSLog(@"Erro! %@", error.debugDescription);
    }
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    // Use only if required. No use here in this app
    
}



#pragma mark- Mixing Audio and Video


-(void)mergeAndSave
{
    //Create AVMutableComposition Object which will hold our multiple AVMutableCompositionTrack or we can say it will hold our video and audio files.
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    //Now first load your audio file using AVURLAsset. Make sure you give the correct path of your videos.
    //  NSURL *audio_url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Asteroid_Sound" ofType:@"mp3"]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // [fileManager removeItemAtPath:[AudioURl path]  error:NULL];
    

    AVURLAsset  *audioAsset = [[AVURLAsset alloc]initWithURL:AudioURl options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    
    //Now we are creating the first AVMutableCompositionTrack containing our audio and add it to our AVMutableComposition object.
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    //Now we will load video file.
    // NSURL *video_url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Asteroid_Video" ofType:@"m4v"]];
    AVURLAsset  *videoAsset = [[AVURLAsset alloc]initWithURL:VideoURL options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    
    //Now we are creating the second AVMutableCompositionTrack containing our video and add it to our AVMutableComposition object.
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];

    
    NSError*error=nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyyMMddHHmmss"];
    NSString *strDate = [formatter stringFromDate:[NSDate date]]; // Convert date to string
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",self.folderName]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])//Check
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Will Create folder
    
    NSString *savedImagePath = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",strDate]];
    
    
    NSURL *outputFileUrl = [NSURL fileURLWithPath:savedImagePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:savedImagePath])
        [[NSFileManager defaultManager] removeItemAtPath:savedImagePath error:nil];
    
    
    //Now create an AVAssetExportSession object that will save your final video at specified path.
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    _assetExport.outputFileType = @"com.apple.quicktime-movie";
    _assetExport.outputURL = outputFileUrl;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
            // [self exportDidFinish:_assetExport];
             
             NSLog(@"File merged sucessfully");
             if ([fileManager fileExistsAtPath:[AudioURl path]]) {
                 
                 NSFileManager *fileManager = [NSFileManager defaultManager];
                 [fileManager removeItemAtPath:[AudioURl path]  error:NULL];

             }
             
             if ([fileManager fileExistsAtPath:[AudioURl path]]) {
                 NSLog(@"File Available");
             }
             else{
                 NSLog(@"File not available");
             }
    
             
             if ([fileManager fileExistsAtPath:[VideoURL path]]) {
                 
                 NSFileManager *fileManager = [NSFileManager defaultManager];
                 [fileManager removeItemAtPath:[VideoURL path]  error:NULL];
                 
             }
           

             [self performSelectorOnMainThread:@selector(showVideoSuccessMessage) withObject:nil waitUntilDone:NO];
         });
     }];
}


// Not used in live version. Only used while testing


- (void)exportDidFinish:(AVAssetExportSession*)session
{
    if(session.status == AVAssetExportSessionStatusCompleted)
    {
        NSURL *outputURL = session.outputURL;
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL])
        {
            [library writeVideoAtPathToSavedPhotosAlbum:outputURL
                                        completionBlock:^(NSURL *assetURL, NSError *error)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     if (error) {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"  message:@"Video Saving Failed"  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil, nil];
                         
                         [alert show];
                     }
                     else {
                         UIAlertView *alert = [[UIAlertView alloc]
                                                initWithTitle:@"Video Saved" message:@"Saved To Photo Album"      delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                         
                         [alert show];
                     }
                 });
             }];
        }
    }
}







#pragma mark - Image rotate, zoom controls



-(void)setUpScrolling
{
    [interfaceScrollView layoutIfNeeded];
    interfaceScrollView.delegate=self;
    interfaceScrollView.zoomScale=1.0f;
    interfaceScrollView.minimumZoomScale=0.25f;
    interfaceScrollView.maximumZoomScale=8.0f;
    interfaceScrollView.bounces=YES;
    interfaceScrollView.bouncesZoom=YES;
    interfaceScrollView.clipsToBounds = YES;
    interfaceImage.hidden = NO;
}



- (IBAction)actionResetButton:(id)sender {
    interfaceScrollView.zoomScale=1.0f;

    CGAffineTransform transform = CGAffineTransformMakeRotation(0);
    interfaceScrollView.transform = transform;

    interfaceScrollView.center = CGPointMake(self.view.center.x ,
                                              self.view.center.y );
    interfaceImage.center = interfaceScrollView.center;
    
}





- (IBAction)actionZoomIn:(id)sender {
    [UIView animateWithDuration:.5 animations:^
    {
        scaleValue = scaleValue * 1.2;

        CGAffineTransform transform1 = CGAffineTransformMakeScale(scaleValue, scaleValue);

        CGAffineTransform transform = CGAffineTransformRotate(transform1,  atan2f(interfaceImage.transform.b, interfaceImage.transform.a));
        
        interfaceImage.transform = transform;
    }];
}




- (IBAction)actionZoomOut:(id)sender {
    
    [UIView animateWithDuration:.5 animations:^{

        scaleValue = scaleValue * 0.8;
    
        CGAffineTransform transform1 = CGAffineTransformMakeScale(scaleValue, scaleValue);
        
        CGAffineTransform transform = CGAffineTransformRotate(transform1,  atan2f(interfaceImage.transform.b, interfaceImage.transform.a));

        interfaceImage.transform = transform;
     }];
}

- (IBAction)actionLeftRtate:(id)sender {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView animateWithDuration:.8 animations:^
     {
        CGAffineTransform transform = CGAffineTransformRotate(interfaceImage.transform, -M_PI_4);
        interfaceImage.transform = transform;
        }];
}





- (IBAction)actionRightRotate:(id)sender
{
    [UIView animateWithDuration:.8 animations:^
    {
        CGAffineTransform transform = CGAffineTransformRotate(interfaceImage.transform, M_PI_4);
        interfaceImage.transform = transform;
        
    }];
}





- (IBAction)moveImage:(UIPanGestureRecognizer*)recognizer {
    
    CGPoint translation = [recognizer translationInView:self.view];
    interfaceImage.center = CGPointMake(interfaceImage.center.x + translation.x,
                                         interfaceImage.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:interfaceScrollView];
}


#pragma mark- UIScrollView Delegate

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return interfaceImage;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}


- (void)centerScrollViewContents {
    // This method centers the scroll view contents also used on did zoom
    CGSize boundsSize = interfaceScrollView.bounds.size;
    CGRect contentsFrame = interfaceImage.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    interfaceImage.frame = contentsFrame;
}


#pragma mark - Memory Check

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
            //[self performSelectorOnMainThread:@selector(showMemory:) withObject:memory waitUntilDone:NO];
            return YES;
        }
    }
    NSLog(@"memory=%@",memory);
    
    
    return NO;
}



-(void)stopRecordForMemoryOver
{
    if (isRecording) {
        [self recordVideo:nil];
    }
    
    [CustomToast showWithText:@"There is not enough space to store data. Please clean up your device and try again."
                    superView:self.view
                    bLandScap:YES];
}

#pragma mark - Handling Rotation


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (interfaceScrollView.zoomScale != 1.0f || atan2f(interfaceImage.transform.b, interfaceImage.transform.a) != 0 )
    {
        interfaceScrollView.zoomScale=1.0f;
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(0);
        interfaceScrollView.transform = transform;
        
        interfaceScrollView.center = CGPointMake(self.view.center.x ,
                                                 self.view.center.y );
        interfaceImage.center = interfaceScrollView.center;
    }

}


#pragma mark - View Disappears


-(void)viewDidDisappear:(BOOL)animated
{
    [connection cancel];
}

-(void)viewWillDisappear:(BOOL)animated
{
    if(isRecording)
        [self recordVideo:nil];
}



@end
