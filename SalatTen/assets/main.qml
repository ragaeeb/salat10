import bb.cascades 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: root
    
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
            id: cityItem
            layout: DockLayout {}
            
            ScrollView
            {
                id: backgroundView
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                scrollViewProperties.pinchToZoomEnabled: false
                
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
                        opacity: 0
                        loadEffect: ImageViewLoadEffect.FadeZoom
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill
                        scalingMethod: ScalingMethod.AspectFill
                    }
                }
            }
            
            ResultListView
            {
                id: cityList
                // Lists tries to expand as much as possible and since it's located inside another listView it will get unlimited widht. 
                stickToEdgePolicy: ListViewStickToEdgePolicy.Beginning
                property bool draggingStarted: false
                property alias hijriCalc: hijri
                scrollIndicatorMode: ScrollIndicatorMode.None
                
                onCreationCompleted: {
                    cityList.maxWidth = deviceUtils.pixelSize.width
                    cityList.maxHeight = deviceUtils.pixelSize.height
                    quoteLabel.maxWidth = cityList.maxWidth-100;
                }
                
                attachedObjects: [
                    ListScrollStateHandler {
                        id: lssh
                        property variant lastVisible
                        
                        onScrollingChanged: {
                            if (scrolling) {
                                cityList.draggingStarted = true
                                bg2.opacity = 1;
                            } else if (atBeginning) {
                                cityList.draggingStarted = false;
                                bg2.opacity = 0;
                            }
                        }
                        
                        onFirstVisibleItemChanged: {
                            if (lastVisible != firstVisibleItem && firstVisibleItem.length == 1)
                            {
                                sql.fetchRandomBenefit(quoteLabel);
                                lastVisible = firstVisibleItem;
                            }
                        }
                    },
                    
                    HijriCalculator {
                        id: hijri
                    }
                ]
                
                // list offset. Currently set from HeaderItem.qml. Ideally something similar to visibleArea would be nice instead.
                property int offset
                onOffsetChanged: {
                    // paralax-scrolling the background based on offset.
                    backgroundView.scrollToPoint(0, - offset / 3, ScrollAnimation.None);
                }
                
                listItemComponents: [
                    ListItemComponent {
                        type: "header"
                        HeaderItem {
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "item"
                        
                        EventListItem {
                            id: eli
                        }
                    }
                ]
            }
            
            TextArea
            {
                id: quoteLabel
                backgroundVisible: false
                editable: false
                textStyle.fontSize: FontSize.XXSmall
                opacity: lssh.firstVisibleItem.length == 1 && !lssh.scrolling ? 1 : 0
                textStyle.textAlign: TextAlign.Center
                horizontalAlignment: HorizontalAlignment.Center
                
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
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.GetRandomBenefit)
                    {
                        var quote = data[0];
                        text = "<html><i>\n“%1”</i>\n\n- <b><a href=\"%5\">%2</a>%4</b>\n\n[%3]</html>".arg( quote.body.replace(/&/g,"&amp;") ).arg(quote.author).arg( quote.reference.replace(/&/g,"&amp;") ).arg( getSuffix(quote.birth, quote.death, quote.is_companion == 1, quote.female == 1) ).arg( quote.id.toString() );
                    }
                }
                
                activeTextHandler: ActiveTextHandler
                {
                    onTriggered: {
                        var link = event.href.toString();
                        
                        if ( link.match("\\d+") ) {
                            persist.invoke("com.canadainc.Quran10.bio.previewer", "", "", "", link);
                            reporter.record("OpenAuthorLink", link);
                        }
                        
                        event.abort();
                    }
                }
            }
            
            function showAnim() {
                show.play();
            }
            function hideAnim() {
                show.stop();
                hide.play();
                cityList.scrollToPosition(ScrollPosition.Beginning,ScrollAnimation.Smooth);
            }
            
            animations: [
                ParallelAnimation {
                    id: show
                    target: cityList
                    FadeTransition {
                        fromOpacity: 0
                        toOpacity: 1
                        duration: 500
                        easingCurve: StockCurve.CubicOut
                    }
                    TranslateTransition {
                        fromY: 300
                        toY: 0
                        duration: 500
                        easingCurve: StockCurve.CubicOut
                    }
                },
                ParallelAnimation {
                    id: hide
                    target: cityList
                    FadeTransition {
                        toOpacity: 0
                        duration: 100
                        easingCurve: StockCurve.CubicIn
                    }
                    TranslateTransition {
                        fromY: 0
                        toY: 300
                        duration: 500
                        easingCurve: StockCurve.CubicIn
                    }
                }
            ]
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
        
        cityItem.showAnim();
        sql.fetchRandomBenefit(quoteLabel);
    }
    
    onCreationCompleted: {
        app.lazyInitComplete.connect(onReady);
    }
}