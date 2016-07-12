//
//  ShowImageViewController.h
//  VideoScope
//
//  Created by JS Products on 15/03/16.
//  Copyright © 2016  JS Products. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface ShowImageViewController : UIViewController<UIScrollViewDelegate>
{
    
    IBOutlet UIImageView *interfaceImage;
    IBOutlet UIScrollView *interFaceScrollView;
    
}

@property (nonatomic, strong) NSString* strImagePath;

@end
