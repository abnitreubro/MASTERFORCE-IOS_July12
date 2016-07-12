//
//  AboutCell.m
//  P2PCamera
//
//  Created by mac on 12-10-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AboutCell.h"

@implementation AboutCell

@synthesize labelItem;
@synthesize labelVersion;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) dealloc
{
    self.labelItem = nil;
    self.labelVersion = nil;
    [super dealloc];
}

@end
