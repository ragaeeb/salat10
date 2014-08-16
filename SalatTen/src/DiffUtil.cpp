#include "precompiled.h"

#include "DiffUtil.h"

namespace salat {

using namespace bb::cascades;

void DiffUtil::diffIqamahs(GroupDataModel* model, QMap<QString, QTime> const& iqamahs)
{
    int sections = model->childCount( QVariantList() );

    for (int i = 0; i < sections; i++)
    {
        int childrenInSection = model->childCount( QVariantList() << i );

        for (int j = 0; j < childrenInSection; j++)
        {
            QVariantList indexPath = QVariantList() << i << j;
            QVariantMap current = model->data(indexPath).toMap();
            QString key = current.value("key").toString();

            if ( iqamahs.contains(key) )
            {
                QDateTime iqamah = QDateTime( current.value("dateValue").toDate(), iqamahs.value(key) );
                current["iqamah"] = iqamah;
            } else {
                current.remove("iqamah");
            }

            model->updateItem(indexPath, current);
        }
    }
}

} /* namespace salat */
