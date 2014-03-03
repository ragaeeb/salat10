#include "precompiled.h"

#include "service.hpp"
#include "Logger.h"

using namespace bb;
using namespace salat;

#if !defined(QT_NO_DEBUG)
namespace {

FILE* f = NULL;

void redirectedMessageOutput(QtMsgType type, const char *msg)
{
	Q_UNUSED(type);
	fprintf(f, "%s\n", msg);
}

}
#endif

Q_DECL_EXPORT int main(int argc, char **argv)
{
#if !defined(QT_NO_DEBUG)
	f = fopen("/accounts/1000/shared/misc/salat.txt", "w");
	qInstallMsgHandler(redirectedMessageOutput);
#endif

	LOGGER("Started");

	Application app(argc, argv);
	Service::create(&app);

	LOGGER("Executing event loop");

	return Application::exec();
}
