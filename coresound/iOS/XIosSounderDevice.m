//
//  XIosSounderDevice.m
//  XSound
//
//  Created by Oogh on 2020/7/6.
//  Copyright © 2020 Oogh. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <Accelerate/Accelerate.h>
#import "XIosSounderDevice.h"
#import "XELAudioSession.h"

static const AudioUnitElement inputElement = 1;

@interface XIosSounderDevice() {
    SInt16 *_outData;
}

@property(nonatomic, assign) AUGraph auGraph;
@property(nonatomic, assign) AUNode auNode;
@property(nonatomic, assign) AudioUnit audioUnit;
@property(nonatomic, assign) AUNode convertNode;
@property(nonatomic, assign) AudioUnit convertAudioUnit;

@property(readwrite, copy) id<FillAudioDataDelegate> fillAudioDataDelegate;

@end

const float SMAudioIOBufferDurationSmall = 0.0058f;

@implementation XIosSounderDevice

- (id)initWidthChannels:(NSInteger)channels
          sampleRate:(NSInteger)sampleRate
       bytesPerSample:(NSInteger)bytesPerSample
fillAudioDataDelegate:(id<FillAudioDataDelegate>)fillAudioDataDelegate {
    if ((self = [super init])) {
        [[XELAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback];
        [[XELAudioSession sharedInstance] setPreferredSampleRate:sampleRate];
        [[XELAudioSession sharedInstance] setActive:YES];
        [[XELAudioSession sharedInstance] setPreferredLatency:SMAudioIOBufferDurationSmall * 4];
        [[XELAudioSession sharedInstance] addRouteChangedListener];
        [self addAudioSessionInterruptedObserver];
        
        _outData = (SInt16*)calloc(8192, sizeof(SInt16));
        _fillAudioDataDelegate = fillAudioDataDelegate;
        _sampleRate = sampleRate;
        _channels = channels;
        
        [self createAudioUnitGraph];
    }
    return self;
}

#pragma mark - Public

- (BOOL)start {
    return YES;
}

- (void)stop {
    
}

#pragma mark - Private

- (void)createAudioUnitGraph {
    OSStatus status = noErr;
    status = NewAUGraph(&_auGraph);
    checkStatus(status, @"[XIosSounderDevice] NewAUGraph failed!", YES);
    
    // TODO(oogh): 2020/07/07 从这里开始继续工作...
}


#pragma mark - InterruptedObserver

- (void)addAudioSessionInterruptedObserver {
    [self removeAudioSessionInterruptedObserver];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotificationAudioInterrupted:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:[AVAudioSession sharedInstance]];
}

- (void)removeAudioSessionInterruptedObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                               name:AVAudioSessionInterruptionNotification
                                              object:nil];
}

- (void)onNotificationAudioInterrupted:(NSNotification*)sender {
    AVAudioSessionInterruptionType type = [[[sender userInfo] objectForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    switch (type) {
        case AVAudioSessionInterruptionTypeBegan:
            [self stop];
            break;
        case AVAudioSessionInterruptionTypeEnded:
            [self start];
            break;
        default:
            break;
    }
}

#pragma mark - Static

static void checkStatus(OSStatus status, NSString *msg, BOOL fatal) {
    if (status != noErr) {
        char fourCC[16];
        *(UInt32*)fourCC = CFSwapInt32HostToBig(status);
        fourCC[4] = '\0';
        
        if(isprint(fourCC[0]) && isprint(fourCC[1]) && isprint(fourCC[2]) && isprint(fourCC[3])) {
            NSLog(@"%@: %s", msg, fourCC);
        } else {
            NSLog(@"%@: %d", msg, (int)status);
        }
        
        if (fatal) {
            exit(-1);
        }
    }
}

@end
