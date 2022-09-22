use actix_web::Result;
use actix_web::{get, App, HttpResponse, HttpServer};
use rand::prelude::*;
use std::io;

#[get("/")]
async fn get_pic() -> Result<HttpResponse> {
    let mut rng = rand::thread_rng();

    let dir = std::fs::read_dir("cute_pics")?;

    let mut pics = Vec::new();
    for entry in dir {
        pics.push(entry?.path());
    }

    let pic = pics.choose(&mut rng).unwrap();

    Ok(HttpResponse::build(actix_web::http::StatusCode::OK)
        .content_type("image/png")
        .body(std::fs::read(pic)?))
}

#[actix_web::main]
async fn main() -> io::Result<()> {
    let addr = "127.0.0.1:8080";

    println!("Listening on http://{}/", addr);

    HttpServer::new(|| App::new().service(get_pic))
        .bind(addr)?
        .run()
        .await
}
