# Sailbox

Urbit Gall app for learning Sail HTML generation and developing reusable web components. Also provides an **HTTP/SSE agent transformer** for building web apps with minimal boilerplate.

## Quick Start

**Frontend**: Visit e.g. `http://localhost/sailbox` to see the live interface

**HTTP/SSE Transformer**: The sailbox app itself demonstrates the transformer pattern - check `app/sailbox.hoon` to see how it works

**Key files to modify:**
- `desk/app/sailbox.hoon` - Gall agent using the transformer pattern (demonstrates best practices)
- `desk/lib/sailbox.hoon` - HTTP/SSE agent transformer library
- `desk/lib/sail-lab.hoon` - Production component library (inline styles)
- `desk/lib/sail-components.hoon` - CSS framework component library (first draft)

## Purpose

Sailbox serves three purposes:

1. **Teaching Laboratory** - Minimal working Gall+Rudder+Sail stack for experimenting with HTML generation patterns
2. **Component Foundry** - Building reusable, composable interface tools for Urbit web applications
3. **Agent Transformer Library** - Reusable HTTP/SSE wrapper that handles boilerplate (like `shoe` for CLI apps)

## Approach

- **Observable Output First** - Start with visible proof, build outward with testable changes
- **Hypothesis-Driven Development** - Make technical beliefs explicit, test in isolation
- **Minimal Intervention** - Change as little as possible, avoid speculative helpers
- **Natural Modularity** - Extract components only after patterns prove themselves under real use

## What This Demonstrates

Current working patterns:
- HTTP/SSE agent transformer (see `app/sailbox.hoon`)
- Sail HTML templating using Hoon runes
- Form handling and state management
- Basic CRUD operations (add ships to a list)
- Helper core pattern for page rendering
- 24 advanced Sail patterns (conditional rendering, SVG, forms, grids, etc.)

## HTTP/SSE Agent Transformer

The sailbox library includes an agent transformer (similar to `shoe` for CLI apps) that handles HTTP and Server-Sent Events with minimal boilerplate.

### Quick Example

```hoon
/+  dbug, default-agent, sailbox
|%
+$  card  card:sailbox
--
^-  agent:gall
%-  agent:dbug
%-  agent:sailbox
^-  sailbox:sailbox
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)

++  on-init   [~ this]
++  on-save   !>(~)
++  on-load   |=(vase [~ this])
++  on-poke   on-poke:def
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def

++  do-get
  |=  [[ext=(unit @ta) site=(list @t)] args=(list [key=@t value=@t])]
  ^-  mime
  [/text/html (as-octs:mimes:html '<h1>Hello World!</h1>')]

++  do-post
  |=  [site=path args=(list [key=@t value=@t])]
  ^-  (quip card _this)
  [~ this]

++  do-upload
  |=  [site=path =parts:sailbox]
  ^-  (quip card _this)
  [~ this]

++  make-sse-event
  |=  [site=(list @t) args=(list [key=@t value=@t]) id=(unit @t) event=(unit @t)]
  ^-  wain
  ~['event data here']

++  first-sse-event
  |=  [site=(list @t) args=(list [key=@t value=@t]) last-event-id=(unit @t)]
  ^-  (unit sse-key:sailbox)
  ~
--
```

### What the Wrapper Handles

The `agent:sailbox` wrapper automatically manages:
- **Eyre binding** - Connects your app to `/yourapp` endpoint
- **HTTP routing** - Routes GET/POST/multipart to appropriate arms
- **SSE connections** - Tracks open Server-Sent Event streams
- **Keep-alive timer** - Sends periodic keep-alive pings
- **Connection timeouts** - Closes stale connections after 2 minutes
- **Custom cards** - Transforms `[%sse ...]` cards into SSE events

### Required Arms

Your agent must implement exactly 15 arms:

**Standard Gall arms (10):**
- `on-init`, `on-save`, `on-load`, `on-poke`, `on-watch`
- `on-leave`, `on-peek`, `on-agent`, `on-arvo`, `on-fail`

**HTTP/SSE arms (5):**
- `++do-get` - Handle GET requests, return `mime`
- `++do-post` - Handle POST requests, return cards and state
- `++do-upload` - Handle multipart uploads, return cards and state
- `++make-sse-event` - Generate SSE event content for a site/event combination
- `++first-sse-event` - Optional initial event when SSE connection opens

### Sending SSE Events

Emit custom `%sse` cards to send events to matching connections:

```hoon
:_  this
~[[%sse /myapp/updates ~ `'data-changed']]
```

The wrapper automatically:
1. Finds all SSE connections matching `/myapp/updates`
2. Calls `make-sse-event` to generate the event content
3. Sends the event to each matching connection

### Agent Structure with Helper Core Pattern

The sailbox app demonstrates the recommended structure for complex web apps. The key insight is to keep the main agent core at exactly 15 arms (10 standard Gall + 5 HTTP/SSE), and move page-rendering logic into a helper core:

```hoon
/-  *sailbox
/+  dbug, default-agent, server, sailbox,
    html-utils, examples, lab=sail-lab, feather
::
|%
+$  state-0  [%0 ships=(list ship)]
+$  card  card:sailbox  :: IMPORTANT: use card:sailbox, not card:agent:gall
--
::
=|  state-0
=*  state  -
::
=<  :: "inverted taco" - agent core comes first, helper core below
::
%-  agent:dbug
%-  agent:sailbox  :: wrap with transformer
^-  sailbox:sailbox
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
    hc    ~(. +> bowl)  :: helper core access
::
:: Standard Gall arms (10)
++  on-init   [~ this]
++  on-save   !>(state)
++  on-load   |=(vase [~ this])
++  on-poke   |=([mark vase] ...)
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
::
:: HTTP/SSE arms (5)
++  do-get
  |=  [[ext=(unit @ta) site=(list @t)] args=(list [key=@t value=@t])]
  ^-  mime
  ?+  site  [/text/html (as-octs:mimes:html '<h1>404</h1>')]
    [%sailbox ~]         [/text/html (manx-to-octs:server page:hc)]
    [%sailbox %other ~]  [/text/html (manx-to-octs:server other-page:hc)]
  ==
::
++  do-post
  |=  [site=path args=(list [key=@t value=@t])]
  ^-  (quip card _this)
  ... :: handle form submission
::
++  do-upload
  |=  [site=path =parts:sailbox]
  ^-  (quip card _this)
  ... :: handle file uploads
::
++  make-sse-event
  |=  [site=(list @t) args=(list [key=@t value=@t]) id=(unit @t) event=(unit @t)]
  ^-  wain
  ~['data: event content']
::
++  first-sse-event
  |=  [site=(list @t) args=(list [key=@t value=@t]) last-event-id=(unit @t)]
  ^-  (unit sse-key:sailbox)
  ~
--
::
:: Helper core - all page rendering functions go here
|_  =bowl:gall
++  page        ^-  manx  ;html: ;body: ;h1: Main Page
++  other-page  ^-  manx  ;html: ;body: ;h1: Other Page
++  style  '''CSS goes here'''
--
```

**Key structural points:**

1. **Card type**: Use `+$  card  card:sailbox` not `card:agent:gall`
2. **Agent wrapper**: `%-  agent:sailbox` wraps your agent
3. **Exactly 15 arms**: Don't add extra arms to the main agent core
4. **Helper core**: Use `=<` pattern to separate concerns
5. **Helper access**: Use `hc` pin to call helper functions from main arms
6. **State access**: Both cores share the same state via `=|` and `=*`

### GET-after-POST/Upload Pattern

A powerful feature of the transformer is the ability to return a GET response after processing a POST or file upload. This is perfect for HTMX-style updates where you want to mutate state and immediately return the updated HTML.

**In your POST form, include a `get` parameter:**

```html
<form method="post">
  <input type="text" name="ship" value="~sampel-palnet" />
  <button type="submit" name="action" value="add-ship">Add Ship</button>
  <!-- The magic: GET /sailbox after processing POST -->
  <input type="hidden" name="get" value="/sailbox" />
</form>
```

**What happens:**

1. Form submits POST to `/sailbox` with `ship=~sampel-palnet&action=add-ship&get=/sailbox`
2. Transformer calls `do-post:og` to process the form (adds ship to state)
3. Transformer extracts the `get` parameter
4. Transformer calls `do-get:og` with the path from `get` parameter
5. Returns the GET response instead of 204

**For multipart uploads, same pattern:**

```html
<form method="post" enctype="multipart/form-data">
  <input type="file" name="upload" />
  <!-- GET after upload -->
  <input type="text" name="get" value="/myapp/gallery" />
  <button type="submit">Upload</button>
</form>
```

**Implementation details (from lib/sailbox.hoon):**

```hoon
:: In POST handling (line ~436-448)
=/  args=key-value-list:kv  (parse-body:kv body.request.req)
=/  get=(unit @t)  (get-key:kv 'get' args)  :: extract 'get' param
=^  cards  app
  (do-post:og site.lin (delete-key:kv 'get' args))  :: remove 'get' from args
:_  this
%+  welp
  (deal cards make-sse-event:og)
?^  get
  %+  give-mime-response  eyre-id
  (do-get:og (parse-request-line:server u.get))  :: call do-get with 'get' path
%+  give-simple-payload:app:server
  eyre-id
two-oh-four  :: standard 204 if no 'get' param

:: In multipart upload handling (line ~422-434)
=/  paz=(map @t part:multipart)  (~(gas by *(map @t part:multipart)) u.parts)
=/  get=(unit part:multipart)  (~(get by paz) 'get')  :: extract 'get' part
=.  u.parts  ~(tap by (~(del by paz) 'get'))  :: remove 'get' from parts
=^  cards  app
  (do-upload:og site.lin u.parts)
:_  this
%+  welp
  (deal cards make-sse-event:og)
?^  get
  %+  give-mime-response  eyre-id
  (do-get:og (parse-request-line:server body.u.get))  :: use body of 'get' part
%+  give-simple-payload:app:server
  eyre-id
two-oh-four
```

**Why this is powerful:**

- Eliminates need for separate HTMX `hx-swap-oob` patterns
- Keeps mutation and re-rendering in one request
- Works naturally with browser form submissions
- No client-side JavaScript required
- Perfect for progressive enhancement

## Component Library Foundation

Ready-to-use utility libraries:
- `desk/lib/sailbox.hoon` - HTTP/SSE agent transformer and utilities
- `desk/lib/html-utils.hoon` - jQuery-like DOM manipulation and CSS selectors
- `desk/lib/manx-utils.hoon` - Comprehensive XML/manx tree traversal (~tinnus-napbus)
- `desk/lib/json-utils.hoon` - Safe JSON handling and path-based access
- `desk/lib/skeleton.hoon` - Bare agent template for rapid prototyping

## Core Files

**Agent:**
- `desk/app/sailbox.hoon` - Demo agent using transformer pattern (~100 lines agent + ~370 lines helper core)

**Libraries:**
- `desk/lib/sailbox.hoon` - HTTP/SSE agent transformer (~524 lines)
- `desk/lib/sail-lab.hoon` - Production-ready Sail components
- `desk/lib/examples.hoon` - 24 advanced Sail patterns

**Structures:**
- `desk/sur/sailbox.hoon` - Type definitions for sailbox commands

**Supporting:**
- `desk/mar/sailbox/command.hoon` - Command mark file

# Installation

1. **Clone this repo.**

2. **Boot up a ship** (fakezod or moon or whatever you use).

3. **Create new desk:**
   ```bash
   |new-desk %sailbox
   ```

4. **Install immediately (before any commits):**
   ```bash
   |install our %sailbox
   ```

5. **Mount to filesystem:**
   ```bash
   |mount %sailbox
   ```

6. **Copy sailbox files:**
   ```bash
   cp -r desk/* [ship-name]/sailbox/
   ```

7. **Commit the desk:**
   ```bash
   |commit %sailbox
   ```

8. **Access the web interface:** Visit `[ship-url]/sailbox` in your browser.

## Development Workflow

For iterating on sailbox code:

1. **Setup sync configuration:**
   ```bash
   cp config.example.json config.json
   # Edit config.json with your pier path (e.g., "/path/to/pier/sailbox/")
   ```

2. **Start continuous sync:**
   ```bash
   ./sync.sh
   ```

3. **Make changes to files in `desk/`** - they sync automatically

4. **Commit in dojo:**
   ```bash
   |commit %sailbox
   ```

The sync script watches for file changes and automatically syncs them to your ship.

## Learning Resources

- [Sail documentation](https://developers.urbit.org/guides/additional/sail)
- [Sail/XML runes](https://developers.urbit.org/reference/hoon/rune/mic)
- [Rudder library source](https://github.com/Fang-/suite/blob/11b505ef78a65512ed6ccc7ff77551188499d5b7/lib/rudder.hoon)
- [App School I](https://developers.urbit.org/guides/core/app-school)
