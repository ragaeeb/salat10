#ifndef QUERYID_H_
#define QUERYID_H_

#include <qobjectdefs.h>

namespace salat {

class QueryId
{
    Q_GADGET
    Q_ENUMS(Type)

public:
    enum Type {
    	GetArticles,
    	GetAllAngles,
    	GetAnglesForStrategy,
        GetSujudArticles,
        GetRandomBenefit
    };
};

}

#endif
