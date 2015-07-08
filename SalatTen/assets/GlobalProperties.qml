import bb.cascades 1.0

QtObject
{
    function onFinished(result, cookie)
    {
        if (result)
        {
            if (cookie.app == "quran10") {
                persist.openUri("http://quran10.canadainc.org");
            }
        }
        
        reporter.record(cookie, result);
    }
    
    function onTargetLookupFinished(target, success)
    {
        if (!success) {
            persist.showDialog(root, {'app': "quran10"}, qsTr("Quran10"), qsTr("This feature requires the app Quran10 v4.0.0.0 or greater to be installed on your device. Would you like to download and install it now?"), qsTr("Yes"), qsTr("No") );
        }
    }
    
    function getSuffix(birth, death, isCompanion, female)
    {
        if (isCompanion)
        {
            if (female) {
                return qsTr("رضي الله عنها");
            } else {
                return qsTr("رضي الله عنه");
            }
        } else if (death) {
            return qsTr(" (رحمه الله)");
        } else if (birth) {
            return qsTr(" (حفظه الله)");
        }
        
        return "";
    }
}