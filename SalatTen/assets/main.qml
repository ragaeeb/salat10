import bb.cascades 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        page.destroy();
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
    }
    
    Page
    {
        id: tabsPage

        Container
        {
            layout: DockLayout {}
            
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
                    opacity: timings.draggingStarted ? 1 : 0
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
            
            ResultListView
            {
                id: timings
                
                function onExportReady(daysToExport, result, accountId)
                {
                    progressDelegate.delegateActive = true;
                    offloader.exportToCalendar(daysToExport, result, accountId);
                    
                    navigationPane.pop();
                }
                
                function exportToCalendar()
                {
                    if ( offloader.hasCalendarAccess() )
                    {
                        definition.source = "CalendarExport.qml";
                        
                        var exporter = definition.createObject();
                        exporter.exportingReady.connect(onExportReady);
                        
                        navigationPane.push(exporter);
                    }
                }
                
                function onFinished(confirmed)
                {
                    if (confirmed) {
                        console.log("UserEvent: ClearCalendarPromptYes");
                        progressDelegate.delegateActive = true;
                        offloader.cleanupCalendarEvents();
                    } else {
                        console.log("UserEvent: ClearCalendarPromptNo");
                    }
                    
                    reporter.record("ClearCalendarResult", confirmed.toString());
                }
                
                function clearCalendar() {
                    persist.showDialog( timings, qsTr("Confirmation"), qsTr("Are you sure you want to clear all favourites?") );
                }
                
                onCreationCompleted: {
                    timings.maxWidth = deviceUtils.pixelSize.width
                    timings.maxHeight = deviceUtils.pixelSize.height
                    quoteLabel.maxWidth = timings.maxWidth-100;
                }
                
                onFooterShown: {
                    sql.fetchRandomBenefit(quoteLabel);
                }
            }
            
            TextArea
            {
                id: quoteLabel
                backgroundVisible: false
                editable: false
                textStyle.fontSize: FontSize.XXSmall
                opacity: timings.lssh.firstVisibleItem.length == 1 && !timings.lssh.scrolling ? 1 : 0
                textStyle.textAlign: TextAlign.Center
                horizontalAlignment: HorizontalAlignment.Center
                topMargin: 0;bottomMargin: 0
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.GetRandomBenefit)
                    {
                        var quote = data[0];
                        text = "<html><i>\n“%1”</i>\n\n- <b><a href=\"%5\">%2</a>%4</b>\n\n[%3]\n</html>".arg( quote.body.replace(/&/g,"&amp;") ).arg(quote.author).arg( quote.reference.replace(/&/g,"&amp;") ).arg( global.getSuffix(quote.birth, quote.death, quote.is_companion == 1, quote.female == 1) ).arg( quote.id.toString() );
                    }
                }
                
                activeTextHandler: ActiveTextHandler
                {
                    id: ath
                    
                    onTriggered: {
                        var link = event.href.toString();
                        
                        if ( link.match("\\d+") ) {
                            persist.invoke("com.canadainc.Quran10.bio.previewer", "", "", "", link, global);
                            reporter.record("OpenAuthorLink", link);
                        }
                        
                        event.abort();
                    }
                }
            }

            ControlDelegate
            {
                id: progressDelegate
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                delegateActive: false;
                visible: delegateActive
                
                function onProgressChanged(current, total)
                {
                    control.showBusy = false;
                    control.value = current;
                    control.toValue = total;
                }
                
                function onComplete(message, icon)
                {
                    delegateActive = false;
                    persist.showToast(message, icon);
                }
                
                onCreationCompleted: {
                    offloader.operationProgress.connect(onProgressChanged);
                    offloader.operationComplete.connect(onComplete);
                }
                
                sourceComponent: ComponentDefinition
                {
                    Container
                    {
                        property alias value: progress.value
                        property alias toValue: progress.toValue
                        property alias showBusy: busy.running
                        horizontalAlignment: HorizontalAlignment.Fill
                        
                        ActivityIndicator
                        {
                            id: busy
                            horizontalAlignment: HorizontalAlignment.Center
                            preferredHeight: 100; preferredWidth: 100
                            running: true
                        }
                        
                        ProgressIndicator
                        {
                            id: progress
                            fromValue: 0;
                            horizontalAlignment: HorizontalAlignment.Center
                            state: ProgressIndicatorState.Progress
                        }
                    }
                }
            }
        }
    }
    
    function onCurrentEventChanged()
    {
        var current = boundary.getCurrent( new Date() );
        var k = current.key;
        
        if (k == "halfNight" || k == "lastThirdNight") {
            k = "isha";
        }
        
        var src = "images/graphics/%1.jpg".arg(k);
        bg.imageSource = src;
        offloader.blur(bg2, src);
    }
    
    function onReady()
    {
        notification.currentEventChanged.connect(onCurrentEventChanged);
        onCurrentEventChanged();
        
        timings.anim.play();
        sql.fetchRandomBenefit(quoteLabel);
    }
    
    onCreationCompleted: {
        app.lazyInitComplete.connect(onReady);
    }
}