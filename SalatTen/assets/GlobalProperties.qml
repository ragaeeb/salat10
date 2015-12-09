import bb.cascades 1.0

QtObject
{
    id: root
    
    function onFinished(result, rememberMe, cookie)
    {
        if (cookie == "locationServices")
        {
            if (!result && rememberMe) {
                persist.setFlag("hideLocationServicesWarning", 1);
            }
            
            if (result) {
                persist.launchSettingsApp("location");
            }
            
            reporter.record( cookie, result.toString()+"_"+rememberMe.toString() );
        }
    }
    
    function onPromptFinished(result, cookie)
    {
        if (result && cookie.app == "quran10") {
            persist.openUri("http://quran10.canadainc.org");
        }
        
        reporter.record(cookie.app, result);
    }
    
    function getRandomReal(min, max) {
        return Math.random() * (max - min) + min;
    }
    
    function onTargetLookupFinished(target, success)
    {
        if (!success) {
            persist.showDialog(root, {'app': "quran10"}, qsTr("Quran10"), qsTr("This feature requires the app Quran10 v4.0.0.0 or greater to be installed on your device. Would you like to download and install it now?"), qsTr("Yes"), qsTr("No"), true, "", false, "onPromptFinished" );
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
    
    function showLocationServices()
    {
        if ( !persist.containsFlag("hideLocationServicesWarning") ) {
            persist.showDialog(root, "locationServices", qsTr("Location Services"), qsTr("Warning: It seems like the location services is not enabled on your BlackBerry 10 device so the app will not be able to fetch real-time data and map information.\n\nWould you like to launch the Location Services screen and enable the Location Services permission there?"), qsTr("Yes"), qsTr("No"), true, qsTr("Don't ask again"), false );
        }
    }
    
    function renderAthanStatus(ListItemData)
    {
        if (ListItemData.athaan == true && ListItemData.isSalat) {
            return "images/list/ic_athaan_enable.png";
        } else if (ListItemData.notification == true) {
            return "images/list/ic_notification_enable.png";
        } else {
            return "images/list/ic_athaan_mute.png";
        }
    }
    
    function onConfirmedDownload(result, data)
    {
        if (data.cookie == "dbUpdate")
        {
            reporter.record( "UpdateDBResult", result.toString() );
            
            if (result) {
                notification.downloadPlugins();
            } else {
                notification.clearPendingCheckin();
            }
        }
    }
    
    function onUpdateAvailable(size, version, forced)
    {
        if (boundary.calculationFeasible)
        {
            if (forced) {
                onConfirmedDownload(true, {'cookie': "dbUpdate"});
            } else {
                persist.showDialog( root, {'cookie': "dbUpdate"}, qsTr("Updates"), qsTr("An updated database of articles and quotes was posted on %1. The total download size is %2. Would you like to download it now?").arg( Qt.formatDate( new Date(version), "MMM d, yyyy").toString() ).arg( textUtils.bytesToSize(size) ), qsTr("Yes"), qsTr("No"), true, "", false, "onConfirmedDownload" );
            }
        }
    }
    
    onCreationCompleted: {
        notification.dbUpdateAvailable.connect(onUpdateAvailable);
    }
}