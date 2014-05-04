#include "SalatCollector.h"
#include "JlCompress.h"
#include "SalatUtils.h"

namespace salat {

using namespace canadainc;

SalatCollector::SalatCollector()
{
}


QString SalatCollector::appName() const {
    return "salat10";
}


QByteArray SalatCollector::compressFiles()
{
    AppLogFetcher::dumpDeviceInfo();

    QStringList files;
    files << DEVICE_INFO_LOG;
    files << SERVICE_LOG_FILE;
    files << UI_LOG_FILE;
    files << QSettings().fileName();

    for (int i = files.size()-1; i >= 0; i--)
    {
        if ( !QFile::exists(files[i]) ) {
            files.removeAt(i);
        }
    }

    JlCompress::compressFiles(ZIP_FILE_PATH, files);

    QFile f(ZIP_FILE_PATH);
    f.open(QIODevice::ReadOnly);

    QByteArray qba = f.readAll();
    f.close();

    QFile::remove(SERVICE_LOG_FILE);
    QFile::remove(UI_LOG_FILE);

    return qba;
}


SalatCollector::~SalatCollector()
{
}

} /* namespace autoblock */
