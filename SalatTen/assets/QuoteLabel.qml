import bb.cascades 1.0
import com.canadainc.data 1.0

TextArea
{
    id: quoteLabel
    backgroundVisible: false
    editable: false
    textStyle.fontSize: FontSize.XXSmall
    textStyle.textAlign: TextAlign.Center
    horizontalAlignment: HorizontalAlignment.Center
    topMargin: 0; bottomMargin: 0
    
    animations: [
        FadeTransition {
            id: ft
            fromOpacity: 0
            toOpacity: 1
            easingCurve: StockCurve.CubicOut
            duration: 2000
        }
    ]
    
    function onDataLoaded(id, data)
    {
        console.log("*** D", data.length);
        if (id == QueryId.GetRandomBenefit && data.length > 0)
        {
            var quote = data[0];
            console.log("*** D1", quote);
            
            if (text.length == 0) {
                ft.play();
            }
            deviceUtils.log(quote);
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