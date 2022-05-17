//
//  CDVObsClient.h
//  aeolian
//
//  Created by 顾九 on 2020/5/11.
//

#import <Cordova/CDVPlugin.h>

@interface CDVObsClient : CDVPlugin

- (void)upload:(CDVInvokedUrlCommand*)command;

@end
