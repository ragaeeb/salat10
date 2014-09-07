import bb.cascades 1.2

TabbedPane
{
    id: root
    activeTab: timingsTab
    
    Menu.definition: CanadaIncMenu
    {
        id: menuDef
        projectName: "salat10"
        allowDonations: true
        showServiceLogging: true
        help.imageSource: "images/menu/ic_help.png"
        help.title: qsTr("Help") + Retranslate.onLanguageChanged
        settings.imageSource: "images/menu/ic_settings.png"
        settings.title: qsTr("Settings") + Retranslate.onLanguageChanged
    }
    
    onActiveTabChanged: {
        peekEnabled = activeTab != locationTab;
    }

    Tab
    {
        id: timingsTab
        title: qsTr("Timings") + Retranslate.onLanguageChanged
        description: qsTr("Salah Times") + Retranslate.onLanguageChanged
        imageSource: "images/tabs/ic_clock.png"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivateWhenSelected
        
        delegate: Delegate
        {
            source: "TimingsPane.qml"
            
            function onLocateClicked()
            {
                locationTab.triggered();
                activeTab = locationTab;
            }
            
            onObjectChanged: {
                if (active) {
                    object.locateClicked.connect(onLocateClicked);
                }
            }
        }

        onTriggered: {
            console.log("UserEvent: TimingsTab");
        }
    }

    Tab {
        id: compass
        title: qsTr("Qibla") + Retranslate.onLanguageChanged
        description: qsTr("Compass") + Retranslate.onLanguageChanged
        imageSource: "images/compass/ic_compass.png"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivatedWhileSelected

        delegate: Delegate {
            source: "CompassPane.qml"
        }

        onTriggered: {
            console.log("UserEvent: CompassTab");
        }
    }
    
    Tab {
        id: articles
        title: qsTr("Articles") + Retranslate.onLanguageChanged
        description: qsTr("Articles") + Retranslate.onLanguageChanged
        imageSource: "images/tabs/ic_article.png"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivatedWhileSelected
        
        delegate: Delegate {
            source: "ArticlesPage.qml"
        }

        onTriggered: {
            console.log("UserEvent: ArticlesTab");
        }
    }
    
    Tab {
        id: sujud
        title: qsTr("Sujud As-Sahw") + Retranslate.onLanguageChanged
        description: qsTr("Prostration of Forgetfulness") + Retranslate.onLanguageChanged
        imageSource: "images/tabs/ic_articles.png"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivatedWhileSelected
        
        delegate: Delegate {
            source: "SujudAsSahwPane.qml"
        }

        onTriggered: {
            console.log("UserEvent: SujudTab");
        }
    }
    
    Tab {
        id: locationTab
        title: qsTr("Location") + Retranslate.onLanguageChanged
        imageSource: "images/tabs/ic_map.png"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivatedWhileSelected
        
        delegate: Delegate {
            source: "LocationPane.qml"
        }

        onTriggered: {
            console.log("UserEvent: LocationTab");
        }
    }
    
    Tab {
        id: tutorial
        title: qsTr("Tutorial") + Retranslate.onLanguageChanged
        description: qsTr("Step by Step") + Retranslate.onLanguageChanged
        imageSource: "images/tabs/ic_tutorial.png"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivatedWhileSelected
        
        delegate: Delegate {
            source: "TutorialPane.qml"
        }

        onTriggered: {
            console.log("UserEvent: TutorialTab");
        }
    }
    
    function onSettingChanged(key)
    {
        if (key == "location")
        {
            var location = persist.getValueFor("location");
            locationTab.description = location ? location : qsTr("Location");
        }
    }
    
    function onSidebarVisualStateChanged(newState)
    {
        sidebarStateChanged.disconnect(onSidebarVisualStateChanged);
        onSettingChanged("location");
        
        persist.settingChanged.connect(onSettingChanged);
    }
    
    function initialized()
    {
        if ( !persist.contains("angles") ) {
            menuDef.settings.triggered();
        }
        
        sidebarStateChanged.connect(onSidebarVisualStateChanged);
    }

    onCreationCompleted: {
        app.lazyInitComplete.connect(initialized);
    }
}