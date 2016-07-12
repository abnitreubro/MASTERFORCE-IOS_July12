//
//  RemoteFileSearchResultProtocol.h
//  P2PCamera
//
//  Created by Tsang on 13-2-22.
//
//

#import <Foundation/Foundation.h>

@protocol RemoteFileSearchResultProtocol <NSObject>
-(void)searchResult:(BOOL)isAll  StartTime:(NSString *)startTime EndTime:(NSString *)endTime;
@end
