import asyncjs
import dom
import jsffi
import jsconsole
import std/jsfetch


var web_ifc {.importjs: "window.WebIFC".}: JsObject


proc new_ifc_api(): JsObject {.importjs: "new window.WebIFC.IfcAPI()", nodecl.}


proc new_text_decoder(): JsObject {.importjs: "new TextDecoder()", nodecl, used.}


proc new_uint8array(buffer: JsObject): JsObject {.importjs: "new Uint8Array(#)", nodecl.}


proc init_ifc_api(ifc_api: JsObject) {.importjs: "#.Init()", async, discardable.}


proc array_buffer(ifc_api: Response): Future[JsObject] {.importjs: "#.arrayBuffer()", async.}


proc expose_api(ifc_api: JsObject) {.importjs: "window.ifcapi = #", async, discardable.}


proc get_ifc_line(ifc_api: JsObject, model_id, item_id: cint): JsObject {.importjs: "#.GetLine(#, #)", async.}


proc get_ifc_class(ifc_api: JsObject): JsObject {.importjs: "#.__proto__.constructor.name", async.}


proc main*() {.async discardable.} =
  console.log("main nim proc started")
  console.log("web_ifc: ", web_ifc)
  var ifc_api = new_ifc_api()
  ifc_api.SetWasmPath("http://127.0.0.1:8888/static/wasm/ifcjs/".cstring, true)
  console.log("ifc_api: ", ifc_api)

  expose_api(ifc_api)

  await ifc_api.init_ifc_api()
  console.log("ifc_api: ", ifc_api)

  var
    res = await fetch("http://127.0.0.1:8888/static/ifc/01.ifc".cstring)
    arr_buffer = await res.array_buffer()
    uint8_arr = new_uint8array(arr_buffer)
    # text_decoder = new_text_decoder()
    # ifc_text = text_decoder.decode(arr_buffer)

  let
    model_id = ifcapi.OpenModel(uint8_arr)
    all_lines = ifcapi.GetAllLines(model_id)
    lines_count = all_lines.size().to(int) - 1

  console.log("res: ", res)
  # console.log("ifc_text: ", ifc_text)
  console.log("model_id: ", model_id)
  console.log("ifc lines found: ", lines_count)

  for i in 0 .. lines_count:
    let
      item_id = all_lines.get(i)
      elem = get_ifc_line(ifcapi, model_id.to(cint), item_id.to(cint))
      ifc_class = elem.get_ifc_class()
    # console.log(i, item_id, ifc_class)

    if ifc_class.to(cstring) == "IfcSpace".cstring:
      let
        ifc_guid = elem.GlobalId.value
        elem_name = elem.Name.value
        li = dom.document.createElement("li")
        sep = " - ".cstring

      console.log(ifc_guid, elem_name)

      li.textContent = ifc_guid.to(cstring) & sep & ifc_class.to(cstring) & sep & elem_name.to(cstring)
      dom.document.getElementById("element_list").appendChild(li)

main()
