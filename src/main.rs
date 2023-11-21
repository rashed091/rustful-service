mod common;
mod controllers;
mod models;
mod schema;
mod services;

use controllers::user_controller;
use dotenv::dotenv;
use salvo::prelude::*;
use std::env;

#[handler]
async fn hello() -> &'static str {
    "Hello World"
}

#[tokio::main]
async fn main() {
    env::set_var("RUST_LOG", "debug");
    tracing_subscriber::fmt().init();

    dotenv().ok();

    let host = env::var("HOST").expect("HOST is not set in .env file");
    let port = env::var("PORT").expect("PORT is not set in .env file");
    let server_url = format!("{host}:{port}");

    let router = Router::new().get(user_controller::all_users);
    let acceptor = TcpListener::new(server_url).bind().await;

    Server::new(acceptor).serve(router).await;
}
