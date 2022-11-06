import prologue
import prologue/middlewares/staticfile


proc ifc_js*(ctx: Context) {.async.} =
  await ctx.static_file_response("templates/nim_ifcjs.html", "")


proc wasm_static*(ctx: Context) {.async.} =
  echo "wasm fetched"
  await ctx.staticFileResponse("/static/wasm/ifcjs/web-ifc.wasm", ".", mimetype="application/wasm", charset="")


let settings = newSettings(
  debug = true,
  port  = Port(8888),
  app_name = "nim_ifcjs",
)

var app = new_app(settings)
app.add_route("/", ifc_js)
app.add_route("/static/wasm/ifcjs/web-ifc.wasm", wasm_static)

app.use(static_file_middleware(@["static/js", "static/ifc"]))
app.get("/favicon.ico", redirect_to("static/img/favicon.png"))

app.run()
