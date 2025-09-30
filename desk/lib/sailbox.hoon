/+  server, multipart, html-utils
|%
++  numb :: adapted from numb:enjs:format
  |=  a=@u
  ^-  tape
  ?:  =(0 a)  "0"
  %-  flop
  |-  ^-  tape
  ?:(=(0 a) ~ [(add '0' (mod a 10)) $(a (div a 10))])
::
+$  sse-connection
  $:  started=@da
      site=(list @ta)
      args=(list [key=@t value=@t])
  ==
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
+$  sse-key  [id=(unit @t) event=(unit @t)]
::
+$  sse-event
  $:  id=(unit @t)
      event=(unit @t)
      data=wain
  ==
::
+$  sse-manx
  $:  id=(unit @t)
      event=(unit @t)
      =manx
  ==
::
+$  sse-json
  $:  id=(unit @t)
      event=(unit @t)
      =json
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
      ?~  data.i.events
        ~['data: ']
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
++  sse-keep-alive  `octs`(as-octs:mimes:html ':\0a\0a')
::
++  give-sse-event
  |=  [eyre-id=@ta =sse-event]
  ^-  card:agent:gall
  =/  data=octs  (sse-events ~[sse-event])
  (give-response-data eyre-id `data)
::
++  manx-to-wain
  |=  =manx
  ^-  wain
  [(crip (en-xml:html manx))]~
::
++  give-sse-manx
  |=  [eyre-id=@ta id=(unit @t) event=(unit @t) =manx]
  ^-  card:agent:gall
  =/  =sse-event  [id event (manx-to-wain manx)]
  (give-sse-event eyre-id sse-event)
::
++  json-to-wain
  |=  =json
  ^-  wain
  [(en:json:html json)]~
::
++  give-sse-json
  |=  [eyre-id=@ta id=(unit @t) event=(unit @t) =json]
  ^-  card:agent:gall
  =/  =sse-event  [id event (json-to-wain json)]
  (give-sse-event eyre-id sse-event)
::
++  give-sse-header
  |=  eyre-id=@ta
  ^-  card:agent:gall
  (give-response-header eyre-id sse-header)
::
++  give-sse-keep-alive
  |=  eyre-id=@ta
  ^-  card:agent:gall
  (give-response-data eyre-id `sse-keep-alive)
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
:: HTTP/SSE agent transformer library
::
::    Wraps a Gall agent to handle HTTP requests and SSE connections.
::    Similar to shoe for CLI apps, but for web apps.
::
++  keep-alive  ~s30
++  sse-timeout  ~m2
+$  parts  (list [@t part:multipart])
+$  state-0  [%0 connections=(map @ta sse-connection)]
::  $card: standard gall cards plus SSE effects
::
+$  card
  $%  card:agent:gall
      [%sse site=(list @t) id=(unit @t) event=(unit @t)]
  ==
::  +sailbox: gall agent core with extra arms for HTTP/SSE
::
++  sailbox
  $_  ^|
  |_  bowl:gall
  ::  +do-get: handle GET requests
  ::
  ++  do-get
    |~  $:  [ext=(unit @ta) site=(list @t)]
            args=(list [key=@t value=@t])
        ==
    *mime
  ::  +do-post: handle POST requests
  ::
  ++  do-post
    |~  [site=path args=(list [key=@t value=@t])]
    *(quip card _^|(..on-init))
  ::  +do-upload: handle multipart uploads
  ::
  ++  do-upload
    |~  [site=path parts=(list [@t part:multipart])]
    *(quip card _^|(..on-init))
  ::  +make-sse-event: generate SSE event content for a site/event
  ::
  ++  make-sse-event
    |~  $:  site=(list @t)
            args=(list [key=@t value=@t])
            id=(unit @t)
            event=(unit @t)
        ==
    *wain
  ::  +first-sse-event: initial event when SSE connection opens
  ::
  ++  first-sse-event
    |~  $:  site=(list @t)
            args=(list [key=@t value=@t])
            last-event-id=(unit @t)
        ==
    *(unit sse-key)
  ::  standard gall agent arms
  ::
  ++  on-init
    *(quip card _^|(..on-init))
  ::
  ++  on-save
    *vase
  ::
  ++  on-load
    |~  vase
    *(quip card _^|(..on-init))
  ::
  ++  on-poke
    |~  [mark vase]
    *(quip card _^|(..on-init))
  ::
  ++  on-watch
    |~  path
    *(quip card _^|(..on-init))
  ::
  ++  on-leave
    |~  path
    *(quip card _^|(..on-init))
  ::
  ++  on-peek
    |~  path
    *(unit (unit cage))
  ::
  ++  on-agent
    |~  [wire sign:agent:gall]
    *(quip card _^|(..on-init))
  ::
  ++  on-arvo
    |~  [wire sign-arvo]
    *(quip card _^|(..on-init))
  ::
  ++  on-fail
    |~  [term tang]
    *(quip card _^|(..on-init))
  --
::  +agent: creates wrapper core that handles HTTP/SSE and calls sailbox arms
::
++  agent
  |=  app=sailbox
  =|  state-0
  =*  state  -
  ^-  agent:gall
  =>
    |%
    ++  kv  kv:html-utils
    ++  deal
      |=  $:  cards=(list card)
              $=  make-sse-event
              $-  $:  site=(list @t)
                      args=(list [key=@t value=@t])
                      id=(unit @t)
                      event=(unit @t)
                  ==
              wain
          ==
      ^-  (list card:agent:gall)
      %-  zing
      %+  turn  cards
      |=  =card
      ^-  (list card:agent:gall)
      ?.  ?=(%sse -.card)
        ~[card]
      %+  murn  ~(tap by connections)
      |=  [eyre-id=@ta con=sse-connection]
      ^-  (unit card:agent:gall)
      ?.  =(site.con site.card)
        ~
      :-  ~
      %+  give-sse-event 
        eyre-id
      :+  id.card  event.card
      (make-sse-event site.con args.con id.card event.card)
    --
  ::
  |_  =bowl:gall
  +*  this  .
      og    ~(. app bowl)
  ::
  ++  on-init
    ^-  (quip card:agent:gall agent:gall)
    =^  cards  app  on-init:og
    :_  this
    :_  (deal cards make-sse-event:og)
    [%pass /eyre/connect %arvo %e %connect [~ /[dap.bowl]] dap.bowl]
  ::
  ++  on-save  on-save:og :: TODO: consider preserving connections state
  :: TODO: consider preserving connections state
  ::
  ++  on-load
    |=  old-state=vase
    ^-  (quip card:agent:gall agent:gall)
    =^  cards  app  (on-load:og old-state)
    [(deal cards make-sse-event:og) this]
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card:agent:gall agent:gall)
    ?.  ?=(%handle-http-request mark)
      =^  cards  app  (on-poke:og mark vase)
      [(deal cards make-sse-event:og) this]
    =+  !<([eyre-id=@ta req=inbound-request:eyre] vase)
    =/  lin=request-line:server  (parse-request-line:server url.request.req)
    ~&  >>  accept+(get-header:http 'accept' header-list.request.req)
    ~&  >>  connection+(get-header:http 'connection' header-list.request.req)
    ~&  >>  last-event-id+(get-header:http 'last-event-id' header-list.request.req)
    ~&  >  "received {(trip method.request.req)} request for {<site.lin>}!"
    ::
    ?:  (is-sse-request req)
      =/  last-event-id=(unit @t)
        (get-header:http 'last-event-id' header-list.request.req)
      =/  first=(unit sse-key)
        (first-sse-event:og site.lin args.lin last-event-id)
      =/  cards=(list card:agent:gall)
        %+  welp
          ~[(give-sse-header eyre-id)]
        ?~  first
          ~
        :_  ~
        %+  give-sse-event
          eyre-id
        :+  id.u.first  event.u.first
        (make-sse-event:og site.lin args.lin u.first)
      :-  cards
      %=    this
          connections
        %+  ~(put by connections)
          eyre-id
        [now.bowl site.lin args.lin]
      ==
    ?+    method.request.req
      :_  this
      %+  give-simple-payload:app:server
        eyre-id
      (method-not-allowed method.request.req)
      ::
        %'GET'
      :_  this
      (give-mime-response eyre-id (do-get:og lin))
      ::
        %'POST'
      =/  parts=(unit (list [@t part:multipart]))
        (de-request:multipart [header-list body]:request.req)
      ?^  parts
        =/  paz=(map @t part:multipart)
          (~(gas by *(map @t part:multipart)) u.parts)
        =/  get=(unit part:multipart)  (~(get by paz) 'get')
        =.  u.parts  ~(tap by (~(del by paz) 'get'))
        =^  cards  app
          (do-upload:og site.lin u.parts)
        :_  this
        %+  welp
          (deal cards make-sse-event:og)
        ?^  get
          %+  give-mime-response  eyre-id
          (do-get:og (parse-request-line:server body.u.get))
        %+  give-simple-payload:app:server
          eyre-id
        two-oh-four
      =/  args=key-value-list:kv  (parse-body:kv body.request.req)
      =/  get=(unit @t)  (get-key:kv 'get' args)
      =/  action=(unit @t)  (get-key:kv 'action' args)
      =^  cards  app
        (do-post:og site.lin (delete-key:kv 'get' args))
      :_  this
      %+  welp
        (deal cards make-sse-event:og)
      ?^  get
        %+  give-mime-response  eyre-id
        (do-get:og (parse-request-line:server u.get))
      %+  give-simple-payload:app:server
        eyre-id
      two-oh-four
    ==
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card:agent:gall agent:gall)
    ?>  =(our.bowl src.bowl)
    ?+  path
      =^  cards  app  (on-watch:og path)
      [(deal cards make-sse-event:og) this]
        [%http-response *]
      [~ this]
    ==
  ::
  ++  on-leave
    |=  =path
    ^-  (quip card:agent:gall agent:gall)
    =^  cards  app  (on-leave:og path)
    [(deal cards make-sse-event:og) this]
  ::
  ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    (on-peek:og path)
  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card:agent:gall agent:gall)
    =^  cards  app  (on-agent:og wire sign)
    [(deal cards make-sse-event:og) this]
  ::
  ++  on-arvo
    |=  [=wire =sign-arvo]
    ^-  (quip card:agent:gall agent:gall)
    ?+  wire
      =^  cards  app  (on-arvo:og wire sign-arvo)
      [(deal cards make-sse-event:og) this]
        [%eyre %connect ~]
      ?+  sign-arvo
        =^  cards  app  (on-arvo:og wire sign-arvo)
        [(deal cards make-sse-event:og) this]
          [%eyre %bound *]
        ~?  !accepted.sign-arvo
          [dap.bowl 'eyre bind rejected!' binding.sign-arvo]
        [~ this]
      ==
      ::
        [%timer %sse ~]
      ?+  sign-arvo
        =^  cards  app  (on-arvo:og wire sign-arvo)
        [(deal cards make-sse-event:og) this]
          [%behn %wake *]
        =|  cards=(list card:agent:gall)
        =/  conn=(list [eyre-id=@ta con=sse-connection])
          ~(tap by connections)
        |-
        ?~  conn
          :_  this  :_  cards
          [%pass /timer/sse %arvo %b %wait (add now.bowl keep-alive)]
        =.  cards
          :_  cards
          ?:  (lth now.bowl (add started.con.i.conn sse-timeout))
            (give-sse-keep-alive eyre-id.i.conn)
          [%give %kick ~[/http-response/[eyre-id.i.conn]] ~]
        =?  connections  (gte now.bowl (add started.con.i.conn sse-timeout))
          (~(del by connections) eyre-id.i.conn)
        $(conn t.conn)
      ==
    ==
  ::
  ++  on-fail
    |=  [=term =tang]
    ^-  (quip card:agent:gall agent:gall)
    =^  cards  app  (on-fail:og term tang)
    [(deal cards make-sse-event:og) this]
  --
--
