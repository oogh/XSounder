//
// Created by Oogh on 2020/3/19.
//

#include "XSoundJNI.h"
#include <string>
#include <memory>
#include "XAndroidSounder.h"

static const std::string CLASS_NAME = "com/core/sound/XSounder";

jlong sounderCreate(JNIEnv*, jobject) {
    std::shared_ptr<XAndroidSounder>* sounder = new std::shared_ptr<XAndroidSounder>(new XAndroidSounder());
    return reinterpret_cast<jlong>(sounder);
}

void sounderDestroy(JNIEnv*, jobject, jlong sounderPtr) {
    std::shared_ptr<XAndroidSounder>* sounder = reinterpret_cast<std::shared_ptr<XAndroidSounder> *>(sounderPtr);
    delete sounder;
}

void sounderSetInput(JNIEnv* env, jobject, jlong sounderPtr, jstring filename) {
    auto sounder = reinterpret_cast<std::shared_ptr<XAndroidSounder> *>(sounderPtr);
    jboolean copy;
    const char* path = env->GetStringUTFChars(filename, &copy);
    (*sounder)->setInput(path);
    env->ReleaseStringUTFChars(filename, path);
}

void sounderStart(JNIEnv*, jobject, jlong sounderPtr) {
    auto sounder = reinterpret_cast<std::shared_ptr<XAndroidSounder> *>(sounderPtr);
    (*sounder)->start();
}

static JNINativeMethod gMethods[] = {
        {"nativeCreateSounder", "()J", reinterpret_cast<void*>(sounderCreate)},
        {"nativeDestroySounder", "(J)V", reinterpret_cast<void*>(sounderDestroy)},
        {"nativeSetInput", "(JLjava/lang/String;)V", reinterpret_cast<void*>(sounderSetInput)},
        {"nativeStart", "(J)V", reinterpret_cast<void*>(sounderStart)},
};

int sounderRegisterNativeMethods(JNIEnv* env) {
    jclass clazz = env->FindClass(CLASS_NAME.c_str());
    if (nullptr == clazz) {
        return -1;
    }
    if (env->RegisterNatives(clazz, gMethods, sizeof(gMethods) / sizeof(gMethods[0])) < 0) {
        return JNI_FALSE;
    }
    return JNI_TRUE;
}


