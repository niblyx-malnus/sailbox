# Sail Guide

Comprehensive guide to Sail patterns, `en-xml:html`, and development approaches for building sophisticated web interfaces in Hoon.

## What is Sail?

Sail is Urbit's domain-specific language (DSL) for composing HTML and XML structures directly in Hoon. Unlike external templating systems, Sail is deeply integrated into Hoon, allowing you to generate HTML with arbitrary Hoon expressions and interpolation.

## Core Data Structures

Sail produces `$manx` structures representing XML/HTML hierarchical data:

```hoon
+$  mane  $@(@tas [@tas @tas])                    ::  XML name+space
+$  manx  $~([[%$ ~] ~] [g=marx c=marl])          ::  dynamic XML node
+$  marl  (list manx)                             ::  XML node list
+$  mart  (list [n=mane v=tape])                  ::  XML attributes
+$  marx  $~([%$ ~] [n=mane a=mart])              ::  dynamic XML tag
```

- `$manx`: Single XML/HTML node with tag (`g=marx`) and contents (`c=marl`)
- `$marl`: List of XML nodes (children)
- `$mart`: List of attributes (key-value pairs)
- `$marx`: Tag with name and attributes

## `en-xml:html` Function

### Overview

`en-xml:html` is the core function in Urbit's `zuse.hoon` library for rendering Sail structures (`$manx`) into HTML text. It's essential for converting Hoon's functional HTML composition into actual HTML strings that can be served to web browsers.

### Function Signature

```hoon
++  en-xml:html
  |=(a=manx `tape`(apex a ~))
```

Takes a `$manx` (XML/HTML node structure) and returns a `tape` (string) of HTML.

### Basic Usage

#### Wide Form (Single Line)
```hoon
> (en-xml:html ;p:"Hello World")
"<p>Hello World</p>"

> (crip (en-xml:html ;div(class "container"):"Content"))
'<div class="container">Content</div>'
```

#### Tall Form (Multi-line)
```hoon
> %-  en-xml:html
  ;html
    ;head
      ;title: My Page
    ==
    ;body
      ;h1: Welcome
      ;p: This is content
    ==
  ==
```

### Key Features

#### Automatic Sanitization

The function automatically escapes special HTML characters to prevent XSS attacks:

```hoon
> (crip (en-xml:html ;p: <script>alert('XSS')</script>))
'<p>&lt;script&gt;alert('XSS')&lt;/script&gt;</p>'

> (crip (en-xml:html ;div(onclick "alert('xss')"):"Click me"))
'<div onclick="alert('xss')">Click me</div>'
```

#### Special Tag Handling

- Self-closing tags like `<br />` and `<img />` are handled correctly
- Script and style tags preserve their content without escaping

```hoon
> (crip (en-xml:html ;br;))
'<br />'

> (crip (en-xml:html ;img@"/pic.png";))
'<img src="/pic.png" />'
```

## Basic Syntax Patterns

### Tag Structure
```hoon
;html
  ;head
    ;title: Page Title
    ;meta(charset "utf-8");
  ==
  ;body
    ;h1: Welcome!
    ;p: This is a paragraph
  ==
==
```

### Tag Closing Methods
- **Empty tags**: `;div;` → `<div></div>`
- **Filled tags**: `;h1: Title` → `<h1>Title</h1>`
- **Nested tags**: Use `==` to close containers with children

### Attribute Patterns

1. **Wide form**: `;div(class "container", id "main")`
2. **Tall form**:
   ```hoon
   ;div
     =class  "container"
     =id     "main"
   ```
3. **Shortcuts**:
   - IDs: `;nav#header` → `<nav id="header">`
   - Classes: `;h1.title` → `<h1 class="title">`
   - Images: `;img@"pic.png";` → `<img src="pic.png"/>`
   - Links: `;a/"url": text` → `<a href="url">text</a>`

### Interpolation
```hoon
=/  name=tape  "World"
;p: Hello {name}!
```

## Why Tall Form Matters

### 1. **Readability and Structure**

Tall form naturally mirrors HTML's hierarchical structure, making complex layouts readable:

```hoon
:: Wide form - hard to read for complex structures
> (en-xml:html ;div(class "container");div(class "row");div(class "col"):"Content")

:: Tall form - clear hierarchy
> %-  en-xml:html
  ;div(class "container")
    ;div(class "row")
      ;div(class "col")
        ;+  "Content"
      ==
    ==
  ==
```

### 2. **Interpolation and Logic**

Tall form allows seamless integration of Hoon expressions:

```hoon
> =/  items=(list tape)  ~["apple" "banana" "orange"]
  %-  en-xml:html
  ;ul
    ;*  %+  turn  items
        |=  item=tape
        ;li: {item}
  ==
```

### 3. **Attribute Management**

Tall form provides cleaner attribute syntax for multiple attributes:

```hoon
:: Wide form - gets unwieldy
;div(id "main", class "container active", data-value "123", style "color: red")

:: Tall form - organized and maintainable
;div
  =id         "main"
  =class      "container active"
  =data-value "123"
  =style      "color: red"
  ;p: Content here
==
```

### 4. **Component Composition**

Tall form enables clean component composition patterns:

```hoon
++  page-template
  |=  [title=tape content=manx]
  ^-  manx
  ;html
    ;head
      ;title: {title}
      ;meta(charset "utf-8");
    ==
    ;body
      ;nav
        ;a/"/"         : Home
        ;a/"/about"    : About
        ;a/"/contact"  : Contact
      ==
      ;main
        ;+  content
      ==
    ==
  ==

:: Usage
> %-  en-xml:html
  %+  page-template  "My Site"
  ;div
    ;h1: Welcome to my site
    ;p: This is the homepage
  ==
```

## Advanced Sail Runes

### `;+` Miclus - Conditional Logic
```hoon
;div
  ;+  ?:  logged-in
        ;p: Welcome back!
      ;p: Please log in
==
```

### `;*` Mictar - List Rendering
```hoon
;ul
  ;*  %+  turn  items
      |=  item=@t
      ;li: {(trip item)}
==
```

### `;=` Mictis - Create Marl
```hoon
=/  buttons=marl
  ;=  ;button: Save
      ;button: Cancel
  ==
;div
  ;*  buttons
==
```

### `;/` Micfas - Tape to Manx
```hoon
;p
  ;+  ;/  "Plain text content"
==
```

## Component Patterns

### Functional Components
```hoon
++  render-button
  |=  [text=tape class=tape]
  ^-  manx
  ;button(class class): {text}

++  render-list
  |=  items=(list tape)
  ^-  manx
  ;ul
    ;*  %+  turn  items
        |=  item=tape
        ;li: {item}
  ==
```

### Page Composition
```hoon
++  page
  |=  [title=tape content=marl]
  ^-  manx
  ;html
    ;head ;title: {title} ==
    ;body ;*  content ==
  ==

++  nav-item
  |=  [href=tape text=tape active=?]
  ^-  manx
  ;li(class ?:(active "active" ""))
    ;a/"{href}": {text}
  ==
```

### Data-Driven Rendering
```hoon
++  render-table
  |=  [headers=(list tape) rows=(list (list tape))]
  ^-  manx
  ;table
    ;thead
      ;tr
        ;*  %+  turn  headers
            |=(h=tape ;th: {h})
      ==
    ==
    ;tbody
      ;*  %+  turn  rows
          |=  row=(list tape)
          ;tr
            ;*  %+  turn  row
                |=(cell=tape ;td: {cell})
          ==
    ==
  ==
```

## Common Patterns

### Dynamic Lists
```hoon
> =/  users=(list @p)  ~[~zod ~nec ~bud]
  %-  en-xml:html
  ;ul.user-list
    ;*  %+  turn  users
        |=  user=@p
        ;li
          ;a/"/user/{<user>}": {<user>}
        ==
  ==
```

### Conditional Rendering
```hoon
> =/  logged-in=?  %.y
  %-  en-xml:html
  ;div
    ;+  ?:  logged-in
          ;span: Welcome back!
        ;a/"/login": Please log in
  ==
```

### Form Generation
```hoon
> %-  en-xml:html
  ;form(method "post", action "/submit")
    ;label(for "name"): Name:
    ;input(type "text", id "name", name "name");
    ;button(type "submit"): Submit
  ==
```

## Advanced Component Principles

### Composability over Complexity

Build components that combine naturally rather than trying to create monolithic solutions:

- **Single-purpose functions** that do one thing well
- **Data-driven design** where components adapt to input structure
- **Functional composition** using `|=` gates that return `manx`
- **Nested responsibility** where complex components delegate to simpler ones

### State as Data

Treat UI state explicitly as data that flows through your components:

- **Loading states** as boolean flags that change rendering
- **Default values** passed as parameters rather than hardcoded
- **Validation errors** as structured data (maps, lists) that components interpret
- **User interactions** that return new state rather than mutating existing state

### Manx as a Transformation Target

Think of Sail structures as data you can manipulate programmatically:

- **Post-generation modification** - build base structure, then apply changes
- **Conditional attributes** - add/remove attributes based on state
- **Content injection** - insert computed values into static templates
- **Tree traversal** - find and modify specific elements in complex structures

### Progressive Component Development

Start simple and add complexity only when needed:

- **Base case first** - make the simplest version work
- **Add parameters gradually** - extend with optional features
- **Extract when duplicating** - factor out common patterns only after repetition
- **Test each addition** - verify every enhancement works in isolation

### Consistent Interface Patterns

Establish conventions that make components predictable:

- **Parameter order** - name, required flag, default value, options
- **Return types** - always return `manx` for renderable components
- **Naming schemes** - verbs for actions, nouns for data, adjectives for variants
- **Error handling** - explicit error states rather than crashes

### Separation of Concerns

Keep different responsibilities in different functions:

- **Presentation logic** in Sail components
- **Business logic** in pure Hoon functions
- **State management** in data transformation functions
- **Integration points** clearly marked and isolated

### CSS Integration
```hoon
++  style
  ^~
  %-  trip
  '''
  body { background: black; color: white; }
  .container { max-width: 800px; margin: auto; }
  .active { background: #007acc; }
  '''
```

## Integration with Urbit Ecosystem

### Serving HTML via Eyre

```hoon
:: In a Gall agent's on-peek arm
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+  path  ~
    [%x %page ~]
    =/  html-manx=manx
      ;html
        ;body
          ;h1: Hello from Urbit
        ==
      ==
    =/  html-tape=tape  (en-xml:html html-manx)
    =/  html-cord=@t    (crip html-tape)
    ``html+!>(html-cord)
  ==
```

### With Rudder Framework

```hoon
^-  (page:rudder data command)
|_  [=bowl:gall * data]
++  argue  |=([headers body] ...)  :: Parse request
++  final  (alert:rudder url build) :: Handle response
++  build
  |=  $:  arg=(list [k=@t v=@t])
          msg=(unit [gud=? txt=tape])
      ==
  ^-  reply:rudder
  |^  [%page page]
  ++  page
    ^-  manx
    ;html
      ;head
        ;title: My App
      ==
      ;body
        ;h1: Welcome to my Rudder app
        ;*  ?~  msg  ~
            :_  ~
            ?:  gud.u.msg
              ;div.success: {txt.u.msg}
            ;div.error: {txt.u.msg}
      ==
    ==
  --
```

### Mark Files
- `%hymn`: Complete HTML documents (`$manx`)
- `%elem`: XML fragments (`$manx`)
- `%html`: Rendered HTML text (`@t`)

## Utility Libraries

### html-utils.hoon - DOM Manipulation
jQuery-like operations on manx structures:

```hoon
:: Attribute manipulation
++  put  |=([n=mane v=tape] ...)  :: Set attribute
++  get  |=([n=mane] ...)         :: Get attribute
++  del  |=([n=mane] ...)         :: Delete attribute

:: CSS-like selectors
++  sid  |=(i=tape ...)           :: Match by ID
++  cas  |=(c=tape ...)           :: Match by class
++  tag  |=(n=mane ...)           :: Match by tag

:: Tree traversal
++  get  |=(p=path ...)           :: Get element at path
++  put  |=([p=path m=manx] ...)  :: Replace element
++  wit  |=([=con =tan] ...)      :: Transform matching descendants
```

### manx-utils.hoon - Tree Operations
Comprehensive XML/manx manipulation by ~tinnus-napbus:

```hoon
:: Tree traversal
++  pre-flatten    :: Depth-first flattening
++  post-flatten   :: Post-order flattening

:: Text operations
++  pre-get-text   :: Extract all text content
++  search-text    :: Find text within tree

:: Structure validation
++  whitelisted    :: Filter by allowed tags
++  blacklisted    :: Remove forbidden tags
++  prune-tag      :: Remove specific tags
++  prune-attrs    :: Remove specific attributes
```

### json-utils.hoon - Data Integration
Safe JSON handling and manipulation:

```hoon
:: Path-based access
++  get-path       :: Access nested JSON values
++  put-path       :: Set nested JSON values

:: Type conversion
++  safe-convert   :: Safe type coercion
++  extract-list   :: Extract JSON arrays

:: CRUD operations
++  merge-objects  :: Combine JSON objects
++  filter-props   :: Filter object properties
```

## Web Component Integration

e.g.

```hoon
++  col-split
  '''
  class ColSplit extends HTMLElement {
      constructor() {
          super();
          this.attachShadow({ mode: 'open' });
          // ... component logic
      }
  }
  customElements.define('col-split', ColSplit);
  '''
```

## Performance Considerations

1. **Pre-render when possible**: For static content, render once and cache the result
2. **Use tape, not cord**: `en-xml:html` returns a tape - only convert to cord when necessary
3. **Batch operations**: Build complete structures before rendering rather than concatenating HTML strings

## Component Development Strategy

### 1. Start with Observable Output
- Build simple working components first
- Verify each change produces visible results
- Test in isolation before composition

### 2. Extract Proven Patterns
- Identify repeated UI structures
- Factor out when duplication emerges
- Ensure extracted components are self-contained

### 3. Build Component Library
Focus areas for reusable components:
- **Form Components** - Validation, error states, field types
- **Data Display** - Tables, cards, lists with sorting/filtering
- **Interactive Patterns** - Modals, tabs, accordions
- **Layout Components** - Grids, containers, responsive patterns

### 4. Test Under Real Use
- Use components in actual applications
- Refine based on real-world pressure
- Maintain backwards compatibility where possible

## Unique Advantages of Sail

1. **Functional HTML** - No string concatenation risks, full type safety
2. **Deep Hoon Integration** - Access to entire language for logic
3. **Component Reusability** - Functions naturally become reusable components
4. **Type Safety** - Compile-time guarantees about structure validity
5. **Urbit-Native** - Deep integration with Gall, Eyre, and the Urbit stack

## Development Resources

### Key Documentation
- [Sail Guide](https://developers.urbit.org/guides/additional/sail) - Official Sail documentation
- [Sail/XML Runes](https://developers.urbit.org/reference/hoon/rune/mic) - Complete rune reference
- [App School I](https://developers.urbit.org/guides/core/app-school) - Gall application development

### Example Applications
- Ahoy (ping tracker) - Real-world Sail application
- Pals (ship list) - CRUD patterns and state management
- Groups - Complex UI interactions and data binding

## Summary

`en-xml:html` is the bridge between Hoon's functional HTML composition and the text-based HTML that browsers understand. When combined with Sail's tall form syntax, it provides a powerful, type-safe way to generate HTML that:

- Prevents XSS vulnerabilities through automatic escaping
- Maintains readability through hierarchical structure
- Enables component reusability through functional composition
- Integrates seamlessly with Urbit's web serving infrastructure

The tall form syntax is particularly important because it:
- Makes complex HTML structures readable and maintainable
- Allows natural integration of Hoon logic and interpolation
- Provides clean syntax for attributes and nested structures
- Enables functional component patterns that are impossible in traditional templating

Sail represents a unique approach where HTML generation is functional, typed, and deeply integrated with the rest of the Urbit development experience.
