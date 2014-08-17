#ifndef CALCULATOR_H_
#define CALCULATOR_H_

#include "SolarCalculator.h"

#include <QVariantMap>
#include <QDateTime>

#define index_fajr 0
#define index_sunrise 1
#define index_dhuhr 2
#define index_asr 3
#define index_maghrib 4
#define index_isha 5
#define index_halfNight 6
#define index_lastThirdNight 7

namespace salat {

class Coordinates;
class SalatParameters;

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
	QList<QDateTime> calculate(QDate const& fixedDate, Coordinates const& geo, SalatParameters const& angles, qreal asrRatio);
	static Coordinates createCoordinates(QDateTime local, qreal latitude, qreal longitude);
	static SalatParameters createParams(QVariantMap const& angleMap);
	virtual ~Calculator();
};

} /* namespace salat */
#endif /* CALCULATOR_H_ */
