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
--