//
//  XAVAudioSession+RouteUtils.h
//  XSound
//
//  Created by Andy on 2020/7/6.
//

#ifndef XAVAudioSession_RouteUtils_h
#define XAVAudioSession_RouteUtils_h

#import <AVFoundation/AVFoundation.h>

@interface AVAudioSession (RouteUtils)

- (BOOL)usingBlueTooth;

- (BOOL)usingWiredMicrophone;

- (BOOL)shouldShowEarphoneAlert;

@end


#endif /* XAVAudioSession_RouteUtils_h */
