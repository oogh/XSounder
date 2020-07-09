//
//  XIosSounder.h
//  XSound
//
//  Created by Oogh on 2020/07/06.
//  Copyright © 2020 Oogh. All rights reserved.
//

#import "XIosSounder.h"
#import "XWeakProxy.h"
#import "XIosSounderDevice.h"

@interface XIosSounder()<FillAudioDataDelegate>
{
    XIosSounderDevice* _sounderDevice;
    FILE* _inputFile;
}
@end

@implementation XIosSounder

- (void)setInput:(NSString*)filename {
    _inputFile = fopen(filename.UTF8String, "r");
    if (!_inputFile) {
        NSLog(@"[XIosSounder] setInput failed: %s\n", filename.UTF8String);
        return;
    }
}

- (void)start {
    if (!_sounderDevice) {
        _sounderDevice = [[XIosSounderDevice alloc] initWidthChannels:2 sampleRate:44100 bytesPerSample:2 fillAudioDataDelegate:self];
    }
    [_sounderDevice start];
}

- (void)stop {
    if (_sounderDevice) {
        [_sounderDevice stop];
        _sounderDevice = nil;
    }
}

- (NSInteger)fillAudioData:(SInt16 *)samples frames:(NSInteger)frames channels:(NSInteger)channels {
    memset(samples, 0, frames * channels * sizeof(SInt16));
    // 填充音频数据
    if (_inputFile) {
        fread(samples, 1, frames * channels * sizeof(SInt16), _inputFile);
    }
    return 1;
}

@end
