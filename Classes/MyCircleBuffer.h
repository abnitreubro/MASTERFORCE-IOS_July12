//
//  MyCircleBuffer.h
//  P2PCamera
//
//  Created by Tsang on 13-1-24.
//
//

#import <Foundation/Foundation.h>
#import "defineutility.h"
@interface MyCircleBuffer : NSObject
{
    char *buff;
    int sum;
    int readPos;
    int writePos;
    int stock;
}
-(void)writeOneFrame:(char *)pbuf Len:(int)size;
-(char *)readOneFrame;
@end
