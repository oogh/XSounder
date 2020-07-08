//
//  XELAudioSession.m
//  XSound
//
//  Created by Andy on 2020/7/6.
//

#import "XELAudioSession.h"
#import "XAVAudioSession+RouteUtils.h"

const NSTimeInterval AUSAudioSessionLatency_Background = 0.0929;
const NSTimeInterval AUSAudioSessionLatency_Default = 0.0232;
const NSTimeInterval AUSAudioSessionLatency_LowLatency = 0.0058;

@implementation XELAudioSession

+ (XELAudioSession*) sharedInstance {
    static XELAudioSession* instance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[XELAudioSession alloc] init];
    });
    return instance;
}

- (id)init {
    if ((self = [super init])) {
        _preferredSampleRate = 44100.0;
        _currentSampleRate = 44100.0;
        _audioSession = [AVAudioSession sharedInstance];
    }
    return self;
}

- (void)setCategory:(NSString *)category {
    _category = category;
    NSError* error = nil;
    if (![self.audioSession setCategory:_category error:&error]) {
        NSLog(@"[XELAudioSession] setCategory failed: %@", error.localizedDescription);
    }
}

- (void)setActive:(BOOL)active {
    _active = active;
    
    NSError* error = nil;
    if (![self.audioSession setPreferredSampleRate:_preferredSampleRate error:&error]) {
        NSLog(@"[XELAudioSession] setPreferredSampleRate failed: %@", error.localizedDescription);
    }
    
    if (![self.audioSession setActive:_active error:&error]) {
        NSLog(@"[XELAudioSession] setActive failed: %@", error.localizedDescription);
    }
    
    _currentSampleRate = [self.audioSession sampleRate];
}

- (void)setPreferredLatency:(NSTimeInterval)preferredLatency {
    _preferredSampleRate = preferredLatency;
    
    NSError* error = nil;
    if (![self.audioSession setPreferredIOBufferDuration:_preferredLatency error:&error]) {
        NSLog(@"[XELAudioSession] setPreferredIOBufferDuration failed: %@", error.localizedDescription);
    }
}

- (void)addRouteChangedListener {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotificationAudioRouteChanged)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    [self adjustOnRouteChange];
}

#pragma mark - notification observer

- (void)onNotificationAudioRouteChanged:(NSNotification*)sender {
    [self adjustOnRouteChange];
}

- (void)adjustOnRouteChange {
    AVAudioSessionRouteDescription *currentRoute = [[AVAudioSession sharedInstance] currentRoute];
    if (currentRoute) {
        if ([[AVAudioSession sharedInstance] usingWiredMicrophone]) {
        } else {
            if (![[AVAudioSession sharedInstance] usingBlueTooth]) {
                [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
            }
        }
    }
}

@end
