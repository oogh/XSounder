//
// Created by Oogh on 2020/3/19.
//

#include "XAndroidSounderAL.h"
#include "XLogger.h"
#include "XException.h"

XAndroidSounderAL::XAndroidSounderAL() {

}

XAndroidSounderAL::~XAndroidSounderAL() {

}

void XAndroidSounderAL::setup() {
    mInput = fopen(mFilename.data(), "r");
    if (!mInput) {
        throw XException("[XAndroidSounderAL] open file failed\n");
    }

    mALPlayer = new XALPlayer();
    bool success = mALPlayer->ConfigOpenAL(2, 16, 44100);
    if (!success) {
        LOGE("[XAndroidSounderAL] ConfigOpenAL failed!");
        return;
    }

    mOutBuffer = reinterpret_cast<uint8_t *>(malloc(4096 * 3));
    if (mInput) {
        size_t ret = fread(mOutBuffer, 1, 3 * 4096, mInput);
        mALPlayer->OpenAudio(mOutBuffer, (uint) ret);
        mALPlayer->PlaySound();
    }

}

void XAndroidSounderAL::start() {

    setup();

    size_t ret;
    while (!feof(mInput)) {
        int val = mALPlayer->NumOfBuffProcessed();
        if (0 >= val) { // 一个 buf 都还没处理完，持续等待播放
            continue;
        }
        while (val--) {
            // 读取下一缓存区数据
            ret = fread(mOutBuffer, 1, 4096, mInput);

            mALPlayer->OpenAudio(mOutBuffer, (uint) ret);
        }
    }
}