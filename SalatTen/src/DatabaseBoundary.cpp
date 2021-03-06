#include "precompiled.h"

#include "DatabaseBoundary.h"
#include "CommonConstants.h"
#include "DatabaseHelper.h"
#include "IOUtils.h"
#include "Logger.h"
#include "QueryId.h"

#define NAME_FIELD(var) QString("coalesce(%1.displayName, TRIM( replace( coalesce(%1.kunya,'') || ' ' || (coalesce(%1.prefix,'') || ' ' || %1.name), '  ', ' ' ) ) )").arg(var)

namespace salat {

using namespace canadainc;
using namespace bb::data;

DatabaseBoundary::DatabaseBoundary() :
        m_sql( QString("%1/assets/dbase/salat10.db").arg( QCoreApplication::applicationDirPath() ) )
{
    m_sql.setVerboseLogging();
}


void DatabaseBoundary::fetchAngles(QObject* caller) {
    m_sql.executeQuery(caller, "SELECT * FROM angles ORDER BY strategy_key", QueryId::GetAllAngles);
}


void DatabaseBoundary::fetchArticles(QObject* caller) {
    m_sql.executeQuery(caller, "SELECT suite_pages.id AS id,COALESCE(i.displayName, i.name) AS author,COALESCE(heading,title) AS title,suites.reference,suite_pages.reference AS suite_page_reference,body FROM suites LEFT JOIN individuals i ON i.id=suites.author INNER JOIN suite_pages ON suite_pages.suite_id=suites.id", QueryId::GetArticles);
}


void DatabaseBoundary::fetchCenters(QObject* caller) {
    m_sql.executeQuery(caller, "SELECT name,website,latitude,longitude,city AS location FROM masjids INNER JOIN locations ON masjids.location=locations.id", QueryId::FetchCenters);
}


void DatabaseBoundary::fetchRandomBenefit(QObject* caller) {
    m_sql.executeQuery(caller, QString("SELECT %1 AS author,%2 AS translator,body,TRIM( COALESCE(suites.title,'') || ' ' || COALESCE(quotes.reference,'') ) AS reference,i.birth,i.death,i.female,i.is_companion,j.birth AS translator_birth,j.death AS translator_death,j.female AS translator_female,j.is_companion AS translator_companion FROM quotes INNER JOIN individuals i ON i.id=quotes.author LEFT JOIN individuals j ON j.id=quotes.translator LEFT JOIN suites ON quotes.suite_id=suites.id WHERE quotes.id=( SELECT ABS( RANDOM() % (SELECT COUNT() AS total_quotes FROM quotes) ) )").arg( NAME_FIELD("i") ).arg( NAME_FIELD("j") ), QueryId::GetRandomBenefit);
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

    QString query = QString("SELECT suite_pages.id AS id,COALESCE(i.displayName, i.name) AS author,COALESCE(heading,title) AS title,suites.reference,suite_pages.reference AS suite_page_reference,body FROM suites LEFT JOIN individuals i ON i.id=suites.author INNER JOIN suite_pages ON suite_pages.suite_id=suites.id WHERE %1").arg( fields.join(" OR ") );

    m_sql.executeQuery(caller, query, QueryId::SearchArticles, args);
}


QObject* DatabaseBoundary::getSource() {
    return &m_sql;
}


QString DatabaseBoundary::writeArticle(QVariantMap const& qvm)
{
    QString path = QString("%1/article.txt").arg( QDir::tempPath() );
    QString title = qvm.value("title").toString();
    QString body = qvm.value("body").toString();
    QString reference = qvm.value("reference").toString();

    if ( !qvm.value("suite_page_reference").toString().isEmpty() ) {
        reference = qvm.value("suite_page_reference").toString();
    }

    body = QString("%4: %1\n\n%2\n\n%3").arg(title).arg(body).arg(reference).arg( qvm.value("author").toString() );

    IOUtils::writeTextFile( path, body, true, false );

    return QUrl::fromLocalFile(path).toString();
}


DatabaseBoundary::~DatabaseBoundary()
{
}

}
