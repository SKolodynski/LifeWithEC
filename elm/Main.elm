import String
import WebSocket

main = dispGrid <~ helper (constant "start")

disp:String -> Element
disp s = flow right (map dispChar (String.toList s))

-- connect : String -> Signal String -> Signal String
helper = WebSocket.connect "ws://localhost:17400"

dispChar:Char->Element
dispChar c = (if c=='1' then color black else color white) (spacer 30 30)

dispStr:String->Element
dispStr s = flow right (map dispChar (String.toList s))

dispGrid:String->Element
dispGrid s = flow down (map dispStr (String.split "," s))

