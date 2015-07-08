#include "precompiled.h"

#include "service.hpp"
#include "Logger.h"

using namespace bb;
using namespace salat;

Q_DECL_EXPORT int main(int argc, char **argv)
{
	Application app(argc, argv);
	Service::create(&app);

	registerLogging(SERVICE_LOG);

	return Application::exec();
}
