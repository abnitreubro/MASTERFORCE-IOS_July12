//
//  GestureUITableView.h
//  P2PCamera
//
//  Created by Tsang on 13-1-30.
//
//

#import <UIKit/UIKit.h>
@protocol GestureTableDelegate<NSObject>
-(void)rowLongPressed:(UILongPressGestureRecognizer *)theLong;
@end
@interface GestureUITableView : UITableView
@property(nonatomic,assign)id<GestureTableDelegate>gestureDelegate;
@end
