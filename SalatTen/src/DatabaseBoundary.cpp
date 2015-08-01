#include "precompiled.h"

#include "DatabaseBoundary.h"
#include "DatabaseHelper.h"
#include "Logger.h"
#include "QueryId.h"

#define NAME_FIELD(var) QString("coalesce(%1.displayName, TRIM( replace( coalesce(%1.kunya,'') || ' ' || (coalesce(%1.prefix,'') || ' ' || %1.name), '  ', ' ' ) ) )").arg(var)

namespace salat {

using namespace canadainc;
using namespace bb::data;

DatabaseBoundary::DatabaseBoundary() :
        m_sql( QString("%1/assets/dbase/salat10.db").arg( QCoreApplication::applicationDirPath() ) )
{
}


void DatabaseBoundary::fetchAllOrigins(QObject* caller)
{
    m_sql.executeQuery(caller, QString("SELECT %1 AS name,i.id,i.is_companion,latitude+((RANDOM()%10)*0.0001) AS latitude,longitude+((RANDOM()%10)*0.0001) AS longitude FROM individuals i INNER JOIN locations ON i.location=locations.id").arg( NAME_FIELD("i") ), QueryId::FetchAllOrigins);
}


void DatabaseBoundary::fetchAngles(QObject* caller) {
    m_sql.executeQuery(caller, "SELECT * FROM angles ORDER BY name", QueryId::GetAllAngles);
}


void DatabaseBoundary::fetchArticles(QObject* caller) {
    m_sql.executeQuery(caller, "SELECT suite_pages.id AS id,COALESCE(i.displayName, i.name) AS author,COALESCE(heading,title) AS title FROM suites LEFT JOIN individuals i ON i.id=suites.author INNER JOIN suite_pages ON suite_pages.suite_id=suites.id", QueryId::GetArticles);
}


void DatabaseBoundary::fetchRandomBenefit(QObject* caller) {
    m_sql.executeQuery(caller, QString("SELECT %1 AS author,body,TRIM( COALESCE(suites.title,'') || ' ' || COALESCE(quotes.reference,'') ) AS reference,i.id,birth,death,female,is_companion FROM quotes INNER JOIN individuals i ON i.id=quotes.author LEFT JOIN suites ON quotes.suite_id=suites.id WHERE quotes.id=( ABS( RANDOM() % (SELECT COUNT() AS total_quotes FROM quotes) )+1 )").arg( NAME_FIELD("i") ), QueryId::GetRandomBenefit);
}


void DatabaseBoundary::searchArticles(QObject* caller, QString const& searchTerm)
{
    LOGGER(searchTerm);

    QStringList fields = QStringList() << "title" << "heading" << "i.displayName" << "i.name";
    QVariantList args;

    for (int i = fields.size()-1; i >= 0; i--) {
        fields[i] = QString("(%1 LIKE '%' || ? || '%')").arg(fields[i]);
        args << searchTerm;
    }

    QString query = QString("SELECT suite_pages.id AS id,COALESCE(i.displayName, i.name) AS author,COALESCE(heading,title) AS title FROM suites LEFT JOIN individuals i ON i.id=suites.author INNER JOIN suite_pages ON suite_pages.suite_id=suites.id WHERE %1").arg( fields.join(" OR ") );

    m_sql.executeQuery(caller, query, QueryId::SearchArticles, args);
}


QObject* DatabaseBoundary::getSource() {
    return &m_sql;
}


DatabaseBoundary::~DatabaseBoundary()
{
}

}
