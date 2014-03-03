#ifndef TRANSLATOR_H_
#define TRANSLATOR_H_

#include <QObject>
#include <QMap>
#include <QStringList>

namespace salat {

class Translator : public QObject
{
	Q_OBJECT

	QMap<QString, QString> m_map;
	QMap<QString, bool> m_salats;

public:
	Translator();
	virtual ~Translator();

	Q_INVOKABLE QString render(QString const& key);
	Q_INVOKABLE static QStringList eventKeys();
	Q_INVOKABLE static QStringList salatKeys();
	QMap<QString, bool> salatMap();
	void reload();

	static const char* key_fajr;
	static const char* key_sunrise;
	static const char* key_dhuhr;
	static const char* key_asr;
	static const char* key_maghrib;
	static const char* key_isha;
	static const char* key_half_night;
	static const char* key_last_third_night;
};

} /* namespace salat */
#endif /* TRANSLATOR_H_ */
