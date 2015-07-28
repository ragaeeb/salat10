#ifndef DATAMODELWRAPPER_H_
#define DATAMODELWRAPPER_H_

#include <QDateTime>

#include "Calculator.h"
#include "SalatParameters.h"
#include "Translator.h"

#include <bb/cascades/GroupDataModel>

namespace canadainc {
    class Persistance;
}

namespace salat {

using namespace canadainc;

struct Cache
{
    SalatParameters angles;
    qreal asrRatio;
    qreal latitude;
    qreal longitude;
    QMap<QString, bool> salatMap;
    QMap<QString, int> adjustments;
    QVariantMap athaans;
    QVariantMap notifications;
    QMap<QString, QTime> iqamahs;
    bool nightStartsIsha;
    int dstAdjust;

    bool feasible() const;
    bool anglesSet() const;

    Cache() : asrRatio(0), latitude(0), longitude(0), nightStartsIsha(false), dstAdjust(0)
    {
    }
};

class DataModelWrapper : public QObject
{
	Q_OBJECT
    Q_PROPERTY(bool calculationFeasible READ calculationFeasible NOTIFY recalculationNeeded)
	Q_PROPERTY(bool anglesSaved READ anglesSaved NOTIFY recalculationNeeded)
    Q_PROPERTY(bool atLeastOneAthanScheduled READ atLeastOneAthanScheduled)
    Q_PROPERTY(int dstAdjustment READ dstAdjustment NOTIFY recalculationNeeded)

	Persistance* m_persistance;
	Calculator m_calculator;
	bb::cascades::GroupDataModel m_model;
	Translator m_translator;
	Cache m_cache;

    void applyDiff(QString const& settingKey, QString const& itemKey);
	void calculateAndAppend(QDateTime const& reference);
	QVariantList matchValue(QDateTime const& reference);
	void refreshNeeded();
	void updateCache(QStringList const& keys);

private slots:
    void settingChanged(QString const& key);

signals:
    void recalculationNeeded();

public:
	DataModelWrapper(Persistance* p, QObject* parent=NULL);
	virtual ~DataModelWrapper();

	Q_INVOKABLE QVariant getModel();
	Q_INVOKABLE void loadMore();
	Q_INVOKABLE void loadBeginning();
	Q_INVOKABLE QVariantList calculate(QDateTime qdt, int numDays=1);
	void lazyInit();

	/**
	 * @return The next event after the reference point.
	 */
	Q_INVOKABLE QVariantMap getCurrent(QDateTime const& reference);
	Q_INVOKABLE QVariantMap getNext(QDateTime const& reference);

	Persistance* getPersist();
	Calculator* getCalculator();
	Translator* getTranslator();

    bool calculationFeasible() const;
    bool anglesSaved() const;
    bool atLeastOneAthanScheduled();
    int dstAdjustment() const;
};

} /* namespace salat */
#endif /* DATAMODELWRAPPER_H_ */
