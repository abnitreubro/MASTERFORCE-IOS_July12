//
//  ListTableViewCell.h
//  P2PCamera
//
//  Created by JS Products on 03/05/16.
//
//

#import <UIKit/UIKit.h>

@interface ListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cameraName;
@property (weak, nonatomic) IBOutlet UIImageView *cameraImage;

@end
