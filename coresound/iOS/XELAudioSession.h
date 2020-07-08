//
//  XELAudioSession.h
//  XSound
//
//  Created by Andy on 2020/7/6.
//

#ifndef XELAudioSession_h
#define XELAudioSession_h

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

extern const NSTimeInterval AUSAudioSessionLatency_Background;
extern const NSTimeInterval AUSAudioSessionLatency_Default;
extern const NSTimeInterval AUSAudioSessionLatency_LowLatency;

@interface XELAudioSession : NSObject

+ (XELAudioSession*)sharedInstance;

@property(nonatomic, strong) AVAudioSession* audioSession;
@property(nonatomic, assign) Float64 preferredSampleRate;
@property(nonatomic, assign, readonly) Float64 currentSampleRate;
@property(nonatomic, assign) NSTimeInterval preferredLatency;
@property(nonatomic, assign) BOOL active;
@property(nonatomic, strong) NSString* category;

- (void)addRouteChangedListener;

@end

#endif /* XELAudioSession_h */
