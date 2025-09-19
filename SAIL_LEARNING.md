# Sail Learning Documentation

Comprehensive guide to Sail patterns, resources, and development approaches for building sophisticated web interfaces in Hoon.

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

## Real-World Application Patterns

### Form Handling
```hoon
;form(method "post")
  ;input(type "text", name "who", placeholder "~sampel");
  ;button(type "submit", name "what", value "add-watch"): "+"
==
```

### Dynamic Content with State
```hoon
++  login-form
  |=  [logged-in=? error=(unit tape)]
  ^-  manx
  ?:  logged-in
    ;div.welcome: Welcome back!
  ;div.login
    ;+  ?~  error  ;span;
        ;span.error: {u.error}
    ;form(method "post")
      ;input(type "text", name "username");
      ;input(type "password", name "password");
      ;button(type "submit"): Login
    ==
  ==
```

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

## Web Component Integration

Following grubbery's pattern for custom web components:

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

## Integration with Urbit Ecosystem

### Mark Files
- `%hymn`: Complete HTML documents (`$manx`)
- `%elem`: XML fragments (`$manx`)
- `%html`: Rendered HTML text (`@t`)

### Eyre Integration
- Automatic conversion of `%hymn` marks to HTML
- Integration with Rudder for web applications
- Support for server-side rendering and API endpoints

### Rudder Framework
```hoon
^-  (page:rudder data command)
|_  [=bowl:gall * data]
++  argue  |=([headers body] ...)  :: Parse request
++  final  (alert:rudder url build) :: Handle response
++  build  |=([args msg] ...)      :: Render page
```

## Development Resources

### Key Documentation
- [Sail Guide](https://developers.urbit.org/guides/additional/sail) - Official Sail documentation
- [Sail/XML Runes](https://developers.urbit.org/reference/hoon/rune/mic) - Complete rune reference
- [App School I](https://developers.urbit.org/guides/core/app-school) - Gall application development

### Source Code Locations
- `~/Projects/urbit/docs.urbit.org/` - Official documentation with examples
- `~/Projects/urbit/grubbery/desk/gub/web-components.hoon` - Web component patterns
- `~/Projects/urbit/urbit/pkg/arvo/` - Core Urbit Sail implementations
- `~/Projects/urbit/desks/sailbox/desk/lib/` - Utility libraries for advanced patterns

### Example Applications
- Ahoy (ping tracker) - Real-world Sail application
- Pals (ship list) - CRUD patterns and state management
- Groups - Complex UI interactions and data binding

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

Sail represents a unique approach where HTML generation is functional, typed, and deeply integrated with the rest of the Urbit development experience.