#include "precompiled.h"

#include "applicationui.hpp"
#include "Logger.h"
#include "CalculatorTest.h"

using namespace bb::cascades;
using namespace salat;

Q_DECL_EXPORT int main(int argc, char **argv)
{
    Application app(argc, argv);

    bb::system::InvokeManager i;

    registerLogging( i.startupMode() == ApplicationStartupMode::InvokeCard ? CARD_LOG : UI_LOG );

    //CalculatorTest::testCalculate();

    ApplicationUI ui(&i);
    return Application::exec();
}
