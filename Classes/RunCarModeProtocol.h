//
//  RunCarModeProtocol.h
//  P2PCamera
//
//  Created by Tsang on 12-12-24.
//
//

#import <Foundation/Foundation.h>

@protocol RunCarModeProtocol <NSObject>
-(void)runcarStatusResult:(NSString *)did  Sysver:(NSString *)sysver DevName:(NSString *)devname Devid:(NSString *)devid AlarmStatus:(int )alarmstatus SdCardStatus:(int) sdstatus SdcardTotalSize:(int)totalsize SdcardRemainSize:(int)remainsize Mac:(NSString *)mac WifiMac:(NSString *)wifimac DNSstatus:(int)dns_status UPNPstatus:(int)upnp_status;
@end
