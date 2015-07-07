#ifndef THREADUTILS_H_
#define THREADUTILS_H_

#include <QSet>
#include <QString>

namespace bb {
    namespace cascades {
        class GroupDataModel;
    }
}

namespace salat {

using namespace bb::cascades;

struct ThreadUtils
{
    static QPair<bb::ImageData, bb::cascades::ImageView*> applyBlur(bb::cascades::ImageView* iv, QString const& imageSrc);
    static void compressFiles(QSet<QString>& attachments);
    static void diffIqamahs(GroupDataModel* model, QMap<QString, QTime> const& iqamahs);
};

} /* namespace quran */

#endif /* THREADUTILS_H_ */
