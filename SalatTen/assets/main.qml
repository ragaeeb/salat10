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
                    opacity: cityList.draggingStarted ? 1 : 0
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
                id: cityList
                
                function editHijriDate()
                {
                    menuDef.compDef.source = "AdjustHijriDialog.qml";
                    
                    var dialog = menuDef.compDef.createObject();
                    dialog.open();
                }
                
                onCreationCompleted: {
                    cityList.maxWidth = deviceUtils.pixelSize.width
                    cityList.maxHeight = deviceUtils.pixelSize.height
                    quoteLabel.maxWidth = cityList.maxWidth-100;
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
                opacity: cityList.lssh.firstVisibleItem.length == 1 && !cityList.lssh.scrolling ? 1 : 0
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
            
            function showAnim() {
                show.play();
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