#ifndef SALATCOLLECTOR_H_
#define SALATCOLLECTOR_H_

#include "AppLogFetcher.h"

namespace salat {

using namespace canadainc;

class SalatCollector : public LogCollector
{
public:
    SalatCollector();
    QString appName() const;
    QByteArray compressFiles();
    ~SalatCollector();
};

} /* namespace golden */

#endif /* SALATCOLLECTOR_H_ */
