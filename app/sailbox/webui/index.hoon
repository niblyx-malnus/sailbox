/-  *sailbox
/+  rudder
^-  (page:rudder data command)
|_  [=bowl:gall * data]
++  argue
  |=  [headers=header-list:http body=(unit octs)]
  ^-  $@(brief:rudder command)
  =/  args=(map @t @t)  ?~(body ~ (frisk:rudder q.u.body))
  ?~  action=(~(get by args) 'action')  ~
  ?>  =(u.action %add-ship)
  ?~  ship=(slaw %p (~(gut by args) 'ship' ''))  ~
  [%add-ship u.ship]
::
++  final  (alert:rudder (cat 3 '/' dap.bowl) build)
::
++  build
  |=  $:  arg=(list [k=@t v=@t])
          msg=(unit [o=? =@t])
      ==
  ^-  reply:rudder
  |^  [%page page]
  ++  style
    '''
    .green { color: #229922; }
    .bold { font-weight: bold; }
    '''
  ++  page
    ^-  manx
    ;hmtl
      ;head
        ;title:"%sailbox"
        ;meta(charset "utf-8");
        ;meta(name "viewport", content "width=device-width, initial-scale=1");
        ;style:"{(trip style)}"
      ==
      ;body
        ;h1: Hello, Mars!
        ;p.green.bold: Welcome to the sailbox.
        ;p: Add some ships.
        ;p: If you want to delete them, you will have to implement it yourself.
        ;table
          ;form(method "post")
            ;tr(style "font-weight: bold")
              ;td:""
              ;td:"@p"
            ==
            ;tr
              ;td
                ;button(type "submit", name "action", value "add-ship"):"+"
              ==
              ;td
                ;input(type "text", name "ship", placeholder "~sampel");
              ==
            ==
          ==
        ==
        ;table
          ;*  %+  turn  ships
              |=  =ship
              ;tr
                ;td: {(scow %p ship)}
              ==
        ==
      ==
    ==
  --
--
