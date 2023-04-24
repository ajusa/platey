import platey/plates

# TODO: Sidebar menu, preserving selected sidebar option through errors, etc
include std/prelude
import jsony, mummy, mummy/routers, std/[locks, threadpool, osproc], bossy
import libfswatch, libfswatch/fswatch

type PlateMsg = object
  name: string

proc runCommand*(file: string): string =
  &"nim --hints:off --warnings:off r {file}"

proc handleOutput*(output: string, code: int, selected: string): string =
  if code != 0:
    return &"""<div id="content"><pre>{output}</pre></div>"""
  try:
    let plates = output.extractPlates()
    let filtered = plates.filterIt(it.name == selected)
    let selectedPlate = if filtered.len > 0: filtered[0] else: plates[0]
    var links = ""
    for plate in plates:
      let msg = PlateMsg(name: plate.name).toJson()
      links &= &"""<button ws-send="" hx-vals='{msg}'>{plate.name}</button> """
    return &"""
    <div id="plates">{links}</div>
    <div id="content">{selectedPlate.body}</div>
    """
  except:
    return &"""<div id="content">Unable to parse output of plate: {output}</div>"""

const index = """
<html>
  <head>
    <script src="https://unpkg.com/htmx.org@1.8.5"></script>
    <script src="https://unpkg.com/htmx.org/dist/ext/ws.js"></script>
    <style>
      #reset-this-root * {
          all: unset;
      }
    </style>
  </head>
  <body>
    <div hx-ext="ws" ws-connect="/ws">
      <div id="reset-this-root">
        <div id="plates"></div>
      </div>
      <div id="content"></div>
    </div>
  </body>
</html>
"""

template hold(lock: Lock, body: untyped) = {.gcsafe.}: withLock lock: body
proc makeLock(): Lock = initLock(result)

var (target, targetLock) = ("examples/example.nim", makeLock())
var (clients, clientsLock) = (initTable[WebSocket, string](), makeLock())

proc updateClients() =
  var file: string
  hold(targetLock):
    file = target
  let (output, code) = file.runCommand.execCmdEx()
  hold(clientsLock):
    for client, selected in clients:
      let response = handleOutput(output, code, selected)
      client.send(response)

proc monitor() {.gcsafe.} =
  proc changed(event: fsw_cevent, event_num: cuint) =
    if event.flags[] == Updated: updateClients()
  var mon = newMonitor()
  var file: string
  hold(targetLock):
    file = target
  mon.addPath(file)
  mon.setCallback(changed)
  mon.start()

proc indexHandler(request: Request) =
  var headers: HttpHeaders
  headers["Content-Type"] = "text/html"
  request.respond(200, headers, index)

proc upgradeHandler(request: Request) =
  discard request.upgradeToWebSocket()

proc websocketHandler(
  ws: WebSocket,
  event: WebSocketEvent,
  message: Message
) =
  case event:
  of OpenEvent:
    hold(clientsLock): clients[ws] = ""
    updateClients()
  of MessageEvent:
    if message.kind == TextMessage:
      let plateMsg = message.data.fromJson(PlateMsg)
      ws.send("<div id='content'>Loading...</div>")
      hold(clientsLock):
        clients[ws] = plateMsg.name
      updateClients()
  of ErrorEvent:
    discard
  of CloseEvent:
    hold(clientsLock): clients.del(ws)

when isMainModule:
  let args = getCommandLineArgs()
  hold(targetLock):
    target = args.toBase.filterIt(it[1] == "")[0][0]
  var router: Router
  router.get("/", indexHandler)
  router.get("/ws", upgradeHandler)

  let server = newServer(router, websocketHandler)
  echo "Serving on http://localhost:8080"
  spawn monitor()
  server.serve(Port(8080))
