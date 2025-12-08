module main

import log
import os
import strconv
import time
import veb
import einar_hjortdal.dotenv
import einar_hjortdal.bandsintown

const env_typekit_code = 'TYPEKIT_CODE'
const env_bandsintown_api_key = 'BANDSINTOWN_API_KEY'
const env_cache_duration = 'CACHE_DURATION'
const env_debug = 'CACHE_DURATION'

fn set_log_level() {
	if os.getenv(env_debug) == 'true' {
		log.set_level(log.Level.debug)
	} else {
		log.set_level(log.Level.info)
	}
}

struct CacheEntry {
	expires time.Time
	value   string
}

struct InMemoryCache {
	duration time.Duration
mut:
	data map[string]CacheEntry
}

fn (mut c InMemoryCache) set(key string, value string) {
	log.debug('Setting new cache entry with key `${key}`')
	c.data[key] = CacheEntry{
		expires: time.now().add(c.duration)
		value:   value
	}
}

fn (mut c InMemoryCache) get(key string) ?string {
	if key !in c.data {
		log.debug('Cache entry with key `${key}` not found, returning none')
		return none
	}

	entry := c.data[key]
	if (entry.expires - time.now()) < 0 {
		log.debug('Cache entry with key `${key}` expired, returning none')
		return none
	}

	log.debug('Cache entry with key `${key}` found, returning value')
	return entry.value
}

pub struct Context {
	veb.Context
}

pub struct App {
	veb.StaticHandler
	typekit_code       string
	bandsintown_client &bandsintown.Client
mut:
	cache &InMemoryCache
}

fn get_typekit_code() string {
	typekit_code := os.getenv(env_typekit_code)

	if typekit_code == '' {
		panic('missing environment variable ${env_typekit_code}')
	}

	return typekit_code
}

fn get_bandsintown_client() &bandsintown.Client {
	bandsintown_api_key := os.getenv(env_bandsintown_api_key)

	if bandsintown_api_key == '' {
		panic('missing environment variable ${env_bandsintown_api_key}')
	}

	return bandsintown.new_client(bandsintown_api_key)
}

fn get_in_memoty_cache() &InMemoryCache {
	cache_duration_string := os.getenv(env_cache_duration)

	if cache_duration_string == '' {
		return &InMemoryCache{}
	}

	cache_duration := strconv.parse_int(cache_duration_string, 10, 64) or {
		panic('cannot parse environment variable ${env_bandsintown_api_key} to i64')
	}

	return &InMemoryCache{
		duration: time.second * cache_duration
	}
}

// TODO on startup gzip statics that can be gzipped, middleware serve gzipped if browser supports it.
fn main() {
	dotenv.load()
	set_log_level()

	mut app := &App{
		typekit_code:       get_typekit_code()
		bandsintown_client: get_bandsintown_client()
		cache:              get_in_memoty_cache()
	}

	app.handle_static('static', false)!

	veb.run[App, Context](mut app, 8080)
}
