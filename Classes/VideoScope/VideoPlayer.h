//
//  VideoPlayer.h
//  P2PCamera
//
//  Created by JS Products on 20/04/16.
//
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>


@interface VideoPlayer : UIViewController
{
    UIBarButtonItem *shareBtn;
    IBOutlet UIImageView *videoImage;
    IBOutlet NSLayoutConstraint *imageHeightConstraint;
    IBOutlet UIView *imageContainingView;
    
    AVPlayerLayer  *playerLayer;
    AVAsset  * asset;
    AVPlayerItem * playerItem;
    
    id playbackObserver;

    IBOutlet UIView *transparentControlView;
    IBOutlet UIView *controlsView;
    IBOutlet UILabel *labelStartTime;
    IBOutlet UILabel *labelStopTime;
    IBOutlet UISlider *movieSlider;
    IBOutlet UIButton *playStopButton;
    
    BOOL isPlaying,isSliding;
}

- (IBAction)movieSliderAction:(id)sender;

- (IBAction)playStopButton:(id)sender;

@property (strong,nonatomic)     AVPlayer * player;



@property (strong, nonatomic) NSString *strVideoPath;


@end
