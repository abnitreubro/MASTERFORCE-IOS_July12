//
//  MySetDialog.m
//  P2PCamera
//
//  Created by Tsang on 13-5-6.
//
//

#import "MySetDialog.h"
#import <QuartzCore/QuartzCore.h>
@implementation MySetDialog
@synthesize btnArr;
@synthesize diaDelegate;

- (id)initWithFrame:(CGRect)frame Btn:(int)num
{
    self = [super initWithFrame:frame];
    
    btnArr=[[NSMutableArray alloc]init];
    
    if (self) {
        int width=frame.size.width;
        int height=frame.size.height;
        int btnHeight=(height-5*(num+1))/num;
        int btnWidth=width-10;
        for (int i=0; i<num; i++) {
            
            UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
           
            
            btn.frame=CGRectMake(5,5*(i+1)+btnHeight*i,btnWidth,btnHeight);
            btn.tag=i;
            btn.backgroundColor=[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.8];
            [btn setBackgroundImage:[UIImage imageNamed:@"dialogbtnselect.png"] forState:UIControlStateHighlighted];
            [btn setBackgroundImage:[UIImage imageNamed:@"dialogbtnselect.png"] forState:UIControlStateSelected];
           // [btn setTitle:@"2222" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            [btnArr addObject:btn];

        }
       //[(UIButton *)[btnArr objectAtIndex:2] setTitle:<#(NSString *)#> forState:<#(UIControlState)#>]
    }
    
    
    return self;
}

-(void)onClick:(id)sender{
    
    UIButton *btn=(UIButton *)sender;
    int tag=btn.tag;
    NSLog(@"tag=%d",tag);
    
    switch (tag) {
        case 0:{
            ((UIButton *)[btnArr objectAtIndex:0]).selected=YES;
            ((UIButton *)[btnArr objectAtIndex:1]).selected=NO;
            [diaDelegate mySetDialogOnClick:0];
        }
            break;
        case 1:
        {
            ((UIButton *)[btnArr objectAtIndex:1]).selected=YES;
            ((UIButton *)[btnArr objectAtIndex:0]).selected=NO;
            [diaDelegate mySetDialogOnClick:1];
        }
            break;
        case 2:
            [diaDelegate mySetDialogOnClick:2];
            break;
        default:
            break;
    }
}
-(void)setBtnImag:(UIImage *)img Index:(int)index{
    [[btnArr objectAtIndex:index] setImage:img forState:UIControlStateNormal];
}
-(void)setBtnTitle:(NSString *)title Index:(int)index{
    [[btnArr objectAtIndex:index] setTitle:title forState:UIControlStateNormal];
}
-(void)dealloc{
    
    [super dealloc];
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
