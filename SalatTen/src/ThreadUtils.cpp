#include "precompiled.h"

#include "ThreadUtils.h"
#include "AppLogFetcher.h"
#include "JlCompress.h"

namespace salat {

using namespace bb::cascades;

void ThreadUtils::compressFiles(QSet<QString>& attachments)
{
    canadainc::AppLogFetcher::removeInvalid(attachments);

    JlCompress::compressFiles( ZIP_FILE_PATH, attachments.toList() );
    //QFile::remove(CARD_LOG_FILE);
}


} /* namespace salat */
