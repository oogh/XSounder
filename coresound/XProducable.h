//
// Created by Oogh on 2020/3/19.
//

#ifndef XPRODUCABLE_H
#define XPRODUCABLE_H

#include <cstdint>
#include <string>

class XProducable {
public:
    XProducable();
    
    virtual ~XProducable();
    
    virtual void setInput(const char* filename);
    
    virtual void start();

    virtual int fillAudioData(uint8_t* samples, int length);
    
    virtual int fillVideoData(uint8_t* pixels[4], int width, int height);

protected:
    std::string mFilename;
    
};

#endif //XPRODUCABLE_H
