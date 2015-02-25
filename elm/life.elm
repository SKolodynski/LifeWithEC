import String
import Signal
import WebSocket as Ws
import Graphics.Element (..)
import List
import Color (..)

-- main = dispGrid <~ helper (constant "start")
main = Signal.map dispGrid (helper (Signal.constant "start"))

-- connect : String -> Signal String -> Signal String
helper = Ws.connect "ws://localhost:17400"

dispGrid:String->Element
dispGrid s = flow down (List.map dispStr (String.split "," s))

dispStr:String->Element
dispStr s = flow right (List.map dispChar (String.toList s))

dispChar:Char->Element
dispChar c = (if c=='1' then color black else color white) (spacer 30 30)



