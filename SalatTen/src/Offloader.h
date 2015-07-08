#ifndef OFFLOADER_H_
#define OFFLOADER_H_

#include <bb/ImageData>
#include <bb/cascades/ImageView>
#include <bb/system/LocaleHandler>

namespace salat {

class CleanupEvents;
class ScheduleEvents;

class Offloader : public QObject
{
    Q_OBJECT

    bb::cascades::Image m_blurred;
    QFutureWatcher< QPair<bb::ImageData, bb::cascades::ImageView*> > m_qfw;
    CleanupEvents* m_cleanup;
    ScheduleEvents* m_schedule;
    bb::system::LocaleHandler m_timeRender;

private slots:
    void handleCleanupComplete(QObject* obj);
    void handleExportComplete(QObject* obj);
    void onBlurred();

public slots:
    void terminateThreads();

signals:
    void accountsImported(QVariantList const& qvl);
    void operationProgress(int current, int total);
    void operationComplete(QString const& toastMessage, QString const& icon);

public:
    Offloader();
    virtual ~Offloader();

    Q_INVOKABLE void blur(bb::cascades::ImageView* i, QString const& imageSrc);
    Q_INVOKABLE void cleanupCalendarEvents();
    Q_INVOKABLE void exportToCalendar(int numDays, QVariantList const& events, qint64 accountId);
    Q_INVOKABLE bool hasCalendarAccess();
    Q_INVOKABLE void loadAccounts();
    Q_INVOKABLE void renderMap(bb::cascades::maps::MapView* mapView, qreal latitude, qreal longitude, QString const& name, QString const& event, bool focus=false);
    Q_INVOKABLE QString renderStandardTime(QDateTime const& theTime);
};

} /* namespace quran */

#endif /* OFFLOADER_H_ */