#ifndef THREADUTILS_H_
#define THREADUTILS_H_

#include <QVariant>

namespace salat {

using namespace bb::cascades;

struct ThreadUtils
{
    static void compressFiles(QSet<QString>& attachments);
};

} /* namespace quran */

#endif /* THREADUTILS_H_ */
