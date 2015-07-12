#ifndef CALCULATOR_H_
#define CALCULATOR_H_

#include "SolarCalculator.h"

#include <QVariantMap>
#include <QDateTime>

namespace salat {

class Coordinates;
class SalatParameters;

enum PrayerIndex {Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha, HalfNight, LastThirdNight};

class Calculator
{
	SolarCalculator m_solar;

	qreal computeAsr(bool problematic, qreal latitude, qreal asrRatio);
	void calculateFajrIsha(QDate const& fixedDate, Coordinates const& geo, SalatParameters const& angles, QList<QDateTime>& results);
	bool computeFajr(qreal fajrTwilight, qreal latitude, QDate const& fixedDate, QList<QDateTime>& results);
	bool computeIsha(qreal ishaTwilight, qreal ishaInterval, qreal latitude, QDate const& fixedDate, QList<QDateTime>& results);
	void computeFajrIshaInSolstice(Coordinates const& geo, SalatParameters const& angles, QDate const& fixedDate, bool fajrInSolstice, bool ishaInSolstice, QList<QDateTime>& results);

public:
	Calculator();
	QList<QDateTime> calculate(QDate const& fixedDate, Coordinates const& geo, SalatParameters const& angles, qreal asrRatio, bool nightStartsIsha=false);
	static Coordinates createCoordinates(QDateTime local, qreal latitude, qreal longitude);
	static SalatParameters createParams(QVariantMap const& angleMap);
	virtual ~Calculator();
};

} /* namespace salat */
#endif /* CALCULATOR_H_ */
