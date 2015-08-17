import bb.cascades 1.3
import com.canadainc.data 1.0
import "paddings.js" as Paddings

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        deviceUtils.cleanUpAndDestroy(page);
        
        if ( reporter.deferredCheck("alFurqanAdvertised", 20) ) {
            var advertisement = definition.init("AlFurqanAdvertisement.qml");
            advertisement.open();
        } else if ( reporter.deferredCheck("alFurqanQuranAdvertised", 5) ) {
            var advertisement = definition.init("AlFurqanAdvertisement.qml");
            advertisement.quran = true;
            advertisement.open();
        }
    }
    
    function onFinished(result, data)
    {
        if (result)
        {
            if (data.cookie == "prayerSchedulesArticle") {
                persist.openUri("http://www.troid.ca/index.php/comprehensive/salaah/810-prayer-schedules-important-rulings-guidelines-and-cautions");
            } else if (data.cookie == "prayerSchedulesVideo") {
                persist.openUri("https://www.youtube.com/watch?v=UpzkRvWSIoc");
            }
        }
        
        persist.setFlag(data.cookie, 1);
        reporter.record(data.cookie, result);
    }
    
    Menu.definition: CanadaIncMenu
    {
        id: menuDef
        projectName: "salat10"
        allowDonations: true
        bbWorldID: "21198062"
        help.imageSource: "images/menu/ic_help.png"
        help.title: qsTr("Help") + Retranslate.onLanguageChanged
        settings.imageSource: "images/menu/ic_settings.png"
        settings.title: qsTr("Settings") + Retranslate.onLanguageChanged
        
        onFinished: {
            if (clean) {
                tutorial.promptVideo("https://youtu.be/Y4QjODg6SR4");
            }
            
            notification.currentEventChanged.connect(onCurrentEventChanged);
            
            if (boundary.calculationFeasible)
            {
                previewer.delegateActive = true;
                
                tutorial.execCentered("randomBenefit", qsTr("You can tap on the author's name to find out more information about them (you need to have the Quran10 app installed).") );
                tutorial.exec("todaysHijriDate", qsTr("This is today's Hijri date."), HorizontalAlignment.Center, VerticalAlignment.Bottom, 0, 0, 0, ui.du(Paddings.previewLine1VPadding) );
                tutorial.exec("exportToCalendar", qsTr("You can press-and-hold on this section to export the timings right to your calendar so that you can get prayer time reminders to show up directly on your device's calendar. This will also allow reminders to be shown even while the app is closed!"), HorizontalAlignment.Center, VerticalAlignment.Bottom, 0, 0, 0, ui.du(Paddings.previewLine1VPadding) );
                tutorial.exec("hijriConverter", qsTr("You can tap on this calendar icon to convert between Hijri and Gregorian calendar dates!"), HorizontalAlignment.Left, VerticalAlignment.Bottom, ui.du(2), 0, 0, ui.du(Paddings.previewLine1VPadding) );
                tutorial.exec("editDate", qsTr("You can tap on this edit icon to adjust the calculated hijri date as necessary."), HorizontalAlignment.Right, VerticalAlignment.Bottom, 0, ui.du(2), 0, ui.du(Paddings.previewLine1VPadding) );
                tutorial.exec("currentEvent", qsTr("This displays the current event that is already in progress."), HorizontalAlignment.Left, VerticalAlignment.Bottom, ui.du(13), 0, 0, ui.du(Paddings.previewLine2VPadding) );
                tutorial.exec("editCurrent", qsTr("You can tap on this edit icon to adjust the current event as necessary."), HorizontalAlignment.Right, VerticalAlignment.Bottom, 0, ui.du(2), 0, ui.du(Paddings.previewLine2VPadding) );
                tutorial.exec("toggleCurrentEvent", qsTr("Tapping on the icon will toggle the athan and notification settings for that specific event. So if you want to turn on or turn off the athan and notifications tap on the icon."), HorizontalAlignment.Left, VerticalAlignment.Bottom, ui.du(5), 0, 0, ui.du(Paddings.previewLine2VPadding) );
                tutorial.exec("nextEvent", qsTr("This displays the next event that is coming up."), HorizontalAlignment.Left, VerticalAlignment.Bottom, ui.du(13), 0, 0, ui.du(1) );
                tutorial.exec("toggleNextEvent", qsTr("Tapping on the icon will toggle the athan and notification settings for that next event. So if you want to turn on or turn off the athan and notifications tap on the icon."), HorizontalAlignment.Left, VerticalAlignment.Bottom, ui.du(2), 0, 0, ui.du(1) );
                tutorial.exec("editNextEvent", qsTr("You can tap on this edit icon to adjust the next event's timing as necessary."), HorizontalAlignment.Right, VerticalAlignment.Bottom, 0, ui.du(2), 0, ui.du(1) );
                tutorial.exec("footerTap", qsTr("Tap anywhere on this strip to expand it and see the details for today."), HorizontalAlignment.Center, VerticalAlignment.Bottom, 0, 0, 0, ui.du(1) );
                tutorial.execSwipe("expandFooter", qsTr("You can also expand this strip by swiping-up on it and see the details."), HorizontalAlignment.Center, VerticalAlignment.Bottom, "u");
                tutorial.execSwipe("openAppMenu", qsTr("Swipe down from the top-bezel to display the Settings and Help and file bugs!"), HorizontalAlignment.Center, VerticalAlignment.Top, "d");
                
                if ( reporter.deferredCheck("prayerSchedulesArticle", 3) ) {
                    persist.showDialog( navigationPane, {'cookie': 'prayerSchedulesArticle'}, qsTr("Prayer Schedule Rulings"), qsTr("Note that prayer schedule apps can sometimes give you incorrect timings! Would you like to learn more?"), qsTr("Yes"), qsTr("No") );
                } else if ( reporter.deferredCheck("prayerSchedulesVideo", 21) ) {
                    persist.showDialog( navigationPane, {'cookie': 'prayerSchedulesVideo'}, qsTr("Prayer Schedules"), qsTr("Would you like to learn what the scholars said about prayer schedules?"), qsTr("Yes"), qsTr("No") );
                }
                
                if (boundary.atLeastOneAthanScheduled)
                {
                    if ( !persist.containsFlag("athanPicked") ) {
                        var picker = definition.init("AthanPreviewSheet.qml");
                        picker.all = ["dhuhr", "asr", "maghrib", "isha"];
                        picker.open();
                    } else if ( !tutorial.suppressTutorials && !persist.containsFlag("tutorialMuteAthan") ) {
                        var picker = definition.init("MuteAthanTutorial.qml");
                        picker.open();
                    }
                }
                
                onCurrentEventChanged();
            } else if (!boundary.anglesSet) {
                var ok = app.refreshLocation();
                
                if (!ok) {
                    global.showLocationServices();
                }
                
                menuDef.settings.triggered();
            }
        }
    }
    
    Page
    {
        id: timingsPage

        SwipeDetector
        {
            layout: DockLayout {}
            
            onSwipedUp: {
                if (previewer.delegateActive)
                {
                    tapper.activateList();
                    reporter.record("SwipedUpPreview");
                }
            }
            
            onSwipedUpRight: {
                if (previewer.delegateActive)
                {
                    tapper.activateList();
                    reporter.record("SwipedUpRightPreview");
                }
            }
            
            onSwipedUpLeft: {
                if (previewer.delegateActive)
                {
                    tapper.activateList();
                    reporter.record("SwipedUpLeftPreview");
                }
            }
            
            Container
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                layout: DockLayout {}
                
                ImageView
                {
                    id: bg
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    scalingMethod: ScalingMethod.AspectFill
                }
                
                ImageView
                {
                    id: bg2
                    opacity: timings.delegateActive ? 1 : 0
                    loadEffect: ImageViewLoadEffect.FadeZoom
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    scalingMethod: ScalingMethod.AspectFill
                }
                
                Container
                {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    background: Color.Black
                    opacity: bg2.opacity == 1 ? 0.35 : 0
                }
            }
            
            ControlDelegate
            {
                id: timings
                delegateActive: false
                source: "ResultListView.qml"
                visible: delegateActive
                property bool firstTime: false
                
                function onFooterShown()
                {
                    if (!firstTime) { // this is needed because for some reason the first time the list view initializes the footerShown() signal is emitted
                        firstTime = true;
                    } else {
                        if (boundary.calculationFeasible) {
                            sql.fetchRandomBenefit(quoteLabel);
                        }
                    }
                }
                
                onControlChanged: {
                    if (control)
                    {
                        control.maxWidth = deviceUtils.pixelSize.width
                        control.maxHeight = deviceUtils.pixelSize.height
                        control.anim.play();
                        control.scrollToItem([0,0], ScrollAnimation.Smooth);
                        control.footerShown.connect(onFooterShown);
                    }
                }
            }
            
            ControlDelegate
            {
                id: previewer
                verticalAlignment: VerticalAlignment.Bottom
                horizontalAlignment: HorizontalAlignment.Fill
                delegateActive: false
                source: "PreviewListItem.qml"
                visible: delegateActive
                
                onDelegateActiveChanged: {
                    if (!delegateActive && control) {
                        control.cleanUp();
                    }
                }
                
                onControlChanged: {
                    if (control) {
                        quoteLabel.maxHeight = deviceUtils.pixelSize.height-control.preferredHeight;
                        sql.fetchRandomBenefit(quoteLabel);
                    }
                }

                gestureHandlers: [
                    TapHandler
                    {
                        id: tapper
                        
                        function activateList()
                        {
                            if (previewer.delegateActive)
                            {
                                timings.delegateActive = true;
                                previewer.delegateActive = false;
                            }
                        }
                        
                        onTapped: {
                            reporter.record("PreviewTapped");
                            activateList();
                        }
                    }
                ]
            }
            
            QuoteLabel {
                id: quoteLabel
                opacity: previewer.delegateActive || ( timings.control && timings.control.lssh.firstVisibleItem.length == 1 && !timings.control.lssh.scrolling ) || !boundary.calculationFeasible ? 1 : 0
            }
            
            MissingParametersControl {
                id: missing
            }
            
            OperationProgressBar {
                id: progressDelegate
            }
            
            PermissionToast
            {
                id: permissions
                horizontalAlignment: HorizontalAlignment.Right
                verticalAlignment: VerticalAlignment.Center
                
                function process()
                {
                    var allMessages = [];
                    var allIcons = [];
                    
                    if ( !persist.hasLocationAccess() ) {
                        allMessages.push("Warning: It seems like the app does not have access to access your device's location. This permission is needed to detect your GPS location so that accurate calculations can be made. If you keep this permission off, the app may not work properly.\n\nPress OK to launch the application permissions, then go to Salat10 and please enable the Location permission.");
                        allIcons.push("images/toast/ic_location_failed.png");
                    }
                    
                    if ( !persist.hasSharedFolderAccess() ) {
                        allMessages.push("Warning: It seems like the app does not have access to access your shared folder. This permission is needed to allow you to set custom athan sounds. Without this permission some features may not work properly.");
                        allIcons.push("images/toast/ic_no_shared_folder.png");
                    }
                    
                    if ( !offloader.isServiceRunning() )
                    {
                        allMessages.push("Warning: It seems like the Salat10 background service is not running. The Run In Background permission is necessary for the athaan and notifications to function properly.");
                        allIcons.push("images/toast/no_service.png");
                    }
                    
                    if (allMessages.length > 0)
                    {
                        messages = allMessages;
                        icons = allIcons;
                        delegateActive = true;
                    }
                }
            }
        }
    }
    
    function onCurrentEventChanged()
    {
        if (boundary.calculationFeasible)
        {
            if (!timings.delegateActive) {
                previewer.delegateActive = true;
            }
            
            var current = boundary.getCurrent( new Date() );
            var k = current.key;
            
            if (k == "halfNight" || k == "lastThirdNight") {
                k = "isha";
            }
            
            var src = "images/graphics/%1.jpg".arg(k);
            bg.imageSource = src;
            offloader.blur(bg2, src);
        } else {
            bg.imageSource = "images/graphics/background.png";
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
            
            function init(qml)
            {
                source = qml;
                return createObject();
            }
        }
    ]
}