//
// Created by Oogh on 2020/3/19.
//

#include "XAndroidSounder.h"
#include "XLogger.h"
#include "XException.h"

void printResult(SLresult result) {
    switch (result) {
        case SL_RESULT_SUCCESS    : {
            LOGI("SL_RESULT_SUCCESS");
        }
            break;
        case SL_RESULT_PRECONDITIONS_VIOLATED    : {
            LOGE("SL_RESULT_PRECONDITIONS_VIOLATED");
        }
            break;
        case SL_RESULT_PARAMETER_INVALID    : {
            LOGE("SL_RESULT_PARAMETER_INVALID");
        }
            break;
        case SL_RESULT_MEMORY_FAILURE    : {
            LOGE("SL_RESULT_MEMORY_FAILURE");
        }
            break;
        case SL_RESULT_RESOURCE_ERROR    : {
            LOGE("SL_RESULT_RESOURCE_ERROR");
        }
            break;
        case SL_RESULT_RESOURCE_LOST    : {
            LOGE("SL_RESULT_RESOURCE_LOST");
        }
            break;
        case SL_RESULT_IO_ERROR    : {
            LOGE("SL_RESULT_IO_ERROR");
        }
            break;
        case SL_RESULT_BUFFER_INSUFFICIENT    : {
            LOGE("SL_RESULT_BUFFER_INSUFFICIENT");
        }
            break;
        case SL_RESULT_CONTENT_CORRUPTED    : {
            LOGE("SL_RESULT_CONTENT_CORRUPTED");
        }
            break;
        case SL_RESULT_CONTENT_UNSUPPORTED    : {
            LOGE("SL_RESULT_CONTENT_UNSUPPORTED");
        }
            break;
        case SL_RESULT_CONTENT_NOT_FOUND    : {
            LOGE("SL_RESULT_CONTENT_NOT_FOUND");
        }
            break;
        case SL_RESULT_PERMISSION_DENIED    : {
            LOGE("SL_RESULT_PERMISSION_DENIED");
        }
            break;
        case SL_RESULT_FEATURE_UNSUPPORTED: {
            LOGE("SL_RESULT_FEATURE_UNSUPPORTED");
        }
            break;
        case SL_RESULT_INTERNAL_ERROR: {
            LOGE("SL_RESULT_INTERNAL_ERROR");
        }
            break;
        case SL_RESULT_UNKNOWN_ERROR: {
            LOGE("SL_RESULT_INTERNAL_ERROR");
        }
            break;
        case SL_RESULT_OPERATION_ABORTED: {
            LOGE("SL_RESULT_INTERNAL_ERROR");
        }
            break;
        case SL_RESULT_CONTROL_LOST: {
            LOGE("SL_RESULT_INTERNAL_ERROR");
        }
            break;
        default:
            LOGE("RESULT UNKONW");
    }
}

int count = 0;
void slCallback(SLAndroidSimpleBufferQueueItf queue, void* context) {
    auto sounder = reinterpret_cast<XAndroidSounder*>(context);
    SLAndroidSimpleBufferQueueItf dataQueue = sounder->getDataQueue();
    void* buffer = malloc(44100 * 2 * 2);
    count++;
    int size = sounder->getPCMData(&buffer);
    if (buffer) {
        SLresult result = (*dataQueue)->Enqueue(dataQueue, buffer, size);
    }
}

XAndroidSounder::XAndroidSounder() {

}

XAndroidSounder::~XAndroidSounder() {

}

void XAndroidSounder::setup() {
    mInput = fopen(mFilename.data(), "r");
    if(!mInput) {
        throw XException("[XAndroidSounder] open file failed\n");
    }

    mOutBuffer = reinterpret_cast<uint8_t *>(malloc(44100 * 2 * 2));

    // 1. setup engine
    SLresult result;
    result = slCreateEngine(&mEngineObject, 0, nullptr, 0, nullptr, nullptr);
    printResult(result);

    result = (*mEngineObject)->Realize(mEngineObject, SL_BOOLEAN_FALSE);
    printResult(result);

    result = (*mEngineObject)->GetInterface(mEngineObject, SL_IID_ENGINE, &mEngine);
    printResult(result);

    // 2. setup mixer
    const SLInterfaceID reverbIds[1] = {SL_IID_ENVIRONMENTALREVERB};
    const SLboolean reverbReqs[1] = {SL_BOOLEAN_FALSE};
    result = (*mEngine)->CreateOutputMix(mEngine, &mMixer, 1, reverbIds, reverbReqs);
    printResult(result);

    result = (*mMixer)->Realize(mMixer, SL_BOOLEAN_FALSE);
    printResult(result);

    result = (*mMixer)->GetInterface(mMixer, SL_IID_ENVIRONMENTALREVERB, &mMixReverb);
    printResult(result);

    if (result == SL_RESULT_SUCCESS) {
        result = (*mMixReverb)->SetEnvironmentalReverbProperties(mMixReverb, &mMixReverbSettings);
        printResult(result);
    }
    SLDataLocator_OutputMix outputMix = {SL_DATALOCATOR_OUTPUTMIX, mMixer};

    // 3. setup player
    SLDataLocator_AndroidSimpleBufferQueue queue = {SL_DATALOCATOR_ANDROIDSIMPLEBUFFERQUEUE, 2};
    SLDataFormat_PCM pcm = {
            SL_DATAFORMAT_PCM,
            2,
            SL_SAMPLINGRATE_44_1,
            SL_PCMSAMPLEFORMAT_FIXED_16,
            SL_PCMSAMPLEFORMAT_FIXED_16,
            SL_SPEAKER_FRONT_LEFT | SL_SPEAKER_FRONT_RIGHT,
            SL_BYTEORDER_LITTLEENDIAN
    };
    SLDataSource dataSource = {&queue, &pcm};
    SLDataSink dataSink = {&outputMix, nullptr};
    const SLInterfaceID playerIds[3] = {SL_IID_BUFFERQUEUE, SL_IID_EFFECTSEND, SL_IID_VOLUME};
    const SLboolean playerReqs[3] = {SL_BOOLEAN_TRUE, SL_BOOLEAN_TRUE, SL_BOOLEAN_TRUE};
    result = (*mEngine)->CreateAudioPlayer(mEngine, &mPlayerObject, &dataSource, &dataSink, 3, playerIds, playerReqs);
    printResult(result);

    result = (*mPlayerObject)->Realize(mPlayerObject, SL_BOOLEAN_FALSE);
    printResult(result);

    result = (*mPlayerObject)->GetInterface(mPlayerObject, SL_IID_PLAY, &mPlayer);
    printResult(result);

    // 4. setup pcm data queue & callback
    result = (*mPlayerObject)->GetInterface(mPlayerObject, SL_IID_BUFFERQUEUE, &mDataQueue);
    printResult(result);

    result = (*mDataQueue)->RegisterCallback(mDataQueue, slCallback, this);
    printResult(result);

    // 5. setup volume
    result = (*mPlayerObject)->GetInterface(mPlayerObject, SL_IID_VOLUME, &mVolume);
    printResult(result);
}

void XAndroidSounder::start() {

    setup();

    (*mPlayer)->SetPlayState(mPlayer, SL_PLAYSTATE_PLAYING);
    slCallback(mDataQueue, this);
}

int XAndroidSounder::getPCMData(void** pcm) {
    int size = 0;
    while (!feof(mInput)) {
        size = fread(mOutBuffer, 1, 44100 * 2 * 2, mInput);
        if (mOutBuffer) {
            LOGI("[XAndroidSounder] pcm reading ...\n");
        } else {
            LOGE("[XAndroidSounder] read pcm eof\n");
            break;
        }
        *pcm = mOutBuffer;
        break;
    }
    return size;
}

SLAndroidSimpleBufferQueueItf XAndroidSounder::getDataQueue() {
    return mDataQueue;
}
