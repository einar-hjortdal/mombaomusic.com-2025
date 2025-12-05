module main

import veb

pub struct Context {
	veb.Context
}

pub struct App {
	veb.StaticHandler
}

// TODO on startup gzip statics that can be gzipped, middleware serve gzipped if browser supports it.
fn main() {
	mut app := &App{}
	app.handle_static('static', false)!
	veb.run[App, Context](mut app, 8080)
}
