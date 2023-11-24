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
async fn health() -> &'static str {
    "I'm alive"
}


#[tokio::main]
async fn main() {
    env::set_var("RUST_LOG", "debug");
    tracing_subscriber::fmt().init();

    dotenv().ok();

    let host = env::var("HOST").expect("HOST is not set in .env file");
    let port = env::var("PORT").expect("PORT is not set in .env file");
    let server_url = format!("{host}:{port}");

    let router = Router::new()
        .push(Router::with_path("/healthz").get(health))
        .push(Router::with_path("/users")
                .get(user_controller::get_all_users)
                .post(user_controller::create_user)
                .delete(user_controller::delete_all_users)
                .push(Router::with_path("<id>")
                        .get(user_controller::get_user)
                        .patch(user_controller::update_user)
                        .delete(user_controller::delete_user)
                    )
            );

    let acceptor = TcpListener::new(server_url).bind().await;

    Server::new(acceptor).serve(router).await;
}
