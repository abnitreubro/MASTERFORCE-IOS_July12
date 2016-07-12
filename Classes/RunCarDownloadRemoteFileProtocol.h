//
//  RunCarDownloadRemoteFileProtocol.h
//  P2PCamera
//
//  Created by Tsang on 13-1-29.
//
//

#import <Foundation/Foundation.h>

@protocol RunCarDownloadRemoteFileProtocol <NSObject>

-(void)PlaybackDownloadDataResult:(char *)pbuf Len:(int)length CurrData:(unsigned int)curData TotalData:(unsigned int)totalData;
@end
