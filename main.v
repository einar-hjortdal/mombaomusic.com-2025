module main

import veb
import os
import einar_hjortdal.dotenv

const env_typekit_code = 'TYPEKIT_CODE'

pub struct Context {
	veb.Context
}

pub struct App {
	veb.StaticHandler
	typekit_code string
}

// TODO on startup gzip statics that can be gzipped, middleware serve gzipped if browser supports it.
fn main() {
	dotenv.load()
	typekit_code := os.getenv(env_typekit_code)
	if typekit_code == '' {
		panic(error('missing environment variable ${env_typekit_code}'))
	}

	mut app := &App{
		typekit_code: typekit_code
	}

	app.handle_static('static', false)!

	veb.run[App, Context](mut app, 8080)
}
