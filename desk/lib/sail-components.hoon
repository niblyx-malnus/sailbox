:: sail-components.hoon - CSS-based Sail component library
::
:: First draft component library to be improved through use
:: Assumes external CSS framework (Bootstrap-style classes)
::
|%
:: Basic Components
::
:: Create a styled button with optional click handler
::
++  button
  |=  [text=tape class=tape name=tape value=tape]
  ^-  manx
  ;button(class class, type "submit", name name, value value): {text}
:: Create a card container with title and content
::
++  card
  |=  [title=tape content=marl]
  ^-  manx
  ;div.card
    ;div.card-header
      ;h3: {title}
    ==
    ;div.card-body
      ;*  content
    ==
  ==
:: Create a badge/chip component
::
++  badge
  |=  [text=tape type=?(%primary %secondary %success %warning %danger)]
  ^-  manx
  =/  class=tape
    ?-  type
      %primary    "badge badge-primary"
      %secondary  "badge badge-secondary"
      %success    "badge badge-success"
      %warning    "badge badge-warning"
      %danger     "badge badge-danger"
    ==
  ;span(class class): {text}
::
:: List Components
::
++  ship-list
  :: Render a list of ships with optional actions
  |=  [ships=(list @p) show-actions=?]
  ^-  manx
  ;ul.ship-list
    ;*  %+  turn  ships
        |=  =ship
        ;li.ship-item
          ;span.ship-name: {(scow %p ship)}
          ;+  ?:  show-actions
                ;div.ship-actions
                  ;button.btn-sm(name "action", value "message-{(scow %p ship)}"): Message
                  ;button.btn-sm(name "action", value "remove-{(scow %p ship)}"): Remove
                ==
              ;span;
        ==
  ==
++  data-table
  :: Create a data table with headers and rows
  |=  [headers=(list tape) rows=(list (list tape))]
  ^-  manx
  ;table.data-table
    ;thead
      ;tr
        ;*  %+  turn  headers
            |=  h=tape
            ;th: {h}
      ==
    ==
    ;tbody
      ;*  %+  turn  rows
          |=  row=(list tape)
          ;tr
            ;*  %+  turn  row
                |=  cell=tape
                ;td: {cell}
          ==
    ==
  ==
::
:: Form Components
::
++  text-input
  :: Create a text input with label
  |=  [name=tape label=tape placeholder=tape value=tape]
  ^-  manx
  ;div.form-group
    ;label(for name): {label}
    ;input(type "text", id name, name name, placeholder placeholder, value value);
  ==
++  select-dropdown
  :: Create a select dropdown
  |=  [name=tape label=tape options=(list [value=tape text=tape]) selected=tape]
  ^-  manx
  ;div.form-group
    ;label(for name): {label}
    ;select(id name, name name)
      ;*  %+  turn  options
          |=  [value=tape text=tape]
          ?:  =(value selected)
            ;option(value value, selected ""): {text}
          ;option(value value): {text}
    ==
  ==
++  checkbox
  :: Create a checkbox with label
  |=  [name=tape label=tape checked=?]
  ^-  manx
  ;div.form-check
    ;+  ?:  checked
          ;input.form-check-input(type "checkbox", id name, name name, checked "");
        ;input.form-check-input(type "checkbox", id name, name name);
    ;label.form-check-label(for name): {label}
  ==
::
:: Layout Components
::
++  container
  :: Create a container with optional width constraint
  |=  [content=marl max-width=(unit tape)]
  ^-  manx
  =/  style=tape
    ?~  max-width
      ""
    "max-width: {u.max-width}; margin: 0 auto;"
  ;div.container(style style)
    ;*  content
  ==
++  row
  :: Create a flexbox row
  |=  cols=(list manx)
  ^-  manx
  ;div.row(style "display: flex; flex-wrap: wrap; gap: 1rem;")
    ;*  cols
  ==
++  col
  :: Create a column with optional width
  |=  [content=marl width=(unit tape)]
  ^-  manx
  =/  style=tape
    ?~  width
      "flex: 1;"
    "width: {u.width};"
  ;div.col(style style)
    ;*  content
  ==
::
:: Navigation Components
::
++  navbar
  :: Create a navigation bar
  |=  [brand=tape links=(list [href=tape text=tape]) active=tape]
  ^-  manx
  ;nav.navbar
    ;div.navbar-brand
      ;a/"/":{brand}
    ==
    ;ul.navbar-nav
      ;*  %+  turn  links
          |=  [href=tape text=tape]
          ;li.nav-item(class ?:(=(href active) "active" ""))
            ;a/"{href}".nav-link: {text}
          ==
    ==
  ==
++  breadcrumb
  :: Create a breadcrumb navigation
  |=  items=(list [href=tape text=tape])
  ^-  manx
  ;nav(aria-label "breadcrumb")
    ;ol.breadcrumb
      ;*  %-  tail
          %+  spun  items
          |=  [[href=tape text=tape] index=@ud]
          :-  ?:  =(index (dec (lent items)))
                ;li.breadcrumb-item.active(aria-current "page"): {text}
              ;li.breadcrumb-item
                ;a/"{href}": {text}
              ==
          +(index)
    ==
  ==
::
:: Feedback Components
::
++  alert
  :: Create an alert/notification
  |=  [message=tape type=?(%info %success %warning %error)]
  ^-  manx
  =/  class=tape
    ?-  type
      %info     "alert alert-info"
      %success  "alert alert-success"
      %warning  "alert alert-warning"
      %error    "alert alert-error"
    ==
  ;div(class class, role "alert")
    ;+  ?-  type
          %info     ;span: ℹ️
          %success  ;span: ✅
          %warning  ;span: ⚠️
          %error    ;span: ❌
        ==
    ;span: {" "}{message}
  ==
++  progress-bar
  :: Create a progress bar
  |=  [value=@ud max=@ud label=(unit tape)]
  ^-  manx
  =/  percent=@ud  (div (mul value 100) max)
  ;div.progress
    ;div.progress-bar(style "width: {<percent>}%", role "progressbar",
                       aria-valuenow "{<value>}", aria-valuemin "0", aria-valuemax "{<max>}")
      ;+  ?~  label
            ;span;
          ;span: {u.label}
    ==
  ==
++  spinner
  :: Create a loading spinner
  |=  [size=?(%sm %md %lg) text=(unit tape)]
  ^-  manx
  =/  class=tape
    ?-  size
      %sm  "spinner spinner-sm"
      %md  "spinner spinner-md"
      %lg  "spinner spinner-lg"
    ==
  ;div.spinner-container
    ;div(class class, role "status")
      ;span.sr-only: Loading...
    ==
    ;+  ?~  text
          ;span;
        ;span.spinner-text: {u.text}
  ==
::
:: Interactive Components
::
++  tabs
  :: Create a tabbed interface
  |=  [tabs=(list [id=tape label=tape content=manx]) active=tape]
  ^-  manx
  ;div.tabs
    ;ul.nav.nav-tabs
      ;*  %+  turn  tabs
          |=  [id=tape label=tape content=manx]
          ;li.nav-item
            ;a.nav-link(class ?:(=(id active) "active" ""), href "#{id}"): {label}
          ==
    ==
    ;div.tab-content
      ;*  %+  turn  tabs
          |=  [id=tape label=tape content=manx]
          ;div.tab-pane(class ?:(=(id active) "active" ""), id id)
            ;+  content
          ==
    ==
  ==
++  accordion
  :: Create an accordion/collapsible sections
  |=  [items=(list [id=tape title=tape content=manx]) open=(unit tape)]
  ^-  manx
  ;div.accordion
    ;*  %+  turn  items
        |=  [id=tape title=tape content=manx]
        ;div.accordion-item
          ;h2.accordion-header(id "heading-{id}")
            ;button.accordion-button(class ?:(=([~ id] open) "" "collapsed"),
                                     type "button", data-toggle "collapse",
                                     data-target "#{id}"): {title}
          ==
          ;div.accordion-collapse(class ?:(=([~ id] open) "collapse show" "collapse"),
                                  id id)
            ;div.accordion-body
              ;+  content
            ==
          ==
        ==
  ==
++  modal
  :: Create a modal dialog template
  |=  [id=tape title=tape body=manx footer=(unit manx)]
  ^-  manx
  ;div.modal(id id, tabindex "-1", role "dialog")
    ;div.modal-dialog(role "document")
      ;div.modal-content
        ;div.modal-header
          ;h5.modal-title: {title}
          ;button.close(type "button", data-dismiss "modal", aria-label "Close")
            ;span(aria-hidden "true"): ×
          ==
        ==
        ;div.modal-body
          ;+  body
        ==
        ;+  ?~  footer
              ;span;
            ;div.modal-footer
              ;+  u.footer
            ==
      ==
    ==
  ==
::
:: Utility Components
::
++  icon
  :: Create an icon (using Unicode or emoji)
  |=  type=?(%home %user %settings %search %menu %close %check %times)
  ^-  manx
  =/  icon-char=tape
    ?-  type
      %home     "🏠"
      %user     "👤"
      %settings "⚙️"
      %search   "🔍"
      %menu     "☰"
      %close    "✕"
      %check    "✓"
      %times    "✗"
    ==
  ;span.icon: {icon-char}
::
++  timestamp
  :: Format and display a timestamp
  |=  [time=@da format=?(%relative %absolute %both)]
  ^-  manx
  =/  abs-time=tape  (scow %da time)
  =/  rel-time=tape  "2 hours ago"  :: TODO: Calculate relative time
  ?-  format
    %relative  ;time(datetime abs-time): {rel-time}
    %absolute  ;time(datetime abs-time): {abs-time}
    %both      ;time(datetime abs-time, title abs-time): {rel-time}
  ==
++  code-block
  :: Create a code block with optional syntax highlighting
  |=  [code=tape language=(unit tape)]
  ^-  manx
  ;pre
    ;code(class ?~(language "" "language-{u.language}")): {code}
  ==
::
:: Composite Components
::
++  user-card
  :: Create a user/ship card
  |=  [=ship status=?(%online %offline %away) bio=(unit tape)]
  ^-  manx
  ;div.user-card
    ;div.user-header
      ;span.user-name: {(scow %p ship)}
      ;span.user-status(class "status-{<status>}")
        ;+  ?-  status
              %online   ;span: 🟢
              %offline  ;span: ⚫
              %away     ;span: 🟡
            ==
      ==
    ==
    ;+  ?~  bio
          ;span;
        ;div.user-bio: {u.bio}
  ==
++  comment-thread
  :: Create a comment thread display
  |=  comments=(list [author=@p time=@da text=tape])
  ^-  manx
  ;div.comment-thread
    ;*  %+  turn  comments
        |=  [author=@p time=@da text=tape]
        ;div.comment
          ;div.comment-header
            ;span.comment-author: {(scow %p author)}
            ;span.comment-time: {(scow %da time)}
          ==
          ;div.comment-body: {text}
        ==
  ==
++  stat-card
  :: Create a statistics display card
  |=  [label=tape value=tape change=(unit [positive=? amount=tape])]
  ^-  manx
  ;div.stat-card
    ;div.stat-label: {label}
    ;div.stat-value: {value}
    ;+  ?~  change
          ;span;
        ;div.stat-change(class ?:(positive.u.change "positive" "negative"))
          ;+  ?:  positive.u.change
                ;span: ↑ {amount.u.change}
              ;span: ↓ {amount.u.change}
        ==
  ==
--