//
// Created by Oogh on 2020/3/19.
//

#ifndef XANDROID_SOUNDERAL_H
#define XANDROID_SOUNDERAL_H

#include "XSounder.h"
#include "XALPlayer.h"

class XAndroidSounderAL : public XSounder {
public:
    XAndroidSounderAL();

    ~XAndroidSounderAL() override;

    void setup() override;

    void start() override;

private:
    FILE* mInput;

    uint8_t* mOutBuffer;

    XALPlayer *mALPlayer;
};
#endif //XANDROID_SOUNDERAL_H
