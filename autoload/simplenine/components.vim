vim9script
scriptencoding utf-8

import "simplenine.vim"

export const filepath = simplenine.StringComponent.new("%f")
export const fullpath = simplenine.StringComponent.new("%F")
export const filename = simplenine.StringComponent.new("%t")
export const modify = simplenine.StringComponent.new(
  "%{&modified&&!&modifiable?\"±\":&modified?\"+\":!&modifiable?\"-\":\"\"}",
  (_) => &modified || !&modifiable
)
export const readonly = simplenine.StringComponent.new("RO", (_) => &readonly)
export const filetype = simplenine.StringComponent.new("%{!empty(&ft)?&ft:\"unknown\"}")
export const line = simplenine.StringComponent.new("%l")
export const totalline = simplenine.StringComponent.new("%L")
export const percent = simplenine.StringComponent.new("%p%%")
export const separator = simplenine.RawComponent.new("%=")
export const encoding = simplenine.StringComponent.new("%{!empty(&fenc)?&fenc:&enc}")
export const fileformat = simplenine.StringComponent.new("%{&ff}")

# vim: et sw=2:
