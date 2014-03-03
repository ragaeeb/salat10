#include "precompiled.h"

#include "Logger.h"

#include "applicationui.hpp"

using namespace bb::cascades;
using namespace salat;

#if !defined(QT_NO_DEBUG)
namespace {

void redirectedMessageOutput(QtMsgType type, const char *msg) {
	Q_UNUSED(type);
	fprintf(stderr, "%s\n", msg);
}

}
#endif

Q_DECL_EXPORT int main(int argc, char **argv)
{
    Application app(argc, argv);

#if !defined(QT_NO_DEBUG)
	qInstallMsgHandler(redirectedMessageOutput);
#endif

    ApplicationUI::create(&app);
    return Application::exec();
}
