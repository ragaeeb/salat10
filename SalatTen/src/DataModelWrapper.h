#ifndef DATAMODELWRAPPER_H_
#define DATAMODELWRAPPER_H_

#include <QDateTime>
#include <QMutex>

#include "Calculator.h"
#include "Persistance.h"
#include "Translator.h"

#include <bb/cascades/GroupDataModel>

namespace salat {

using namespace canadainc;

class DataModelWrapper : public QObject
{
	Q_OBJECT
	Q_PROPERTY(bool empty READ isEmpty NOTIFY emptyChanged)

	Persistance m_persistance;
	Calculator m_calculator;
	QMutex m_mutex;
	bb::cascades::GroupDataModel m_model;
	Translator m_translator;
	bool m_empty;

	void calculateAndAppend(QDateTime const& reference);
	QVariantList matchValue(QDateTime const& reference);
	void init();

private slots:
    void itemAdded(QVariantList indexPath);
    void itemsChanged(bb::cascades::DataModelChangeType::Type eChangeType = bb::cascades::DataModelChangeType::Init, QSharedPointer<bb::cascades::DataModel::IndexMapper> indexMapper = QSharedPointer<bb::cascades::DataModel::IndexMapper>(0));

signals:
    void emptyChanged();

public:
	DataModelWrapper(QObject* parent=NULL);
	virtual ~DataModelWrapper();

	Q_INVOKABLE QVariant getModel();
	Q_INVOKABLE void loadMore();
	Q_INVOKABLE void loadBeginning();
	Q_INVOKABLE QVariantList calculate(QDateTime qdt, int numDays=1);
	Q_INVOKABLE void reset();
	bool isEmpty() const;
	void applyDiff(QString const& settingKey, QString const& itemKey);

	/**
	 * @return The next event after the reference point.
	 */
	Q_INVOKABLE QVariantMap getCurrent(QDateTime const& reference);
	Q_INVOKABLE QVariantMap getNext(QDateTime const& reference);

	Persistance* getPersist();
	Calculator* getCalculator();
	Translator* getTranslator();

	Q_INVOKABLE void saveIqamah(QString const& key, QDateTime const& time);
	Q_INVOKABLE void removeIqamah(QString const& key);
	void updateIqamahs();
};

} /* namespace salat */
#endif /* DATAMODELWRAPPER_H_ */
