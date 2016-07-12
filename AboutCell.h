//
//  AboutCell.h
//  P2PCamera
//
//  Created by mac on 12-10-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutCell : UITableViewCell{
    IBOutlet UILabel *labelItem;
    IBOutlet UILabel *labelVersion;
}

@property (nonatomic, retain) UILabel *labelItem;
@property (nonatomic, retain) UILabel *labelVersion;

@end
