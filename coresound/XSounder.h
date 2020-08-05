//
// Created by Oogh on 2020/3/19.
//

#ifndef XSOUNDER_H
#define XSOUNDER_H

#include <memory>
#include <string>
#include <string>

class XSounder {
public:
    XSounder();

    virtual ~XSounder();

    virtual void setup();

    virtual void start();

    virtual void setInput(const std::string& filename);

protected:
    std::string mFilename;

};
#endif //XSOUNDER_H
