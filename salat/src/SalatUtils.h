#ifndef SALATUTILS_H_
#define SALATUTILS_H_

#include <QString>

#define SERVICE_KEY "logService"
#define SERVICE_LOG_FILE QString("%1/logs/service.log").arg( QDir::currentPath() )

#endif /* SALATUTILS_H_ */
