#ifndef DIFFUTIL_H_
#define DIFFUTIL_H_

namespace bb {
    namespace cascades {
        class GroupDataModel;
    }
}

namespace salat {

using namespace bb::cascades;

class DiffUtil
{
public:
    static void diffIqamahs(GroupDataModel* model, QMap<QString, QTime> const& iqamahs);
};

} /* namespace salat */

#endif /* DIFFUTIL_H_ */
