//
//  MyHeaderView.h
//  P2PCamera
//
//  Created by Tsang on 13-1-28.
//
//

#import <UIKit/UIKit.h>

@interface MyHeaderView : UIView
{
    UILabel *labelName;
    UIImageView *imgView;
    NSString *strName;
    BOOL open;
}
@property (nonatomic,copy)NSString *strName;
@property(nonatomic,assign)BOOL open;
@end
