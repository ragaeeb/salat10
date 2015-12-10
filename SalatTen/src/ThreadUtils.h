#ifndef THREADUTILS_H_
#define THREADUTILS_H_

#include <QSet>
#include <QString>

#include "SalatParameters.h"

namespace bb {
    namespace cascades {
        class GroupDataModel;
        class ImageView;
    }
}

namespace canadainc {
    class Report;
}

namespace salat {

using namespace bb::cascades;

struct ThreadUtils
{
    static QPair<bb::ImageData, bb::cascades::ImageView*> applyBlur(bb::cascades::ImageView* iv, QString const& imageSrc);
    static void compressFiles(canadainc::Report& r, QString const& zipPath, const char* password);
    static void diffIqamahs(GroupDataModel* model, QMap<QString, QTime> const& iqamahs);
    static QVariantMap processDownload(QVariantMap const& cookie, QByteArray const& data);
    static QString renderHTML(qreal latitude, qreal longitude, SalatParameters const& sp, qreal asrRatio, bool nightStartsAtIsha, int dstAdjust, QMap<QString, int> const& adjustments, QString const& location);
};

} /* namespace quran */

#endif /* THREADUTILS_H_ */
