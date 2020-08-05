//
//  XIosSounder.h
//  XSound
//
//  Created by Oogh on 2020/07/06.
//  Copyright © 2020 Oogh. All rights reserved.
//

#import "XIosSounderAL.h"
#import "XWeakProxy.h"
#import "XALPlayer.h"

@interface XIosSounderAL()
{
    XALPlayer* _alPlayer;
    uint8_t* _buffer;
    FILE* _inputFile;
}
@end

@implementation XIosSounderAL

- (void)setInput:(NSString*)filename {
    _inputFile = fopen(filename.UTF8String, "r");
    if (!_inputFile) {
        NSLog(@"[XIosSounder] setInput failed: %s\n", filename.UTF8String);
        return;
    }
}

- (void)start {
    [self setup];
    size_t ret;
    while (!feof(_inputFile))
    {
        int val = _alPlayer->NumOfBuffProcessed();
        if (0 >= val) // 一个 buf 都还没处理完，持续等待播放
        {
            continue;
        }
        while (val--) {
            // 读取下一缓存区数据
            ret = fread(_buffer, 1, 4096, _inputFile);
            
            _alPlayer->OpenAudio(_buffer, (uint)ret);
        }
    }
}

- (void)stop {
    if (_inputFile) {
        fclose(_inputFile);
        _inputFile = nil;
    }
}

- (void)setup {
    _alPlayer = new XALPlayer();
    bool result = _alPlayer->ConfigOpenAL(2, 16, 44100);
    if (!result) {
        NSLog(@"[XIosSounderAL] ConfigOpenAL failed!");
        return;
    }
    
    _buffer = reinterpret_cast<uint8_t*>(malloc(3 * 4096));
    if (_inputFile) {
        size_t ret = fread(_buffer, 1, 3 * 4096, _inputFile);
        _alPlayer->OpenAudio(_buffer, (uint)ret);
        _alPlayer->PlaySound();
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
