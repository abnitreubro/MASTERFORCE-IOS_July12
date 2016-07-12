//
//  RemoteDownloadFiles.h
//  P2PCamera
//
//  Created by Tsang on 13-1-29.
//
//

#ifndef __P2PCamera__RemoteDownloadFiles__
#define __P2PCamera__RemoteDownloadFiles__

#include <iostream>
#import <Foundation/Foundation.h>
#import "defineutility.h"
class RemoteDownload{
public:
    RemoteDownload(NSString *filePath);
    ~RemoteDownload();
    void sendData(char *pbuf,unsigned int length);
    void close();
private:
    FILE *mfile;
    NSString *fPath;
};


#endif /* defined(__P2PCamera__RemoteDownloadFiles__) */
