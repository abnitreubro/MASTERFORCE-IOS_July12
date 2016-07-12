//
//  BufferEntry.h
//  P2PCamera
//
//  Created by Tsang on 13-1-24.
//
//

#import <Foundation/Foundation.h>
#import "obj_common.h"
@interface BufferEntry : NSObject{
    int len;
    char *data;
    int type;
}
@property int len;
@property char *data;
@property int type;
@end
