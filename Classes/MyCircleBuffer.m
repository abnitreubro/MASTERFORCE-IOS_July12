//
//  MyCircleBuffer.m
//  P2PCamera
//
//  Created by Tsang on 13-1-24.
//
//

#import "MyCircleBuffer.h"


@implementation MyCircleBuffer
-(id)init{
    self=[super init];
    buff=new char[VBUF_SIZE];
    sum=VBUF_SIZE;
    readPos=0;
    writePos=0;
    stock=0;
    return  self;
}
-(void)writeOneFrame:(char *)pbuf Len:(int)size{
    if (stock+size>sum) {//buff满了
        NSLog(@"buff 满了");
        return;
    }
    int offset=sum-writePos;
    if (offset>size) {
        memcpy(&buff[writePos], pbuf, size);
        writePos+=size;
    }else{
        memcpy(&buff[writePos], pbuf, offset);
        int left=size-offset;
        memcpy(buff, &pbuf[offset], left);
        writePos=left;
    }
    stock+=size;
}
-(char *)readOneFrame{
    AVI_BUFF_HEAD aviHead;
   int result= [self read:(char*)&aviHead Size:sizeof(aviHead)];
    if (result==0) {
        return NULL;
    }
    char *pbuf=new char[aviHead.length];
    if (pbuf==NULL) {
        return NULL;
    }
    result=[self read:pbuf Size:aviHead.length];
    if (result==0) {
      delete pbuf;
        return NULL;
    }
    return pbuf; 
}
-(int)read:(void *)buf Size:(int)size{
    if (stock<size) {
        return 0;
    }
    if (writePos>readPos) {
        memcpy(buf, &buff[readPos], size);
        readPos+=size;
    }else{
        int offset=sum-readPos;
        if (offset>size) {
            memcpy(buf, &buff[readPos], size);
            readPos+=size;
        }else{
            memcpy(buf, &buff[readPos], offset);
            int left=size-offset;
            memcpy(&((char*)buf)[offset], buff, left);
            readPos=left;
        }
    }
    
    stock-=size;
    return size;
}
@end
