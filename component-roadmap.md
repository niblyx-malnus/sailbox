# Sailbox Component Roadmap

## 80/20 Essential Web Components for Sail

This is our target list of composable components that cover ~90% of web interface needs.

### ✅ Implemented
- **Card** - Content container (`card:lab`)
- **Ship Badge** - Status indicator with sigils (`ship-badge-with-sigil:lab`)

### 🏗️ Layout & Structure (Foundation - High Priority)
- **Stack** - Vertical layout with consistent spacing
- **Row** - Horizontal layout with gap control
- **Container** - Max-width centered content wrapper
- **Divider** - Visual separator line

### 📝 Inputs & Forms (Most Used - High Priority)
- **Button** - Primary/secondary/danger variants
- **Input** - Text input with label and validation states
- **Select** - Dropdown picker
- **Textarea** - Multi-line text input
- **Checkbox** - Boolean toggle with label
- **Radio Group** - Single choice from options

### 🔔 Feedback & Status (Critical UX - Medium Priority)
- **Alert** - Success/warning/error messages
- **Loading Spinner** - Progress indicator
- **Toast** - Temporary notification popup

### 🧭 Navigation (Essential - Medium Priority)
- **Link** - Styled anchor with hover states
- **Breadcrumbs** - Navigation path
- **Tabs** - Content switching
- **Menu** - Dropdown action list

### 📊 Data Display (High Impact - Medium Priority)
- **Table** - Structured data with sorting
- **List** - Simple item list with separators
- **Avatar** - User/entity image placeholder
- **Code Block** - Syntax-highlighted code display

### 📱 Content (Common Patterns - Lower Priority)
- **Modal** - Overlay dialog
- **Accordion** - Collapsible content sections

## Implementation Strategy

1. **Start with Layout primitives** (Stack, Row, Container) - these compose into everything else
2. **Add Form elements** next - highest user interaction value
3. **Build out Feedback components** - critical for good UX
4. **Expand Data Display** - when we have more complex content

## Design Principles

- **Composable** - Each component should work well alone and with others
- **Minimal** - Start with simplest working version, enhance incrementally
- **Testable** - Each component must be immediately verifiable in isolation
- **Consistent** - Shared design tokens for spacing, colors, typography