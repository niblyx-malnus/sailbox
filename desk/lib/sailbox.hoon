/+  server
|%
++  numb :: adapted from numb:enjs:format
  |=  a=@u
  ^-  tape
  ?:  =(0 a)  "0"
  %-  flop
  |-  ^-  tape
  ?:(=(0 a) ~ [(add '0' (mod a 10)) $(a (div a 10))])
::
++  render-tang-to-wall
  |=  [wid=@u tan=tang]
  ^-  wall
  (zing (turn tan |=(a=tank (wash 0^wid a))))
::
++  render-tang-to-marl
  |=  [wid=@u tan=tang]
  ^-  marl
  =/  raw=(list tape)  (zing (turn tan |=(a=tank (wash 0^wid a))))
  ::
  |-  ^-  marl
  ?~  raw  ~
  [;/(i.raw) ;br; $(raw t.raw)]
::
++  two-oh-four
  ^-  simple-payload:http
  [[204 ['content-type' 'application/json']~] ~]
::
++  internal-server-error
  |=  [authorized=? msg=tape t=tang]
  ^-  simple-payload:http
  =;  =manx
    :_  `(manx-to-octs:server manx)
    [500 ['content-type' 'text/html']~]
  ;html
    ;head
      ;title:"500 Internal Server Error"
    ==
    ;body
      ;h1:"Internal Server Error"
      ;p: {msg}
      ;*  ?:  authorized
            ;=
              ;code:"*{(render-tang-to-marl 80 t)}"
            ==
          ~
    ==
  ==
::
++  method-not-allowed
  |=  method=@t
  ^-  simple-payload:http
  =;  =manx
    :_  `(manx-to-octs:server manx)
    [405 ['content-type' 'text/html']~]
  ;html
    ;head
      ;title:"405 Method Not Allowed"
    ==
    ;body
      ;h1:"Method Not Allowed: {(trip method)}"
    ==
  ==
::
++  is-sse-request
  |=  req=inbound-request:eyre
  ^-  ?
  ?&  ?=(%'GET' method.request.req)
      .=  [~ 'text/event-stream']
      (get-header:http 'accept' header-list.request.req)
  ==
::
+$  sse-event
  $:  id=(unit @t)
      event=(unit @t)
      data=wain
  ==
::
+$  sse-connections  (map @ta [lin=request-line:server until=@da])
::
++  sse-events
  =|  comments=wain
  =|  retry=(unit @ud)
  |=  events=(list sse-event)
  ^-  octs
  =|  response=wain
  =?  response  ?=(^ retry)
    (snoc response (cat 3 'retry: ' (crip (numb u.retry))))
  =.  response
    |-
    ?~  events
      (snoc response '')
    =?  response  ?=(^ id.i.events)
      (snoc response (cat 3 'id: ' u.id.i.events))
    =?  response  ?=(^ event.i.events)
      (snoc response (cat 3 'event: ' u.event.i.events))
    =.  response
      %+  weld  response
      %+  turn  data.i.events
      |=(=@t (cat 3 'data: ' t))
    $(events t.events)
  =.  response
    |-
    ?~  comments
      (snoc response '')
    =.  response  (snoc response (cat 3 ': ' i.comments))
    $(comments t.comments)
  (as-octs:mimes:html (of-wain:format response))
::
++  sse-last-id
  |=  req=inbound-request:eyre
  ^-  (unit @t)
  (get-header:http 'last-event-id' header-list.request.req)
::
++  sse-header
  ^-  response-header:http
  :-  200
  :~  ['content-type' 'text/event-stream']
      ['cache-control' 'no-cache']
      ['connection' 'keep-alive']
  ==
::
++  give-sse-manx
  |=  [eyre-id=@ta id=(unit @t) event=(unit @t) =manx]
  ^-  card:agent:gall
  =/  =sse-event  [id event [(crip (en-xml:html manx))]~]
  =/  data=octs  (sse-events ~[sse-event])
  (give-response-data eyre-id `data)
::
++  give-sse-json
  |=  [eyre-id=@ta id=(unit @t) event=(unit @t) =json]
  ^-  card:agent:gall
  =/  =sse-event  [id event [(en:json:html json)]~]
  =/  data=octs  (sse-events ~[sse-event])
  (give-response-data eyre-id `data)
::
++  give-sse-header
  |=  eyre-id=@ta
  ^-  card:agent:gall
  (give-response-header eyre-id sse-header)
::
++  give-response-header
  |=  [eyre-id=@ta =response-header:http]
  ^-  card:agent:gall
  :^  %give  %fact  ~[/http-response/[eyre-id]]
  http-response-header+!>(response-header)
::
++  give-response-data
  |=  [eyre-id=@ta data=(unit octs)]
  ^-  card:agent:gall
  [%give %fact ~[/http-response/[eyre-id]] http-response-data+!>(data)]
::
++  give-manx-response
  |=  [eyre-id=@ta =manx]
  ^-  (list card:agent:gall)
  %+  give-simple-payload:app:server
    eyre-id
  (manx-response:gen:server manx)
::
++  mime-response
  |=  =mime
  ^-  simple-payload:http
  :_  `q.mime
  :-  200
  :~  ['cache-control' 'no-cache']
      ['content-type' (rsh [3 1] (spat p.mime))]
  ==
::
++  give-mime-response
  |=  [eyre-id=@ta =mime]
  ^-  (list card:agent:gall)
  %+  give-simple-payload:app:server
    eyre-id
  (mime-response mime)
--
