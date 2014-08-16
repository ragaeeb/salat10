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
    QMap<QString, bool> salatMap;
    QMap<QString, int> adjustments;
    QVariantMap athaans;
    QVariantMap notifications;
    QMap<QString, QTime> iqamahs;
};

class DataModelWrapper : public QObject
{
	Q_OBJECT
	Q_PROPERTY(bool empty READ isEmpty NOTIFY emptyChanged)
    Q_PROPERTY(bool calculationFeasible READ calculationFeasible NOTIFY recalculationNeeded)
    Q_PROPERTY(bool atLeastOneAthanScheduled READ atLeastOneAthanScheduled)

	Persistance* m_persistance;
	Calculator m_calculator;
	bb::cascades::GroupDataModel m_model;
	Translator m_translator;
	bool m_empty;
	Cache m_cache;

    void applyDiff(QString const& settingKey, QString const& itemKey);
	void calculateAndAppend(QDateTime const& reference);
	QVariantList matchValue(QDateTime const& reference);
	void refreshNeeded();

private slots:
    void itemAdded(QVariantList indexPath);
    void itemsChanged(bb::cascades::DataModelChangeType::Type eChangeType = bb::cascades::DataModelChangeType::Init, QSharedPointer<bb::cascades::DataModel::IndexMapper> indexMapper = QSharedPointer<bb::cascades::DataModel::IndexMapper>(0));
    void settingChanged(QString const& key);

signals:
    void emptyChanged();
    void recalculationNeeded();

public:
	DataModelWrapper(Persistance* p, QObject* parent=NULL);
	virtual ~DataModelWrapper();

	Q_INVOKABLE QVariant getModel();
	Q_INVOKABLE void loadMore();
	Q_INVOKABLE void loadBeginning();
	Q_INVOKABLE QVariantList calculate(QDateTime qdt, int numDays=1);
	bool isEmpty() const;
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
    bool atLeastOneAthanScheduled();
};

} /* namespace salat */
#endif /* DATAMODELWRAPPER_H_ */
