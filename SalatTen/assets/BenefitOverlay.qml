import bb.cascades 1.0
import com.canadainc.data 1.0

ControlDelegate
{
    id: root
    property string benefitText
    horizontalAlignment: HorizontalAlignment.Right
    verticalAlignment: VerticalAlignment.Center
    delegateActive: false
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.GetRandomBenefit && data.length > 0)
        {
            var quote = data[0];
            
            if (quote.reference.length > 0) {
                benefitText = qsTr("\"%1\" - %2\n%3").arg(quote.body).arg(quote.author).arg(quote.reference);
            } else {
                benefitText = qsTr("\"%1\" - %2").arg(quote.body).arg(quote.author);
            }
            
            delegateActive = true;
        }
    }
    
    function initialized()
    {
        sql.dataLoaded.connect(onDataLoaded);
        sql.query = "SELECT author,body,reference from articles WHERE event_key='quotes'";
        sql.load(QueryId.GetRandomBenefit);
    }
    
    onCreationCompleted: {
        var random = Math.floor( Math.random()*10 ) + 1;
        
        if (random > 7) {
            app.lazyInitComplete.connect(initialized);
        }
    }
    
    sourceComponent: ComponentDefinition
    {
        Container
        {
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Fill
            topPadding: 2; bottomPadding: 2; rightPadding: 2; leftPadding: 2
            background: Color.White
            translationX: 250
            
            animations: [
                SequentialAnimation
                {
                    id: animator
                    
                    TranslateTransition
                    {
                        toX: 0
                        easingCurve: StockCurve.QuarticOut
                        duration: 1500
                        delay: 1000
                    }
                    
                    TranslateTransition
                    {
                        fromX: 0
                        toX: 265
                        easingCurve: StockCurve.QuinticInOut
                        duration: 1500
                        delay: 5000
                        
                        onEnded: {
                            root.delegateActive = false;
                        }
                    }
                }
            ]
            
            onCreationCompleted: {
                animator.play();
            }
            
            Container
            {
                leftPadding: 5; rightPadding: 5; topPadding: 5; bottomPadding: 5
                background: bg.imagePaint
                maxWidth: 250
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Fill
                layout: DockLayout {}

                Label {
                    text: benefitText
                    multiline: true
                    horizontalAlignment: HorizontalAlignment.Right
                    textStyle.textAlign: TextAlign.Center
                    textStyle.fontSize: FontSize.XXSmall
                }

                attachedObjects: [
                    ImagePaintDefinition {
                        id: bg
                        imageSource: "images/graphics/title_bg.png"
                    }
                ]
            }
        }
    }
}