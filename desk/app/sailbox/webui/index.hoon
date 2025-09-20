/-  *sailbox
/+  rudder, sigil, lab=sail-lab
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
    body { font-family: monospace; padding: 20px; }
    .green { color: #229922; }
    .bold { font-weight: bold; }
    '''
  ++  page
    ^-  manx
    ;html
      ;head
        ;title:"%sailbox"
        ;meta(charset "utf-8");
        ;meta(name "viewport", content "width=device-width, initial-scale=1");
        ;style:"{(trip style)}"
      ==
      ;body
        ;+  %+  stack:lab
            :~  ;h1: Sailbox - Enhanced with Components
                (alert:lab %success "Sail is rendering HTML!")

                ;div
                  ;h2: Add a ship:
                  ;+  (input-with-button:lab "ship" "~sampel" "Add" "add-ship")
                ==

                ;div
                  ;h2: Ships in collection ({<(lent ships)>}) - Drag to reorder (v4):
                  ;+  (ship-list-sortable:lab ships 8)
                ==

                ;div
                  ;h2: Testing Sail interpolation:
                  ;p: Current time: {<now.bowl>}
                  ;p: Our ship: {<our.bowl>}
                ==

                (card:lab "Test Card" "This is a simple card component that works!")
            ==
          24
      ==
    ==
  --
--