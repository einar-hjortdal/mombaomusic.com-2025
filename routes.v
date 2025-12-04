module main

import os
import veb

const to_replace = '___replace'
const static_path = '/static'
const images_path = '${static_path}/images'

fn handle_error_500(mut ctx Context, message string) veb.Result {
	ctx.res.set_status(.internal_server_error)
	return ctx.text(message)
}

fn css_class_orientation(filename string) string {
	if filename.contains('horizontal') {
		return 'class="horizontal"'
	}
	return 'class="vertical"'
}

// TODO serialize a csv for title and alt, include orientation
// TODO add srcset
fn build_image_list() !string {
	files := os.ls('${os.getwd()}${images_path}')!
	mut images := []string{len: files.len}
	for i := 0; i < files.len; i++ {
		filename := files[i]
		images[i] = "
		<li>
				<div>
					<img
						${css_class_orientation(filename)}
						loading='lazy'
						src='${images_path}/${filename}'
					/>
				</div>
		</li>
		"
	}
	// return images.join('')

	// artificially create more images, I don't have anough to work with
	return '${images.join('')}${images.join('')}'
}

@['/'; get]
pub fn (mut app App) homepage(mut ctx Context) veb.Result {
	index_html := os.read_file('index.html') or { return handle_error_500(mut ctx, err.msg()) }
	image_list := build_image_list() or { return handle_error_500(mut ctx, err.msg()) }
	return ctx.html(index_html.replace(to_replace, image_list))
}
