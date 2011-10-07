package
{
    import be.boulevart.google.ajaxapi.search.images.data.GoogleImage;
    
    import flash.display.Bitmap;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.StyleSheet;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;

    public class Photo extends Sprite
    {
        private var _id             :int;
        private var _bitmap         :DisplayObject;
        private var _googleImg      :GoogleImage;
        private var _thumbHeight    :int;
        private var _infoStr        :String;
        private var _info_txt       :TextField;
        
        public function Photo( bitmap:DisplayObject, googleImg:GoogleImage)
        {
            _bitmap = bitmap;

            var css:StyleSheet = new StyleSheet();
            var linkStyle:Object = { 
                color:"#0000FF"
            };
            css.setStyle("a", linkStyle);
            
            _googleImg = googleImg;
            _thumbHeight = int( googleImg.thumbHeight );
            
            _infoStr    = "<b>Title: </b>" + _googleImg.title + "\n"
                        //+ "\nTitleNoFormatting: " + _googleImg.titleNoFormatting + "\n"
                        + "<b>Photo Size: </b>" + _googleImg.width + "X" + _googleImg.height + "\n"
                        + "<b>Thumb size: </b>" + _googleImg.thumbWidth + "X" + _googleImg.thumbHeight + "\n"
                        + generateLink( "UnescapedUrl", _googleImg.unescapedUrl )   // this one is better than following url
                        + generateLink( "Url", _googleImg.url )
                        + generateLink( "VisibleUrl", _googleImg.visibleUrl )
                        + generateLink( "OriginalContextUrl", _googleImg.originalContextUrl )
                        + generateLink( "ThumbUrl", _googleImg.thumbUrl )
                        + "<b>Content: </b>" + _googleImg.content + "\n"
                        + "<b>ContentNoFormatting: </b>" + _googleImg.contentNoFormatting + "\n";   //this one is better than previous content

            _info_txt = new TextField();
            _info_txt.visible = false;
            _info_txt.defaultTextFormat = new TextFormat("Arial", "12", 0x000000, false);
            _info_txt.autoSize = TextFieldAutoSize.LEFT;
            _info_txt.border = true;
            _info_txt.styleSheet = css;
            _info_txt.opaqueBackground = 0xffffff;
            _info_txt.useRichTextClipboard = true;
            _info_txt.htmlText = _infoStr;
            
            _info_txt.addEventListener( MouseEvent.ROLL_OUT, onRollOut_info_txt, false, 0, true);
            
            this.addEventListener( Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true );	//removed in onAddedToStage()
            
        }

        private function generateLink( title:String, urlStr:String ):String
        {
            return "<b>" + title + ": " + "</b>" + "<u><a href='" + urlStr + "' >" + urlStr + "</a></u>" + "\n";
        }
        
        private function onRollOut_info_txt( evt:MouseEvent ):void
        {
            _info_txt.visible = false;
        }
        
        private function onClick( event:MouseEvent ):void
        {
            _info_txt.visible = true;
            this.parent.addChild( _info_txt );
            event.stopImmediatePropagation();
        }
        
        private function onStratDragging( event:MouseEvent ):void
        {
            this.startDrag();
            event.stopImmediatePropagation();
        }

        private function onStopDragging( event:MouseEvent ):void
        {
            this.stopDrag();
            event.stopImmediatePropagation();
        }

        private function onAddedToStage( event:Event ):void
        {
            this.removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );	
            
            _info_txt.y = this.y;
            _info_txt.x = this.x;
            
            this.addChild(_bitmap);
            
            this.buttonMode		= true;
            this.useHandCursor	= true;
            
            this.addEventListener( MouseEvent.MOUSE_DOWN, onStratDragging, false, 0, true );				
            this.addEventListener( MouseEvent.MOUSE_UP, onStopDragging, false, 0, true );
            this.addEventListener( MouseEvent.CLICK, onClick, false, 0, true );
        }
        
        
        override public function toString():String
        {
            return _infoStr;
        }
        
        public function get id():int
        {
            return _id;
        }
        
        public function get bitmap():DisplayObject
        {
            return _bitmap;
        }
        
        public function get googleImg():GoogleImage
        {
            return _googleImg;
        }
        
        public function get thumbHeight():int
        {
            return _thumbHeight;
        }
    }
}