/-  *sailbox
/+  rudder, dbug, verb, default-agent
/~  pages  (page:rudder data command)  /app/sailbox/webui
|%
:: $data: ships=(list ship)
+$  state-0  [%0 data]
+$  eyre-id  @ta
+$  card  card:agent:gall
--
=|  state-0
=*  state  -
%-  agent:dbug
%+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  :_  this
  [%pass /eyre/connect %arvo %e %connect [~ /[dap.bowl]] dap.bowl]~
::
++  on-save  !>(state)
::
++  on-load
  |=  ole=vase
  ^-  (quip card _this)
  =/  old=state-0  !<(state-0 ole)
  ~&  ~(key by pages)
  [~ this(state old)]
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+  mark  (on-poke:def mark vase)
      %sailbox-command
    =/  command  !<(command vase)
    ?-    -.command
        %do-a-thing
      ~&  "Do a thing..."
      `this
        %do-another
      ~&  "Do another..."
      `this
        %add-ship
      ~&  "Adding ship..."
      `this(ships [ship.command ships])
    ==
    ::
      %handle-http-request
    =;  out=(quip card _+.state)
      [-.out this(+.state +.out)]
    %.  [bowl !<(order:rudder vase) +.state]
    %:  (steer:rudder _+.state command)
      pages
      (point:rudder /[dap.bowl] & ~(key by pages))
      (fours:rudder +.state)
      |=  cmd=command
      ^-  $@  brief:rudder
          [brief:rudder (list card) _+.state]
      =^  caz  this
        (on-poke %sailbox-command !>(cmd))
      ['Processed succesfully.' caz +.state]
    ==
  ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?>  =(our.bowl src.bowl)
  ?+  path  (on-watch:def path)
    [%http-response *]  [~ this]
  ==
::
++  on-agent  on-agent:def
++  on-peek   on-peek:def
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?+  sign-arvo  (on-arvo:def wire sign-arvo)
      [%eyre %bound *]
    ~?  !accepted.sign-arvo
      [dap.bowl 'eyre bind rejected!' binding.sign-arvo]
    [~ this]
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
