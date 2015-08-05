import bb.cascades 1.3
import bb.cascades.pickers 1.0
import bb.multimedia 1.0

Sheet
{
    id: root
    property variant all
    
    Page
    {
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
        titleBar: TitleBar
        {
            title: qsTr("Select Athan") + Retranslate.onLanguageChanged
            
            acceptAction: ActionItem
            {
                id: accept
                property string selected
                enabled: selected.length > 0
                title: qsTr("Accept") + Retranslate.onLanguageChanged
                imageSource: "images/graphics/title_arrow.png"
                
                onSelectedChanged: {
                    if (selected.length > 0)
                    {
                        player.sourceUrl = selected;
                        
                        if (npc.acquired) {
                            player.play();
                        } else {
                            npc.acquire();
                        }
                    }
                }
                
                onTriggered: {
                    console.log("UserEvent: AcceptAthan");
                    reporter.record("AcceptAthan", selected);
                    var customAthans = {};
                    
                    for (var i = all.length-1; i >= 0; i--) {
                        customAthans[ all[i] ] = selected;
                    }
                    
                    persist.saveValueFor("customAthaans", customAthans);
                    persist.setFlag("athanPicked", 1);
                    persist.showToast( qsTr("Athan Successfully Set"), "images/menu/ic_select_more.png" );
                    
                    root.close();
                }
            }
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Center
            background: bg.imagePaint
            topPadding: 10;
            
            Label
            {
                text: qsTr("Please choose your preferred athan for Dhuhr to Isha (you will have to set the Fajr one on your own):") + Retranslate.onLanguageChanged
                multiline: true
                horizontalAlignment: HorizontalAlignment.Fill
                textStyle.textAlign: TextAlign.Center
            }
            
            Divider {
                bottomMargin: 0
            }
            
            ListView
            {
                id: listView
                scrollRole: ScrollRole.Main
                
                dataModel: ArrayDataModel {
                    id: adm
                }
                
                onTriggered: {
                    console.log("UserEvent: AthanTriggered", indexPath);
                    clearSelection();
                    toggleSelection(indexPath);
                    
                    player.stop();
                    player.reset();
                    
                    var uri = dataModel.data(indexPath).uri;
                    
                    if (uri) {
                        accept.selected = uri;
                        reporter.record("AthanPreview", uri);
                    } else {
                        picker.open();
                        reporter.record("AthanPreviewPick");
                    }
                }
                
                listItemComponents: [
                    ListItemComponent
                    {
                        StandardListItem
                        {
                            id: sli
                            translationX: 1000
                            imageSource: ListItemData.imageSource
                            title: ListItemData.artist
                            
                            ListItem.onInitializedChanged: {
                                if (initialized) {
                                    tt.play();
                                }
                            }
                            
                            animations: [
                                TranslateTransition
                                {
                                    id: tt
                                    fromX: 1000
                                    toX: 0
                                    delay: Math.max(250, sli.ListItem.indexInSection*350)
                                    easingCurve: StockCurve.SineOut
                                    duration: sli.ListItem.indexInSection*500
                                }
                            ]
                        }
                    }
                ]
                
                onCreationCompleted: {
                    adm.append({'artist': qsTr("Anonymous"), 'imageSource': "images/menu/ic_help.png", 'uri': "asset:///audio/athan_sahabah.mp3"});
                    adm.append({'artist': qsTr("Muhammad Ibn Ibrahim Al Luhaidan"), 'imageSource': "images/list/ic_notification_enable.png", 'uri': "asset:///audio/athan_birmingham.mp3"});
                    adm.append({'artist': qsTr("Shaykh Muhammad Nasir-ud-Din al-Albani (رحمه الله)"), 'imageSource': "images/list/ic_athaan_enable.png", 'uri': "asset:///audio/athan_albaani.mp3"});
                    adm.append({'artist': "Custom", 'imageSource': "images/menu/ic_athaan_custom.png", 'uri': null});
                }
                
                attachedObjects: [
                    MediaPlayer {
                        id: player
                    },
                    
                    NowPlayingConnection {
                        id: npc
                        
                        onAcquired: {
                            player.play();
                        }
                        
                        onPause: {
                            player.pause();
                        }
                        
                        onPlay: {
                            player.play();
                        }
                        
                        onRevoked: {
                            player.pause();
                        }
                    },
                    
                    FilePicker
                    {
                        id: picker
                        defaultType: FileType.Music
                        mode: FilePickerMode.Picker
                        title: qsTr("Select Athan") + Retranslate.onLanguageChanged
                        
                        directories :  {
                            return ["/accounts/1000/removable/sdcard/music", "/accounts/1000/shared/music"]
                        }
                        
                        onFileSelected : {
                            console.log("UserEvent: AthanFileSelected", selectedFiles[0]);
                            reporter.record("AthanCustomPicked", selectedFiles[0]);
                            accept.selected = "file://"+selectedFiles[0];
                        }
                        
                        onCanceled: {
                            console.log("UserEvent: AthanFileCanceled");
                            reporter.record("AthanFileCanceled");
                            accept.selected = "";
                            listView.clearSelection();
                        }
                    }
                ]
            }
            
            attachedObjects: [
                ImagePaintDefinition {
                    id: bg
                    imageSource: "asset:///images/graphics/banner_expanded.amd"
                }
            ]
        }
    }
    
    onOpened: {
        tutorial.execBelowTitleBar( "previewAthan", qsTr("Tap on an item in the list to preview the athan sound."), ui.du(2) );
        tutorial.execCentered( "previewCustom", qsTr("To use your own custom athan sound, tap on the Custom list element and choose the audio file.") );
        tutorial.exec("acceptAthan", qsTr("When you are happy with your selection, tap the '%1' button.").arg(accept.title), HorizontalAlignment.Right, VerticalAlignment.Top, 0, ui.du(2), ui.du(4), 0, "images/tabs/ic_tutorial.png" );
    }
    
    onClosed: {
        player.stop();
        destroy();
    }
}