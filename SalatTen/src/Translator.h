#ifndef TRANSLATOR_H_
#define TRANSLATOR_H_

#include <QObject>
#include <QMap>
#include <QStringList>

#define key_fajr "fajr"
#define key_sunrise "sunrise"
#define key_dhuhr "dhuhr"
#define key_asr "asr"
#define key_maghrib "maghrib"
#define key_isha "isha"
#define key_half_night "halfNight"
#define key_last_third_night "lastThirdNight"

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
};

} /* namespace salat */
#endif /* TRANSLATOR_H_ */
