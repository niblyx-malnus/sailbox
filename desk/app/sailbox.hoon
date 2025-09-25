/-  *sailbox
/+  dbug, verb, default-agent, server, multipart, sailbox,
    html-utils, sigil, examples, lab=sail-lab, feather
::
|%
:: $data: ships=(list ship)
+$  state-0  [%0 data]
+$  eyre-id  @ta
+$  card  card:agent:gall
++  kv  kv:html-utils
--
::
=|  state-0
=*  state  -
::
=<
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
    hc    ~(. +> bowl)
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
    =+  !<([eyre-id=@ta req=inbound-request:eyre] vase)
    =/  lin=request-line:server  (parse-request-line:server url.request.req)
    ~&  >>  accept+(get-header:http 'accept' header-list.request.req)
    ~&  >>  connection+(get-header:http 'connection' header-list.request.req)
    ~&  >>  last-event-id+(get-header:http 'last-event-id' header-list.request.req)
    ~&  >  "received {(trip method.request.req)} request for {<site.lin>}!"
    ?:  (is-sse-request:sailbox req)
      ~&  >>>  %is-sse
      !! :: +do-sse
    ?+    method.request.req
      :_  this
      %+  give-simple-payload:app:server
        eyre-id
      (method-not-allowed:sailbox method.request.req)
      ::
        %'GET'
      :_  this
      (give-mime-response:sailbox eyre-id (do-get:hc lin))
      ::
        %'POST'
      =/  parts=(unit (list [@t part:multipart]))
        (de-request:multipart [header-list body]:request.req)
      ?^  parts
        =/  paz=(map @t part:multipart)
          (~(gas by *(map @t part:multipart)) u.parts)
        =/  get=(unit part:multipart)  (~(get by paz) 'get')
        =.  u.parts  ~(tap by (~(del by paz) 'get'))
        =^  cards  state
          abet:(do-upload:hc site.lin u.parts)
        :_  this
        %+  welp  cards
        ?^  get
          %+  give-mime-response:sailbox  eyre-id
          (do-get:hc (parse-request-line:server body.u.get))
        %+  give-simple-payload:app:server
          eyre-id
        two-oh-four:sailbox
      =/  args=key-value-list:kv  (parse-body:kv body.request.req)
      =/  get=(unit @t)  (get-key:kv 'get' args)
      =^  cards  state
        abet:(do-post:hc site.lin (delete-key:kv 'get' args))
      :_  this
      %+  welp  cards
      ?^  get
        %+  give-mime-response:sailbox  eyre-id
        (do-get:hc (parse-request-line:server u.get))
      %+  give-simple-payload:app:server
        eyre-id
      two-oh-four:sailbox
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
::
=|  cards=(list card)
|_  =bowl:gall
+*  this  .
++  emit  |=(=card this(cards [card cards]))
++  emil  |=(cadz=(list card) this(cards (welp (flop cadz) cards)))
++  abet  [(flop cards) state]
::
++  do-get
  |=  request-line:server
  :: +$  request-line
  ::   $:  [ext=(unit @ta) site=(list @t)]
  ::       args=(list [key=@t value=@t])
  ::   ==
  ^-  mime
  ?+    site  !!
      [%sailbox ~]
    [/text/html (manx-to-octs:server page)]
      [%sailbox %gradient ~]
    [/text/html (manx-to-octs:server gradient-page)]
      [%sailbox %wallet ~]
    [/text/html (manx-to-octs:server wallet-page)]
      [%sailbox %ingredients ~]
    [/text/html (manx-to-octs:server ingredients-page)]
  ==
::
++  do-post
  |=  [site=path args=key-value-list:kv]
  ^+  this
  ?+    site  !!
      [%sailbox ~]
    =/  action=@t  (need (get-key:kv 'action' args))
    ?>  =(%add-ship action)
    =/  =ship  (slav %p (need (get-key:kv 'ship' args)))
    this(ships [ship ships])
  ==
::
++  do-upload
  |=  [site=path parts=(list [@t part:multipart])]
  ^+  this
  !!
::
++  style
  '''
  /* Force scrolling override */
  html, body {
    overflow: auto !important;
    height: auto !important;
    min-height: 100vh !important;
  }
  body {
    font-family: monospace;
    padding: 20px;
  }
  .green { color: #229922; }
  .bold { font-weight: bold; }
  .table-container table { border-collapse: collapse; width: 100%; margin: 10px 0; }
  .table-container th, .table-container td { border: 1px solid #ddd; padding: 8px; text-align: left; }
  .table-container th { background-color: #f2f2f2; font-weight: bold; }
  '''
::
++  page
  ^-  manx
  ;html
    ;head
      ;title:"%sailbox"
      ;meta(charset "utf-8");
      ;meta(name "viewport", content "width=device-width, initial-scale=1");
      ;script(src "https://unpkg.com/htmx.org@2.0.3");
      ;script(src "https://unpkg.com/htmx-ext-sse@2.2.2/sse.js");
      ;+  feather:feather
      ;style:"{(trip style)}"
      ;style
        ;         /* Icon Component Factory Styles */
        ;         .hover-transform:hover {
        ;           transform: scale(1.1) rotate(5deg);
        ;           transition: transform 0.2s ease;
        ;         }
        ;         .favorite-icon {
        ;           transition: all 0.3s ease;
        ;           filter: drop-shadow(0 2px 4px rgba(239, 68, 68, 0.3));
        ;         }
        ;         .favorite-icon:hover {
        ;           transform: scale(1.2);
        ;           filter: drop-shadow(0 4px 8px rgba(239, 68, 68, 0.5));
        ;         }
        ;         .success-indicator {
        ;           background: rgba(16, 185, 129, 0.1);
        ;           border-radius: 50%;
        ;           padding: 2px;
        ;         }
        ;         .rating-star {
        ;           transition: transform 0.2s ease;
        ;           cursor: pointer;
        ;         }
        ;         .rating-star:hover {
        ;           transform: scale(1.1) rotate(10deg);
        ;         }
        ;         .nav-arrow {
        ;           transition: transform 0.2s ease;
        ;         }
        ;         .nav-arrow:hover {
        ;           transform: translateX(4px);
        ;         }
        ;         /* Pattern #17 Animation Styles */
        ;         @keyframes shake {
        ;           0%  { transform: translate(0, 0) }
        ;           10% { transform: translate(-8px, 3px) }
        ;           30% { transform: translate(3px, -8px) }
        ;           50% { transform: translate(-3px, -3px) }
        ;           80% { transform: translate(5px, 8px) }
        ;         }
        ;         .winner {
        ;           animation: shake 0.5s infinite;
        ;           border: 2px solid gold;
        ;           padding: 2px 6px;
        ;           border-radius: 4px;
        ;           display: inline-block;
        ;         }
      ==
    ==
    ;body
      =hx-ext  "sse"
      =sse-connect  "/sailbox"
      =sse-close  "close"
      ;+  %-  scrollable-container:lab
          %+  stack:lab
            20
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

            ;div
              ;h2: Migrev Pattern #1 - Core Decomposition with |%
              ;+  %-  render-simple-table:examples
                  :-  ~["Name" "Ship" "Status"]
                  :~  ~["Alice" "~zod" "Online"]
                      ~["Bob" "~nec" "Offline"]
                      ~["Charlie" "~bud" "Online"]
                  ==
            ==

            ;div
              ;h2: Migrev Pattern #2 - Wide Form Bodies
              ;+  %-  render-with-wide-form:examples
                  :-  "Shopping List"
                  ~["Milk" "Bread" "Eggs" "Coffee"]
            ==

            ;div
              ;h2: Migrev Pattern #3 - Empty Nodes
              ;+  (render-conditional-content:examples %.y "✅ VISIBLE CONTENT" "Test A: Content Shown")
              ;+  (render-conditional-content:examples %.n "❌ This should not appear" "Test B: Content Hidden (;/(\"\") empty node)")
            ==

            ;div
              ;h2: Migrev Pattern #4 - Michep (;-) CSS & JS Injection
              ;+  (render-with-embedded-css:examples "Click Me!" "This uses the undocumented ;- rune")
            ==

            ;div
              ;h2: Migrev Pattern #5 - Pretty Printer Debugging
              ;+  %:  render-debug-info:examples
                  (malt ~[['key1' 'value1'] ['key2' 'value2'] ['ship' (crip (scow %p our.bowl))]])
                  %.y
                  now.bowl
              ==
            ==

            ;div
              ;h2: Migrev Pattern #6 - Direct manx Manipulation
              ;+  %:  render-manx-manipulation:examples
                  "Dynamic List with Highlighting"
                  ~["First item" "Second item" "Third item (highlighted)" "Fourth item"]
                  `2
              ==
            ==

            ;div
              ;h2: Migrev Pattern #7 - Conditional Attributes
              ;+  (render-conditional-attributes:examples "This is a normal message" %.n %.y %light)
              ;+  (render-conditional-attributes:examples "⚠️ URGENT: This is important!" %.y %.y %accent)
              ;+  (render-conditional-attributes:examples "Dark theme notification" %.n %.n %dark)
            ==

            ;div
              ;h2: Advanced Pattern #8 - SVG-in-Sail Raw Embedding
              ;+  %:  render-svg-embedding:examples
                  "Icon Library via de-xml:html"
                  ~[%arrow-right %check %star %heart %question]
              ==
            ==

            ;div
              ;h2: Advanced Pattern #9 - Icon Component Factory
              ;+  %:  render-icon-factory:examples
                  "Dynamic Icon Components with CSS Manipulation"
                  :~  [%loader "2rem" "#3b82f6" "animate-spin"]
                      [%settings "1.5rem" "#6b7280" "hover-transform"]
                      [%heart "3rem" "#ef4444" "favorite-icon"]
                      [%check "1rem" "#10b981" "success-indicator"]
                      [%star "2.5rem" "#f59e0b" "rating-star"]
                      [%arrow-right "1.25rem" "#8b5cf6" "nav-arrow"]
                  ==
              ==
            ==

            ;div
              ;h2: Advanced Pattern #10 - Manx Transformation Pattern
              ;+  %:  render-manx-transformation:examples
                  "Functional Operations on Manx Structures"
                  :~  ["Debug Info Transform" %debug "Debug Element"]
                      ["Interactive Transform" %interactive "Click Me!"]
                      ["Responsive Image Transform" %image "Demo Image"]
                      ["Base Element" %base "No Transform"]
                  ==
              ==
            ==

            ;div
              ;h2: Advanced Pattern #11 - Typed Door Pattern for Scoped Components
              ;+  %:  render-typed-door-pattern:examples
                  "Component Libraries with Shared Context"
                  :~  [%primary %md %solid %button "Primary Button"]
                      [%secondary %lg %outline %button "Secondary Button"]
                      [%success %sm %ghost %badge "Success Badge"]
                      [%danger %md %solid %card "Danger themed card content"]
                      [%primary %lg %outline %card "Primary themed card content"]
                      [%success %sm %solid %badge "Small Success"]
                  ==
              ==
            ==

            ;div
              ;h2: Advanced Pattern #12 - CSS Utility Class Generation
              ;+  %:  render-css-utility-pattern:examples
                  "Systematic Utility Class Composition"
                  ['row' '4' 'center' 'between']
                  ~[1 2 3 4]
                  ~["Item A" "Item B" "Item C" "Item D" "Item E"]
              ==
            ==

            ;div
              ;h2: Advanced Pattern #13 - Complex List Rendering
              ::  Force recompile for updated examples
              ;+  (render-complex-list-patterns:examples "Hierarchical Data and Conditional Tables")
            ==

            ;div
              ;h2: Advanced Pattern #14 - Form Generation Pattern
              ::  Force recompile for updated examples again
              ;+  (render-form-generation-pattern:examples "Complex Forms with Validation Display")
            ==

            ;div
              ;h2: Advanced Pattern #15 - Embedded Udon Pattern
              ;+  (render-embedded-udon-pattern:examples "Seamless Udon Integration with Sail")
            ==

            ;div
              ;h2: Advanced Pattern #16 - Data-Driven Grid System Pattern
              ;+  (render-data-driven-grid-pattern:examples "Algorithmic Grid Layout Systems")
            ==

            ;div
              ;h2: Advanced Pattern #17 - CSS-in-Tape Embedding Pattern
              ;+  (render-css-in-tape-pattern:examples "Inline CSS with Feather-Style Syntax")
            ==

            ;div
              ;h2: Advanced Pattern #18 - Conditional Marl Construction with Unit Types
              ;+  (render-conditional-marl-pattern:examples "Optional Content with Unit Types")
            ==

            ;div
              ;h2: Advanced Pattern #19 - Dynamic Status Indicator Pattern
              ;+  (render-dynamic-status-pattern:examples "Real-time Status Displays with Computed Values")
            ==

            ;div
              ;h2: Advanced Pattern #20 - SVG Sigil Generation Pattern
              ;+  (render-svg-sigil-pattern:examples "Generate Unique SVG Avatars from Ship Names")
            ==

            ;div
              ;h2: Advanced Pattern #21 - Meta Tag Generation Pattern
              ;+  (render-meta-tag-pattern:examples "Generate Comprehensive Social Media and SEO Meta Tags")
            ==

            ;div
              ;h2: Advanced Pattern #22 - Inline CSS Generation Pattern
              ;+  (render-inline-css-pattern:examples "Generate Inline CSS from Hoon Data Structures")
            ==

            ;div
              ;h2: Advanced Pattern #23 - Calendar Date Grid Generation
              ;+  (render-calendar-pattern:examples "Generate Complex Calendar Grids with Date-Specific Styling")
            ==

            ;div
              ;h2: Tlon Pattern #24 - Safe Text Node Pattern
              ;+  (render-safe-text-pattern:examples "Handle Atomic vs Complex Text Content with Proper Escaping")
            ==
          ==
    ==
  ==
::
++  gradient-styles
  '''
  html, body {
    margin: 0;
    padding: 0;
    overflow-x: hidden;
  }
  .gradient-container {
    height: 200vh;
    width: 100%;
    background: linear-gradient(to bottom,
      #9333ea 0%,    /* purple */
      #dc2626 33%,   /* red */
      #ea580c 66%,   /* orange */
      #eab308 100%   /* yellow */
    );
  }
  .content {
    position: absolute;
    top: 50px;
    left: 50px;
    color: white;
    font-family: monospace;
    font-size: 24px;
    text-shadow: 2px 2px 4px rgba(0,0,0,0.7);
  }
  '''
::
++  gradient-page
  ^-  manx
  %-  htmx-page:lab
  :+  "Sailbox Gradient"  &
  :-  `gradient-styles
  ;div(class "gradient-container")
    ;div(class "content")
      ;h1: Purple Red Orange Yellow Gradient
      ;p: Scroll down to see the full gradient!
      ;p: Height: 200vh (twice the viewport)
    ==
  ==
::
++  wallet-page
  ^-  manx
  =/  full-wallets-content=manx
    ;div.fc.g4
      ;div.p4.b1.br2
        ;div.s1.bold.mb2: 💼 Full BIP32 Wallets
        ;p.f2.s-1: Complete wallets with master keys and derivation paths
        ;p.f3.s-2: Generate from seed phrases, restore existing wallets, or create new ones
      ==
    ==
  =/  watch-only-content=manx
    ;div.fc.g4
      ;div.p4.b1.br2
        ;div.s1.bold.mb2: 👁️ Watch-Only Accounts
        ;p.f2.s-1: Monitor addresses without spending capability
        ;p.f3.s-2: Import xpubs or single addresses to track balances and transactions
      ==
    ==
  =/  signing-accounts-content=manx
    ;div.fc.g4
      ;div.p4.b1.br2
        ;div.s1.bold.mb2: 🔑 Signing Accounts
        ;p.f2.s-1: Individual keys and hardware wallet connections
        ;p.f3.s-2: Import private keys or connect hardware wallets for transaction signing
      ==
    ==
  =/  tab-items=(list [id=tape label=tape content=manx])
    :~  ["full" "💼 Full Wallets" full-wallets-content]
        ["watch" "👁️ Watch-Only" watch-only-content]
        ["signing" "🔑 Signing" signing-accounts-content]
    ==
  %-  htmx-page:lab
  :^  "Bitcoin Wallet"  &  ~
  ;div.fc.g4.p5.ma.mw-page
    ;div.tc.mb3
      ;h1.s3.bold: ₿ Bitcoin Wallet
      ;p.f2.s-1: Manage your Bitcoin wallets and accounts
    ==
    ;+  (tabs:lab tab-items "full")
  ==
::
++  ingredients-page
  ^-  manx
  *manx
--
