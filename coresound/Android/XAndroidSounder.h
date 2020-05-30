//
// Created by Oogh on 2020/3/19.
//

#ifndef XANDROID_SOUNDER_H
#define XANDROID_SOUNDER_H

#include "XSounder.h"
extern  "C" {
#include <SLES/OpenSLES.h>
#include <SLES/OpenSLES_Android.h>
};


class XAndroidSounder : public XSounder {
public:
    XAndroidSounder();

    ~XAndroidSounder() override;

    void setup() override;

    void start() override;

    int getPCMData(void** pcm);

    SLAndroidSimpleBufferQueueItf getDataQueue();

private:


private:
    // 引擎对象
    SLObjectItf mEngineObject;
    SLEngineItf mEngine;

    // 混音器
    SLObjectItf mMixer;
    SLEnvironmentalReverbItf mMixReverb;
    SLEnvironmentalReverbSettings mMixReverbSettings = SL_I3DL2_ENVIRONMENT_PRESET_STONECORRIDOR;

    // 播放器
    SLObjectItf  mPlayerObject;
    SLPlayItf mPlayer;
    SLVolumeItf mVolume;

    // 数据缓冲队列
    SLAndroidSimpleBufferQueueItf mDataQueue;

    FILE* mInput;

    uint8_t* mOutBuffer;
};
#endif //XANDROID_SOUNDER_H
