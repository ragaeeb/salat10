#ifndef DATABASEBOUNDARY_H_
#define DATABASEBOUNDARY_H_

#include "DatabaseHelper.h"

namespace canadainc {
    class DatabaseHelper;
}

namespace salat {

using namespace canadainc;

class DatabaseBoundary : public QObject
{
	Q_OBJECT

	DatabaseHelper m_sql;

public:
	DatabaseBoundary();
	virtual ~DatabaseBoundary();

    Q_INVOKABLE void fetchAngles(QObject* caller);
    Q_INVOKABLE void fetchArticles(QObject* caller);
    Q_INVOKABLE void fetchCenters(QObject* caller);
    Q_INVOKABLE void fetchRandomBenefit(QObject* caller);
    Q_INVOKABLE void searchArticles(QObject* caller, QString const& searchTerm);
    Q_INVOKABLE QString writeArticle(QVariantMap const& qvm);

    QObject* getSource();
};

}
#endif
