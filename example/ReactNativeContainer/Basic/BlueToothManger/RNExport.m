//
//  ViewController.m
//  ReactNativeContainer
//
//  Created by Orange on 2018/9/18.
//  Copyright © 2018年 Orange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>


@interface RCT_EXTERN_MODULE(ViewController, UIViewController)
RCT_EXTERN_METHOD(popViewController: (BOOL)animated)
RCT_EXTERN_METHOD(dissMissViewController: (BOOL)animated)

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}
@end

@interface RCT_EXTERN_MODULE(BLEManager, NSObject)
RCT_EXTERN_METHOD(scanPeripherals:(double)a serviceUUIDs:(NSArray *)b options:(NSDictionary *)c)

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}
@end

@interface RCT_EXTERN_MODULE(BLERNEventSender, RCTEventEmitter)
RCT_EXTERN_METHOD(supportedEvents)

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}
@end
