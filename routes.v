module main

import os
import veb

const marker_typekit = '___typekit'
const marker_home_images = '___home_images'
const marker_tour_dates_upcoming = '___tour_dates_upcoming'
const marker_tour_dates_past = '___tour_dates_past'

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

	events_upcoming := app.bandsintown_client.get_event_data_upcoming(bandsintown_artist_name) or {
		return handle_error_500(mut ctx, err.msg())
	}

	events_past := app.bandsintown_client.get_event_data_past(bandsintown_artist_name) or {
		return handle_error_500(mut ctx, err.msg())
	}

	list_upcoming := get_event_list_upcoming(events_upcoming) or {
		return handle_error_500(mut ctx, err.msg())
	}

	list_past := get_event_list_past(events_past) or { return handle_error_500(mut ctx, err.msg()) }

	result := tour_html
		.replace(marker_typekit, app.typekit_code)
		.replace(marker_tour_dates_upcoming, list_upcoming)
		.replace(marker_tour_dates_past, list_past)

	app.cache.set(cache_key_tour, result)

	return ctx.html(result)
}
