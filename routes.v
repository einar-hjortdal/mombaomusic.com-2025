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

const file_name_home = 'index.html'
const file_name_manifesto = 'manifesto.html'
const file_name_contact = 'contact.html'
const file_name_tour = 'tour.html'

const cache_key_home = 'home'
const cache_key_manifesto = 'manifesto'
const cache_key_contact = 'contact'
const cache_key_tour = 'tour'

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
	if cached := app.cache.get(cache_key_home) {
		return ctx.html(cached)
	}

	index_html := os.read_file(file_name_home) or { return handle_error_500(mut ctx, err.msg()) }
	image_list := build_image_list() or { return handle_error_500(mut ctx, err.msg()) }

	result := index_html
		.replace(marker_typekit, app.typekit_code)
		.replace(marker_home_images, image_list)

	app.cache.set(cache_key_home, result)

	return ctx.html(result)
}

@['/contact'; get]
pub fn (mut app App) contact(mut ctx Context) veb.Result {
	if cached := app.cache.get(cache_key_contact) {
		return ctx.html(cached)
	}

	contact_html := os.read_file(file_name_contact) or {
		return handle_error_500(mut ctx, err.msg())
	}
	result := contact_html.replace(marker_typekit, app.typekit_code)

	app.cache.set(cache_key_contact, result)

	return ctx.html(result)
}

@['/manifesto'; get]
pub fn (mut app App) manifesto(mut ctx Context) veb.Result {
	if cached := app.cache.get(cache_key_manifesto) {
		return ctx.html(cached)
	}

	manifesto_html := os.read_file(file_name_manifesto) or {
		return handle_error_500(mut ctx, err.msg())
	}
	result := manifesto_html.replace(marker_typekit, app.typekit_code)

	app.cache.set(cache_key_manifesto, result)

	return ctx.html(result)
}

@['/tour'; get]
pub fn (mut app App) tour(mut ctx Context) veb.Result {
	if cached := app.cache.get(cache_key_tour) {
		return ctx.html(cached)
	}

	tour_html := os.read_file(file_name_tour) or { return handle_error_500(mut ctx, err.msg()) }
	events := app.bandsintown_client.get_event_data_all('mombao') or {
		return handle_error_500(mut ctx, err.msg())
	}

	mut tour_dates := []string{len: events.len}
	for i := 0; i < events.len; i++ {
		event := events[i]

		// format date
		parsed_date := time.parse_iso8601(event.datetime) or {
			return handle_error_500(mut ctx, err.msg())
		}
		formatted_date := parsed_date.custom_format('DD MMM, YYYY')

		// invert order
		inverted_i := events.len - 1 - i
		tour_dates[inverted_i] = '<li>${formatted_date} ${event.venue.city} ${event.venue.name}</li>'
	}

	result := tour_html
		.replace(marker_typekit, app.typekit_code)
		.replace(marker_tour_dates, tour_dates.join(''))

	app.cache.set(cache_key_tour, result)

	return ctx.html(result)
}
