#include "Translator.h"

namespace salat {

Translator::Translator()
{
	reload();

	m_salats[key_fajr] = true;
	m_salats[key_dhuhr] = true;
	m_salats[key_asr] = true;
	m_salats[key_maghrib] = true;
	m_salats[key_isha] = true;
}


void Translator::reload()
{
	m_map[key_fajr] = tr("Fajr");
	m_map[key_sunrise] = tr("Sunrise");
	m_map[key_dhuhr] = tr("Dhuhr");
	m_map[key_asr] = tr("Asr");
	m_map[key_maghrib] = tr("Maghrib");
	m_map[key_isha] = tr("Isha");
	m_map[key_half_night] = tr("1/2 Night");
	m_map[key_last_third_night] = tr("Last 1/3 Night");
}


QMap<QString, bool> Translator::salatMap() {
	return m_salats;
}


QString Translator::render(QString const& key) {
	return m_map.value(key);
}


QStringList Translator::salatKeys() {
	return QStringList() << key_fajr << key_dhuhr << key_asr << key_maghrib << key_isha;
}


QStringList Translator::eventKeys() {
	return QStringList() << key_fajr << key_sunrise << key_dhuhr << key_asr << key_maghrib << key_isha << key_half_night << key_last_third_night;
}


Translator::~Translator() {
}

} /* namespace salat */
