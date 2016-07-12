//
//  PicDirCell.h
//  P2PCamera
//
//  Created by mac on 12-11-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PicDirCell : UITableViewCell{
    IBOutlet UILabel *labelName;
    IBOutlet UIImageView *imageView;
}

@property (nonatomic, retain) UILabel *labelName;
@property (nonatomic, retain) UIImageView *imageView;

@end
