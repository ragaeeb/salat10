import bb.cascades 1.3
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        deviceUtils.cleanUpAndDestroy(page);
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
            notification.currentEventChanged.connect(onCurrentEventChanged);
            onCurrentEventChanged();
            
            previewer.delegateActive = true;
            
            permissions.process();
            
            if (boundary.calculationFeasible)
            {
                if (boundary.atLeastOneAthanScheduled)
                {
                    if ( !persist.containsFlag("athanPicked") ) {
                        var picker = definition.init("AthanPreviewSheet.qml");
                        picker.all = ["dhuhr", "asr", "maghrib", "isha"];
                        picker.open();
                    } else if ( !persist.containsFlag("tutorialMuteAthan") ) {
                        var picker = definition.init("MuteAthanTutorial.qml");
                        picker.open();
                    }
                }
            } else {
                if (!boundary.anglesSaved) {
                    quoteLabel.text = qsTr("No angles have been set\n\nTap here to choose the appropriate calculation angles...");
                } else {
                    quoteLabel.text = qsTr("No location has been set\n\nTap here to choose your location...");
                }
                
                tapHandler.tapped(undefined);
            }
        }
    }
    
    Page
    {
        id: tabsPage

        SwipeDetector
        {
            layout: DockLayout {}
            
            onSwipedUp: {
                tapper.activateList();
                reporter.record("SwipedUpPreview");
            }
            
            gestureHandlers: [
                TapHandler {
                    id: tapHandler
                    
                    function rootTapped()
                    {
                        if (!boundary.calculationFeasible)
                        {
                            if (!boundary.anglesSaved) {
                                menuDef.settings.triggered();
                            } else {
                                var x = definition.init("LocationPane.qml");
                                navigationPane.push(x);
                            }
                        }
                    }
                    
                    onTapped: {
                        reporter.record("NoLocationsSetTapped");
                        rootTapped();
                    }
                }
            ]
            
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
                        
                        quoteLabel.maxWidth = control.maxWidth-100;
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
                
                onControlChanged: {
                    if (control) {
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