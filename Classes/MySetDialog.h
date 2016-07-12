//
//  MySetDialog.h
//  P2PCamera
//
//  Created by Tsang on 13-5-6.
//
//

#import <UIKit/UIKit.h>
@protocol MySetDialogDelegate<NSObject>

-(void)mySetDialogOnClick:(int)tag;

@end

@interface MySetDialog : UIView{
    NSMutableArray *btnArr;
    id<MySetDialogDelegate> diaDelegate;
}

@property (nonatomic,assign)id<MySetDialogDelegate> diaDelegate;

@property (nonatomic,retain)NSMutableArray *btnArr;
- (id)initWithFrame:(CGRect)frame Btn:(int)num;
-(void)setBtnImag:(UIImage *)img Index:(int)index;
-(void)setBtnTitle:(NSString *)title Index:(int)index;
@end
