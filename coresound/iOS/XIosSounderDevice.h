//
//  XIosSounderDevice.h
//  XSound
//
//  Created by Oogh on 2020/7/6.
//  Copyright © 2020 Oogh. All rights reserved.
//

#ifndef XIosSounderDevice_h
#define XIosSounderDevice_h

@protocol FillAudioDataDelegate <NSObject>
- (NSInteger)fillAudioData:(SInt16*)samples frames:(NSInteger)frames channels:(NSInteger)channels;
@end

@interface XIosSounderDevice : NSObject

@property(nonatomic, assign) Float64 sampleRate;
@property(nonatomic, assign) Float64 channels;

- (id)initWidthChannels:(NSInteger)channels
            sampleRate:(NSInteger)sampleRate
         bytesPerSample:(NSInteger)bytesPerSample
  fillAudioDataDelegate:(id<FillAudioDataDelegate>)fillAudioDataDelegate;

- (BOOL)start;

- (void)stop;

@end


#endif /* XIosSounderDevice_h */
