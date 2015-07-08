#include "precompiled.h"

#include "DatabaseBoundary.h"
#include "DatabaseHelper.h"
#include "Logger.h"
#include "QueryId.h"

namespace salat {

using namespace canadainc;
using namespace bb::data;

DatabaseBoundary::DatabaseBoundary() :
        m_sql( QString("%1/assets/dbase/salat10.db").arg( QCoreApplication::applicationDirPath() ) )
{
}


void DatabaseBoundary::fetchAngles(QObject* caller) {
    m_sql.executeQuery(caller, "SELECT * FROM angles ORDER BY name", QueryId::GetAllAngles);
}


void DatabaseBoundary::fetchArticles(QObject* caller) {
    m_sql.executeQuery(caller, "SELECT suite_pages.id AS id,COALESCE(i.displayName, i.name) AS author,COALESCE(heading,title) AS title FROM suites LEFT JOIN individuals i ON i.id=suites.author INNER JOIN suite_pages ON suite_pages.suite_id=suites.id", QueryId::GetArticles);
}


void DatabaseBoundary::fetchRandomBenefit(QObject* caller)
{
    QString query = QString("SELECT %1 AS author,i.id,body,TRIM( COALESCE(suites.title,'') || ' ' || COALESCE(quotes.reference,'') ) AS reference,birth,death,female,is_companion FROM quotes INNER JOIN individuals i ON i.id=quotes.author LEFT JOIN suites ON quotes.suite_id=suites.id WHERE quotes.id=( ABS( RANDOM() % (SELECT COUNT() AS total_quotes FROM quotes) )+1 )").arg( "coalesce(%1.displayName, TRIM((coalesce(%1.prefix,'') || ' ' || %1.name || ' ' || coalesce(%1.kunya,''))))").arg("i");
    m_sql.executeQuery(caller, query, QueryId::GetRandomBenefit);
}


DatabaseBoundary::~DatabaseBoundary()
{
}

}
