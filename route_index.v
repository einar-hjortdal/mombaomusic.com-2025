module main

import arrays
import os
import veb

const index_html = $embed_file('index.html')
const to_replace = '___replace'
const static_path = '/static'
const images_path = '${static_path}/images'

fn handle_error_500(mut ctx Context, message string) veb.Result {
	ctx.res.set_status(.internal_server_error)
	return ctx.text(message)
}

fn build_image_list() !string {
	files := os.ls('${os.getwd()}${images_path}')!
	mut images := []string{len: files.len}
	for i := 0; i < files.len; i++ {
		filename := files[i]

		// we put 4 images per row, first one needs no left padding, last one needs no right padding
		// TODO refactor, this looks silly
		mut image_container_classes := ['image-container']
		if i % 4 == 0 {
			image_container_classes = arrays.concat(image_container_classes, 'image-container-first-of-row')
		} else if i % 4 == 3 {
			image_container_classes = arrays.concat(image_container_classes, 'image-container-last-of-row')
		} else {
			image_container_classes = arrays.concat(image_container_classes, 'image-container-middle')
		}

		// Note: do not add whitespace before/after li
		images[i] = "<li class='image-li'>
				<div class='${image_container_classes.join(' ')}'>
					<img class='image-img' loading='lazy' src='${images_path}/${filename}'/>
				</div>
		</li>"
	}
	// return "<ul class='image-ul'>${images.join('')}</ul>"

	// artificially create more images, I don't have anough to work with
	return "<ul class='image-ul'>${images.join('')}${images.join('')}</ul>"
}

@['/'; get]
pub fn (mut app App) homepage(mut ctx Context) veb.Result {
	index_html_string := index_html.to_string()
	image_list := build_image_list() or { return handle_error_500(mut ctx, err.msg()) }
	return ctx.html(index_html_string.replace(to_replace, image_list))
}
