module main

import os
import time
import veb

const marker_typekit = '___typekit'
const marker_home_images = '___home_images'
const marker_tour_dates = '___tour_dates'
const static_path = '/static'
const images_path = '${static_path}/images'
const bandsintown_artist_name = 'MOMBAO'

fn handle_error_500(mut ctx Context, message string) veb.Result {
	ctx.res.set_status(.internal_server_error)
	return ctx.text(message)
}

// TODO serialize a csv for title and alt
// TODO add srcset
fn build_image_list() !string {
	mut files := os.ls('${os.getwd()}${images_path}')!
	files.sort()
	mut images := []string{len: files.len}
	for i := 0; i < files.len; i++ {
		filename := files[i]
		images[i] = "<li><img loading='lazy' src='${images_path}/${filename}' /></li>"
	}
	return images.join('')
}

@['/'; get]
pub fn (mut app App) homepage(mut ctx Context) veb.Result {
	file := 'index.html'
	index_html := os.read_file(file) or { return handle_error_500(mut ctx, err.msg()) }
	image_list := build_image_list() or { return handle_error_500(mut ctx, err.msg()) }
	return ctx.html(index_html
		.replace(marker_typekit, app.typekit_code)
		.replace(marker_home_images, image_list))
}

@['/contact'; get]
pub fn (mut app App) contact(mut ctx Context) veb.Result {
	file := 'contact.html'
	contact_html := os.read_file(file) or { return handle_error_500(mut ctx, err.msg()) }
	return ctx.html(contact_html.replace(marker_typekit, app.typekit_code))
}

@['/manifesto'; get]
pub fn (mut app App) manifesto(mut ctx Context) veb.Result {
	file := 'manifesto.html'
	manifesto_html := os.read_file(file) or { return handle_error_500(mut ctx, err.msg()) }
	return ctx.html(manifesto_html.replace(marker_typekit, app.typekit_code))
}

@['/tour'; get]
pub fn (mut app App) tour(mut ctx Context) veb.Result {
	file := 'tour.html'

	if cached := app.cache.get('tour') {
		return ctx.html(cached)
	}

	contact_html := os.read_file(file) or { return handle_error_500(mut ctx, err.msg()) }
	events := app.bandsintown_client.get_event_data_all('mombao') or {
		return handle_error_500(mut ctx, err.msg())
	}

	mut tour_dates := []string{len: events.len}
	for i := 0; i < events.len; i++ {
		event := events[i]
		date := time.parse_iso8601(event.datetime) or {
			return handle_error_500(mut ctx, err.msg())
		}
		tour_dates[i] = '<li>${event.venue.city} ${date.format()} ${event.venue.name}</li>'
	}

	result := contact_html
		.replace(marker_typekit, app.typekit_code)
		.replace(marker_tour_dates, tour_dates.join(''))

	app.cache.set('tour', result)

	return ctx.html(result)
}
