import String
import WebSocket as Ws

main = dispGrid <~ helper (constant "start")

-- connect : String -> Signal String -> Signal String
helper = Ws.connect "ws://localhost:17400"

dispGrid:String->Element
dispGrid s = flow down (map dispStr (String.split "," s))

dispStr:String->Element
dispStr s = flow right (map dispChar (String.toList s))

dispChar:Char->Element
dispChar c = (if c=='1' then color black else color white) (spacer 30 30)



