#include "precompiled.h"

#include "ThreadUtils.h"
#include "Calculator.h"
#include "Coordinates.h"
#include "CommonConstants.h"
#include "JlCompress.h"
#include "IOUtils.h"
#include "Report.h"
#include "SalatUtils.h"
#include "Translator.h"

namespace {

QImage blurred(const QImage& image, const QRect& rect, int radius, bool alphaOnly = false)
{
    int tab[] = { 14, 10, 8, 6, 5, 5, 4, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2 };
    int alpha = (radius < 1)  ? 16 : (radius > 17) ? 1 : tab[radius-1];

    QImage result = image.convertToFormat(QImage::Format_ARGB32_Premultiplied);
    int r1 = rect.top();
    int r2 = rect.bottom();
    int c1 = rect.left();
    int c2 = rect.right();

    int bpl = result.bytesPerLine();
    int rgba[4];
    unsigned char* p;

    int i1 = 0;
    int i2 = 3;

    if (alphaOnly)
        i1 = i2 = (QSysInfo::ByteOrder == QSysInfo::BigEndian ? 0 : 3);

    for (int col = c1; col <= c2; col++) {
        p = result.scanLine(r1) + col * 4;
        for (int i = i1; i <= i2; i++)
            rgba[i] = p[i] << 4;

        p += bpl;
        for (int j = r1; j < r2; j++, p += bpl)
            for (int i = i1; i <= i2; i++)
                p[i] = (rgba[i] += ((p[i] << 4) - rgba[i]) * alpha / 16) >> 4;
    }

    for (int row = r1; row <= r2; row++) {
        p = result.scanLine(row) + c1 * 4;
        for (int i = i1; i <= i2; i++)
            rgba[i] = p[i] << 4;

        p += 4;
        for (int j = c1; j < c2; j++, p += 4)
            for (int i = i1; i <= i2; i++)
                p[i] = (rgba[i] += ((p[i] << 4) - rgba[i]) * alpha / 16) >> 4;
    }

    for (int col = c1; col <= c2; col++) {
        p = result.scanLine(r2) + col * 4;
        for (int i = i1; i <= i2; i++)
            rgba[i] = p[i] << 4;

        p -= bpl;
        for (int j = r1; j < r2; j++, p -= bpl)
            for (int i = i1; i <= i2; i++)
                p[i] = (rgba[i] += ((p[i] << 4) - rgba[i]) * alpha / 16) >> 4;
    }

    for (int row = r1; row <= r2; row++) {
        p = result.scanLine(row) + c2 * 4;
        for (int i = i1; i <= i2; i++)
            rgba[i] = p[i] << 4;

        p -= 4;
        for (int j = c1; j < c2; j++, p -= 4)
            for (int i = i1; i <= i2; i++)
                p[i] = (rgba[i] += ((p[i] << 4) - rgba[i]) * alpha / 16) >> 4;
    }

    return result;
}

}

namespace salat {

using namespace canadainc;

void ThreadUtils::compressFiles(Report& r, QString const& zipPath, const char* password) {
    JlCompress::compressFiles(zipPath, r.attachments, password);
}


QPair<bb::ImageData, bb::cascades::ImageView*> ThreadUtils::applyBlur(bb::cascades::ImageView* iv, QString const& imageSrc)
{
    QImage q = QImage( QString("app/native/assets/%1").arg(imageSrc) );
    q = blurred(q, q.rect(), 7, false);

    bb::ImageData imageData( bb::PixelFormat::RGBA_Premultiplied, q.width(), q.height() );

    unsigned char *dstLine = imageData.pixels();
    for (int y = 0; y < imageData.height(); y++) {
        unsigned char * dst = dstLine;
        for (int x = 0; x < imageData.width(); x++) {
            QRgb srcPixel = q.pixel(x, y);
            *dst++ = qRed(srcPixel);
            *dst++ = qGreen(srcPixel);
            *dst++ = qBlue(srcPixel);
            *dst++ = qAlpha(srcPixel);
        }
        dstLine += imageData.bytesPerLine();
    }

    return qMakePair<bb::ImageData, bb::cascades::ImageView*>(imageData,iv);
}


void ThreadUtils::diffIqamahs(GroupDataModel* model, QMap<QString, QTime> const& iqamahs)
{
    int sections = model->childCount( QVariantList() );

    for (int i = 0; i < sections; i++)
    {
        int childrenInSection = model->childCount( QVariantList() << i );

        for (int j = 0; j < childrenInSection; j++)
        {
            QVariantList indexPath = QVariantList() << i << j;
            QVariantMap current = model->data(indexPath).toMap();
            QString key = current.value(PRAYER_KEY).toString();

            if ( iqamahs.contains(key) )
            {
                QDateTime iqamah = QDateTime( current.value(KEY_SORT_DATE).toDate(), iqamahs.value(key) );
                current[KEY_IQAMAH] = iqamah;
            } else {
                current.remove(KEY_IQAMAH);
            }

            model->updateItem(indexPath, current);
        }
    }
}


QString ThreadUtils::renderHTML(HtmlParams const& hp)
{
    QDate today = hp.now.date();
    today.setDate( today.year(), today.month(), 1 );
    Coordinates geo = Calculator::createCoordinates(hp.now, hp.latitude, hp.longitude);
    Calculator c;
    Translator t;
    QString format = bb::utility::i18n::timeFormat(bb::utility::i18n::DateFormat::Short);
    bb::system::LocaleHandler l(bb::system::LocaleType::Region);
    int daysInMonth = today.daysInMonth();
    QStringList keys = Translator::eventKeys();
    QStringList html = QStringList() << QString("<html><body><h1>Salat10<br>%1, %2: %3</h1><br><br><table border=1>").arg( QDate::longMonthName( today.month() ) ).arg( today.year() ).arg(hp.location);
    {
        QStringList tableRow = QStringList() << "<tr>";

        for (int i = keys.size()-1; i >= 0; i--) {
            keys[i] = t.render(keys[i]);
        }

        QStringList headerList = QStringList() << QObject::tr("Date") << keys;

        foreach (QString const& header, headerList) {
            tableRow << QString("<td style='width: 100px; color: red; text-align: center;'>%1</td>").arg(header);
        }

        tableRow << "</tr>";
        html << tableRow.join("");
    }

    for (int i = 0; i < daysInMonth; i++)
    {
        QStringList tableRow = QStringList() << "<tr>";
        QStringList rowData = QStringList() << today.toString(Qt::SystemLocaleShortDate);
        QList<QDateTime> current = c.calculate(today, geo, hp.angles, hp.asrRatio, hp.nightStartsIsha);

        for (int j = 0; j < current.size(); j++) {
            rowData << l.locale().toString( current[j].addSecs(hp.dstAdjust*3600).addSecs( hp.adjustments.value(keys[j]) ), format );
        }

        foreach (QString const& element, rowData) {
            tableRow << QString("<td style='width: 100px; text-align: center;'>%1</td>").arg(element);
        }

        tableRow << "</tr>";
        html << tableRow.join("");

        today = today.addDays(1);
    }

    html << "</table></body></html>";

    QString path = QString("%1/schedule.html").arg( QDir::tempPath() );
    bool written = IOUtils::writeTextFile( path, html.join("\n"), true, false, true );

    return written ? path : "";
}


} /* namespace salat */
