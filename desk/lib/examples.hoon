::  examples.hoon - Advanced Sail patterns
::
/+  html-utils, feather
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
        %question
          "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"32\" height=\"32\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"#8b5cf6\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><circle cx=\"12\" cy=\"12\" r=\"10\"></circle><path d=\"M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3\"></path><path d=\"M12 17h.01\"></path></svg>"
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
::  Manx Transformation Pattern - programmatic manx transformation with functional operations
::
++  render-manx-transformation
  |=  [title=tape demos=(list [label=tape demo-type=@t content=tape])]
  ^-  manx
  =/  info-style=tape
    "background: #fef7ff; padding: 10px; border-left: 4px solid #8b5cf6; margin: 10px 0;"
  =/  demo-container-style=tape
    "display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; padding: 20px; background: #f9fafb; border-radius: 8px; margin: 10px 0;"
  |^  ;div
        ;p(style info-style)
          ; Manx Transformation Pattern enables programmatic modification of manx structures.
          ; Apply functional operations like adding debug info, making elements interactive, or styling images.
        ==
        ;h3: {title}
        ;div(style demo-container-style)
          ;*  %+  turn  demos
              |=  [label=tape demo-type=@t content=tape]
              (demo-transform label demo-type content)
        ==
        ;div(style "margin-top: 15px; font-size: 0.9em; color: #666;")
          ; Transformations applied: {<(lent demos)>} functional operations on manx structures
        ==
      ==
  ::
  ++  demo-transform
    |=  [label=tape demo-type=@t content=tape]
    ^-  manx
    =/  card-style=tape
      "background: white; padding: 20px; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); border: 1px solid #e5e7eb;"
    =/  header-style=tape
      "font-weight: bold; color: #374151; margin-bottom: 15px; padding-bottom: 10px; border-bottom: 2px solid #f3f4f6;"
    =/  demo-area-style=tape
      "margin: 15px 0; min-height: 60px; display: flex; align-items: center; justify-content: center;"
    =/  base-element=manx
      ?-  demo-type
        %debug     ;div: {content}
        %interactive  ;button: {content}
        %image     ;img(src "https://via.placeholder.com/200x120/4338ca/ffffff?text=Demo", alt content);
        *          ;span: {content}
      ==
    =/  transformed-element=manx
      ?-  demo-type
        %debug        (add-debug-info base-element)
        %interactive  (make-interactive base-element "alert('Button clicked!')")
        %image        (responsive-image base-element)
        *             base-element
      ==
    ;div(style card-style)
      ;div(style header-style): {label}
      ;div(style demo-area-style)
        ;+  transformed-element
      ==
      ;div(style "font-size: 0.8em; color: #6b7280; margin-top: 10px;")
        ; Transformation: {(trip demo-type)} applied to base element
      ==
    ==
  ::
  ++  add-debug-info
    |=  element=manx
    ^-  manx
    =/  with-debug-class=manx  (pac:~(at mx:html-utils element) "debug-enabled border-2 border-yellow-400")
    (pus:~(at mx:html-utils with-debug-class) "background: #fef3c7; position: relative; padding: 10px;")
  ::
  ++  make-interactive
    |=  [element=manx action=tape]
    ^-  manx
    =/  with-class=manx  (pac:~(at mx:html-utils element) "interactive cursor-pointer")
    =/  with-style=manx  (pus:~(at mx:html-utils with-class) "padding: 10px 20px; border: 2px solid #3b82f6; border-radius: 6px; background: #eff6ff;")
    (put:~(at mx:html-utils with-style) %onclick action)
  ::
  ++  responsive-image
    |=  element=manx
    ^-  manx
    =/  with-classes=manx  (pac:~(at mx:html-utils element) "responsive max-w-full h-auto rounded-lg shadow-md")
    =/  with-style=manx  (pus:~(at mx:html-utils with-classes) "object-fit: cover; transition: transform 0.3s ease;")
    (put:~(at mx:html-utils with-style) %onmouseover "this.style.transform='scale(1.05)'")
  --
::  Typed Door Pattern for Scoped Components - component libraries with shared context
::
++  render-typed-door-pattern
  |=  [title=tape demos=(list [theme=@t size=@t variant=@t demo-type=@t content=tape])]
  ^-  manx
  =/  info-style=tape
    "background: #f0fdf4; padding: 10px; border-left: 4px solid #16a34a; margin: 10px 0;"
  =/  demo-container-style=tape
    "display: grid; grid-template-columns: repeat(auto-fit, minmax(350px, 1fr)); gap: 20px; padding: 20px; background: #f8fafc; border-radius: 8px; margin: 10px 0;"
  |^  ;div
        ;p(style info-style)
          ; Typed Door Pattern creates component libraries with shared context.
          ; The door |_ holds theme/size/variant state that all components can access.
        ==
        ;h3: {title}
        ;div(style demo-container-style)
          ;*  %+  turn  demos
              |=  [theme=@t size=@t variant=@t demo-type=@t content=tape]
              (demo-showcase theme size variant demo-type content)
        ==
        ;div(style "margin-top: 15px; font-size: 0.9em; color: #666;")
          ; Component instances: {<(lent demos)>} components sharing contextual styling
        ==
      ==
  ::
  ++  demo-showcase
    |=  [theme=@t size=@t variant=@t demo-type=@t content=tape]
    ^-  manx
    =/  card-style=tape
      "background: white; padding: 20px; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); border: 1px solid #e5e7eb;"
    =/  header-style=tape
      "font-weight: bold; color: #374151; margin-bottom: 15px; padding-bottom: 10px; border-bottom: 2px solid #f3f4f6;"
    =/  demo-area-style=tape
      "margin: 15px 0; min-height: 80px; display: flex; align-items: center; justify-content: center;"
    =/  context-info=tape
      "Theme: {(trip theme)}, Size: {(trip size)}, Variant: {(trip variant)}"
    =/  component-door  ~(. ui-components [theme size variant])
    =/  content-element=manx  ;p: {content}
    =/  rendered-component=manx
      ?-  demo-type
        %button     (button:component-door content "alert('Button clicked!')")
        %card       (card:component-door "Sample Card" content-element)
        %badge      (badge:component-door content)
        *           ;span: {content}
      ==
    ;div(style card-style)
      ;div(style header-style): {(trip demo-type)} Component
      ;div(style demo-area-style)
        ;+  rendered-component
      ==
      ;div(style "font-size: 0.8em; color: #6b7280; margin-top: 10px;")
        ; {context-info}
      ==
    ==
  ::
  ++  ui-components
    |_  [theme=@t size=@t variant=@t]
    ++  button
      |=  [text=tape action=tape]
      ^-  manx
      =/  theme-classes=tape
        ?-  theme
          %primary    "b-4 f0"
          %secondary  "b2 f0"
          %success    "b-3 f0"
          %danger     "b-1 f0"
          *           "b1 f1"
        ==
      =/  size-classes=tape
        ?-  size
          %sm   "p-1 s-1"
          %md   "p-2 s0"
          %lg   "p-3 s1"
          *     "p-2 s0"
        ==
      =/  variant-classes=tape
        ?-  variant
          %solid     "bd0 br2 bold"
          %outline   "bd2 br2"
          %ghost     "bd0 br1 hover"
          *          "bd1 br2"
        ==
      =/  all-classes=tape
        "{theme-classes} {size-classes} {variant-classes} pointer"
      ;button
        =class  all-classes
        =onclick  action
        : {text}
      ==
    ::
    ++  card
      |=  [title=tape content=manx]
      ^-  manx
      =/  theme-classes=tape
        ?-  theme
          %primary    "b-4 f0"
          %secondary  "b1 f1 hover"
          %success    "b-3 f0"
          %danger     "b-1 f0"
          *           "b0 f0"
        ==
      =/  size-classes=tape
        ?-  size
          %sm   "p3"
          %md   "p4"
          %lg   "p6"
          *     "p4"
        ==
      =/  variant-classes=tape
        ?-  variant
          %solid     "bd1 br3"
          %outline   "bd2 br3"
          %ghost     "bd1 br2"
          *          "bd1 br2"
        ==
      =/  all-classes=tape
        "{theme-classes} {size-classes} {variant-classes}"
      ;div
        =class  all-classes
        ;div
          =class  "bd1 mb2 pb2"
          ;h3
            =class  "s1 bold m0"
            : {title}
          ==
        ==
        ;div
          ;+  content
        ==
      ==
    ::
    ++  badge
      |=  text=tape
      ^-  manx
      =/  theme-classes=tape
        ?-  theme
          %primary    "b-4 f0"
          %secondary  "b1 f1"
          %success    "b-3 f0"
          %danger     "b-1 f0"
          *           "b1 f2"
        ==
      =/  size-classes=tape
        ?-  size
          %sm   "p-1 s-2"
          %md   "p-2 s-1"
          %lg   "p1 s0"
          *     "p-1 s-2"
        ==
      =/  variant-classes=tape
        ?-  variant
          %solid     "bd0 br3 bold"
          %outline   "bd1 br3"
          %ghost     "bd0 br2"
          *          "bd0 br3"
        ==
      =/  all-classes=tape
        "{theme-classes} {size-classes} {variant-classes} inline"
      ;span
        =class  all-classes
        : {text}
      ==
    --
  --
::  CSS Utility Class Generation - systematic utility class composition
::
++  render-css-utility-pattern
  |=  [title=tape layout-params=[direction=@t gap=@t align=@t justify=@t] grid-cols=(list @ud) demo-items=(list tape)]
  ^-  manx
  |^  ;div.css-utility-demo
        ;h3: {title}
        ;+  explanation
        ;+  flex-demo
        ;+  spacing-demo
        ;+  grid-demo
      ==
  ::
  ++  explanation
    ;p
      =style  "background: #e1f5fe; padding: 10px; border-left: 4px solid #0277bd; margin: 10px 0;"
      : CSS Utility Class Generation pattern creates systematic utility classes programmatically.
      : Generate flex layouts, spacing, grids, and responsive classes with consistent naming.
    ==
  ::
  ++  flex-demo
    =/  flex-classes=tape  (flex-layout direction.layout-params gap.layout-params align.layout-params justify.layout-params)
    ;div.demo-section
      =style  "margin: 15px 0; padding: 15px; border: 1px solid #ddd; border-radius: 8px;"
      ;h4: Flex Layout Generation
      ;p: Generated classes: "{flex-classes}"
      ;div
        =class  "{flex-classes} b1 p2 br1"
        =style  "min-height: 60px;"
        ;*  %+  turn  demo-items
            |=  item=tape
            ;div.b-4.f0.p-1.br1.tc
              : {item}
            ==
      ==
    ==
  ::
  ++  spacing-demo
    =/  space-classes-1=tape  (spacing-classes 4 2)
    =/  space-classes-2=tape  (spacing-classes 6 4)
    ;div.demo-section
      =style  "margin: 15px 0; padding: 15px; border: 1px solid #ddd; border-radius: 8px;"
      ;h4: Spacing Class Generation
      ;div
        =style  "display: flex; gap: 20px; flex-wrap: wrap;"
        ;div
          =class  space-classes-1
          =style  "background: #fef3c7; border: 2px dashed #f59e0b;"
          ;span: p-4 m-2: "{space-classes-1}"
        ==
        ;div
          =class  space-classes-2
          =style  "background: #dcfce7; border: 2px dashed #16a34a;"
          ;span: p-6 m-4: "{space-classes-2}"
        ==
      ==
    ==
  ::
  ++  grid-demo
    =/  grid-classes=tape  (responsive-grid grid-cols)
    ;div.demo-section
      =style  "margin: 15px 0; padding: 15px; border: 1px solid #ddd; border-radius: 8px;"
      ;h4: Responsive Grid Generation
      ;p: Generated classes: "{grid-classes}"
      ;div
        =class  "{grid-classes} b1 p4 br2"
        ;*  %+  turn  demo-items
            |=  item=tape
            ;div.b-3.f0.p3.br2.tc.s-1
              : {item}
            ==
      ==
    ==
  ::
  ++  flex-layout
    |=  [direction=@t gap=@t align=@t justify=@t]
    ^-  tape
    %-  zing
    :~  ?-  direction
          %row     "fr"
          %column  "fc"
          *        "fr"
        ==
        " "
        "g{(trip gap)}"
        " "
        ?-  align
          %center   "ac"
          %start    "as"
          %end      "ae"
          %stretch  "af"
          *         "ac"
        ==
        " "
        ?-  justify
          %center   "jc"
          %between  "jb"
          %start    "js"
          %end      "je"
          *         "jc"
        ==
    ==
  ::
  ++  spacing-classes
    |=  [p=@ud m=@ud]
    ^-  tape
    "p{((d-co:co 1) p)} mt{((d-co:co 1) m)}"
  ::
  ++  responsive-grid
    |=  cols=(list @ud)
    ^-  tape
    =/  base-col=@ud  ?~(cols 1 i.cols)
    "fc basis-full g2"
  --
::
::  Pattern #13: Complex List Rendering
::
++  render-complex-list-patterns
  |=  [title=tape]
  ^-  manx
  |^  ;div.complex-list-demo
        ;h3: {title}
        ;+  render-explanation
        ;+  render-tree-demo
        ;+  render-table-demo
      ==
  ++  render-explanation
    ^-  manx
    ;p(style "background: #f0fdf4; padding: 10px; border-left: 4px solid #16a34a; margin: 10px 0;")
      : Complex List Rendering pattern handles nested data structures and tables.
      : Generate hierarchical trees and tables with conditional cell styling.
    ==
  ::
  ++  render-tree-demo
    ^-  manx
    ;div(style "margin: 15px 0;")
      ;h4: Hierarchical Tree Structure
      ;+  %-  render-tree
          :~  [%docs "Documentation" ~[[%guides "User Guides" ~] [%api "API Reference" ~]]]
              [%src "Source Code" ~[[%frontend "Frontend" ~] [%backend "Backend" ~]]]
              [%tests "Test Suite" ~]
          ==
    ==
  ::
  ++  render-table-demo
    ^-  manx
    ;div(style "margin: 15px 0;")
      ;h4: Table with Conditional Cell Classes
      ;+  %-  render-table
          :-  ~["Name" "Status" "Score" "Grade"]
          :~  :~  ["Alice" ""]
                  ["Active" "bold f-3 status-active"]
                  ["95" "bold f-4 high-score"]
                  ["A" "bold f-1 grade-a"]
              ==
              :~  ["Bob" ""]
                  ["Inactive" "f4 status-inactive"]
                  ["78" ""]
                  ["B" "f2 grade-b"]
              ==
              :~  ["Charlie" ""]
                  ["Active" "bold f-3 status-active"]
                  ["88" "bold score"]
                  ["A-" "bold f-2 grade-a-minus"]
              ==
          ==
    ==
  ::
  ++  render-tree
    |=  items=(list [key=@tas label=tape children=(list [key=@tas label=tape ~])])
    ^-  manx
    ;ul.tree-list(style "list-style: none; padding-left: 0; margin: 10px 0;")
      ;*  %+  turn  items
          |=  [key=@tas label=tape children=(list [key=@tas label=tape ~])]
          ;li.tree-item(style "margin: 5px 0; border-left: 2px solid #e5e7eb; padding-left: 10px;")
            ;div.tree-header(style "font-weight: bold; color: #374151; margin-bottom: 5px;"): {label}
            ;*  ?~  children
                ~
                :~  ;ul.tree-children(style "list-style: none; padding-left: 15px; margin: 5px 0;")
                      ;*  %+  turn  children
                          |=  [child-key=@tas child-label=tape ~]
                          ;li.tree-child(style "margin: 2px 0; color: #6b7280; font-size: 0.9em;"): {child-label}
                    ==
                ==
          ==
    ==
  ::
  ++  render-table
    |=  [headers=(list tape) rows=(list (list [value=tape classes=tape]))]
    ^-  manx
    ;table.data-table(style "border-collapse: collapse; width: 100%; margin: 10px 0; border: 1px solid #d1d5db;")
      ;thead
        ;tr(style "background: #f9fafb;")
          ;*  %+  turn  headers
              |=  h=tape
              ;th(style "border: 1px solid #d1d5db; padding: 8px; text-align: left; font-weight: bold;"): {h}
        ==
      ==
      ;tbody
        ;*  %+  turn  rows
            |=  row=(list [value=tape classes=tape])
            ;tr
              ;*  %+  turn  row
                  |=  [value=tape classes=tape]
                  ?:  =(classes "")
                    ;td(style "border: 1px solid #d1d5db; padding: 8px;"): {value}
                  ;td(class classes, style "border: 1px solid #d1d5db; padding: 8px;"): {value}
            ==
      ==
    ==
  --
::  Pattern #14: Form Generation Pattern
::  Generate complex forms with validation display
::
++  render-form-generation-pattern
  |=  [title=tape]
  ^-  manx
  |^  ;div.form-generation-demo
        ;h3: {title}
        ;+  render-explanation
        ;+  render-contact-form
        ;+  render-file-upload-form
      ==
  ++  render-explanation
    ^-  manx
    ;div.explanation(style "background: #f3f4f6; padding: 15px; margin: 10px 0; border-radius: 5px;")
      ;p: This pattern demonstrates complex form generation with validation display
      ;ul
        ;li: Field components with error states
        ;li: Required field indicators
        ;li: File upload forms with enctype handling
        ;li: Dynamic validation styling
      ==
    ==
  ++  render-contact-form
    ^-  manx
    ;div
      ;h4: Valid Contact Form
      ;form.contact-form(style "max-width: 400px; margin: 20px 0;")
        ;+  %:  render-field
                "name"
                %text
                "John Doe"
                "Full Name"
                ~
                %.y
            ==
        ;+  %:  render-field
                "email"
                %email
                "user@example.com"
                "Email Address"
                ~
                %.y
            ==
        ;+  %:  render-field
                "phone"
                %tel
                "555-1234"
                "Phone Number"
                ~
                %.n
            ==
        ;+  %:  render-field
                "message"
                %textarea
                "Hello world"
                "Message"
                ~
                %.y
            ==
        ;div.form-actions(style "margin-top: 20px;")
          ;button.submit-btn(type "submit", style "background: #3b82f6; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer;"): Submit
        ==
      ==
      ;h4: Form with Validation Errors (Demo)
      ;form.contact-form-errors(style "max-width: 400px; margin: 20px 0;")
        ;+  %:  render-field
                "name2"
                %text
                ""
                "Full Name"
                ~["This field is required"]
                %.y
            ==
        ;+  %:  render-field
                "email2"
                %email
                "not-an-email"
                "Email Address"
                ~["Please enter a valid email address"]
                %.y
            ==
        ;+  %:  render-field
                "phone2"
                %tel
                "123"
                "Phone Number"
                ~["Phone number must be at least 10 digits"]
                %.n
            ==
        ;div.form-actions(style "margin-top: 20px;")
          ;button.submit-btn(type "submit", disabled "disabled", style "background: #9ca3af; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: not-allowed;"): Submit
        ==
      ==
    ==
  ++  render-file-upload-form
    ^-  manx
    ;div
      ;h4: File Upload Form
      ;+  (file-upload-form "/upload" "image/*,application/pdf")
    ==
  ++  render-field
    |=  $:  name=tape
            type=@t
            value=tape
            label=tape
            errors=(list tape)
            required=?
        ==
    ^-  manx
    ;div.field-group(style "margin-bottom: 15px;")
      ;label(for name, style "display: block; margin-bottom: 5px; font-weight: bold; color: #374151;")
        ;span: {label}
        ;+  ?:(required ;span.required(style "color: #ef4444;"):"*" ;/(""))
      ==
      ;+  ?:  =(type %textarea)
            ;textarea
              =name     name
              =id       name
              =class    ?~(errors "input" "input input-error")
              =style    ?~(errors "width: 100%; padding: 8px; border: 1px solid #d1d5db; border-radius: 4px;" "width: 100%; padding: 8px; border: 1px solid #ef4444; border-radius: 4px;")
              ; {value}
            ==
          ;input
            =type     (trip type)
            =name     name
            =id       name
            =value    value
            =class    ?~(errors "input" "input input-error")
            =style    ?~(errors "width: 100%; padding: 8px; border: 1px solid #d1d5db; border-radius: 4px;" "width: 100%; padding: 8px; border: 1px solid #ef4444; border-radius: 4px;");
      ;div.field-errors
        ;*  %+  turn  errors
            |=  error=tape
            ;div.error-message(style "color: #ef4444; font-size: 0.875em; margin-top: 5px;"): {error}
      ==
    ==
  ++  file-upload-form
    |=  [action=tape accept=tape]
    ^-  manx
    ;form
      =method     "post"
      =action     action
      =enctype    "multipart/form-data"
      =style      "max-width: 400px; margin: 20px 0; padding: 20px; border: 1px solid #d1d5db; border-radius: 8px;"
      ;div.form-group(style "margin-bottom: 15px;")
        ;label.file-label(style "display: block; margin-bottom: 5px; font-weight: bold; color: #374151;")
          ;span: Choose file(s):
          ;input.file-input
            =type     "file"
            =name     "files"
            =accept   accept
            =style    "width: 100%; padding: 8px; border: 1px solid #d1d5db; border-radius: 4px;";
        ==
      ==
      ;div.form-actions
        ;button.submit-btn(type "submit", style "background: #10b981; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer;"): Upload
      ==
    ==
  --
::  Embedded Udon Pattern - seamlessly embed Udon (Urbit markdown) within Sail structures
::
++  render-embedded-udon-pattern
  |=  [title=tape]
  ^-  manx
  |^  ;div.embedded-udon-demo
        ;h3: {title}
        ;+  render-explanation
        ;+  render-slide-show
        ;+  render-blog-post
      ==
  ++  render-explanation
    ^-  manx
    ;div.explanation(style "background: #f0f9ff; padding: 15px; margin: 10px 0; border-radius: 5px; border-left: 4px solid #0ea5e9;")
      ;p: Embedded Udon Pattern lets you write Udon (Urbit markdown) directly within Sail structures
      ;ul
        ;li: Mix structured Sail components with natural markdown content
        ;li: Automatic parsing of Udon syntax into manx elements
        ;li: Slide show generation from markdown sections
        ;li: Blog post formatting with embedded content
      ==
    ==
  ++  render-slide-show
    ^-  manx
    ;div.slide-show-demo
      ;h4: Slide Show Demo (Udon → Sail)
      ;div.slide-container(style "border: 2px solid #e5e7eb; border-radius: 8px; padding: 20px; margin: 15px 0; background: #fafafa; min-height: 300px;")
        ;+
        =;  a=manx
          ;div.slides-container(style "display: flex; flex-direction: column; gap: 20px;")
            ;*
            ::  group elements, separated by %hr
            =|  slides=marl
            =|  slide=marl
            |-  ^-  marl
            =/  news  [;div.slide(style "background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); border-left: 4px solid #3b82f6;"):(*slide) slides]
            ?~  c.a  (flop `marl`news)
            ?:  =(%hr n.g.i.c.a)
              $(c.a t.c.a, slide ~, slides news)
            $(c.a t.c.a, slide (snoc slide i.c.a))
          ==
        ::
        ::  write your slides below.
        ::
        ;>
        # Welcome to Urbit Sail Patterns

        This is our *first slide* demonstrating embedded Udon.

        - Easy markdown syntax
        - Automatic parsing
        - Seamless integration

        ---

        # Advanced Patterns

        We can embed _italic text_, *bold text*, and even `inline code`.

        This makes documentation much easier!

        ---

        # Final Slide

        > This is a blockquote showing how Udon seamlessly integrates with Sail patterns.

        Perfect for creating rich content experiences.
      ==
    ==
  ++  render-blog-post
    ^-  manx
    =/  blog-content=manx
      ;>
      # Urbit Development Best Practices

      Writing effective Hoon code requires understanding several key principles:

      ## Core Concepts

      + *Immutability*: All data structures are immutable by default
      + *Type Safety*: The type system prevents many runtime errors
      + *Functional Programming*: Embrace pure functions and recursion

      ## Code Example

      Here's a simple example of a recursive function:

      ```
      ++  factorial
        |=  n=@ud
        ^-  @ud
        ?:  =(n 0)  1
        (mul n $(n (dec n)))
      ```

      ## Best Practices

      - Use descriptive variable names
      - Keep functions small and focused
      - Write comprehensive tests
      - Document your APIs

      > Remember: Good code is written for humans to read, not just for computers to execute.
    ;div.blog-post-demo
      ;h4: Blog Post Demo (Rich Udon Content)
      ;div.blog-container(style "border: 2px solid #d1d5db; border-radius: 8px; padding: 25px; margin: 15px 0; background: white; box-shadow: 0 1px 3px rgba(0,0,0,0.1);")
        ;div.prose
          ;+  blog-content
        ==
      ==
    ==
  --
::  Data-Driven Grid System Pattern - algorithmically generate complex grid layouts
::
++  render-data-driven-grid-pattern
  |=  [title=tape]
  ^-  manx
  |^  ;div.grid-system-demo
        ;h3: {title}
        ;+  render-explanation
        ;+  render-simple-grid
        ;+  render-interactive-grid
        ;+  render-responsive-grid
      ==
  ++  render-explanation
    ^-  manx
    ;div.explanation(style "background: #f5f3ff; padding: 15px; margin: 10px 0; border-radius: 5px; border-left: 4px solid #8b5cf6;")
      ;p: Data-Driven Grid System Pattern generates complex grid layouts algorithmically
      ;ul
        ;li: Pixel-perfect positioning with coordinate-based placement
        ;li: Dynamic tile generation from data structures
        ;li: Responsive grid containers with calculated dimensions
        ;li: Interactive elements with hover effects and links
      ==
    ==
  ++  render-simple-grid
    ^-  manx
    =/  tiles=(map [x=@ud y=@ud] [color=@t content=tape])
      %-  malt
      :~  [[0 0] ['#3b82f6' "A"]]
          [[1 0] ['#ef4444' "B"]]
          [[0 1] ['#10b981' "C"]]
          [[1 1] ['#f59e0b' "D"]]
      ==
    ;div.grid-demo
      ;h4: Simple 2x2 Grid
      ;+  (grid-system tiles [2 2])
    ==
  ++  render-interactive-grid
    ^-  manx
    =/  tiles=(map [x=@ud y=@ud] [color=@t content=tape])
      %-  malt
      :~  [[0 0] ['#6366f1' "🏠"]]
          [[2 0] ['#ec4899' "🌟"]]
          [[1 1] ['#14b8a6' "⚡"]]
          [[3 1] ['#f97316' "🚀"]]
          [[0 2] ['#8b5cf6' "💎"]]
          [[2 2] ['#06b6d4' "🎯"]]
      ==
    ;div.grid-demo
      ;h4: Interactive Tile Grid
      ;+  (interactive-grid-system tiles [4 3])
    ==
  ++  render-responsive-grid
    ^-  manx
    =/  tiles=(map [x=@ud y=@ud] [color=@t content=tape])
      %-  malt
      :~  [[0 0] ['#1f2937' "Header"]]
          [[1 0] ['#1f2937' "Nav"]]
          [[0 1] ['#374151' "Content"]]
          [[1 1] ['#4b5563' "Sidebar"]]
          [[0 2] ['#6b7280' "Footer"]]
          [[1 2] ['#6b7280' "Extra"]]
      ==
    ;div.grid-demo
      ;h4: Layout Grid System
      ;+  (layout-grid-system tiles [2 3])
    ==
  ::
  ++  grid-system
    |=  [tiles=(map [x=@ud y=@ud] [color=@t content=tape]) dimensions=[w=@ud h=@ud]]
    ^-  manx
    ;div.grid-container
      =style  "position: relative; width: {<(mul w.dimensions 80)>}px; height: {<(mul h.dimensions 80)>}px; background: #f8fafc; border: 2px solid #e2e8f0; border-radius: 8px; margin: 15px 0;"
      ;*  %+  turn  ~(tap by tiles)
          |=  [[x=@ud y=@ud] [color=@t content=tape]]
          (tile [x y] color content)
    ==
  ::
  ++  interactive-grid-system
    |=  [tiles=(map [x=@ud y=@ud] [color=@t content=tape]) dimensions=[w=@ud h=@ud]]
    ^-  manx
    ;div.interactive-grid-container
      =style  "position: relative; width: {<(mul w.dimensions 70)>}px; height: {<(mul h.dimensions 70)>}px; background: #1e293b; border: 2px solid #334155; border-radius: 12px; margin: 15px 0; overflow: hidden;"
      ;*  %+  turn  ~(tap by tiles)
          |=  [[x=@ud y=@ud] [color=@t content=tape]]
          (interactive-tile [x y] color content)
    ==
  ::
  ++  layout-grid-system
    |=  [tiles=(map [x=@ud y=@ud] [color=@t content=tape]) dimensions=[w=@ud h=@ud]]
    ^-  manx
    ;div.layout-grid-container
      =style  "position: relative; width: {<(mul w.dimensions 120)>}px; height: {<(mul h.dimensions 60)>}px; background: #0f172a; border: 2px solid #1e293b; border-radius: 8px; margin: 15px 0;"
      ;*  %+  turn  ~(tap by tiles)
          |=  [[x=@ud y=@ud] [color=@t content=tape]]
          (layout-tile [x y] color content)
    ==
  ::
  ++  tile
    |=  [[x=@ud y=@ud] color=@t content=tape]
    ^-  manx
    =/  left=@ud  (mul x 80)
    =/  top=@ud   (mul y 80)
    ;div.tile
      =style  "position: absolute; top: {<top>}px; left: {<left>}px; width: 70px; height: 70px; background: {(trip color)}; color: white; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 24px; border-radius: 6px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);"
      : {content}
    ==
  ::
  ++  interactive-tile
    |=  [[x=@ud y=@ud] color=@t content=tape]
    ^-  manx
    =/  left=@ud  (mul x 70)
    =/  top=@ud   (mul y 70)
    ;div.interactive-tile
      =style  "position: absolute; top: {<top>}px; left: {<left>}px; width: 60px; height: 60px; background: {(trip color)}; color: white; display: flex; align-items: center; justify-content: center; font-size: 20px; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.3); cursor: pointer; transition: all 0.3s ease; user-select: none;"
      =onmouseover  "this.style.transform='scale(1.1) rotate(5deg)'; this.style.zIndex='10';"
      =onmouseout   "this.style.transform='scale(1) rotate(0deg)'; this.style.zIndex='1';"
      =onclick      "this.style.animation='pulse 0.3s ease';"
      : {content}
    ==
  ::
  ++  layout-tile
    |=  [[x=@ud y=@ud] color=@t content=tape]
    ^-  manx
    =/  left=@ud  (mul x 120)
    =/  top=@ud   (mul y 60)
    ;div.layout-tile
      =style  "position: absolute; top: {<top>}px; left: {<left>}px; width: 110px; height: 50px; background: {(trip color)}; color: #e2e8f0; display: flex; align-items: center; justify-content: center; font-weight: 500; font-size: 12px; border-radius: 4px; border: 1px solid #475569;"
      : {content}
    ==
  --
::
::  Pattern #17: CSS-in-Tape Embedding Pattern
::  Generate inline CSS from tape literals and embed directly in manx
::
++  render-css-in-tape-pattern
  |=  title=tape
  ^-  manx
  ;div
    ;h3: {title}
    ;div
      ;style
        ; .profile-widget {
        ;   border: 1px solid #d1d5db;
        ;   padding: 1.5em;
        ;   margin: 1em 0;
        ;   border-radius: 8px;
        ;   background: #f9fafb;
        ; }
        ; .profile-headline {
        ;   display: flex;
        ;   align-items: center;
        ;   gap: 1em;
        ;   margin-bottom: 1em;
        ; }
      ==
      ;div.profile-widget
        ;div.profile-headline
          ;div.avatar(style "width: 48px; height: 48px; background: linear-gradient(45deg, #3b82f6, #06b6d4); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold;"): ~Z
          ;div.info
            ;h3: ~zod
            ;p: Ship Captain & System Administrator
          ==
        ==
        ;div.content
          ;p: This demonstrates CSS-in-Tape pattern with embedded styles using feather-style syntax.
          ;p.winner: This text uses the animated styles from the head! 🏆
        ==
      ==
    ==
  ==
::
::  Pattern #18: Conditional Marl Construction with Unit Types (Simple Version)
::  Use unit types to conditionally construct content
::
++  render-conditional-marl-pattern
  |=  title=tape
  ^-  manx
  ;div
    ;h3: {title}
    ;div
      ;h4: Profile with Optional Bio
      ;+  (simple-profile `'I love distributed systems!' "~zod")
      ;h4: Profile without Bio
      ;+  (simple-profile ~ "~bus")
      ;h4: Optional List Demo
      ;+  (optional-list `~["alpha" "beta" "gamma"])
      ;h4: Empty List Demo
      ;+  (optional-list ~)
    ==
  ==
::
++  simple-profile
  |=  [bio=(unit @t) name=tape]
  ^-  manx
  ;div.profile(style "border: 1px solid #ccc; padding: 1rem; margin: 0.5rem 0;")
    ;h5: {name}
    ;+  ?~  bio
          ;p: No bio available
        ;p: Bio: {(trip u.bio)}
  ==
::
++  optional-list
  |=  items=(unit (list tape))
  ^-  manx
  ;div.list-demo(style "background: #f5f5f5; padding: 1rem; border-radius: 4px;")
    ;+  ?~  items
          ;p: No items to display
        ;div
          ;p: Items:
          ;*  %+  turn  u.items
              |=  item=tape
              ;div(style "margin: 0.25rem 0; padding: 0.25rem; background: white; border-radius: 2px;"): {item}
        ==
  ==
::
::  Pattern #19: Dynamic Status Indicator Pattern
::  Generate real-time status displays with computed values
::
++  render-dynamic-status-pattern
  |=  title=tape
  ^-  manx
  ;div
    ;h3: {title}
    ;div
      ;h4: Sales Status (Authenticated)
      ;+  (simple-status 7 10 %.y)
      ;h4: Sales Status (Unauthenticated)
      ;+  (simple-status 45 100 %.n)
    ==
  ==
::
++  simple-status
  |=  [sold=@ud total=@ud authenticated=?]
  ^-  manx
  =/  available=@ud  (sub total sold)
  =/  percentage=@ud  ?:(=(total 0) 0 (div (mul sold 100) total))
  ;div(style "border: 1px solid #ccc; padding: 1rem; margin: 0.5rem 0; border-radius: 4px;")
    ;p: Sold: {(scow %ud sold)} / {(scow %ud total)} ({(scow %ud percentage)}%)
    ;p: Available: {(scow %ud available)}
    ;+  ?:  authenticated
          ;button: Buy Now
        ;p: Login to purchase
  ==
::
::  Pattern #20: SVG Sigil Generation Pattern
::  Generate unique SVG avatars directly from Urbit ship names
::
++  render-svg-sigil-pattern
  |=  title=tape
  ^-  manx
  ;div
    ;h3: {title}
    ;div
      ;h4: Ship Sigils
      ;div(style "display: flex; gap: 1rem; flex-wrap: wrap;")
        ;+  (simple-sigil ~zod)
        ;+  (simple-sigil ~nec)
        ;+  (simple-sigil ~bud)
        ;+  (simple-sigil ~wes)
      ==
      ;h4: Generated Patterns
      ;div(style "display: flex; gap: 1rem; flex-wrap: wrap;")
        ;+  (pattern-sigil ~sampel-palnet)
        ;+  (pattern-sigil ~dovryp-toblug)
      ==
    ==
  ==
::
++  simple-sigil
  |=  =ship
  ^-  manx
  =/  ship-num=@ud  (mod (mug ship) 16)
  =/  size=tape  "64"
  =/  color1=tape  (get-ship-color ship-num)
  =/  color2=tape  (get-ship-secondary ship-num)
  ;div(style "text-align: center; margin: 0.5rem;")
    ;+  (svg-sigil ship-num size color1 color2)
    ;p(style "margin-top: 0.5rem; font-size: 0.75rem;"): {(scow %p ship)}
  ==
::
++  pattern-sigil
  |=  =ship
  ^-  manx
  =/  ship-num=@ud  (mod (mug ship) 64)
  =/  size=tape  "80"
  =/  color1=tape  (get-ship-color ship-num)
  =/  color2=tape  (get-ship-secondary ship-num)
  ;div(style "text-align: center; margin: 0.5rem;")
    ;+  (complex-svg-sigil ship-num size color1 color2)
    ;p(style "margin-top: 0.5rem; font-size: 0.75rem;"): {(scow %p ship)}
  ==
::
++  svg-sigil
  |=  [ship-num=@ud size=tape color1=tape color2=tape]
  ^-  manx
  ;svg
    =width  size
    =height  size
    =viewBox  "0 0 128 128"
    =xmlns  "http://www.w3.org/2000/svg"
    ;rect(fill color1, width "128", height "128");
    ;+  (get-ship-shape ship-num color2)
  ==
::
++  complex-svg-sigil
  |=  [ship-num=@ud size=tape color1=tape color2=tape]
  ^-  manx
  ;svg
    =width  size
    =height  size
    =viewBox  "0 0 128 128"
    =xmlns  "http://www.w3.org/2000/svg"
    ;rect(fill color1, width "128", height "128");
    ;+  (get-complex-shape ship-num color2)
  ==
::
++  get-ship-color
  |=  ship-num=@ud
  ^-  tape
  =/  colors=(list tape)
    ~["#3b82f6" "#ef4444" "#10b981" "#f59e0b" "#8b5cf6" "#ec4899" "#06b6d4" "#84cc16"]
  (snag (mod ship-num (lent colors)) colors)
::
++  get-ship-secondary
  |=  ship-num=@ud
  ^-  tape
  =/  colors=(list tape)
    ~["#ffffff" "#f1f5f9" "#fef3c7" "#ecfdf5" "#fdf2f8" "#f0f9ff" "#f7fee7" "#faf5ff"]
  (snag (mod ship-num (lent colors)) colors)
::
++  get-ship-shape
  |=  [ship-num=@ud color=tape]
  ^-  manx
  ?+  (mod ship-num 4)
    ;circle(cx "64", cy "64", r "32", fill color);
  %1
    ;rect(x "32", y "32", width "64", height "64", fill color);
  %2
    ;polygon(points "64,20 100,80 28,80", fill color);
  %3
    ;ellipse(cx "64", cy "64", rx "40", ry "20", fill color);
  ==
::
++  get-complex-shape
  |=  [ship-num=@ud color=tape]
  ^-  manx
  ?+  (mod ship-num 6)
    ;g
      ;circle(cx "32", cy "32", r "16", fill color);
      ;circle(cx "96", cy "96", r "16", fill color);
    ==
  %1
    ;g
      ;rect(x "16", y "16", width "32", height "32", fill color);
      ;rect(x "80", y "80", width "32", height "32", fill color);
      ;rect(x "48", y "48", width "32", height "32", fill color);
    ==
  %2
    ;g
      ;polygon(points "64,8 80,40 48,40", fill color);
      ;polygon(points "64,120 80,88 48,88", fill color);
    ==
  %3
    ;g
      ;circle(cx "64", cy "32", r "12", fill color);
      ;rect(x "52", y "52", width "24", height "24", fill color);
      ;circle(cx "64", cy "96", r "12", fill color);
    ==
  %4
    ;g
      ;ellipse(cx "32", cy "64", rx "20", ry "40", fill color);
      ;ellipse(cx "96", cy "64", rx "20", ry "40", fill color);
    ==
  %5
    ;g
      ;polygon(points "64,16 88,52 40,52", fill color);
      ;polygon(points "64,112 88,76 40,76", fill color);
      ;circle(cx "64", cy "64", r "8", fill color);
    ==
  ==
::
::  Pattern #21: Meta Tag Generation Pattern
::  Generate comprehensive social media and SEO meta tags
::
++  render-meta-tag-pattern
  |=  title=tape
  ^-  manx
  ;div
    ;h3: {title}
    ;div
      ;h4: SEO & Social Media Meta Tags
      ;div(style "background: #f3f4f6; border-radius: 8px; padding: 1rem; font-family: monospace; font-size: 0.875rem;")
        ;*  %:  render-meta-tags
                "Understanding Urbit: A Personal Server Platform"
                "Learn about Urbit, a clean-slate OS and network for the 21st century. Discover how to run your own personal server that you actually own."
                ~sampel-palnet
                "https://urbit.org/images/urbit-social.jpg"
                "https://urbit.org/blog/understanding-urbit"
            ==
      ==
      ;h4: Minimal Meta Tags
      ;div(style "background: #f3f4f6; border-radius: 8px; padding: 1rem; margin-top: 1rem; font-family: monospace; font-size: 0.875rem;")
        ;*  %:  render-meta-tags
                "Quick Guide"
                "A brief introduction"
                ~zod
                ""
                "/guide"
            ==
      ==
    ==
  ==
::
++  render-meta-tags
  |=  $:  title=tape
          description=tape
          author=@p
          image=tape
          url=tape
      ==
  ^-  marl
  :~  ;meta(charset "utf-8");
      ;meta(name "viewport", content "width=device-width, initial-scale=1");
      ;meta(name "description", content description);
      ;meta(property "og:title", content title);
      ;meta(property "og:description", content description);
      ;meta(property "og:image", content image);
      ;meta(property "og:url", content url);
      ;meta(property "og:type", content "article");
      ;meta(property "og:site_name", content "Urbit");
      ;meta(property "og:article:author:username", content (scow %p author));
      ;meta(name "twitter:card", content "summary_large_image");
      ;meta(name "twitter:title", content title);
      ;meta(name "twitter:description", content description);
      ;meta(name "twitter:image", content image);
  ==
::
::  Pattern #22: Inline CSS Generation Pattern
::  Generate inline CSS from Hoon data structures
::
++  render-inline-css-pattern
  |=  title=tape
  ^-  manx
  ;div
    ;h3: {title}
    ;div
      ;h4: Dynamic Inline Styles
      ;+  %:  styled-element
              %div
              %-  ~(gas by *(map tape tape))
              ~[["background-color" "#3b82f6"] ["color" "white"] ["padding" "1rem"] ["border-radius" "0.5rem"]]
              ;div: Blue Box with White Text
          ==
      ;+  %:  styled-element
              %button
              %-  ~(gas by *(map tape tape))
              ~[["background" "linear-gradient(90deg, #8b5cf6, #ec4899)"] ["color" "white"] ["padding" "0.75rem 1.5rem"] ["border" "none"] ["border-radius" "9999px"] ["cursor" "pointer"]]
              ;button: Gradient Button
          ==
      ;h4: Generated Style Properties
      ;div
        ;*  %+  turn  ~[["margin" "2rem"] ["padding" "1rem"] ["font-size" "1.2rem"]]
            |=  [prop=tape val=tape]
            ;div(style "padding: 0.25rem; background: #f9fafb; margin: 0.125rem; font-family: monospace;"): {prop}: {val};
      ==
    ==
  ==
::
++  inline-styles
  |=  s=(map tape tape)
  ^-  tape
  %-  zing
  %+  join  " "
  %+  turn  ~(tap by s)
  |=  [k=tape v=tape]
  :(weld k ": " v ";")
::
++  styled-element
  |=  [tag=@t styles=(map tape tape) content=manx]
  ^-  manx
  ?~  styles
    content
  %=    content
      a.g
    %+  snoc  a.g.content
    ['style' (inline-styles styles)]
  ==
::
::  Pattern #23: Calendar Date Grid Generation (Bottom-up approach)
::  Start with the smallest working piece
::
++  render-calendar-pattern
  |=  title=tape
  ^-  manx
  ;div
    ;h3: {title}
    ;div
      ;h4: November 2024 Calendar Grid
      ;div.b1.bd1.br2.p3
        ;+  calendar-header
        ;+  (calendar-week (gulf 1 7))
        ;+  (calendar-week (gulf 8 14))
      ==
    ==
  ==
::
::
++  calendar-header
  ^-  manx
  ;div.fr.b2.bd1
    ;*  %+  turn  ~["SUN" "MON" "TUE" "WED" "THU" "FRI" "SAT"]
        |=  day=tape
        ;div.grow.tc.bold.f2.s-1: {day}
  ==
::
++  calendar-week
  |=  days=(list @ud)
  ^-  manx
  ;div.fr
    ;*  %+  turn  days
        |=  day=@ud
        (calendar-cell day)
  ==
::
++  calendar-cell
  |=  day=@ud
  ^-  manx
  ;div.bd1.p3.fc
    =style  "min-height: 80px; width: 14.28%; flex: 0 0 14.28%;"
    ;div.bold.f1: {(scow %ud day)}
    ;+  ?+  day  ;/("")
          %3  (event-badge "Meet" %blue)
          %9  (event-badge "Party" %yellow)
        ==
  ==
::
++  event-badge
  |=  [text=tape color=@tas]
  ^-  manx
  =/  badge-classes=tape
    ?+  color  "p1 br1 s-2"
      %blue    "b-4 f-4 p1 br1 s-2"
      %yellow  "b-2 f-2 p1 br1 s-2"
      %green   "b-3 f-3 p1 br1 s-2"
    ==
  ;div(class badge-classes): {text}
::
::  Pattern #24: Safe Text Node Pattern
::  Handle atomic vs complex text content with proper escaping
::
++  render-safe-text-pattern
  |=  title=tape
  ^-  manx
  ;div
    ;h3: {title}
    ;div
      ;h4: Atomic vs Complex Text Content Handling
      ;+  %:  safe-text-demo
              "Simple Text"
              ['bold' "Bold Text"]
              ['italics' "Italic Text"]
              ['code' "inline-code"]
              ['ship' ~sampel-palnet]
          ==
    ==
  ==
::
++  safe-text-demo
  |=  $:  simple=tape
           bold-content=[type=@tas text=tape]
           italic-content=[type=@tas text=tape]
           code-content=[type=@tas text=tape]
           ship-content=[type=@tas ship=@p]
       ==
  ^-  manx
  ;div.fc.g3.p3.b1.br2
    ;div
      ;h5: Atomic Text (Simple):
      ;+  (safe-inline-text simple)
    ==
    ;div
      ;h5: Complex Text (Bold):
      ;+  (safe-inline-element bold-content)
    ==
    ;div
      ;h5: Complex Text (Italics):
      ;+  (safe-inline-element italic-content)
    ==
    ;div
      ;h5: Complex Text (Code):
      ;+  (safe-inline-element code-content)
    ==
    ;div
      ;h5: Complex Text (Ship):
      ;+  (safe-ship-element ship-content)
    ==
  ==
::
++  safe-inline-text
  |=  text=tape
  ^-  manx
  ::  For atomic text - simple escaping and span wrapper
  ;span.safe-text: {text}
::
++  safe-inline-element
  |=  [type=@tas content=tape]
  ^-  manx
  ::  For complex inline content with proper element types
  ?+  type  ;span: {content}
      %bold
    ;strong.bold: {content}
      %italics
    ;em.italic: {content}
      %code
    ;code.mono.b2.p1.br1: {content}
  ==
::
++  safe-ship-element
  |=  [type=@tas ship=@p]
  ^-  manx
  ::  For ship content with proper formatting
  ?+  type  ;span: {(scow %p ship)}
      %ship
    ;span.ship.mono.f-4: {(scow %p ship)}
  ==
::
++  tlon-style-mixed-inlines
  ^-  manx
  ::  Demonstrates real Tlon pattern: mixed atomic + complex inlines
  ;div.mono.s-1
    ;span: "Message from "
    ;strong.bold: "Important User"
    ;span: " ("
    ;span.ship.f-4: "~sampel-palnet"
    ;span: "): "
    ;code.b2.p1.br1: "status update"
  ==
--