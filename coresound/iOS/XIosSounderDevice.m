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

- (void)dealloc {
    if (_outData) {
        free(_outData);
        _outData = NULL;
    }
    
    [self destroyAudioUnitGraph];
    
    [self removeAudioSessionInterruptedObserver];
}

#pragma mark - Public

- (BOOL)start {
    OSStatus status = AUGraphStart(_auGraph);
    checkStatus(status, @"[XIosSounderDevice] AUGraphStart failed!", YES);
    return YES;
}

- (void)stop {
    OSStatus status = AUGraphStop(_auGraph);
    checkStatus(status, @"[XIosSounderDevice] AUGraphStop failed!", YES);
}

#pragma mark - Private

- (void)createAudioUnitGraph {
    OSStatus status = noErr;
    status = NewAUGraph(&_auGraph);
    checkStatus(status, @"[XIosSounderDevice] NewAUGraph failed!", YES);
    
    [self addAudioUnitNodes];
    
    status = AUGraphOpen(_auGraph);
    checkStatus(status, @"[XIosSounderDevice] AUGraphOpen failed!", YES);
    
    [self readUnitsFromNodes];
    
    [self setAudioUnitProperties];
    
    [self makeNodeConnections];
    
    CAShow(_auGraph);
    
    status = AUGraphInitialize(_auGraph);
    checkStatus(status, @"[XIosSounderDevice] AUGraphInitialize failed!", YES);
}

- (void)addAudioUnitNodes {
    OSStatus status = noErr;
    
    AudioComponentDescription ioDescription;
    bzero(&ioDescription, sizeof(ioDescription));
    ioDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    ioDescription.componentType = kAudioUnitType_Output;
    ioDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    
    status = AUGraphAddNode(_auGraph, &ioDescription, &_auNode);
    checkStatus(status, @"[XIosSounderDevice] AUGraphAddNode(I/O) failed!", YES);
    
    AudioComponentDescription convertDescription;
    bzero(&convertDescription, sizeof(convertDescription));
    convertDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    convertDescription.componentType = kAudioUnitType_FormatConverter;
    convertDescription.componentSubType = kAudioUnitSubType_AUConverter;
    status = AUGraphAddNode(_auGraph, &convertDescription, &_convertNode);
    checkStatus(status, @"[XIosSounderDevice] AUGraphAddNode(Convert) failed!", YES);
}

- (void)readUnitsFromNodes {
    OSStatus status = noErr;
    
    status = AUGraphNodeInfo(_auGraph, _auNode, NULL, &_audioUnit);
    checkStatus(status, @"[XIosSounderDevice] AUGraphNodeInfo(I/O) failed!", YES);
    
    status = AUGraphNodeInfo(_auGraph, _convertNode, NULL, &_convertAudioUnit);
    checkStatus(status, @"[XIosSounderDevice] AUGraphNodeInfo(Convert) failed!", YES);
}

- (void)setAudioUnitProperties {
    OSStatus status = noErr;
    
    AudioStreamBasicDescription streamDescription = [self nonInterleavedPCMFormatWithChannels:_channels];
    
    status = AudioUnitSetProperty(_audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, inputElement, &streamDescription, sizeof(streamDescription));
    checkStatus(status, @"[XIosSounderDevice] AudioUnitSetProperty failed!", YES);
    
    AudioStreamBasicDescription clientFormat16Int;
    UInt32 bytesPerSample = sizeof(SInt16);
    bzero(&clientFormat16Int, sizeof(clientFormat16Int));
    clientFormat16Int.mFormatID = kAudioFormatLinearPCM;
    clientFormat16Int.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    clientFormat16Int.mBytesPerPacket = bytesPerSample * _channels;
    clientFormat16Int.mFramesPerPacket = 1;
    clientFormat16Int.mBytesPerFrame = bytesPerSample * _channels;
    clientFormat16Int.mChannelsPerFrame = _channels;
    clientFormat16Int.mBitsPerChannel = bytesPerSample * 8;
    clientFormat16Int.mSampleRate = _sampleRate;
    
    // spectial format for converter
    status = AudioUnitSetProperty(_convertAudioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &streamDescription, sizeof(streamDescription));
    checkStatus(status, @"[XIosSounderDevice] AudioUnitSetProperty(Output) failed!", YES);
    
    status = AudioUnitSetProperty(_convertAudioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &clientFormat16Int, sizeof(clientFormat16Int));
    checkStatus(status, @"[XIosSounderDevice] AudioUnitSetProperty(Input) failed!", YES);
}

- (AudioStreamBasicDescription)nonInterleavedPCMFormatWithChannels:(UInt32)channels {
    UInt32 bytesPerSample = sizeof(Float32);
    
    AudioStreamBasicDescription streamDescription;
    bzero(&streamDescription, sizeof(streamDescription));
    streamDescription.mSampleRate = _sampleRate;
    streamDescription.mFormatID = kAudioFormatLinearPCM;
    streamDescription.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    streamDescription.mBitsPerChannel = bytesPerSample * 8;
    streamDescription.mBytesPerFrame = bytesPerSample;
    streamDescription.mBytesPerPacket = bytesPerSample;
    streamDescription.mFramesPerPacket = 1;
    streamDescription.mChannelsPerFrame = channels;
    return streamDescription;
}

- (void)makeNodeConnections {
    OSStatus status = noErr;
    
    status = AUGraphConnectNodeInput(_auGraph, _convertNode, 0, _auNode, 0);
    checkStatus(status, @"[XIosSounderDevice] AUGraphConnectNodeInput failed!", YES);
    
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = &InputRenderCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)self;
    
    status = AudioUnitSetProperty(_convertAudioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &callbackStruct, sizeof(callbackStruct));
    checkStatus(status, @"[XIosSounderDevice] AudioUnitSetProperty failed!", YES);
}

- (OSStatus)renderData:(AudioBufferList*)auData
           atTimeStamp:(const AudioTimeStamp*)auTimeStamp
            forElement:(UInt32)element
          numberFrames:(UInt32)numFrames
                 flags:(AudioUnitRenderActionFlags*)flags {
    for (int iBuffer = 0; iBuffer < auData->mNumberBuffers; ++iBuffer) {
        memset(auData->mBuffers[iBuffer].mData, 0, auData->mBuffers[iBuffer].mDataByteSize);
    }
    
    if (_fillAudioDataDelegate) {
        [_fillAudioDataDelegate fillAudioData:_outData frames:numFrames channels:_channels];
        for (int iBuffer = 0; iBuffer < auData->mNumberBuffers; ++iBuffer) {
            memcpy((SInt16*)auData->mBuffers[iBuffer].mData, _outData, auData->mBuffers[iBuffer].mDataByteSize);
        }
    }
    return noErr;
}

- (void)destroyAudioUnitGraph {
    AUGraphStop(_auGraph);
    AUGraphUninitialize(_auGraph);
    AUGraphClose(_auGraph);
    AUGraphRemoveNode(_auGraph, _auNode);
    DisposeAUGraph(_auGraph);
    _audioUnit = NULL;
    _auNode = 0;
    _auGraph = NULL;
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

static OSStatus InputRenderCallback(void *inRefCon,
                                    AudioUnitRenderActionFlags *auActionFlags,
                                    const AudioTimeStamp *auTimeStamp,
                                    UInt32 inBusNumber,
                                    UInt32 inNumberFrames,
                                    AudioBufferList *auData) {
    XIosSounderDevice * isd = (__bridge id) inRefCon;
    return [isd renderData: auData
               atTimeStamp: auTimeStamp
                forElement: inBusNumber
              numberFrames: inNumberFrames
                     flags: auActionFlags];
}

@end
