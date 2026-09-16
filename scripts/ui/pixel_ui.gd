class_name PixelUI
extends RefCounted
## Shared Tiny5 (OFL) pixel font for SCUMM/MI VGA UI chrome.

const FONT_PATH := "res://assets/fonts/Tiny5-Regular.ttf"
const SIZE_UI := 8
const SIZE_SMALL := 7

## Warm yellow for selected verb (docs/ART.md) — not purple.
const VERB_SELECTED := Color(1.0, 0.88, 0.25)
const VERB_IDLE := Color(0.75, 0.75, 0.95)
const VERB_HOVER := Color(1.0, 1.0, 0.7)
const INDIGO := Color(0.0, 0.0, 0.35)
const INDIGO_BORDER := Color(0.35, 0.35, 0.55)
const INDIGO_BORDER_SEL := Color(0.95, 0.8, 0.3)

static var _font: Font

static func font() -> Font:
	if _font == null:
		_font = load(FONT_PATH) as Font
	return _font

static func apply_label(label: Label, size: int = SIZE_UI) -> void:
	var f := font()
	if f:
		label.add_theme_font_override("font", f)
	label.add_theme_font_size_override("font_size", size)

static func apply_button(btn: Button, size: int = SIZE_UI) -> void:
	var f := font()
	if f:
		btn.add_theme_font_override("font", f)
	btn.add_theme_font_size_override("font_size", size)

static func empty_style() -> StyleBoxEmpty:
	var sb := StyleBoxEmpty.new()
	sb.set_content_margin_all(2)
	return sb
