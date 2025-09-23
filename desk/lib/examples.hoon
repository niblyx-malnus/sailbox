::  examples.hoon - Advanced Sail patterns
::
/+  html-utils
|%
::  Core Decomposition Pattern - decompose complex rendering with |% arms
::
++  render-simple-table
  |=  [headers=(list tape) rows=(list (list tape))]
  ^-  manx
  |^
    ;div.table-container
      ;p
        =style  "background: #e8f4fd; padding: 10px; border-left: 4px solid #2563eb; margin: 10px 0;"
        ; Core decomposition avoids overnesting by using |% arms to break
        ; complex rendering into composable functions that are debuggable and extensible.
      ==
      ;table
        ;+  render-header
        ;+  render-body
      ==
    ==
  ::
  ++  render-header
    ^-  manx
    ;thead
      ;tr
        ;*  %+  turn  headers
            |=  h=tape
            ;th: {h}
      ==
    ==
  ::
  ++  render-body
    ^-  manx
    ;tbody
      ;*  %+  turn  rows
          |=  row=(list tape)
          ;tr
            ;*  %+  turn  row
                |=  cell=tape
                ;td: {cell}
          ==
    ==
  --
::  Wide Form Bodies - one-liner rendering with stored children
::
++  render-with-wide-form
  |=  [title=tape items=(list tape)]
  ^-  manx
  =;  children=marl
    ;div.wide-form-demo:(*children)
  ;=
    ;h3: {title}
    ;p
      =style  "background: #f0f9ff; padding: 8px; border-radius: 4px; margin: 8px 0;"
      ; Wide form syntax :(*children) provides clean one-liner rendering
      ; of stored children, eliminating nested ;div ;* patterns.
    ==
    ;ul
      ;*  %+  turn  items
          |=  item=tape
          ;li: {item}
    ==
  ==
::  Empty Nodes - proper empty content handling
::
++  render-conditional-content
  |=  [show-content=? message=tape label=tape]
  ^-  manx
  ;div.conditional-demo
    =style  "border: 2px dashed #ccc; padding: 10px; margin: 5px 0;"
    ;h3: {label}
    ;p
      =style  "background: #fef3c7; padding: 8px; border-radius: 4px; margin: 8px 0;"
      ; Empty node pattern ;/("") renders absolutely nothing, including no whitespace.
      ; Contrast with *manx which renders unwanted angle brackets in empty state.
    ==
    ;p: show-content flag: {<?:(show-content "TRUE" "FALSE")>}
    ;div
      =style  "min-height: 30px; background: #f0f0f0; border: 1px solid #ddd; padding: 5px;"
      ;strong: Content area:
      ;+
      ?.  show-content  ;/("")  :: empty node pattern renders nothing
      ;span
        =style  "background: yellow; padding: 2px;"
        ; {message}
      ==
    ==
  ==
::  Michep (;-) for Raw Content - CSS and JavaScript injection
::
++  render-with-embedded-css
  |=  [title=tape message=tape]
  ^-  manx
  ;div
    ;p
      =style  "background: #fde2e7; padding: 10px; border-left: 4px solid #dc2626; margin: 10px 0;"
      ; The ;- rune injects raw content without escaping, enabling direct
      ; CSS and JavaScript embedding without external files.
    ==
    ;style
      ;-  %-  trip
      '''
      .michep-demo {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 20px;
        border-radius: 12px;
        color: white;
        text-align: center;
        margin: 10px 0;
        box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        transition: transform 0.3s ease;
      }
      .michep-demo:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(0,0,0,0.3);
      }
      .michep-title {
        font-size: 1.5rem;
        font-weight: bold;
        margin-bottom: 10px;
        text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
      }
      .michep-message {
        font-size: 1rem;
        opacity: 0.9;
      }
      '''
    ==
    ;div.michep-demo
      ;div.michep-title: {title}
      ;div.michep-message: {message}
    ==
    ;script
      ;-  %-  trip
      '''
      console.log('Michep pattern: embedded JavaScript via ;- rune');

      // Add click interaction to all michep demos
      document.querySelectorAll('.michep-demo').forEach(function(el) {
        el.addEventListener('click', function() {
          if (el.style.transform === 'scale(1.1)') {
            el.style.transform = '';
            el.style.background = 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)';
          } else {
            el.style.transform = 'scale(1.1)';
            el.style.background = 'linear-gradient(135deg, #764ba2 0%, #667eea 100%)';
          }
        });
      });
      '''
    ==
  ==
::  Pretty Printer Debugging - {<expression>} pattern for development
::
++  render-debug-info
  |=  [data=(map @t @t) show-debug=? =time]
  ^-  manx
  =/  info-style=tape
    "background: #f0fdf4; padding: 10px; border-left: 4px solid #16a34a; margin: 10px 0;"
  =/  debug-panel-style=tape
    "background: #1a1a1a; color: #00ff00; border: 2px solid #00ff00; padding: 15px; border-radius: 8px; font-family: 'Courier New', monospace; margin: 10px 0;"
  =/  debug-title-style=tape
    "color: #ffff00; margin-top: 0;"
  =/  debug-small-style=tape
    "color: #888;"
  ;div
    ;h3: Pretty Printer Demo - {<?:(show-debug "🟢 ON" "🔴 OFF")>}
    ;p(style info-style)
      ; The curly-angle pattern \{<expression>} converts any Hoon expression to tape,
      ; enabling display of complex data structures for debugging and development.
    ==
    ;p: Displaying {<(lent ~(tap by data))>} data items with this pattern:
    ;+  ?.  show-debug  ;/("")
        ;div.debug-panel(style debug-panel-style)
          ;h4(style debug-title-style)
            ; DEBUG OUTPUT USING PRETTY PRINTER PATTERNS
          ==
          ;p: Map size: {<~(wyt by data)>} items
          ;p: All keys: {<~(tap in ~(key by data))>}
          ;p: Raw map data: {<data>}
          ;p: Timestamp: {<time>}
          ;small(style debug-small-style)
            ; All above expressions use the pretty-printer debugging pattern
          ==
        ==
  ==
::  Direct manx manipulation - programmatic HTML structure modification
::
++  render-manx-manipulation
  |=  [title=tape items=(list tape) highlight-index=(unit @ud)]
  ^-  manx
  =/  info-style=tape
    "background: #e0f2fe; padding: 10px; border-left: 4px solid #0284c7; margin: 10px 0;"
  =/  container-style=tape
    "border: 2px solid #ddd; border-radius: 8px; padding: 15px; margin: 10px 0;"
  =/  title-style=tape
    "color: #1e40af; margin-bottom: 10px; font-weight: bold;"
  =/  highlight-style=tape
    "background: #fef3c7; padding: 8px; border-radius: 4px; font-weight: bold; border: 2px solid #f59e0b;"
  =/  normal-style=tape
    "padding: 8px; border-radius: 4px; background: #f8fafc; margin: 4px 0;"
  =;  base-list=manx
    ;div
      ;p(style info-style)
        ; Direct manx manipulation enables programmatic modification of HTML structures.
        ; Build base structures, then conditionally modify attributes, classes, and content.
      ==
      ;+  base-list
    ==
  =;  item-elements=marl
    ;div(style container-style)
      ;h3(style title-style): {title}
      ;*  item-elements
    ==
  %+  turn  (gulf 0 (dec (lent items)))
  |=  i=@ud
  =/  item=tape  (snag i items)
  =/  is-highlighted=?
    ?~  highlight-index  %.n
    =(i u.highlight-index)
  =;  base-element=manx
    ?:  is-highlighted
      base-element(a.g [[%style highlight-style] a.g.base-element])
    base-element(a.g [[%style normal-style] a.g.base-element])
  ;div.item: {item}
::  SVG-in-Sail Raw Embedding - de-xml:html conversion pattern
::
++  render-svg-embedding
  |=  [title=tape icons=(list @t)]
  ^-  manx
  =/  info-style=tape
    "background: #fef7ff; padding: 10px; border-left: 4px solid #a855f7; margin: 10px 0;"
  =/  icon-container-style=tape
    "display: flex; gap: 20px; align-items: center; justify-content: center; padding: 20px; background: #f8fafc; border-radius: 8px; margin: 10px 0;"
  |^  ;div
        ;p(style info-style)
          ; SVG-in-Sail pattern uses de-xml:html to convert raw SVG strings to manx at runtime.
          ; This enables embedding complete SVG graphics without external files or complex parsing.
        ==
        ;h3: {title}
        ;div(style icon-container-style)
          ;*  %+  turn  icons
              |=  icon-name=@t
              (render-icon icon-name)
        ==
        ;div(style "margin-top: 15px; font-size: 0.9em; color: #666;")
          ; Icons rendered: {<icons>} using de-xml:html conversion
        ==
      ==
  ::
  ++  render-icon
    |=  name=@t
    ^-  manx
    =/  svg-string=tape
      ?-  name
        %arrow-right
          "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"32\" height=\"32\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"#3b82f6\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M5 12h14\"></path><path d=\"m12 5 7 7-7 7\"></path></svg>"
        %check
          "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"32\" height=\"32\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"#10b981\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M20 6 9 17l-5-5\"></path></svg>"
        %star
          "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"32\" height=\"32\" viewBox=\"0 0 24 24\" fill=\"#fbbf24\" stroke=\"#f59e0b\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><polygon points=\"12,2 15.09,8.26 22,9.27 17,14.14 18.18,21.02 12,17.77 5.82,21.02 7,14.14 2,9.27 8.91,8.26\"></polygon></svg>"
        %heart
          "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"32\" height=\"32\" viewBox=\"0 0 24 24\" fill=\"#ef4444\" stroke=\"#dc2626\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z\"></path></svg>"
        *
          "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"32\" height=\"32\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"#6b7280\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><circle cx=\"12\" cy=\"12\" r=\"3\"></circle><path d=\"M12 1v6m0 6v6\"></path><path d=\"m5.64 7.64 4.24 4.24m4.24 0 4.24-4.24\"></path><path d=\"m7.64 16.36 4.24-4.24m4.24 4.24 4.24 4.24\"></path></svg>"
      ==
    =/  converted=manx  %+  fall  (de-xml:html (crip svg-string))  ;div: ERROR
    ;div
      =style  "display: inline-block; margin: 5px; padding: 10px; background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); transition: transform 0.2s ease;"
      =onmouseover  "this.style.transform='scale(1.1)'"
      =onmouseout  "this.style.transform='scale(1)'"
      ;+  converted
      ;div
        =style  "text-align: center; font-size: 0.75em; color: #666; margin-top: 5px;"
        ; {(trip name)}
      ==
    ==
  --
::  Conditional attributes pattern - dynamic attribute generation
::
++  render-conditional-attributes
  |=  [message=tape is-important=? has-icon=? theme=@tas]
  ^-  manx
  =/  info-style=tape
    "background: #f0f9ff; padding: 10px; border-left: 4px solid #3b82f6; margin: 10px 0;"
  =/  base-style=tape
    "padding: 15px; border-radius: 8px; margin: 10px 0; transition: all 0.3s ease;"
  =/  theme-styles=(map @tas tape)
    %-  malt
    %-  limo
    :~
      :-  %light
      "background: #f8fafc; color: #1e293b; border: 1px solid #e2e8f0;"
      :-  %dark
      "background: #1e293b; color: #f8fafc; border: 1px solid #475569;"
      :-  %accent
      "background: linear-gradient(135deg, #3b82f6, #8b5cf6); color: white; border: none;"
    ==
  =/  importance-styles=(map ? tape)
    %-  malt
    %-  limo
    :~
      :-  %.y
      "box-shadow: 0 4px 15px rgba(239, 68, 68, 0.3); border-left: 4px solid #ef4444;"
      :-  %.n
      "box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);"
    ==
  =/  final-style=tape
    %-  zing
    :~
      base-style
      " "
      (~(got by theme-styles) theme)
      " "
      (~(got by importance-styles) is-important)
    ==
  =/  icon-content=tape
    ?:  has-icon
      ?:  is-important  "🚨 "  "ℹ️ "
    ""
  =/  dynamic-classes=tape
    %-  zing
    :~
      "message-box"
      ?:(is-important " important" "")
      ?:(has-icon " with-icon" "")
      " theme-"
      (trip theme)
    ==
  ;div
    ;p(style info-style)
      ; Conditional attributes pattern dynamically builds classes, styles, and attributes
      ; based on function parameters, ideal for component systems and theming.
    ==
    ;div
      =class  dynamic-classes
      =style  final-style
      =role  ?:(is-important "alert" "note")
      =aria-level  ?:(is-important "2" "3")
      ; {icon-content}{message}
    ==
    ;div(style "margin-top: 10px; font-size: 0.85em; color: #666;")
      ; Dynamic attributes: class="{dynamic-classes}", importance={<?:(is-important "HIGH" "NORMAL")>}, icon={<?:(has-icon "YES" "NO")>}, theme={<theme>}
    ==
  ==
::  Icon Component Factory - functional CSS manipulation with icon generation
::
++  render-icon-factory
  |=  [title=tape demos=(list [name=@t size=tape color=tape classes=tape])]
  ^-  manx
  =/  info-style=tape
    "background: #f3f4f6; padding: 10px; border-left: 4px solid #6b7280; margin: 10px 0;"
  =/  demo-container-style=tape
    "display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; padding: 20px; background: #fafafa; border-radius: 8px; margin: 10px 0;"
  =/  icon-names=(list @t)  ~[%loader %settings %heart %check %star %arrow-right]
  |^  ;div
        ;p(style info-style)
          ; Icon Component Factory pattern combines SVG generation with functional CSS manipulation.
          ; Build reusable icon components with dynamic sizing, coloring, and CSS classes.
        ==
        ;h3: {title}
        ;div(style demo-container-style)
          ;*  %+  turn  demos
              |=  [name=@t size=tape color=tape classes=tape]
              (demo-card name size color classes)
        ==
        ;div(style "margin-top: 15px; font-size: 0.9em; color: #666;")
          ; Factory-generated icons with programmatic CSS application: {<(lent demos)>} variants
        ==
      ==
  ::
  ++  demo-card
    |=  [name=@t size=tape color=tape classes=tape]
    ^-  manx
    =/  card-style=tape
      "background: white; padding: 15px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); text-align: center; border: 1px solid #e5e7eb;"
    =/  icon-wrapper-style=tape
      "display: flex; justify-content: center; align-items: center; height: 80px; margin-bottom: 10px;"
    ;div(style card-style)
      ;div(style icon-wrapper-style)
        ;+  (make-icon name size color classes)
      ==
      ;div(style "font-size: 0.8em; color: #666;")
        ;p: Icon: {(trip name)}
        ;p: Size: {size}
        ;p: Color: {color}
        ;p: Classes: {classes}
      ==
    ==
  ::
  ++  make-icon
    |=  [name=@t size=tape color=tape classes=tape]
    ^-  manx
    =/  base-icon=manx  (make:fi name)
    =/  styled-icon=manx  (pus:~(at mx:html-utils base-icon) "height: {size}; width: {size}; color: {color};")
    (pac:~(at mx:html-utils styled-icon) classes)
  ::
  ++  fi
    |%
    ++  make
      |=  name=@t
      ^-  manx
      =/  svg-string=tape
        ?-  name
          %loader
            "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M21 12a9 9 0 1 1-6.219-8.56\"/></svg>"
          %settings
            "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z\"/><circle cx=\"12\" cy=\"12\" r=\"3\"/></svg>"
          %heart
            "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"currentColor\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z\"/></svg>"
          %check
            "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M20 6 9 17l-5-5\"/></svg>"
          %star
            "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"currentColor\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><polygon points=\"12,2 15.09,8.26 22,9.27 17,14.14 18.18,21.02 12,17.77 5.82,21.02 7,14.14 2,9.27 8.91,8.26\"/></svg>"
          %arrow-right
            "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M5 12h14\"/><path d=\"m12 5 7 7-7 7\"/></svg>"
          *
            "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><circle cx=\"12\" cy=\"12\" r=\"3\"/></svg>"
        ==
      %+  fall  (de-xml:html (crip svg-string))  ;div: ICON-ERROR
    --
  --
--