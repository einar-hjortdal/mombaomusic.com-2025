module main

import arrays
import log
import os
import time
import veb
import einar_hjortdal.bandsintown

fn handle_error_500(mut ctx Context, message string) veb.Result {
	ctx.res.set_status(.internal_server_error)
	return ctx.text(message)
}

fn get_file_list() ![]string {
	mut files := os.ls('${os.getwd()}${images_path}')!
	mut res := []string{}
	for i := 0; i < files.len; i++ {
		file := files[i]

		// ignore compressed files and files with -600w or -1000w in their names
		if file.ends_with('.gz') || file.contains('-600w') || file.contains('-1000w') {
			continue
		}

		res = arrays.concat(res, file)
	}
	return res
}

fn split_filename(file string) !(string, string) {
	i := file.last_index('.') or { return error('file extension missing: `${file}`') }
	return file[..i], file[i..]
}

fn get_image_height(file string) !string {
	cwd := os.getwd()
	result := os.execute('magick identify -format "%h" ${cwd}${images_path}/${file}')
	if result.exit_code == 0 {
		return result.output
	}
	return error(result.output)
}

fn build_image_list() !string {
	mut files := get_file_list()!
	files.sort()
	mut images := []string{len: files.len}
	for i := 0; i < files.len; i++ {
		file := files[i]

		filename, extension := split_filename(file) or {
			log.debug(err.msg())
			continue
		}

		height := get_image_height(file) or {
			log.debug(err.msg())
			continue
		}

		image_path := '${images_path}/${filename}'
		images[i] = '
			<li>
				<img
					loading="lazy"
					height="${height}px"
					width="400px"
					src="${image_path}${extension}"
					srcset="${image_path}${extension} 400w, ${image_path}-600w${extension} 600w, ${image_path}-1000w${extension} 1000w"
					sizes="(min-width: 2000px) 440px, (min-width: 1500px) 340px, (min-width: 1300px) 290px, (min-width: 992px) 461px, (min-width: 768px) 350px, (min-width: 576px) 270px, 180px"
					alt=""
				/>
			</li>
		'
	}
	return images.join('')
}

fn get_event_list(events []bandsintown.EventData) ![]string {
	mut list := []string{len: events.len}
	for i := 0; i < events.len; i++ {
		event := events[i]

		// format date
		datetime := event.datetime
		parsed_date := time.parse_iso8601(datetime)!
		year := parsed_date.custom_format('YYYY')
		month_day := parsed_date.custom_format('DD MMMM')

		event_element := '
			<li class="tour-main-dates-li">
				<div>
					<time class="tour-main-dates-time" datetime="${datetime}">
						<span class="tour-main-dates-year tk-margin-mvb-light">${year}</span>
						<span class="tour-main-dates-month-day tk-margin-mvb-light">${month_day}</span>
					</time>
					<div class="tour-main-dates-location">
						<span class="tour-main-dates-city-country tk-margin-mvb">${event.venue.city}, ${event.venue.country}</span>
						<span class="tour-main-dates-venue tk-margin-mvb-light">${event.venue.name}</span>
					</div>
				</div>
			</li>
		'

		list[i] = event_element
	}
	return list
}

fn get_event_list_upcoming(events []bandsintown.EventData) !string {
	event_list := get_event_list(events)!
	return event_list.join('')
}

fn get_event_list_past(events []bandsintown.EventData) !string {
	event_list := get_event_list(events)!
	mut inverted_list := []string{len: event_list.len}
	for i := 0; i < event_list.len; i++ {
		event := event_list[i]
		inverted_i := event_list.len - 1 - i
		inverted_list[inverted_i] = event
	}
	return inverted_list.join('')
}
