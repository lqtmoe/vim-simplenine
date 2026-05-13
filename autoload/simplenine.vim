vim9script
scriptencoding utf-8

import "simplenine.vim"

class SimpleNine
  var _pre: string
  var _post: string
  var _components: list<simplenine.Component>
  var _statusline: string
  var _statusline_inactive: string

  var _components_ft: dict<list<simplenine.Component>> = {}
  var _statusline_ft: dict<string> = {}
  var _statusline_ft_inactive: dict<string> = {}
  var _components_bt: dict<list<simplenine.Component>> = {}
  var _statusline_bt: dict<string> = {}
  var _statusline_bt_inactive: dict<string> = {}

  def _Compile(components: list<simplenine.Component>, active: bool): string
    var statusline: string

    for component in components
      statusline ..= component.Compile(active, this._pre, this._post)
    endfor

    return "%{\" \"}" .. statusline .. "%{\" \"}"
  enddef

  def SetComponents(components: list<simplenine.Component>)
    var new_components = copy(components)
    this._statusline = this._Compile(new_components, true)
    this._statusline_inactive = this._Compile(new_components, false)
    this._components = new_components  # Lambdaの参照が切れないように、this._componentsへの代入はコンパイル後に行う
  enddef

  def GetComponents(): list<simplenine.Component>
    return copy(this._components)
  enddef

  def SetFileTypeComponents(filetype: string, components: list<simplenine.Component>)
    var new_components = copy(components)
    this._statusline_ft[filetype] = this._Compile(new_components, true)
    this._statusline_ft_inactive[filetype] = this._Compile(new_components, false)
    this._components_ft[filetype] = new_components  # Lambdaの参照が切れないように、this._components_ftへの代入はコンパイル後に行う
  enddef

  def GetFileTypeComponents(filetype: string): list<simplenine.Component>
    return copy(get(this._components_ft, filetype, []))
  enddef

  def SetBufTypeComponents(buftype: string, components: list<simplenine.Component>)
    var new_components = copy(components)
    this._statusline_bt[buftype] = this._Compile(new_components, true)
    this._statusline_bt_inactive[buftype] = this._Compile(new_components, false)
    this._components_bt[buftype] = new_components  # Lambdaの参照が切れないように、this._components_btへの代入はコンパイル後に行う
  enddef

  def GetBufTypeComponents(buftype: string): list<simplenine.Component>
    return copy(get(this._components_bt, buftype, []))
  enddef

  def StatusLine(active: bool, filetype: string, buftype: string): string
    if active
      return get(this._statusline_ft, filetype, get(this._statusline_bt, buftype, this._statusline))
    else
      return get(this._statusline_ft_inactive, filetype, get(this._statusline_bt_inactive, buftype, this._statusline_inactive))
    endif
  enddef

  def new(components: list<simplenine.Component>, this._pre, this._post)
    this._components = copy(components)
    this._statusline = this._Compile(this._components, true)
    this._statusline_inactive = this._Compile(this._components, false)
  enddef
endclass

const FILLCHAR: string = "─"
const COMPONENT_PRE: string = "╴"
const COMPONENT_POST: string = "╶"

const DEFAULT_COMPONENTS: list<simplenine.Component> = [
  simplenine#components#filename,
  simplenine#components#readonly,
  simplenine#components#modify,
  simplenine#components#separator,
  simplenine#components#percent,
  simplenine#components#encoding,
  simplenine#components#fileformat,
  simplenine#components#filetype
]

const DEFAULT_HIGHLIGHTS: dict<tuple<number, string>> = {
  Normal:   (148, "#afdf00"),
  Insert:   (231, "#ffffff"),
  Replace:  (160, "#af0000"),
  Visual:   (208, "#ff8700"),
  Inactive: (240, "#585858"),
  Terminal: (231, "#ffffff"),
  Command:  (148, "#afdf00"),
  Select:   (208, "#ff8700"),
}

const MODE_MAP: dict<string> = {
  n:        "SimpleNineNormal",
  i:        "SimpleNineInsert",
  R:        "SimpleNineReplace",
  v:        "SimpleNineVisual",
  V:        "SimpleNineVisual",
  "\<C-v>": "SimpleNineVisual",
  s:        "SimpleNineSelect",
  S:        "SimpleNineSelect",
  "\<C-s>": "SimpleNineSelect",
  c:        "SimpleNineCommand",
  t:        "SimpleNineTerminal"
}

const INSTANCE: SimpleNine = SimpleNine.new(DEFAULT_COMPONENTS, COMPONENT_PRE, COMPONENT_POST)

export def Setup()
  augroup simplenine
    autocmd!
    autocmd ColorScheme * SetupColorScheme()
    autocmd ModeChanged * {
      if v:event.old_mode[0] != v:event.new_mode[0]
        UpdateStlColor(v:event.new_mode[0])
      endif
    }
  augroup END

  SetupColorScheme()

  execute "set fillchars+=stl:" .. FILLCHAR
  execute "set fillchars+=stlnc:" .. FILLCHAR
  &statusline = "%!" .. expand("<SID>") .. "StatusLine()"
enddef

def SetupColorScheme()
  for [name, hl] in items(DEFAULT_HIGHLIGHTS)
    var [ctermfg, guifg] = hl
    execute "highlight" "default" "SimpleNine" .. name "ctermfg=" .. ctermfg "guifg=" .. guifg
  endfor

  highlight default link SimpleNineComponent Normal
  highlight default link SimpleNineComponentInactive SimpleNineInactive

  highlight clear StatusLine
  highlight! link StatusLine SimpleNineNormal
  highlight clear StatusLineNC
  highlight! link StatusLineNC SimpleNineInactive
  highlight clear StatusLineTerm
  highlight! link StatusLineTerm SimpleNineTerminal
  highlight clear StatusLineTermNC
  highlight! link StatusLineTermNC SimpleNineInactive

  UpdateStlColor(mode())
enddef

def UpdateStlColor(mode: string)
  execute "highlight!" "link" "StatusLine" get(MODE_MAP, mode, "SimpleNineNormal")
enddef

def StatusLine(): string
  return GetStatusLineString(
    win_getid() == g:statusline_winid,
    getbufvar(winbufnr(g:statusline_winid), "&filetype"),
    getbufvar(winbufnr(g:statusline_winid), "&buftype")
  )
enddef

export def SetComponents(components: list<simplenine.Component>)
  INSTANCE.SetComponents(components)
enddef

export def GetComponents(): list<simplenine.Component>
  return INSTANCE.GetComponents()
enddef

export def UpdateComponents(UpdateFunc: func(list<simplenine.Component>): list<simplenine.Component>)
  SetComponents(UpdateFunc(GetComponents()))
enddef

export def SetFileTypeComponents(filetype: string, components: list<simplenine.Component>)
  INSTANCE.SetFileTypeComponents(filetype, components)
enddef

export def GetFileTypeComponents(filetype: string): list<simplenine.Component>
  return INSTANCE.GetFileTypeComponents(filetype)
enddef

export def SetBufTypeComponents(buftype: string, components: list<simplenine.Component>)
  INSTANCE.SetBufTypeComponents(buftype, components)
enddef

export def UpdateFileTypeComponents(filetype: string, UpdateFunc: func(list<simplenine.Component>): list<simplenine.Component>)
  SetFileTypeComponents(filetype, UpdateFunc(GetFileTypeComponents(filetype)))
enddef

export def GetBufTypeComponents(buftype: string): list<simplenine.Component>
  return INSTANCE.GetBufTypeComponents(buftype)
enddef

export def GetStatusLineString(active: bool = true, filetype: string = &filetype, buftype: string = &buftype): string
  return INSTANCE.StatusLine(active, filetype, buftype)
enddef

export def UpdateBufTypeComponents(buftype: string, UpdateFunc: func(list<simplenine.Component>): list<simplenine.Component>)
  SetBufTypeComponents(buftype, UpdateFunc(GetBufTypeComponents(buftype)))
enddef

# vim: et sw=2:
