//
// Created by Oogh on 2020/3/19.
//

#include "XProducable.h"

XProducable::XProducable() {
    
}

XProducable::~XProducable() {

}

void XProducable::XProducable::setInput(const char* filename) {
    mFilename = filename;
}

void XProducable::start() {

}

int XProducable::fillAudioData(uint8_t* samples, int length) {
    return -1;
}

int XProducable::fillVideoData(uint8_t* pixels[4], int width, int height) {
    return -1;
}