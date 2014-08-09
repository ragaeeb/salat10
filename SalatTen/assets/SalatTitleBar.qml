import bb.cascades 1.0

TitleBar
{
    signal editTitleTriggered();
    property alias bannerText: bannerLabel.text
    
    kind: TitleBarKind.FreeForm
    kindProperties: FreeFormTitleBarKindProperties
    {
        content: Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Top
            background: titleBG.imagePaint
            preferredHeight: 100
            leftPadding: 20
            
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            
            attachedObjects: [
                ImagePaintDefinition {
                    id: titleBG
                    imageSource: "images/graphics/title_bg.png"
                }
            ]
            
            ImageView {
                imageSource: "images/graphics/title_arrow.png"
                topMargin: 0
                leftMargin: 0
                rightMargin: 0
                bottomMargin: 0
                scalingMethod: ScalingMethod.AspectFill
                horizontalAlignment: HorizontalAlignment.Left
                verticalAlignment: VerticalAlignment.Center
                translationX: -300
                
                animations: [
                    ParallelAnimation
                    {
                        id: arrowAnim
                        delay: 1000
                        
                        FadeTransition {
                            easingCurve: StockCurve.QuinticIn
                            fromOpacity: 0
                            toOpacity: 1
                            duration: 500
                        }
                        
                        TranslateTransition {
                            toX: 0
                            fromX: -300
                            duration: 1000
                            easingCurve: StockCurve.SineOut
                        }
                        
                        onCreationCompleted: {
                            play();
                        }
                    }
                ]
            }
            
            ImageView {
                imageSource: "images/graphics/title.png"
                topMargin: 0
                leftMargin: 10
                rightMargin: 0
                bottomMargin: 0
                scalingMethod: ScalingMethod.AspectFit
                horizontalAlignment: HorizontalAlignment.Left
                verticalAlignment: VerticalAlignment.Center
                translationX: -300
                
                animations: [
                    ParallelAnimation
                    {
                        id: translateFade
                        
                        FadeTransition {
                            easingCurve: StockCurve.CircularOut
                            fromOpacity: 0
                            toOpacity: 1
                            duration: 500
                        }
                        
                        TranslateTransition {
                            toX: 0
                            fromX: -300
                            duration: 1000
                            easingCurve: StockCurve.ExponentialInOut
                        }
                        
                        onCreationCompleted: {
                            play();
                        }
                    }
                ]
                
                onCreationCompleted: {
                    translateFade.play();
                }
            }
        }
        
        expandableArea
        {
            onExpandedChanged: {
                if (expanded) {
                    fader.play();
                } else {
                    bannerLabel.translationY = -100;
                }
            }
            
            content: Container
            {
                id: exContainer
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                contextActions: [
                    ActionSet {
                        title: bannerText
                        
                        ActionItem {
                            title: qsTr("Edit") + Retranslate.onLanguageChanged
                            imageSource: "images/menu/ic_edit.png"
                            
                            onTriggered: {
                                editTitleTriggered();
                            }
                        }
                    }
                ]
                
                onTouch: {
                    if ( event.isDown() ) {
                        exContainer.opacity = 0.5;
                    } else if ( event.isUp() || event.isCancel() ) {
                        exContainer.opacity = 1;
                    }
                }
                
                Container {
                    background: Color.White
                    preferredHeight: 2
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Top
                }
                
                Container
                {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    layout: DockLayout {}
                    
                    ImageView {
                        imageSource: "asset:///images/graphics/banner_expanded.amd"
                        topMargin: 0
                        leftMargin: 0
                        rightMargin: 0
                        bottomMargin: 0
                        scalingMethod: ScalingMethod.AspectFill
                        maxHeight: 75
                        
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Top
                    }
                    
                    Label {
                        id: bannerLabel
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Center
                        textStyle.fontSize: FontSize.XSmall
                        textStyle.textAlign: TextAlign.Center
                        translationY: -100
                        
                        animations: [
                            TranslateTransition
                            {
                                id: fader
                                fromY: -100
                                toY: 0
                                easingCurve: StockCurve.BounceOut
                                duration: 750
                            }
                        ]
                    }
                }
                
                Container {
                    background: Color.White
                    preferredHeight: 2
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Bottom
                }
            }
        }
    }
}