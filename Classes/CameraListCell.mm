//
//  CameraListCell.m
//  IpCameraClient
//
//  Created by jiyonglong on 12-4-24.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CameraListCell.h"


@implementation CameraListCell

@synthesize imageCamera;
@synthesize NameLable;
@synthesize PPPPIDLable;
@synthesize PPPPStatusLable;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.     
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {    
    [super setSelected:selected animated:animated];    
    // Configure the view for the selected state.
}


- (void)dealloc {
    self.imageCamera = nil;
    self.NameLable = nil;
    self.PPPPIDLable = nil;
    self.PPPPStatusLable = nil;   
    [super dealloc];
}


@end
