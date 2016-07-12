//
//  SearchListCell.h
//  IpCameraClient
//
//  Created by jiyonglong on 12-4-26.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SearchListCell : UITableViewCell {
    
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *addrLabel;
    IBOutlet UILabel *didLabel;

}

@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *addrLabel;
@property (nonatomic, retain) UILabel *didLabel;

@end
