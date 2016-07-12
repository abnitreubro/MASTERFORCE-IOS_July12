//
//  CameraListCell.h
//  IpCameraClient
//
//  Created by jiyonglong on 12-4-24.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CameraListCell : UITableViewCell {
    
    IBOutlet UIImageView *imageCamera;    
    IBOutlet UILabel *NameLable;     
    IBOutlet UILabel *PPPPIDLable;    
    IBOutlet UILabel *PPPPStatusLable;  
    
}

@property (nonatomic, retain) UIImageView *imageCamera;
@property (nonatomic, retain) UILabel *NameLable;
@property (nonatomic, retain) UILabel *PPPPIDLable;
@property (nonatomic, retain) UILabel *PPPPStatusLable;

@end
