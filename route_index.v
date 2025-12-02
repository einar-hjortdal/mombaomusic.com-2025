module main

import os
import veb

const index_html = $embed_file('index.html')
const to_replace = '___replace'
const static_path = '/static'
const images_path = '${static_path}/images'
const horizontal_keyword = 'horizontal'

fn handle_error_500(mut ctx Context, message string) veb.Result {
	ctx.res.set_status(.internal_server_error)
	return ctx.text(message)
}

fn css_class_horizontal(filename string) string {
	if filename.contains(horizontal_keyword) {
		return horizontal_keyword
	}
	return ''
}

fn build_image_list() !string {
	files := os.ls('${os.getwd()}${images_path}')!
	mut images := []string{len: files.len}
	for i := 0; i < files.len; i++ {
		filename := files[i]
		images[i] = "
			<li ${css_class_horizontal(filename)}>
				<img loading='lazy' src='${images_path}/${filename}'/>
			</li>
		"
	}
	return "<ul class='image-list'>${images.join('')}</ul>"
}

@['/'; get]
pub fn (mut app App) homepage(mut ctx Context) veb.Result {
	index_html_string := index_html.to_string()
	image_list := build_image_list() or { return handle_error_500(mut ctx, err.msg()) }
	return ctx.html(index_html_string.replace(to_replace, image_list))
}
