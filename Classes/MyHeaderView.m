//
//  MyHeaderView.m
//  P2PCamera
//
//  Created by Tsang on 13-1-28.
//
//

#import "MyHeaderView.h"

@implementation MyHeaderView
@synthesize open;
@synthesize strName;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor grayColor];
        imgView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 12, 17, 17)];
        imgView.image=[UIImage imageNamed:@"arrow.png"];
        [self addSubview:imgView];
        labelName=[[UILabel alloc]initWithFrame:CGRectMake(30, 0, 150, 40)];
        //labelName.textAlignment=UITextAlignmentCenter;
        labelName.backgroundColor=[UIColor clearColor];
        [self addSubview:labelName];
    }
    return self;
}
-(void)dealloc
{
    [labelName release];
    [imgView release];
    [strName release];
    [super dealloc];
}
-(void)setStrName:(NSString *)str{
    [strName release];
    strName=[str retain];
    labelName.text=strName;
}
-(void)setOpen:(BOOL)theOpen{
    open=theOpen;
   
    if (open) {
      

        imgView.image=[UIImage imageNamed:@"arrowdown.PNG"];
    }else{
        

        imgView.image=[UIImage imageNamed:@"arrow.png"];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
