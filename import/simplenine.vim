vim9script
scriptencoding utf-8

export interface Component
  def Compile(active: bool, pre: string, post: string, highlight_base: string): string
endinterface

export class RawComponent implements Component
  var _component: string

  def Compile(active: bool, pre: string, post: string, highlight_base: string): string
    return this._component
  enddef

  def new(this._component)
  enddef
endclass

export class StringComponent implements Component
  # pre%#highlight#component%#highlight_base#post
  static const _FORMAT_NO_GUARD = '%s%%#%s#%s%%#%s#%s'  # pre, highlight, component, highlight_base, post
  # %{%this._GuardFunc()?"pre%#highlight#component%#highlight_base#post":""%}
  static const _FORMAT_GUARD = '%%{%%%s(%s)?"%s%%#%s#%s%%#%s#%s":""%%}'  # GuardFunc(), active, pre, highlight, component, highlight_base, post

  var _component: string
  var _GuardFunc: func(bool): bool = null_function
  var _highlight: string = "SimpleNineComponent"
  var _highlight_inactive: string = "SimpleNineComponentInactive"

  static def _Escape(s: string): string
    return escape(s, "\"\\")
  enddef

  def Compile(active: bool, pre: string, post: string, highlight_base: string): string
    if this._GuardFunc is null_function
      return printf(
        _FORMAT_NO_GUARD,
        pre,
        active ? this._highlight : this._highlight_inactive,
        this._component,
        highlight_base,
        post
      )
    else
      return printf(
        _FORMAT_GUARD,
        string(this._GuardFunc),
        active ? "v:true" : "v:false",
        _Escape(pre),
        active ? _Escape(this._highlight) : _Escape(this._highlight_inactive),
        _Escape(this._component),
        _Escape(highlight_base),
        _Escape(post)
      )
    endif
  enddef

  def new(this._component, this._GuardFunc = v:none, this._highlight = v:none, this._highlight_inactive = v:none)
  enddef
endclass

export class FunctionComponent implements Component
  # pre%#highlight#%{ComponentFunc()}%#highlight_base#post
  static const _FORMAT_NO_GUARD = '%s%%#%s#%%{%s(%s)}%%#%s#%s'  # pre, highlight, ComponentFunc(), active, highlight_base, post
  # %{%GuardFunc()?"pre%#highlight#%{ComponentFunc()}%#highlight_base#post":""%}
  static const _FORMAT_GUARD = '%%{%%%s(%s)?"%s%%#%s#%%{%s(%s)}%%#%s#%s":""%%}'  # GuardFunc(), active, pre, highlight, ComponentFunc(), active, highlight_base, post

  var _ComponentFunc: func(bool): string
  var _GuardFunc: func(bool): bool = null_function
  var _highlight: string = "SimpleNineComponent"
  var _highlight_inactive: string = "SimpleNineComponentInactive"

  static def _Escape(s: string): string
    return escape(s, "\"\\")
  enddef

  def Compile(active: bool, pre: string, post: string, highlight_base: string): string
    if this._GuardFunc is null_function
      return printf(
        _FORMAT_NO_GUARD,
        pre,
        active ? this._highlight : this._highlight_inactive,
        string(this._ComponentFunc),
        active ? "v:true" : "v:false",
        highlight_base,
        post
      )
    else
      return printf(
        _FORMAT_GUARD,
        string(this._GuardFunc),
        active ? "v:true" : "v:false",
        _Escape(pre),
        active ? _Escape(this._highlight) : _Escape(this._highlight_inactive),
        string(this._ComponentFunc),
        active ? "v:true" : "v:false",
        _Escape(highlight_base),
        _Escape(post)
      )
    endif
  enddef

  def new(this._ComponentFunc, this._GuardFunc = v:none, this._highlight = v:none, this._highlight_inactive = v:none)
  enddef
endclass

# vim: et sw=2:
