//
//  RemoteDownloadFiles.cpp
//  P2PCamera
//
//  Created by Tsang on 13-1-29.
//
//

#include "RemoteDownloadFiles.h"
RemoteDownload::RemoteDownload(NSString *filePath){
    
    fPath=filePath;
    mfile=fopen((char *)[fPath UTF8String], "wb");
        if (mfile==NULL) {
            NSLog(@"second create file in c language");
             mfile=fopen((char *)[filePath UTF8String], "wb");
        }else{
           NSLog(@"mfile=!!!!==1111111");
        }
  
}

RemoteDownload::~RemoteDownload(){
    //[fPath release];
    fPath=nil;
}

void RemoteDownload::sendData(char *pbuf, unsigned int length){
    char *buff=new char[length];
    memcpy(buff, pbuf, length);
    fwrite(pbuf, 1, length, mfile);
    SAFE_DELETE(buff);
}

void RemoteDownload::close(){
    fclose(mfile);
}