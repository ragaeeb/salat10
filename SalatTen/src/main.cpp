#include "precompiled.h"

#include "applicationui.hpp"

using namespace bb::cascades;
using namespace salat;

Q_DECL_EXPORT int main(int argc, char **argv)
{
    Application app(argc, argv);

    ApplicationUI::create(&app);
    return Application::exec();
}
