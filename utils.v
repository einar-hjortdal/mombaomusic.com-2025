module main

import einar_hjortdal.bandsintown
import time

fn get_event_list(events []bandsintown.EventData) !string {
	mut list := []string{len: events.len}
	for i := 0; i < events.len; i++ {
		event := events[i]

		// format date
		datetime := event.datetime
		parsed_date := time.parse_iso8601(datetime)!
		year := parsed_date.custom_format('YYYY')
		month_day := parsed_date.custom_format('DD MMMM')

		// invert order
		inverted_i := events.len - 1 - i
		list[inverted_i] = '
			<li class="tour-main-dates-li">
				<div class="tour-main-dates-li-container">
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
	}
	return list.join('')
}
